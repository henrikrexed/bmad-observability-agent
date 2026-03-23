# Java OpenTelemetry Instrumentation

Comprehensive guide for instrumenting Java applications with OpenTelemetry to generate traces, logs, and metrics for production observability.

## Quick Start

### Java Agent (Recommended)

```bash
# Download the agent
curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

# Run your application with the agent
java -javaagent:opentelemetry-javaagent.jar \
     -Dotel.service.name=my-service \
     -Dotel.traces.exporter=otlp \
     -Dotel.exporter.otlp.endpoint=https://your-collector-endpoint \
     -Dotel.exporter.otlp.headers="Authorization=Bearer YOUR_TOKEN" \
     -jar myapp.jar
```

### Maven Dependencies (Manual Instrumentation)

```xml
<dependencies>
    <!-- OpenTelemetry API -->
    <dependency>
        <groupId>io.opentelemetry</groupId>
        <artifactId>opentelemetry-api</artifactId>
        <version>1.32.0</version>
    </dependency>
    
    <!-- OpenTelemetry SDK -->
    <dependency>
        <groupId>io.opentelemetry</groupId>
        <artifactId>opentelemetry-sdk</artifactId>
        <version>1.32.0</version>
    </dependency>
    
    <!-- OTLP Exporter -->
    <dependency>
        <groupId>io.opentelemetry</groupId>
        <artifactId>opentelemetry-exporter-otlp</artifactId>
        <version>1.32.0</version>
    </dependency>
    
    <!-- Auto-configuration -->
    <dependency>
        <groupId>io.opentelemetry</groupId>
        <artifactId>opentelemetry-sdk-extension-autoconfigure</artifactId>
        <version>1.32.0</version>
    </dependency>
</dependencies>
```

## Environment Configuration

### System Properties / Environment Variables

| Property/Variable | Default | Description |
|------------------|---------|-------------|
| `otel.service.name` / `OTEL_SERVICE_NAME` | `unknown_service:java` | Service identifier |
| `otel.traces.exporter` / `OTEL_TRACES_EXPORTER` | `otlp` | Trace exporter |
| `otel.metrics.exporter` / `OTEL_METRICS_EXPORTER` | `none` | Set to `otlp` for metrics |
| `otel.logs.exporter` / `OTEL_LOGS_EXPORTER` | `none` | Set to `otlp` for logs |
| `otel.exporter.otlp.endpoint` / `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | Collector endpoint |
| `otel.exporter.otlp.headers` / `OTEL_EXPORTER_OTLP_HEADERS` | - | Authentication headers |
| `otel.resource.attributes` / `OTEL_RESOURCE_ATTRIBUTES` | - | Additional resource attributes |

## Spring Boot Integration

### Auto-Instrumentation with Java Agent

```yaml
# application.yml
spring:
  application:
    name: my-spring-service

