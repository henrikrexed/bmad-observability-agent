# Go OpenTelemetry Instrumentation

Comprehensive guide for instrumenting Go applications with OpenTelemetry to generate traces, logs, and metrics for production observability.

## Quick Start

### Installation

```bash
# Core SDK and API
go get go.opentelemetry.io/otel
go get go.opentelemetry.io/otel/sdk

# gRPC exporters
go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc
go get go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc
go get go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploggrpc
```

### Environment Variables

```bash
export OTEL_SERVICE_NAME="my-service"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="otlp"
export OTEL_LOGS_EXPORTER="otlp"
export OTEL_EXPORTER_OTLP_ENDPOINT="https://your-collector-endpoint"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer YOUR_TOKEN"
```

### Basic Initialization

```go
package main

import (
	"context"
	"log"
	
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

func initTelemetry(ctx context.Context) (func(), error) {
	res, err := resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceNameKey.String("my-service"),
			semconv.ServiceVersionKey.String("1.0.0"),
			semconv.DeploymentEnvironmentKey.String("production"),
		),
		resource.WithFromEnv(),
	)
	if err != nil {
		return nil, err
	}

	// Trace provider
	traceExporter, err := otlptracegrpc.New(ctx)
	if err != nil {
		return nil, err
	}
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(traceExporter),
		sdktrace.WithResource(res),
	)
	otel.SetTracerProvider(tp)

	// Metric provider
	metricExporter, err := otlpmetricgrpc.New(ctx)
	if err != nil {
		return nil, err
	}
	mp := sdkmetric.NewMeterProvider(
		sdkmetric.WithReader(sdkmetric.NewPeriodicReader(metricExporter)),
		sdkmetric.WithResource(res),
	)
	otel.SetMeterProvider(mp)

	shutdown := func() {
		_ = tp.Shutdown(ctx)
		_ = mp.Shutdown(ctx)
	}

	return shutdown, nil
}

func main() {
	ctx := context.Background()
	shutdown, err := initTelemetry(ctx)
	if err != nil {
		log.Fatalf("failed to initialize telemetry: %v", err)
	}
	defer shutdown()

	// Your application code here
}
```

## Environment Configuration

### Required Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_SERVICE_NAME` | `unknown_service` | Service identifier |
| `OTEL_TRACES_EXPORTER` | `none` | **Must be `otlp`** to export |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | Collector endpoint |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_METRICS_EXPORTER` | `none` | Set to `otlp` for metrics |
| `OTEL_LOGS_EXPORTER` | `none` | Set to `otlp` for logs |
| `OTEL_EXPORTER_OTLP_HEADERS` | - | Authentication headers |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` | Protocol type |
| `OTEL_RESOURCE_ATTRIBUTES` | - | Additional attributes |

## Framework-Specific Instrumentation

### net/http Server

