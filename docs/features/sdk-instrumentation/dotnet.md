# .NET OpenTelemetry Instrumentation

Comprehensive guide for instrumenting .NET applications with OpenTelemetry to generate traces, logs, and metrics for production observability.

## Quick Start

### Installation

```bash
# For ASP.NET Core applications
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
dotnet add package OpenTelemetry.Instrumentation.SqlClient
```

### Environment Variables

```bash
export OTEL_SERVICE_NAME="my-dotnet-service"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="otlp"
export OTEL_LOGS_EXPORTER="otlp"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://your-collector-endpoint"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer YOUR_TOKEN"
```

### Basic Setup

```csharp
// Program.cs (.NET 6+)
using OpenTelemetry;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;

var builder = WebApplication.CreateBuilder(args);

// Configure OpenTelemetry
builder.Services.AddOpenTelemetry()
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder
            .SetResourceBuilder(ResourceBuilder.CreateDefault()
                .AddService("my-dotnet-service", "1.0.0")
                .AddAttributes(new Dictionary<string, object>
                {
                    ["deployment.environment"] = "production"
                }))
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddSqlClientInstrumentation()
            .AddOtlpExporter();
    })
    .WithMetrics(meterProviderBuilder =>
    {
        meterProviderBuilder
            .SetResourceBuilder(ResourceBuilder.CreateDefault()
                .AddService("my-dotnet-service", "1.0.0"))
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddOtlpExporter();
    });

var app = builder.Build();

app.MapGet("/", () => "Hello World!");
app.Run();
```

## Environment Configuration

### Configuration Sources

| Source | Format | Example |
|--------|--------|---------|
| Environment Variables | `OTEL_*` | `OTEL_SERVICE_NAME=my-service` |
| appsettings.json | JSON | `"OpenTelemetry": { "ServiceName": "my-service" }` |
| Configuration API | C# | `builder.Configuration["OpenTelemetry:ServiceName"]` |

### Key Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `OTEL_SERVICE_NAME` | `unknown_service` | Service identifier |
| `OTEL_TRACES_EXPORTER` | `otlp` | Trace exporter |
| `OTEL_METRICS_EXPORTER` | `none` | Set to `otlp` for metrics |
| `OTEL_LOGS_EXPORTER` | `none` | Set to `otlp` for logs |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | Collector endpoint |
| `OTEL_EXPORTER_OTLP_HEADERS` | - | Authentication headers |

## ASP.NET Core Integration

### Complete Setup with Custom Instrumentation

```csharp
// Program.cs
using OpenTelemetry;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;
using OpenTelemetry.Logs;
using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

// Configure OpenTelemetry
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource
        .AddService(
            serviceName: builder.Configuration["OpenTelemetry:ServiceName"] ?? "my-dotnet-service",
            serviceVersion: "1.0.0")
        .AddAttributes(new Dictionary<string, object>
        {
            ["deployment.environment"] = builder.Environment.EnvironmentName,
            ["service.instance.id"] = Environment.MachineName
        }))
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder
            .AddAspNetCoreInstrumentation(options =>
            {
                options.RecordException = true;
                options.Filter = (httpContext) =>
                {
                    // Skip health checks and metrics endpoints
                    return (!httpContext.Request.Path.Value?.StartsWith("/health") ?? true) &&
                           (!httpContext.Request.Path.Value?.StartsWith("/metrics") ?? true);
                };
                options.EnrichWithHttpRequest = (activity, httpRequest) =>
                {
                    activity.SetTag("user.id", httpRequest.Headers["X-User-ID"].FirstOrDefault());
                    activity.SetTag("tenant.id", httpRequest.Headers["X-Tenant-ID"].FirstOrDefault());
                    activity.SetTag("request.id", httpRequest.Headers["X-Request-ID"].FirstOrDefault());
                };
                options.EnrichWithHttpResponse = (activity, httpResponse) =>
                {
                    activity.SetTag("http.response.size", httpResponse.ContentLength);
                };
            })
            .AddHttpClientInstrumentation(options =>
            {
                options.RecordException = true;
                options.FilterHttpRequestMessage = (httpRequestMessage) =>
                {
                    // Skip internal health checks
                    return !httpRequestMessage.RequestUri?.AbsolutePath.Contains("/health") ?? true;
                };
                options.EnrichWithHttpRequestMessage = (activity, httpRequestMessage) =>
                {
                    activity.SetTag("http.client.request.size", httpRequestMessage.Content?.Headers?.ContentLength);
                };
            })
            .AddSqlClientInstrumentation(options =>
            {
                options.SetDbStatementForText = true;
                options.RecordException = true;
                options.EnableConnectionLevelAttributes = true;
            })
            .AddSource("MyApp.*") // Custom activity sources
            .AddOtlpExporter();
    })
    .WithMetrics(meterProviderBuilder =>
    {
        meterProviderBuilder
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddMeter("MyApp.*") // Custom meters
            .AddOtlpExporter();
    });

// Configure logging
builder.Logging.AddOpenTelemetry(options =>
{
    options.IncludeScopes = true;
    options.IncludeFormattedMessage = true;
    options.AddOtlpExporter();
});

var app = builder.Build();

// Configure middleware
app.UseRouting();
app.MapControllers();

// Health checks
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();
```