# JVM arguments (can be set in Dockerfile or startup script)
# -javaagent:opentelemetry-javaagent.jar
# -Dotel.service.name=${spring.application.name}
# -Dotel.traces.exporter=otlp
# -Dotel.metrics.exporter=otlp
# -Dotel.exporter.otlp.endpoint=http://otel-collector:4317
```

### Manual Instrumentation Configuration

```java
package com.example.config;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.exporter.otlp.metrics.OtlpGrpcMetricExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.metrics.SdkMeterProvider;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import io.opentelemetry.semconv.ResourceAttributes;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenTelemetryConfig {
    
    @Value("${otel.service.name:my-spring-service}")
    private String serviceName;
    
    @Value("${otel.exporter.otlp.endpoint:http://localhost:4317}")
    private String otlpEndpoint;
    
    @Bean
    public OpenTelemetry openTelemetry() {
        Resource resource = Resource.getDefault()
                .merge(Resource.create(Attributes.of(
                        ResourceAttributes.SERVICE_NAME, serviceName,
                        ResourceAttributes.SERVICE_VERSION, "1.0.0",
                        ResourceAttributes.DEPLOYMENT_ENVIRONMENT, "production"
                )));
        
        SdkTracerProvider tracerProvider = SdkTracerProvider.builder()
                .addSpanProcessor(BatchSpanProcessor.builder(
                        OtlpGrpcSpanExporter.builder()
                                .setEndpoint(otlpEndpoint)
                                .build())
                        .build())
                .setResource(resource)
                .build();
        
        SdkMeterProvider meterProvider = SdkMeterProvider.builder()
                .setResource(resource)
                .build();
        
        return OpenTelemetrySdk.builder()
                .setTracerProvider(tracerProvider)
                .setMeterProvider(meterProvider)
                .build();
    }
}
```

### Spring Boot Controller with Custom Spans

```java
package com.example.controller;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    private final Tracer tracer;
    private final OrderService orderService;
    
    public OrderController(OpenTelemetry openTelemetry, OrderService orderService) {
        this.tracer = openTelemetry.getTracer("order-controller");
        this.orderService = orderService;
    }
    
    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(
            @RequestBody OrderRequest request,
            @RequestHeader(value = "X-User-ID", required = false) String userId,
            @RequestHeader(value = "X-Tenant-ID", required = false) String tenantId) {
        
        Span span = tracer.spanBuilder("order.create")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            // Add business context
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("order.amount", request.getAmount())
                    .put("order.currency", request.getCurrency())
                    .put("order.items.count", request.getItems().size())
                    .put("user.id", userId != null ? userId : "anonymous")
                    .put("tenant.id", tenantId != null ? tenantId : "default")
                    .build());
            
            // Add to logging context
            MDC.put("trace_id", span.getSpanContext().getTraceId());
            MDC.put("span_id", span.getSpanContext().getSpanId());
            MDC.put("user_id", userId);
            
            logger.info("Creating order for user: {}, amount: {}", 
                       userId, request.getAmount());
            
            // Process order
            OrderResponse response = orderService.processOrder(request);
            
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("order.id", response.getOrderId())
                    .put("order.status", response.getStatus())
                    .build());
            
            span.setStatus(StatusCode.OK);
            logger.info("Order created successfully: {}", response.getOrderId());
            
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            span.setStatus(StatusCode.ERROR, "Invalid order data: " + e.getMessage());
            logger.error("Order creation failed - invalid data", e);
            return ResponseEntity.badRequest().build();
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, "Order processing failed: " + e.getMessage());
            logger.error("Order creation failed", e);
            return ResponseEntity.internalServerError().build();
            
        } finally {
            span.end();
            MDC.clear();
        }
    }
    
    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponse> getOrder(@PathVariable String orderId) {
        Span span = tracer.spanBuilder("order.get")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAttribute("order.lookup.id", orderId);
            
            OrderResponse order = orderService.getOrder(orderId);
            
            if (order == null) {
                span.setAttribute("order.found", false);
                return ResponseEntity.notFound().build();
            }
            
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("order.found", true)
                    .put("order.status", order.getStatus())
                    .put("order.amount", order.getAmount())
                    .build());
            
            return ResponseEntity.ok(order);
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, e.getMessage());
            logger.error("Failed to get order: {}", orderId, e);
            return ResponseEntity.internalServerError().build();
            
        } finally {
            span.end();
        }
    }
}
```

### Service Layer with Custom Spans

```java
package com.example.service;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {
    
    private final Tracer tracer;
    private final PaymentService paymentService;
    private final InventoryService inventoryService;
    private final OrderRepository orderRepository;
    
    public OrderService(OpenTelemetry openTelemetry, 
                       PaymentService paymentService,
                       InventoryService inventoryService, 
                       OrderRepository orderRepository) {
        this.tracer = openTelemetry.getTracer("order-service");
        this.paymentService = paymentService;
        this.inventoryService = inventoryService;
        this.orderRepository = orderRepository;
    }
    
    @Transactional
    public OrderResponse processOrder(OrderRequest request) {
        Span span = tracer.spanBuilder("order.process")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAttribute("processing.type", "synchronous");
            
            // Step 1: Validate order
            validateOrder(request);
            span.setAttribute("processing.step.validation", "completed");
            
            // Step 2: Check inventory
            inventoryService.reserveItems(request.getItems());
            span.setAttribute("processing.step.inventory", "completed");
            
            // Step 3: Process payment
            PaymentResult payment = paymentService.processPayment(
                request.getAmount(), request.getPaymentMethod());
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("payment.transaction_id", payment.getTransactionId())
                    .put("payment.status", payment.getStatus())
                    .put("processing.step.payment", "completed")
                    .build());
            
            // Step 4: Create order
            Order order = createOrder(request, payment);
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("order.id", order.getId())
                    .put("processing.step.creation", "completed")
                    .build());
            
            // Step 5: Schedule fulfillment
            scheduleOrderFulfillment(order.getId());
            span.setAttribute("processing.step.fulfillment", "scheduled");
            
            span.setStatus(StatusCode.OK);
            
            return OrderResponse.builder()
                    .orderId(order.getId())
                    .status(order.getStatus())
                    .amount(order.getAmount())
                    .build();
                    
        } catch (InsufficientInventoryException e) {
            span.setStatus(StatusCode.ERROR, "Insufficient inventory: " + e.getMessage());
            throw e;
        } catch (PaymentFailedException e) {
            span.setStatus(StatusCode.ERROR, "Payment failed: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, "Order processing failed: " + e.getMessage());
            throw new OrderProcessingException("Failed to process order", e);
        } finally {
            span.end();
        }
    }
    
    private void validateOrder(OrderRequest request) {
        Span span = tracer.spanBuilder("order.validate")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("validation.amount", request.getAmount())
                    .put("validation.currency", request.getCurrency())
                    .put("validation.items.count", request.getItems().size())
                    .build());
            
            if (request.getAmount() <= 0) {
                throw new IllegalArgumentException("Order amount must be positive");
            }
            
            if (request.getItems().isEmpty()) {
                throw new IllegalArgumentException("Order must contain at least one item");
            }
            
            // Additional validation logic...
            
            span.setStatus(StatusCode.OK);
            span.setAttribute("validation.result", "valid");
            
        } finally {
            span.end();
        }
    }
}
```

## Database Integration

### JPA/Hibernate with Custom Spans

```java
package com.example.repository;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public class OrderRepository {
    
    private final JpaRepository<Order, String> jpaRepository;
    private final Tracer tracer;
    
    public OrderRepository(JpaRepository<Order, String> jpaRepository, 
                          OpenTelemetry openTelemetry) {
        this.jpaRepository = jpaRepository;
        this.tracer = openTelemetry.getTracer("order-repository");
    }
    
    public Order save(Order order) {
        Span span = tracer.spanBuilder("db.order.save")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("db.operation.type", "insert")
                    .put("db.table", "orders")
                    .put("order.id", order.getId())
                    .put("order.amount", order.getAmount())
                    .build());
            
            Order savedOrder = jpaRepository.save(order);
            
            span.setAttribute("db.operation.result", "success");
            span.setStatus(StatusCode.OK);
            
            return savedOrder;
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
    
    public Optional<Order> findById(String orderId) {
        Span span = tracer.spanBuilder("db.order.find_by_id")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("db.operation.type", "select")
                    .put("db.table", "orders")
                    .put("order.lookup.id", orderId)
                    .build());
            
            Optional<Order> order = jpaRepository.findById(orderId);
            
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("order.found", order.isPresent())
                    .put("db.operation.result", "success")
                    .build());
            
            span.setStatus(StatusCode.OK);
            return order;
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
}
```

### MongoDB Integration

```java
package com.example.repository;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import org.bson.Document;
import org.springframework.stereotype.Repository;