```go
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("http-server")

func main() {
	// Initialize telemetry (see above)
	
	mux := http.NewServeMux()
	
	// Wrap handlers with OpenTelemetry
	mux.Handle("/api/orders", otelhttp.NewHandler(
		http.HandlerFunc(handleOrders), 
		"orders-handler",
	))
	
	mux.Handle("/health", http.HandlerFunc(healthCheck))
	
	// Wrap the entire server
	handler := otelhttp.NewHandler(mux, "server")
	
	server := &http.Server{
		Addr:    ":8080",
		Handler: handler,
	}
	
	log.Printf("Server starting on :8080")
	log.Fatal(server.ListenAndServe())
}

func handleOrders(w http.ResponseWriter, r *http.Request) {
	// Get the span created by otelhttp
	span := trace.SpanFromContext(r.Context())
	
	// Add business context
	span.SetAttributes(
		attribute.String("user.id", r.Header.Get("X-User-ID")),
		attribute.String("tenant.id", r.Header.Get("X-Tenant-ID")),
		attribute.String("request.id", r.Header.Get("X-Request-ID")),
	)
	
	// Create custom span for business logic
	ctx, businessSpan := tracer.Start(r.Context(), "order.process")
	defer businessSpan.End()
	
	switch r.Method {
	case http.MethodPost:
		if err := processOrder(ctx, r); err != nil {
			businessSpan.SetStatus(codes.Error, err.Error())
			span.SetStatus(codes.Error, fmt.Sprintf("OrderProcessingError: %s", err.Error()))
			http.Error(w, "Failed to process order", http.StatusInternalServerError)
			return
		}
		
		businessSpan.SetStatus(codes.Ok, "")
		w.WriteHeader(http.StatusCreated)
		fmt.Fprintf(w, "Order processed successfully")
		
	case http.MethodGet:
		orders, err := getOrders(ctx)
		if err != nil {
			businessSpan.SetStatus(codes.Error, err.Error())
			span.SetStatus(codes.Error, err.Error())
			http.Error(w, "Failed to get orders", http.StatusInternalServerError)
			return
		}
		
		businessSpan.SetAttributes(
			attribute.Int("orders.count", len(orders)),
		)
		
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"orders": %d}`, len(orders))
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	// Health checks typically don't need tracing
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
}
```

### Gin Framework

```go
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("gin-server")

func main() {
	// Initialize telemetry (see above)
	
	r := gin.New()
	
	// Add OpenTelemetry middleware
	r.Use(otelgin.Middleware("gin-server"))
	
	// Add custom middleware for business context
	r.Use(func(c *gin.Context) {
		span := trace.SpanFromContext(c.Request.Context())
		span.SetAttributes(
			attribute.String("user.id", c.GetHeader("X-User-ID")),
			attribute.String("tenant.id", c.GetHeader("X-Tenant-ID")),
		)
		c.Next()
	})
	
	// Route handlers
	r.POST("/api/orders", createOrder)
	r.GET("/api/orders/:id", getOrder)
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})
	
	r.Run(":8080")
}

func createOrder(c *gin.Context) {
	ctx, span := tracer.Start(c.Request.Context(), "order.create")
	defer span.End()
	
	var orderData struct {
		Amount   float64 `json:"amount"`
		Currency string  `json:"currency"`
		Items    []Item  `json:"items"`
	}
	
	if err := c.ShouldBindJSON(&orderData); err != nil {
		span.SetStatus(codes.Error, "Invalid request body")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}
	
	span.SetAttributes(
		attribute.Float64("order.amount", orderData.Amount),
		attribute.String("order.currency", orderData.Currency),
		attribute.Int("order.items.count", len(orderData.Items)),
	)
	
	order, err := processOrderCreation(ctx, orderData)
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order"})
		return
	}
	
	span.SetAttributes(attribute.String("order.id", order.ID))
	span.SetStatus(codes.Ok, "")
	c.JSON(http.StatusCreated, order)
}
```

### Echo Framework

```go
package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"go.opentelemetry.io/contrib/instrumentation/github.com/labstack/echo/otelecho"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("echo-server")

func main() {
	// Initialize telemetry (see above)
	
	e := echo.New()
	
	// Add OpenTelemetry middleware
	e.Use(otelecho.Middleware("echo-server"))
	
	// Routes
	e.POST("/api/users", createUser)
	e.GET("/api/users/:id", getUser)
	
	e.Logger.Fatal(e.Start(":8080"))
}

func createUser(c echo.Context) error {
	ctx, span := tracer.Start(c.Request().Context(), "user.create")
	defer span.End()
	
	var userData struct {
		Email    string `json:"email"`
		Name     string `json:"name"`
		Role     string `json:"role"`
	}
	
	if err := c.Bind(&userData); err != nil {
		span.SetStatus(codes.Error, "Invalid request body")
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request"})
	}
	
	// Hash email for privacy
	emailHash := hashString(userData.Email)
	span.SetAttributes(
		attribute.String("user.email.hash", emailHash),
		attribute.String("user.role", userData.Role),
	)
	
	user, err := createUserInDB(ctx, userData)
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to create user"})
	}
	
	span.SetAttributes(attribute.String("user.id", user.ID))
	return c.JSON(http.StatusCreated, user)
}
```

## Database Instrumentation

### PostgreSQL with pgx

```bash
go get go.opentelemetry.io/contrib/instrumentation/github.com/jackc/pgx/v5/otelgpx
```

```go
package main