### Controller with Custom Spans

```csharp
// Controllers/OrderController.cs
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using OpenTelemetry;

[ApiController]
[Route("api/[controller]")]
public class OrderController : ControllerBase
{
    private static readonly ActivitySource ActivitySource = new("MyApp.Orders");
    private readonly ILogger<OrderController> _logger;
    private readonly IOrderService _orderService;

    public OrderController(ILogger<OrderController> logger, IOrderService orderService)
    {
        _logger = logger;
        _orderService = orderService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        using var activity = ActivitySource.StartActivity("order.create");
        
        try
        {
            // Add context to current activity (auto-created by ASP.NET Core instrumentation)
            Activity.Current?.SetTag("order.amount", request.Amount);
            Activity.Current?.SetTag("order.currency", request.Currency);
            Activity.Current?.SetTag("order.items.count", request.Items.Count);
            
            // Extract context from headers
            var userId = Request.Headers["X-User-ID"].FirstOrDefault();
            var tenantId = Request.Headers["X-Tenant-ID"].FirstOrDefault();
            
            activity?.SetTag("user.id", userId);
            activity?.SetTag("tenant.id", tenantId);
            
            _logger.LogInformation("Creating order for user {UserId}, amount {Amount}", 
                                 userId, request.Amount);
            
            // Process order
            var order = await _orderService.CreateOrderAsync(request);
            
            activity?.SetTag("order.id", order.OrderId);
            activity?.SetTag("order.status", order.Status);
            activity?.SetStatus(ActivityStatusCode.Ok);
            
            _logger.LogInformation("Order {OrderId} created successfully", order.OrderId);
            
            return Ok(order);
        }
        catch (ArgumentException ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, $"Invalid order data: {ex.Message}");
            _logger.LogWarning(ex, "Order creation failed - invalid data");
            return BadRequest(new { error = "Invalid order data" });
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, $"Order processing failed: {ex.Message}");
            _logger.LogError(ex, "Order creation failed");
            return StatusCode(500, new { error = "Failed to create order" });
        }
    }

    [HttpGet("{orderId}")]
    public async Task<IActionResult> GetOrder(string orderId)
    {
        using var activity = ActivitySource.StartActivity("order.get");
        activity?.SetTag("order.lookup.id", orderId);
        
        try
        {
            var order = await _orderService.GetOrderAsync(orderId);
            
            if (order == null)
            {
                activity?.SetTag("order.found", false);
                return NotFound();
            }
            
            activity?.SetTag("order.found", true);
            activity?.SetTag("order.status", order.Status);
            activity?.SetTag("order.amount", order.Amount);
            
            return Ok(order);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Failed to get order {OrderId}", orderId);
            return StatusCode(500, new { error = "Failed to get order" });
        }
    }
}
```

### Service Layer with Custom Activities