@Repository
public class UserEventRepository {
    
    private final MongoCollection<Document> collection;
    private final Tracer tracer;
    
    public UserEventRepository(MongoDatabase database, OpenTelemetry openTelemetry) {
        this.collection = database.getCollection("user_events");
        this.tracer = openTelemetry.getTracer("user-event-repository");
    }
    
    public void saveUserEvent(UserEvent event) {
        Span span = tracer.spanBuilder("db.user_event.save")
                .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("db.mongodb.collection", "user_events")
                    .put("db.operation.type", "insert")
                    .put("user.id", event.getUserId())
                    .put("event.type", event.getEventType())
                    .build());
            
            Document doc = new Document()
                    .append("userId", event.getUserId())
                    .append("eventType", event.getEventType())
                    .append("timestamp", event.getTimestamp())
                    .append("data", event.getData());
            
            collection.insertOne(doc);
            
            span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                    .put("db.operation.result", "success")
                    .put("event.id", doc.getObjectId("_id").toString())
                    .build());
            
            span.setStatus(StatusCode.OK);
            
        } catch (Exception e) {
            span.setStatus(StatusCode.ERROR, e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
}
```

## Async Processing

### CompletableFuture with Context Propagation

```java
package com.example.service;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import java.util.concurrent.CompletableFuture;

@Service
public class AsyncOrderService {
    
    private final Tracer tracer;
    private final EmailService emailService;
    private final InventoryService inventoryService;
    
    public AsyncOrderService(OpenTelemetry openTelemetry, 
                            EmailService emailService,
                            InventoryService inventoryService) {
        this.tracer = openTelemetry.getTracer("async-order-service");
        this.emailService = emailService;
        this.inventoryService = inventoryService;
    }
    
    @Async
    public CompletableFuture<Void> processOrderAsync(String orderId) {
        // Get current context (includes trace context)
        Context currentContext = Context.current();
        
        return CompletableFuture.runAsync(() -> {
            // Create span with link to parent context
            Span span = tracer.spanBuilder("order.process_async")
                    .setParent(currentContext)
                    .startSpan();
            
            try (Scope scope = span.makeCurrent()) {
                span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                        .put("order.id", orderId)
                        .put("processing.async", true)
                        .build());
                
                // Parallel processing with context propagation
                CompletableFuture<Void> emailFuture = sendConfirmationEmailAsync(orderId);
                CompletableFuture<Void> inventoryFuture = updateInventoryAsync(orderId);
                CompletableFuture<Void> fulfillmentFuture = scheduleFulfillmentAsync(orderId);
                
                // Wait for all to complete
                CompletableFuture.allOf(emailFuture, inventoryFuture, fulfillmentFuture)
                        .join();
                
                span.setStatus(StatusCode.OK);
                span.setAttribute("processing.status", "completed");
                
            } catch (Exception e) {
                span.setStatus(StatusCode.ERROR, e.getMessage());
                throw new RuntimeException("Async order processing failed", e);
            } finally {
                span.end();
            }
        });
    }
    
    private CompletableFuture<Void> sendConfirmationEmailAsync(String orderId) {
        Context currentContext = Context.current();
        
        return CompletableFuture.runAsync(() -> {
            Span span = tracer.spanBuilder("email.send_confirmation")
                    .setParent(currentContext)
                    .startSpan();
            
            try (Scope scope = span.makeCurrent()) {
                span.setAllAttributes(io.opentelemetry.api.common.Attributes.builder()
                        .put("order.id", orderId)
                        .put("email.type", "confirmation")
                        .build());
                
                emailService.sendOrderConfirmation(orderId);
                span.setStatus(StatusCode.OK);
                
            } catch (Exception e) {
                span.setStatus(StatusCode.ERROR, e.getMessage());
                throw e;
            } finally {
                span.end();
            }
        });
    }
}
```

## Custom Metrics

```java
package com.example.metrics;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.metrics.DoubleHistogram;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.LongUpDownCounter;
import io.opentelemetry.api.metrics.Meter;
import org.springframework.stereotype.Component;