import (
	"context"
	"database/sql"

	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"go.opentelemetry.io/contrib/instrumentation/github.com/jackc/pgx/v5/otelgpx"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("database")

func initDatabase(ctx context.Context) (*pgxpool.Pool, error) {
	config, err := pgxpool.ParseConfig("postgres://user:password@localhost/dbname?sslmode=disable")
	if err != nil {
		return nil, err
	}
	
	// Add OpenTelemetry tracer
	config.ConnConfig.Tracer = otelgpx.NewTracer()
	
	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, err
	}
	
	return pool, nil
}

type User struct {
	ID    string `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
}

func getUserByID(ctx context.Context, pool *pgxpool.Pool, userID string) (*User, error) {
	ctx, span := tracer.Start(ctx, "user.get_by_id")
	defer span.End()
	
	span.SetAttributes(
		attribute.String("db.operation.type", "select"),
		attribute.String("user.lookup.id", userID),
	)
	
	var user User
	err := pool.QueryRow(ctx, 
		"SELECT id, email, name FROM users WHERE id = $1", 
		userID,
	).Scan(&user.ID, &user.Email, &user.Name)
	
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return nil, err
	}
	
	span.SetAttributes(attribute.Bool("user.found", true))
	return &user, nil
}

func createUser(ctx context.Context, pool *pgxpool.Pool, user User) error {
	ctx, span := tracer.Start(ctx, "user.create")
	defer span.End()
	
	span.SetAttributes(
		attribute.String("db.operation.type", "insert"),
		attribute.String("user.email.hash", hashString(user.Email)),
	)
	
	_, err := pool.Exec(ctx,
		"INSERT INTO users (id, email, name) VALUES ($1, $2, $3)",
		user.ID, user.Email, user.Name,
	)
	
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return err
	}
	
	span.SetAttributes(attribute.String("user.created.id", user.ID))
	return nil
}
```

### MongoDB

```bash
go get go.opentelemetry.io/contrib/instrumentation/go.mongodb.org/mongo-driver/mongo/otelmongo
```

```go
package main

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.opentelemetry.io/contrib/instrumentation/go.mongodb.org/mongo-driver/mongo/otelmongo"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("mongodb")

func initMongoDB(ctx context.Context) (*mongo.Client, error) {
	opts := options.Client()
	opts.ApplyURI("mongodb://localhost:27017")
	
	// Add OpenTelemetry monitor
	opts.SetMonitor(otelmongo.NewMonitor())
	
	client, err := mongo.Connect(ctx, opts)
	if err != nil {
		return nil, err
	}
	
	return client, nil
}

type Order struct {
	ID        string    `bson:"_id,omitempty"`
	UserID    string    `bson:"user_id"`
	Amount    float64   `bson:"amount"`
	CreatedAt time.Time `bson:"created_at"`
}

func insertOrder(ctx context.Context, client *mongo.Client, order Order) error {
	ctx, span := tracer.Start(ctx, "order.insert")
	defer span.End()
	
	span.SetAttributes(
		attribute.String("db.mongodb.collection", "orders"),
		attribute.String("user.id", order.UserID),
		attribute.Float64("order.amount", order.Amount),
	)
	
	collection := client.Database("ecommerce").Collection("orders")
	_, err := collection.InsertOne(ctx, order)
	
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return err
	}
	
	span.SetAttributes(attribute.String("order.id", order.ID))
	return nil
}
```

### Redis

```bash
go get go.opentelemetry.io/contrib/instrumentation/github.com/redis/go-redis/v9/otelredis
```

```go
package main

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
	"go.opentelemetry.io/contrib/instrumentation/github.com/redis/go-redis/v9/otelredis"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("cache")

func initRedis() *redis.Client {
	rdb := redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})
	
	// Add OpenTelemetry hook
	if err := otelredis.InstrumentTracing(rdb); err != nil {
		panic(err)
	}
	
	return rdb
}

func cacheUser(ctx context.Context, rdb *redis.Client, userID string, userData []byte) error {
	ctx, span := tracer.Start(ctx, "cache.set_user")
	defer span.End()
	
	span.SetAttributes(
		attribute.String("cache.operation", "set"),
		attribute.String("cache.key.type", "user"),
		attribute.String("user.id", userID),
		attribute.Int("cache.value.size", len(userData)),
	)
	
	key := "user:" + userID
	err := rdb.Set(ctx, key, userData, 1*time.Hour).Err()
	
	if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return err
	}
	
	span.SetAttributes(attribute.String("cache.ttl", "1h"))
	return nil
}

func getCachedUser(ctx context.Context, rdb *redis.Client, userID string) ([]byte, error) {
	ctx, span := tracer.Start(ctx, "cache.get_user")
	defer span.End()
	
	span.SetAttributes(
		attribute.String("cache.operation", "get"),
		attribute.String("cache.key.type", "user"),
		attribute.String("user.id", userID),
	)
	
	key := "user:" + userID
	val, err := rdb.Get(ctx, key).Bytes()
	
	if err == redis.Nil {
		span.SetAttributes(attribute.Bool("cache.hit", false))
		return nil, nil // Cache miss
	} else if err != nil {
		span.SetStatus(codes.Error, err.Error())
		return nil, err
	}
	
	span.SetAttributes(
		attribute.Bool("cache.hit", true),
		attribute.Int("cache.value.size", len(val)),
	)
	
	return val, nil
}
```

## Advanced Patterns

### Custom Metrics

```go
package main

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

var (
	meter = otel.Meter("business-metrics")
	
	// Counters
	ordersProcessed metric.Int64Counter
	errorsTotal     metric.Int64Counter
	
	// Histograms
	orderValue     metric.Float64Histogram
	processingTime metric.Int64Histogram
	
	// Gauges
	activeUsers metric.Int64UpDownCounter
)

func initMetrics() error {
	var err error
	
	ordersProcessed, err = meter.Int64Counter(
		"orders.processed.total",
		metric.WithDescription("Total number of orders processed"),
		metric.WithUnit("{order}"),
	)
	if err != nil {
		return err
	}
	
	errorsTotal, err = meter.Int64Counter(
		"errors.total",
		metric.WithDescription("Total number of errors"),
		metric.WithUnit("{error}"),
	)
	if err != nil {
		return err
	}
	
	orderValue, err = meter.Float64Histogram(
		"order.value",
		metric.WithDescription("Distribution of order values"),
		metric.WithUnit("{currency}"),
	)
	if err != nil {
		return err
	}
	
	processingTime, err = meter.Int64Histogram(
		"order.processing.duration",
		metric.WithDescription("Time taken to process orders"),
		metric.WithUnit("ms"),
	)
	if err != nil {
		return err
	}
	
	activeUsers, err = meter.Int64UpDownCounter(
		"users.active",
		metric.WithDescription("Number of active users"),
		metric.WithUnit("{user}"),
	)
	if err != nil {
		return err
	}
	
	return nil
}

func processOrderWithMetrics(ctx context.Context, order Order) error {
	start := time.Now()
	
	// Create span for the operation
	ctx, span := tracer.Start(ctx, "order.process_with_metrics")
	defer span.End()
	
	// Add attributes
	attrs := []attribute.KeyValue{
		attribute.String("order.type", order.Type),
		attribute.String("user.tier", order.UserTier),
		attribute.String("payment.method", order.PaymentMethod),
	}
	
	// Record order value
	orderValue.Record(ctx, order.Amount, metric.WithAttributes(attrs...))
	
	// Simulate processing
	if err := processOrder(ctx, order); err != nil {
		// Record error
		errorsTotal.Add(ctx, 1, metric.WithAttributes(
			attribute.String("error.type", "processing_failed"),
			attribute.String("order.type", order.Type),
		))
		
		span.SetStatus(codes.Error, err.Error())
		return err
	}
	
	// Record success metrics
	duration := time.Since(start).Milliseconds()
	processingTime.Record(ctx, duration, metric.WithAttributes(attrs...))
	ordersProcessed.Add(ctx, 1, metric.WithAttributes(attrs...))
	
	span.SetAttributes(
		attribute.Int64("processing.duration_ms", duration),
		attribute.Float64("order.amount", order.Amount),
	)
	
	return nil
}
```

### Context Propagation Patterns

```go
package main

import (
	"context"
	"fmt"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("context-demo")

// Ensure context flows through goroutines
func processOrderAsync(ctx context.Context, orderID string) {
	// Start a new span linked to the parent
	ctx, span := tracer.Start(ctx, "order.process_async",
		trace.WithLinks(trace.LinkFromContext(ctx)),
	)
	defer span.End()
	
	span.SetAttributes(attribute.String("order.id", orderID))
	
	// Simulate async processing
	go func(ctx context.Context) {
		// Create child span in goroutine
		_, childSpan := tracer.Start(ctx, "order.background_task")
		defer childSpan.End()
		
		// Processing logic here
		fmt.Printf("Processing order %s in background\n", orderID)
		childSpan.SetAttributes(attribute.String("task.type", "background"))
	}(ctx)
}

// Channel-based worker pattern with context
type WorkItem struct {
	Ctx     context.Context
	OrderID string
	Data    interface{}
}

func worker(workChan <-chan WorkItem) {
	for item := range workChan {
		// Use the context from the work item
		ctx, span := tracer.Start(item.Ctx, "worker.process_item")
		
		span.SetAttributes(attribute.String("order.id", item.OrderID))
		
		if err := processWorkItem(ctx, item.Data); err != nil {
			span.SetStatus(codes.Error, err.Error())
		}
		
		span.End()
	}
}

// Producer sends work with context
func producer(ctx context.Context, workChan chan<- WorkItem, orderID string, data interface{}) {
	select {
	case workChan <- WorkItem{
		Ctx:     ctx,
		OrderID: orderID,
		Data:    data,
	}:
		fmt.Printf("Work item queued for order %s\n", orderID)
	case <-ctx.Done():
		fmt.Printf("Context cancelled before queuing order %s\n", orderID)
	}
}
```

## Structured Logging with slog

```go
package main

import (
	"context"
	"log/slog"
	"os"

	"go.opentelemetry.io/otel/trace"
)

// Custom handler that adds trace context
type TraceHandler struct {
	handler slog.Handler
}

func NewTraceHandler(h slog.Handler) *TraceHandler {
	return &TraceHandler{handler: h}
}

func (th *TraceHandler) Enabled(ctx context.Context, level slog.Level) bool {
	return th.handler.Enabled(ctx, level)
}

func (th *TraceHandler) Handle(ctx context.Context, r slog.Record) error {
	// Add trace context if available
	if span := trace.SpanFromContext(ctx); span.SpanContext().IsValid() {
		r.Add("trace_id", span.SpanContext().TraceID().String())
		r.Add("span_id", span.SpanContext().SpanID().String())
	}
	
	return th.handler.Handle(ctx, r)
}

func (th *TraceHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return NewTraceHandler(th.handler.WithAttrs(attrs))
}

func (th *TraceHandler) WithGroup(name string) slog.Handler {
	return NewTraceHandler(th.handler.WithGroup(name))
}

func initLogger() *slog.Logger {
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})
	
	traceHandler := NewTraceHandler(handler)
	
	return slog.New(traceHandler)
}

// Usage example
func handleRequest(ctx context.Context, logger *slog.Logger, userID string) {
	ctx, span := tracer.Start(ctx, "handle_request")
	defer span.End()
	
	span.SetAttributes(attribute.String("user.id", userID))
	
	// This log will include trace_id and span_id
	logger.InfoContext(ctx, "Processing user request",
		"user_id", userID,
		"action", "process",
	)
	
	// Simulate error
	if userID == "invalid" {
		err := fmt.Errorf("invalid user ID: %s", userID)
		span.SetStatus(codes.Error, err.Error())
		
		logger.ErrorContext(ctx, "Request failed",
			"user_id", userID,
			"error", err.Error(),
		)
		return
	}
	
	logger.InfoContext(ctx, "Request completed successfully",
		"user_id", userID,
	)
}
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: go-app
  template:
    metadata:
      labels:
        app: go-app
    spec:
      containers:
      - name: app
        image: my-go-app:latest
        ports:
        - containerPort: 8080
        env:
        # OpenTelemetry Configuration
        - name: OTEL_SERVICE_NAME
          value: "go-app"
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
        
        # Kubernetes metadata
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.name=go-app,service.version=1.0.0,deployment.environment=production,k8s.namespace.name=$(NAMESPACE),k8s.pod.name=$(HOSTNAME),k8s.node.name=$(NODE_NAME)"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "50m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Performance Optimization

### Sampling

```go
import (
	"go.opentelemetry.io/otel/sdk/trace"
)

func initTracerWithSampling() *trace.TracerProvider {
	// Sample 10% of traces
	sampler := trace.TraceIDRatioBased(0.1)
	
	// Or use parent-based sampling
	parentSampler := trace.ParentBased(trace.TraceIDRatioBased(0.1))
	
	return trace.NewTracerProvider(
		trace.WithSampler(parentSampler),
		// other options...
	)
}
```

### Batch Configuration

```go
func initOptimizedTracer() *trace.TracerProvider {
	exporter, _ := otlptracegrpc.New(context.Background())
	
	return trace.NewTracerProvider(
		trace.WithBatcher(exporter,
			trace.WithMaxExportBatchSize(100),
			trace.WithBatchTimeout(time.Second*5),
			trace.WithMaxQueueSize(1000),
		),
	)
}
```

## Troubleshooting

### Debug Logging

```go
import (
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/log/global"
	"go.opentelemetry.io/otel/log/stdr"
)

func enableDebugLogging() {
	// Enable debug logging for troubleshooting
	global.SetLogger(stdr.NewLogger(log.New(os.Stderr, "", log.LstdFlags|log.Lshortfile)))
	otel.SetErrorHandler(otel.ErrorHandlerFunc(func(err error) {
		fmt.Printf("OpenTelemetry error: %v\n", err)
	}))
}
```

### Common Issues

1. **No spans appearing**: Check that tracer provider is set before creating spans
2. **Context not propagating**: Ensure all functions accept and pass `context.Context`
3. **Connection refused**: Verify collector endpoint and protocol settings
4. **Spans disconnected**: Check that context flows through goroutines correctly

## Production Checklist

- [ ] Telemetry initialization with proper error handling
- [ ] Resource attributes set (service, version, environment)
- [ ] Context propagation through all code paths
- [ ] Custom spans for business logic
- [ ] Structured logging with trace correlation
- [ ] Error handling and span status setting
- [ ] Sampling configuration for high-traffic services
- [ ] Graceful shutdown with telemetry flushing
- [ ] Health checks exclude unnecessary instrumentation
- [ ] Performance impact measured and acceptable

## References

- [OpenTelemetry Go Documentation](https://opentelemetry.io/docs/languages/go/)
- [Go Instrumentation Registry](https://opentelemetry.io/ecosystem/registry/?language=go)
- [BMAD Method Guide](../../bmad-method.md)
- [OTTL Guide](../ottl-guide.md)
- [Sensitive Data Protection](../sensitive-data.md)