```csharp
// Services/OrderService.cs
using System.Diagnostics;

public interface IOrderService
{
    Task<OrderResponse> CreateOrderAsync(CreateOrderRequest request);
    Task<OrderResponse?> GetOrderAsync(string orderId);
}

public class OrderService : IOrderService
{
    private static readonly ActivitySource ActivitySource = new("MyApp.OrderService");
    private readonly ILogger<OrderService> _logger;
    private readonly IPaymentService _paymentService;
    private readonly IInventoryService _inventoryService;
    private readonly IOrderRepository _orderRepository;

    public OrderService(
        ILogger<OrderService> logger,
        IPaymentService paymentService,
        IInventoryService inventoryService,
        IOrderRepository orderRepository)
    {
        _logger = logger;
        _paymentService = paymentService;
        _inventoryService = inventoryService;
        _orderRepository = orderRepository;
    }

    public async Task<OrderResponse> CreateOrderAsync(CreateOrderRequest request)
    {
        using var activity = ActivitySource.StartActivity("order.process");
        
        try
        {
            activity?.SetTag("processing.type", "synchronous");
            
            // Step 1: Validate order
            await ValidateOrderAsync(request);
            activity?.SetTag("processing.step.validation", "completed");
            
            // Step 2: Reserve inventory
            await _inventoryService.ReserveItemsAsync(request.Items);
            activity?.SetTag("processing.step.inventory", "completed");
            
            // Step 3: Process payment
            var payment = await _paymentService.ProcessPaymentAsync(
                request.Amount, request.PaymentMethod);
            activity?.SetTag("payment.transaction_id", payment.TransactionId);
            activity?.SetTag("payment.status", payment.Status);
            activity?.SetTag("processing.step.payment", "completed");
            
            // Step 4: Create order
            var order = await CreateOrderRecordAsync(request, payment);
            activity?.SetTag("order.id", order.OrderId);
            activity?.SetTag("processing.step.creation", "completed");
            
            // Step 5: Schedule fulfillment (async)
            _ = Task.Run(() => ScheduleFulfillmentAsync(order.OrderId));
            activity?.SetTag("processing.step.fulfillment", "scheduled");
            
            activity?.SetStatus(ActivityStatusCode.Ok);
            
            return new OrderResponse
            {
                OrderId = order.OrderId,
                Status = order.Status,
                Amount = order.Amount
            };
        }
        catch (InsufficientInventoryException ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, $"Insufficient inventory: {ex.Message}");
            throw;
        }
        catch (PaymentFailedException ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, $"Payment failed: {ex.Message}");
            throw;
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, $"Order processing failed: {ex.Message}");
            throw new OrderProcessingException("Failed to process order", ex);
        }
    }
    
    private async Task ValidateOrderAsync(CreateOrderRequest request)
    {
        using var activity = ActivitySource.StartActivity("order.validate");
        
        activity?.SetTag("validation.amount", request.Amount);
        activity?.SetTag("validation.currency", request.Currency);
        activity?.SetTag("validation.items.count", request.Items.Count);
        
        if (request.Amount <= 0)
        {
            throw new ArgumentException("Order amount must be positive");
        }
        
        if (!request.Items.Any())
        {
            throw new ArgumentException("Order must contain at least one item");
        }
        
        // Additional validation logic...
        
        activity?.SetTag("validation.result", "valid");
        activity?.SetStatus(ActivityStatusCode.Ok);
    }

    public async Task<OrderResponse?> GetOrderAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("order.get");
        activity?.SetTag("order.lookup.id", orderId);
        
        try
        {
            var order = await _orderRepository.GetByIdAsync(orderId);
            
            if (order == null)
            {
                activity?.SetTag("order.found", false);
                return null;
            }
            
            activity?.SetTag("order.found", true);
            activity?.SetTag("order.status", order.Status);
            
            return new OrderResponse
            {
                OrderId = order.OrderId,
                Status = order.Status,
                Amount = order.Amount
            };
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }
}
```

## Database Integration

### Entity Framework Core