@Component
public class OrderMetrics {
    
    private final LongCounter ordersCreated;
    private final LongCounter ordersCompleted;
    private final LongCounter ordersFailed;
    private final DoubleHistogram orderValue;
    private final DoubleHistogram processingDuration;
    private final LongUpDownCounter activeOrders;
    
    public OrderMetrics(OpenTelemetry openTelemetry) {
        Meter meter = openTelemetry.getMeter("order-metrics");
        
        this.ordersCreated = meter
                .counterBuilder("orders.created.total")
                .setDescription("Total number of orders created")
                .setUnit("order")
                .build();
                
        this.ordersCompleted = meter
                .counterBuilder("orders.completed.total")
                .setDescription("Total number of orders completed")
                .setUnit("order")
                .build();
                
        this.ordersFailed = meter
                .counterBuilder("orders.failed.total")
                .setDescription("Total number of failed orders")
                .setUnit("order")
                .build();
                
        this.orderValue = meter
                .histogramBuilder("order.value")
                .setDescription("Distribution of order values")
                .setUnit("currency")
                .build();
                
        this.processingDuration = meter
                .histogramBuilder("order.processing.duration")
                .setDescription("Time taken to process orders")
                .setUnit("ms")
                .build();
                
        this.activeOrders = meter
                .upDownCounterBuilder("orders.active")
                .setDescription("Number of currently active orders")
                .setUnit("order")
                .build();
    }
    
    public void recordOrderCreated(String orderType, String userTier, double amount) {
        Attributes attributes = Attributes.builder()
                .put("order.type", orderType)
                .put("user.tier", userTier)
                .build();
                
        ordersCreated.add(1, attributes);
        orderValue.record(amount, attributes);
        activeOrders.add(1, attributes);
    }
    
    public void recordOrderCompleted(String orderType, String userTier, 
                                   double processingTimeMs) {
        Attributes attributes = Attributes.builder()
                .put("order.type", orderType)
                .put("user.tier", userTier)
                .build();
                
        ordersCompleted.add(1, attributes);
        processingDuration.record(processingTimeMs, attributes);
        activeOrders.add(-1, attributes);
    }
    
    public void recordOrderFailed(String orderType, String errorType, 
                                String failureReason) {
        Attributes attributes = Attributes.builder()
                .put("order.type", orderType)
                .put("error.type", errorType)
                .put("failure.reason", failureReason)
                .build();
                
        ordersFailed.add(1, attributes);
        activeOrders.add(-1, attributes);
    }
}
```

## Structured Logging with Logback

### logback-spring.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- Console appender with JSON format -->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
            <providers>
                <timestamp/>
                <logLevel>
                    <fieldName>level</fieldName>
                </logLevel>
                <loggerName>
                    <fieldName>logger</fieldName>
                </loggerName>
                <message/>
                <mdc>
                    <includeMdcKeyName>trace_id</includeMdcKeyName>
                    <includeMdcKeyName>span_id</includeMdcKeyName>
                    <includeMdcKeyName>user_id</includeMdcKeyName>
                    <includeMdcKeyName>request_id</includeMdcKeyName>
                </mdc>
                <arguments/>
                <stackTrace>
                    <throwableConverter class="net.logstash.logback.stacktrace.ShortenedThrowableConverter">
                        <maxDepthPerThrowable>30</maxDepthPerThrowable>
                        <rootCauseFirst>true</rootCauseFirst>
                    </throwableConverter>
                </stackTrace>
            </providers>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="STDOUT"/>
    </root>
    
    <!-- OpenTelemetry specific loggers -->
    <logger name="io.opentelemetry" level="INFO"/>
    
    <!-- Application loggers -->
    <logger name="com.example" level="DEBUG"/>
</configuration>
```

### Trace-Aware Logging

```java
package com.example.service;

import io.opentelemetry.api.trace.Span;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;

@Service
public class LoggingService {
    
    private static final Logger logger = LoggerFactory.getLogger(LoggingService.class);
    
    public void logBusinessEvent(String event, Object... params) {
        // Get current span context
        Span span = Span.current();
        
        // Add trace context to MDC
        if (span.getSpanContext().isValid()) {
            MDC.put("trace_id", span.getSpanContext().getTraceId());
            MDC.put("span_id", span.getSpanContext().getSpanId());
        }
        
        try {
            // Log with structured data
            logger.info("Business event: {}, params: {}", event, params);
        } finally {
            // Clean up MDC
            MDC.remove("trace_id");
            MDC.remove("span_id");
        }
    }
    
    public void logError(String operation, Exception error, Object context) {
        Span span = Span.current();
        
        if (span.getSpanContext().isValid()) {
            MDC.put("trace_id", span.getSpanContext().getTraceId());
            MDC.put("span_id", span.getSpanContext().getSpanId());
        }
        
        try {
            logger.error("Operation {} failed. Context: {}", operation, context, error);
        } finally {
            MDC.clear();
        }
    }
}
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: java-app
  template:
    metadata:
      labels:
        app: java-app
    spec:
      containers:
      - name: app
        image: my-java-app:latest
        ports:
        - containerPort: 8080
        env:
        # OpenTelemetry Java Agent
        - name: JAVA_TOOL_OPTIONS
          value: "-javaagent:/app/opentelemetry-javaagent.jar"
        
        # OpenTelemetry Configuration
        - name: OTEL_SERVICE_NAME
          value: "java-app"
        - name: OTEL_SERVICE_VERSION
          value: "1.0.0"
        - name: OTEL_TRACES_EXPORTER
          value: "otlp"
        - name: OTEL_METRICS_EXPORTER
          value: "otlp"
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        - name: OTEL_EXPORTER_OTLP_PROTOCOL
          value: "grpc"
        
        # Resource attributes
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.name=java-app,service.version=1.0.0,deployment.environment=production,k8s.namespace.name=$(NAMESPACE),k8s.pod.name=$(HOSTNAME),k8s.node.name=$(NODE_NAME)"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        
        # JVM settings
        - name: JVM_OPTS
          value: "-Xmx512m -Xms256m"
        
        resources:
          requests:
            memory: "512Mi"
            cpu: "200m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10

        volumeMounts:
        - name: otel-agent
          mountPath: /app/opentelemetry-javaagent.jar
          subPath: opentelemetry-javaagent.jar
          
      volumes:
      - name: otel-agent
        configMap:
          name: otel-javaagent
```