```csharp
// Add Entity Framework instrumentation
builder.Services.AddOpenTelemetry()
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder
            .AddEntityFrameworkCoreInstrumentation(options =>
            {
                options.SetDbStatementForText = true;
                options.EnrichWithIDbCommand = (activity, command) =>
                {
                    activity.SetTag("db.command.timeout", command.CommandTimeout);
                    activity.SetTag("db.command.type", command.CommandType.ToString());
                };
            });
    });

// Repository with custom activities
public class OrderRepository : IOrderRepository
{
    private static readonly ActivitySource ActivitySource = new("MyApp.OrderRepository");
    private readonly ApplicationDbContext _context;
    private readonly ILogger<OrderRepository> _logger;

    public OrderRepository(ApplicationDbContext context, ILogger<OrderRepository> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Order> CreateAsync(Order order)
    {
        using var activity = ActivitySource.StartActivity("db.order.create");
        
        activity?.SetTag("db.operation.type", "insert");
        activity?.SetTag("db.table", "orders");
        activity?.SetTag("order.id", order.OrderId);
        activity?.SetTag("order.amount", order.Amount);
        
        try
        {
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            
            activity?.SetTag("db.operation.result", "success");
            activity?.SetStatus(ActivityStatusCode.Ok);
            
            return order;
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }

    public async Task<Order?> GetByIdAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("db.order.get_by_id");
        
        activity?.SetTag("db.operation.type", "select");
        activity?.SetTag("db.table", "orders");
        activity?.SetTag("order.lookup.id", orderId);
        
        try
        {
            var order = await _context.Orders
                .Where(o => o.OrderId == orderId)
                .FirstOrDefaultAsync();
            
            activity?.SetTag("order.found", order != null);
            activity?.SetTag("db.operation.result", "success");
            activity?.SetStatus(ActivityStatusCode.Ok);
            
            return order;
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }
}
```

### MongoDB Integration

```csharp
// Install MongoDB instrumentation package
// dotnet add package OpenTelemetry.Instrumentation.MongoDb

// Configuration
builder.Services.AddOpenTelemetry()
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder.AddMongoDbInstrumentation();
    });

// Repository with MongoDB
public class UserEventRepository
{
    private static readonly ActivitySource ActivitySource = new("MyApp.UserEventRepository");
    private readonly IMongoCollection<UserEvent> _collection;

    public UserEventRepository(IMongoDatabase database)
    {
        _collection = database.GetCollection<UserEvent>("user_events");
    }

    public async Task SaveUserEventAsync(UserEvent userEvent)
    {
        using var activity = ActivitySource.StartActivity("db.user_event.save");
        
        activity?.SetTag("db.mongodb.collection", "user_events");
        activity?.SetTag("db.operation.type", "insert");
        activity?.SetTag("user.id", userEvent.UserId);
        activity?.SetTag("event.type", userEvent.EventType);
        
        try
        {
            await _collection.InsertOneAsync(userEvent);
            
            activity?.SetTag("db.operation.result", "success");
            activity?.SetTag("event.id", userEvent.Id);
            activity?.SetStatus(ActivityStatusCode.Ok);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }
}
```

### Redis Integration

```csharp
// Install Redis instrumentation package
// dotnet add package OpenTelemetry.Instrumentation.StackExchangeRedis

// Configuration
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
});

builder.Services.AddOpenTelemetry()
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder.AddRedisInstrumentation();
    });

// Cache service with custom activities
public class CacheService
{
    private static readonly ActivitySource ActivitySource = new("MyApp.CacheService");
    private readonly IDistributedCache _cache;
    private readonly ILogger<CacheService> _logger;

    public CacheService(IDistributedCache cache, ILogger<CacheService> logger)
    {
        _cache = cache;
        _logger = logger;
    }

    public async Task<T?> GetAsync<T>(string key) where T : class
    {
        using var activity = ActivitySource.StartActivity("cache.get");
        
        activity?.SetTag("cache.operation", "get");
        activity?.SetTag("cache.key", key);
        activity?.SetTag("cache.key.type", typeof(T).Name);
        
        try
        {
            var cached = await _cache.GetStringAsync(key);
            
            if (cached != null)
            {
                activity?.SetTag("cache.hit", true);
                activity?.SetTag("cache.value.size", cached.Length);
                return JsonSerializer.Deserialize<T>(cached);
            }
            
            activity?.SetTag("cache.hit", false);
            return null;
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null)
    {
        using var activity = ActivitySource.StartActivity("cache.set");
        
        activity?.SetTag("cache.operation", "set");
        activity?.SetTag("cache.key", key);
        activity?.SetTag("cache.key.type", typeof(T).Name);
        
        try
        {
            var json = JsonSerializer.Serialize(value);
            var options = new DistributedCacheEntryOptions();
            
            if (expiry.HasValue)
            {
                options.SetSlidingExpiration(expiry.Value);
                activity?.SetTag("cache.ttl", expiry.Value.TotalSeconds);
            }
            
            await _cache.SetStringAsync(key, json, options);
            
            activity?.SetTag("cache.value.size", json.Length);
            activity?.SetStatus(ActivityStatusCode.Ok);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            throw;
        }
    }
}
```

## Custom Metrics

```csharp
// Metrics/OrderMetrics.cs
using System.Diagnostics.Metrics;

public class OrderMetrics
{
    private readonly Meter _meter;
    private readonly Counter<int> _ordersCreated;
    private readonly Counter<int> _ordersCompleted;
    private readonly Counter<int> _ordersFailed;
    private readonly Histogram<double> _orderValue;
    private readonly Histogram<double> _processingDuration;
    private readonly UpDownCounter<int> _activeOrders;

    public OrderMetrics(IMeterFactory meterFactory)
    {
        _meter = meterFactory.Create("MyApp.Orders");
        
        _ordersCreated = _meter.CreateCounter<int>(
            name: "orders.created.total",
            description: "Total number of orders created",
            unit: "order");
            
        _ordersCompleted = _meter.CreateCounter<int>(
            name: "orders.completed.total", 
            description: "Total number of orders completed",
            unit: "order");
            
        _ordersFailed = _meter.CreateCounter<int>(
            name: "orders.failed.total",
            description: "Total number of failed orders", 
            unit: "order");
            
        _orderValue = _meter.CreateHistogram<double>(
            name: "order.value",
            description: "Distribution of order values",
            unit: "currency");
            
        _processingDuration = _meter.CreateHistogram<double>(
            name: "order.processing.duration", 
            description: "Time taken to process orders",
            unit: "ms");
            
        _activeOrders = _meter.CreateUpDownCounter<int>(
            name: "orders.active",
            description: "Number of currently active orders", 
            unit: "order");
    }

    public void RecordOrderCreated(string orderType, string userTier, double amount)
    {
        var tags = new TagList
        {
            ["order.type"] = orderType,
            ["user.tier"] = userTier
        };
        
        _ordersCreated.Add(1, tags);
        _orderValue.Record(amount, tags);
        _activeOrders.Add(1, tags);
    }

    public void RecordOrderCompleted(string orderType, string userTier, double processingTimeMs)
    {
        var tags = new TagList
        {
            ["order.type"] = orderType,
            ["user.tier"] = userTier
        };
        
        _ordersCompleted.Add(1, tags);
        _processingDuration.Record(processingTimeMs, tags);
        _activeOrders.Add(-1, tags);
    }

    public void RecordOrderFailed(string orderType, string errorType, string failureReason)
    {
        var tags = new TagList
        {
            ["order.type"] = orderType,
            ["error.type"] = errorType,
            ["failure.reason"] = failureReason
        };
        
        _ordersFailed.Add(1, tags);
        _activeOrders.Add(-1, tags);
    }
}

// Register metrics
builder.Services.AddSingleton<OrderMetrics>();
```

## Async Processing with Context Propagation