### Dockerfile with OpenTelemetry Agent

```dockerfile
FROM openjdk:17-jre-slim

# Add OpenTelemetry Java agent
COPY opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

# Copy application
COPY target/my-app.jar /app/app.jar

WORKDIR /app

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

# Run with OpenTelemetry agent
ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "app.jar"]
```

## Performance Optimization

### Sampling Configuration

```java
@Configuration
public class TelemetryConfig {
    
    @Bean
    public OpenTelemetry openTelemetry() {
        // Configure sampling for high-traffic applications
        Sampler sampler = Sampler.parentBased(
            Sampler.traceIdRatioBased(0.1) // Sample 10% of root spans
        );
        
        return OpenTelemetryServicesSdk.builder()
                .setTracerProvider(
                    SdkTracerProvider.builder()
                            .setSampler(sampler)
                            .setResource(Resource.getDefault())
                            .addSpanProcessor(BatchSpanProcessor.builder(
                                    OtlpGrpcSpanExporter.builder()
                                            .setEndpoint("http://collector:4317")
                                            .build())
                                    .setMaxExportBatchSize(100)
                                    .setExportTimeout(Duration.ofSeconds(30))
                                    .setScheduleDelay(Duration.ofSeconds(5))
                                    .build())
                            .build())
                .build();
    }
}
```

## Troubleshooting

### Debug Configuration

```java
// Enable debug logging for OpenTelemetry
System.setProperty("otel.java.global-autoconfigure.enabled", "true");
System.setProperty("otel.javaagent.debug", "true");

// Or in application.properties
// otel.java.global-autoconfigure.enabled=true
// otel.javaagent.debug=true
```

### Common Issues

1. **No spans appearing**: Check that the Java agent is properly loaded
2. **ClassPath issues**: Ensure agent is in the classpath before application JARs  
3. **Memory issues**: Tune batch size and export intervals
4. **Connection timeouts**: Check collector endpoint and network connectivity

### Health Check for Telemetry

```java
@RestController
public class TelemetryHealthController {
    
    private final OpenTelemetry openTelemetry;
    
    @GetMapping("/telemetry-health")
    public ResponseEntity<Map<String, Object>> checkTelemetryHealth() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // Test tracer
            Tracer tracer = openTelemetry.getTracer("health-check");
            Span span = tracer.spanBuilder("health_check").startSpan();
            span.setAttribute("check.type", "telemetry");
            span.end();
            
            // Test meter
            Meter meter = openTelemetry.getMeter("health-check");
            LongCounter counter = meter.counterBuilder("health_check").build();
            counter.add(1, Attributes.of(AttributeKey.stringKey("check"), "telemetry"));
            
            status.put("status", "ok");
            status.put("telemetry", "active");
            
        } catch (Exception e) {
            status.put("status", "error");
            status.put("telemetry", e.getMessage());
            return ResponseEntity.status(500).body(status);
        }
        
        return ResponseEntity.ok(status);
    }
}
```

## Production Checklist

- [ ] Java agent properly configured and loaded
- [ ] Service name and version set appropriately
- [ ] Resource attributes include environment, cluster info
- [ ] Sensitive data redaction implemented at application level
- [ ] Sampling configured for high-traffic services
- [ ] Structured logging with trace correlation
- [ ] Custom spans for business logic
- [ ] Metrics collection for key operations
- [ ] Error tracking and correlation
- [ ] Async task tracing with context propagation
- [ ] Health checks for telemetry systems
- [ ] Memory and performance impact measured
- [ ] Graceful shutdown implemented

## References

- [OpenTelemetry Java Documentation](https://opentelemetry.io/docs/languages/java/)
- [Java Auto-Instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
- [Spring Boot Integration](https://opentelemetry.io/docs/languages/java/spring-boot/)
- [BMAD Method Guide](../../bmad-method.md)
- [OTTL Guide](../ottl-guide.md)
- [Sensitive Data Protection](../sensitive-data.md)