```csharp
// Services/AsyncOrderProcessor.cs
public class AsyncOrderProcessor
{
    private static readonly ActivitySource ActivitySource = new("MyApp.AsyncOrderProcessor");
    private readonly ILogger<AsyncOrderProcessor> _logger;
    private readonly IEmailService _emailService;
    private readonly IInventoryService _inventoryService;

    public AsyncOrderProcessor(
        ILogger<AsyncOrderProcessor> logger,
        IEmailService emailService,
        IInventoryService inventoryService)
    {
        _logger = logger;
        _emailService = emailService;
        _inventoryService = inventoryService;
    }

    public async Task ProcessOrderAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("order.process_async");
        
        activity?.SetTag("order.id", orderId);
        activity?.SetTag("processing.async", true);
        
        try
        {
            // Run tasks in parallel while maintaining context
            var emailTask = SendConfirmationEmailAsync(orderId);
            var inventoryTask = UpdateInventoryAsync(orderId);
            var fulfillmentTask = ScheduleFulfillmentAsync(orderId);
            
            await Task.WhenAll(emailTask, inventoryTask, fulfillmentTask);
            
            activity?.SetStatus(ActivityStatusCode.Ok);
            activity?.SetTag("processing.status", "completed");
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Async order processing failed for order {OrderId}", orderId);
            throw;
        }
    }

    private async Task SendConfirmationEmailAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("email.send_confirmation");
        
        activity?.SetTag("order.id", orderId);
        activity?.SetTag("email.type", "confirmation");
        
        try
        {
            await _emailService.SendOrderConfirmationAsync(orderId);
            activity?.SetStatus(ActivityStatusCode.Ok);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Failed to send confirmation email for order {OrderId}", orderId);
            // Don't re-throw - other async operations can continue
        }
    }

    private async Task UpdateInventoryAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("inventory.update");
        
        activity?.SetTag("order.id", orderId);
        
        try
        {
            await _inventoryService.UpdateForOrderAsync(orderId);
            activity?.SetStatus(ActivityStatusCode.Ok);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Failed to update inventory for order {OrderId}", orderId);
        }
    }

    private async Task ScheduleFulfillmentAsync(string orderId)
    {
        using var activity = ActivitySource.StartActivity("fulfillment.schedule");
        
        activity?.SetTag("order.id", orderId);
        
        try
        {
            // Simulate fulfillment scheduling
            await Task.Delay(100); // Simulate API call
            activity?.SetStatus(ActivityStatusCode.Ok);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            _logger.LogError(ex, "Failed to schedule fulfillment for order {OrderId}", orderId);
        }
    }
}
```

## Structured Logging with ILogger

```csharp
// Extensions/LoggerExtensions.cs
public static class LoggerExtensions
{
    public static IDisposable BeginScopeWithTraceContext(this ILogger logger)
    {
        var activity = Activity.Current;
        if (activity?.SpanContext.TraceId != default)
        {
            return logger.BeginScope(new Dictionary<string, object>
            {
                ["TraceId"] = activity.SpanContext.TraceId.ToString(),
                ["SpanId"] = activity.SpanContext.SpanId.ToString()
            });
        }
        
        return new NoOpDisposable();
    }
    
    private class NoOpDisposable : IDisposable
    {
        public void Dispose() { }
    }
}

// Usage in services
public class OrderService : IOrderService
{
    private readonly ILogger<OrderService> _logger;
    
    public async Task<OrderResponse> CreateOrderAsync(CreateOrderRequest request)
    {
        using var scope = _logger.BeginScopeWithTraceContext();
        using var activity = ActivitySource.StartActivity("order.create");
        
        _logger.LogInformation("Processing order creation for user {UserId}, amount {Amount}", 
                              request.UserId, request.Amount);
        
        try
        {
            var order = await ProcessOrderInternal(request);
            
            _logger.LogInformation("Order {OrderId} created successfully", order.OrderId);
            return order;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Order creation failed for user {UserId}", request.UserId);
            throw;
        }
    }
}
```

### Configuration for Structured Logging

```json
// appsettings.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    },
    "Console": {
      "FormatterName": "json",
      "FormatterOptions": {
        "SingleLine": true,
        "IncludeScopes": true,
        "TimestampFormat": "yyyy-MM-ddTHH:mm:ss.fffZ",
        "UseUtcTimestamp": true
      }
    }
  },
  "OpenTelemetry": {
    "ServiceName": "my-dotnet-service",
    "ServiceVersion": "1.0.0"
  }
}
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dotnet-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: dotnet-app
  template:
    metadata:
      labels:
        app: dotnet-app
    spec:
      containers:
      - name: app
        image: my-dotnet-app:latest
        ports:
        - containerPort: 8080
        env:
        # OpenTelemetry Configuration
        - name: OTEL_SERVICE_NAME
          value: "dotnet-app"
        - name: OTEL_SERVICE_VERSION
          value: "1.0.0"
        - name: OTEL_TRACES_EXPORTER
          value: "otlp"
        - name: OTEL_METRICS_EXPORTER
          value: "otlp"
        - name: OTEL_LOGS_EXPORTER
          value: "otlp"
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        - name: OTEL_EXPORTER_OTLP_PROTOCOL
          value: "grpc"
        
        # Resource attributes
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.name=dotnet-app,service.version=1.0.0,deployment.environment=production,k8s.namespace.name=$(NAMESPACE),k8s.pod.name=$(HOSTNAME),k8s.node.name=$(NODE_NAME)"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        
        # ASP.NET Core Configuration
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ASPNETCORE_URLS
          value: "http://+:8080"
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
```

### Dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyApp/MyApp.csproj", "MyApp/"]
RUN dotnet restore "MyApp/MyApp.csproj"
COPY . .
WORKDIR "/src/MyApp"
RUN dotnet build "MyApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## Performance Optimization

### Sampling Configuration

```csharp
// Configure sampling for high-traffic applications
builder.Services.AddOpenTelemetry()
    .WithTracing(tracerProviderBuilder =>
    {
        tracerProviderBuilder
            .SetSampler(new TraceIdRatioBasedSampler(0.1)) // Sample 10% of traces
            .AddOtlpExporter(otlpOptions =>
            {
                otlpOptions.BatchExportProcessorOptions = new()
                {
                    MaxExportBatchSize = 100,
                    ExportTimeoutMilliseconds = 30000,
                    ScheduledDelayMilliseconds = 5000
                };
            });
    });
```

## Troubleshooting

### Debug Configuration

```csharp
// Enable debug logging in Program.cs
builder.Logging.AddFilter("OpenTelemetry", LogLevel.Debug);

// Or via configuration
{
  "Logging": {
    "LogLevel": {
      "OpenTelemetry": "Debug"
    }
  }
}
```

### Health Check for Telemetry

```csharp
[ApiController]
public class TelemetryHealthController : ControllerBase
{
    private static readonly ActivitySource ActivitySource = new("MyApp.TelemetryHealth");
    private static readonly Meter Meter = new("MyApp.TelemetryHealth");
    
    [HttpGet("/telemetry-health")]
    public IActionResult CheckTelemetryHealth()
    {
        try
        {
            // Test activity creation
            using var activity = ActivitySource.StartActivity("health_check");
            activity?.SetTag("check.type", "telemetry");
            
            // Test metrics
            var counter = Meter.CreateCounter<int>("health_check");
            counter.Add(1, new KeyValuePair<string, object?>("check", "telemetry"));
            
            return Ok(new { status = "ok", telemetry = "active" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = "error", telemetry = ex.Message });
        }
    }
}
```

## Production Checklist

- [ ] OpenTelemetry SDK properly configured and initialized
- [ ] Service name and version set appropriately  
- [ ] Resource attributes include environment, cluster info
- [ ] Sensitive data redaction implemented
- [ ] Sampling configured for high-traffic services
- [ ] Structured logging with trace correlation
- [ ] Custom activities for business logic
- [ ] Metrics collection for key operations
- [ ] Error tracking with proper activity status
- [ ] Async task tracing with context propagation
- [ ] Health checks for telemetry systems
- [ ] Performance impact measured and acceptable
- [ ] Graceful shutdown implemented

## References

- [OpenTelemetry .NET Documentation](https://opentelemetry.io/docs/languages/net/)
- [.NET Auto-Instrumentation](https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation)
- [ASP.NET Core Integration](https://github.com/open-telemetry/opentelemetry-dotnet/tree/main/src/OpenTelemetry.Instrumentation.AspNetCore)
- [BMAD Method Guide](../../bmad-method.md)
- [OTTL Guide](../ottl-guide.md)
- [Sensitive Data Protection](../sensitive-data.md)