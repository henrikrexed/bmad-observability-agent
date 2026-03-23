# Python OpenTelemetry Instrumentation

Comprehensive guide for instrumenting Python applications with OpenTelemetry to generate traces, logs, and metrics for production observability.

## Quick Start

### Installation

```bash
pip install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap -a install
```

### Environment Variables

```bash
export OTEL_SERVICE_NAME="my-service"
export OTEL_METRICS_EXPORTER="otlp"  # traces and logs default to otlp
export OTEL_EXPORTER_OTLP_ENDPOINT="https://your-collector-endpoint"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer YOUR_TOKEN"
```

### Activation

```bash
opentelemetry-instrument python main.py
```

## Environment Configuration

### Required Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_SERVICE_NAME` | `unknown_service` | Service identifier |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | Collector endpoint |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_TRACES_EXPORTER` | `otlp` | Trace exporter (defaults to otlp) |
| `OTEL_METRICS_EXPORTER` | `none` | Set to `otlp` for metrics |
| `OTEL_LOGS_EXPORTER` | `otlp` | Log exporter (defaults to otlp) |
| `OTEL_EXPORTER_OTLP_HEADERS` | - | Authentication headers |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `grpc` | Protocol type |
| `OTEL_RESOURCE_ATTRIBUTES` | - | Additional attributes |

**Note**: Unlike Node.js, Python defaults traces and logs to `otlp` exporter.

## Framework-Specific Instrumentation

### Django

```python
# settings.py
import os
from pathlib import Path

# OpenTelemetry will be initialized via opentelemetry-instrument command
# Add any custom configuration here

BASE_DIR = Path(__file__).resolve().parent.parent

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'myapp',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'myapp.middleware.RequestContextMiddleware',  # Custom middleware for context
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'myproject.urls'
```

```python
# myapp/middleware.py
from opentelemetry import trace

class RequestContextMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Add context to the auto-instrumented span
        span = trace.get_current_span()
        if span:
            span.set_attribute("user.id", request.headers.get("X-User-ID"))
            span.set_attribute("tenant.id", request.headers.get("X-Tenant-ID"))
            span.set_attribute("request.id", request.headers.get("X-Request-ID"))
            
            # Add authenticated user context
            if hasattr(request, 'user') and request.user.is_authenticated:
                span.set_attribute("user.authenticated", True)
                span.set_attribute("user.role", getattr(request.user, 'role', 'unknown'))

        response = self.get_response(request)
        return response
```

```python
# myapp/views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from opentelemetry import trace
from opentelemetry.trace import StatusCode
import json

tracer = trace.get_tracer(__name__)

@csrf_exempt
def create_order(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Method not allowed'}, status=405)
    
    with tracer.start_as_current_span("order.create") as span:
        try:
            data = json.loads(request.body)
            
            span.set_attribute("order.amount", data.get("amount", 0))
            span.set_attribute("order.currency", data.get("currency", "USD"))
            span.set_attribute("order.items_count", len(data.get("items", [])))
            
            # Process order
            order = process_order(data)
            
            span.set_attribute("order.id", order["id"])
            span.set_status(StatusCode.OK)
            
            return JsonResponse(order, status=201)
            
        except ValueError as e:
            span.set_status(StatusCode.ERROR, f"ValueError: {str(e)}")
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            return JsonResponse({'error': 'Failed to create order'}, status=500)

def process_order(data):
    with tracer.start_as_current_span("order.process") as span:
        # Simulate order processing
        order_id = generate_order_id()
        
        span.set_attribute("processing.step", "validation")
        validate_order(data)
        
        span.set_attribute("processing.step", "payment")
        process_payment(data["amount"])
        
        span.set_attribute("processing.step", "fulfillment")
        create_fulfillment(order_id)
        
        return {
            "id": order_id,
            "status": "created",
            "amount": data["amount"]
        }
```

**Run Django with OpenTelemetry:**
```bash
opentelemetry-instrument python manage.py runserver
```

### Flask

```python
# app.py
from flask import Flask, request, jsonify
from opentelemetry import trace
from opentelemetry.trace import StatusCode
import logging

app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

tracer = trace.get_tracer(__name__)

# Middleware to add request context
@app.before_request
def before_request():
    span = trace.get_current_span()
    if span:
        span.set_attribute("user.id", request.headers.get("X-User-ID"))
        span.set_attribute("tenant.id", request.headers.get("X-Tenant-ID"))
        span.set_attribute("request.path", request.path)

@app.route('/api/users', methods=['POST'])
def create_user():
    with tracer.start_as_current_span("user.create") as span:
        try:
            data = request.get_json()
            
            # Hash email for privacy
            email_hash = hash_string(data.get("email", ""))
            span.set_attribute("user.email.hash", email_hash)
            span.set_attribute("user.role", data.get("role", "user"))
            
            # Create user
            user = create_user_in_db(data)
            
            span.set_attribute("user.id", user["id"])
            span.set_status(StatusCode.OK)
            
            logger.info("User created successfully", extra={
                "user_id": user["id"],
                "user_role": data.get("role", "user")
            })
            
            return jsonify(user), 201
            
        except ValueError as e:
            span.set_status(StatusCode.ERROR, f"ValueError: {str(e)}")
            logger.error("User creation failed - invalid data", extra={
                "error": str(e)
            })
            return jsonify({"error": "Invalid data"}), 400
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            logger.error("User creation failed", extra={
                "error": str(e)
            })
            return jsonify({"error": "Failed to create user"}), 500

@app.route('/api/users/<user_id>', methods=['GET'])
def get_user(user_id):
    with tracer.start_as_current_span("user.get") as span:
        span.set_attribute("user.lookup.id", user_id)
        
        try:
            user = get_user_from_db(user_id)
            if not user:
                span.set_attribute("user.found", False)
                return jsonify({"error": "User not found"}), 404
            
            span.set_attribute("user.found", True)
            span.set_attribute("user.role", user.get("role", "unknown"))
            
            return jsonify(user)
            
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            return jsonify({"error": "Failed to get user"}), 500

@app.route('/health')
def health():
    # Health checks typically don't need detailed tracing
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(debug=True)
```

**Run Flask with OpenTelemetry:**
```bash
opentelemetry-instrument flask --app app run
```

### FastAPI

```python
# main.py
from fastapi import FastAPI, HTTPException, Header, Depends
from pydantic import BaseModel
from typing import Optional
from opentelemetry import trace
from opentelemetry.trace import StatusCode
import logging

app = FastAPI(title="My Service", version="1.0.0")

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

tracer = trace.get_tracer(__name__)

# Pydantic models
class UserCreate(BaseModel):
    email: str
    name: str
    role: str = "user"

class OrderCreate(BaseModel):
    user_id: str
    amount: float
    currency: str = "USD"
    items: list[dict]

class User(BaseModel):
    id: str
    email: str
    name: str
    role: str

# Dependency to add context
async def add_request_context(
    x_user_id: Optional[str] = Header(None),
    x_tenant_id: Optional[str] = Header(None),
    x_request_id: Optional[str] = Header(None)
):
    span = trace.get_current_span()
    if span:
        if x_user_id:
            span.set_attribute("user.id", x_user_id)
        if x_tenant_id:
            span.set_attribute("tenant.id", x_tenant_id)
        if x_request_id:
            span.set_attribute("request.id", x_request_id)

@app.post("/api/users", response_model=User)
async def create_user(
    user_data: UserCreate,
    context: None = Depends(add_request_context)
):
    with tracer.start_as_current_span("user.create") as span:
        try:
            # Hash email for privacy
            email_hash = hash_string(user_data.email)
            span.set_attribute("user.email.hash", email_hash)
            span.set_attribute("user.role", user_data.role)
            
            # Create user
            user = await create_user_in_db(user_data)
            
            span.set_attribute("user.id", user.id)
            span.set_status(StatusCode.OK)
            
            logger.info("User created", extra={
                "user_id": user.id,
                "user_role": user_data.role
            })
            
            return user
            
        except ValueError as e:
            span.set_status(StatusCode.ERROR, f"ValueError: {str(e)}")
            logger.error("User creation failed", extra={"error": str(e)})
            raise HTTPException(status_code=400, detail="Invalid data")
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            logger.error("User creation failed", extra={"error": str(e)})
            raise HTTPException(status_code=500, detail="Failed to create user")

@app.get("/api/users/{user_id}", response_model=User)
async def get_user(
    user_id: str,
    context: None = Depends(add_request_context)
):
    with tracer.start_as_current_span("user.get") as span:
        span.set_attribute("user.lookup.id", user_id)
        
        try:
            user = await get_user_from_db(user_id)
            if not user:
                span.set_attribute("user.found", False)
                raise HTTPException(status_code=404, detail="User not found")
            
            span.set_attribute("user.found", True)
            span.set_attribute("user.role", user.role)
            
            return user
            
        except HTTPException:
            raise
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            raise HTTPException(status_code=500, detail="Failed to get user")

@app.post("/api/orders")
async def create_order(
    order_data: OrderCreate,
    context: None = Depends(add_request_context)
):
    with tracer.start_as_current_span("order.create") as span:
        try:
            span.set_attribute("order.amount", order_data.amount)
            span.set_attribute("order.currency", order_data.currency)
            span.set_attribute("order.items_count", len(order_data.items))
            span.set_attribute("user.id", order_data.user_id)
            
            # Process order through multiple steps
            order = await process_order_async(order_data)
            
            span.set_attribute("order.id", order["id"])
            span.set_status(StatusCode.OK)
            
            return order
            
        except Exception as e:
            span.set_status(StatusCode.ERROR, str(e))
            raise HTTPException(status_code=500, detail="Failed to create order")

async def process_order_async(order_data: OrderCreate):
    with tracer.start_as_current_span("order.process") as span:
        span.set_attribute("processing.async", True)
        
        # Step 1: Validate
        with tracer.start_as_current_span("order.validate") as validate_span:
            validate_span.set_attribute("validation.type", "async")
            await validate_order_async(order_data)
        
        # Step 2: Process payment
        with tracer.start_as_current_span("payment.process") as payment_span:
            payment_span.set_attribute("payment.amount", order_data.amount)
            payment_span.set_attribute("payment.currency", order_data.currency)
            await process_payment_async(order_data.amount)
        
        # Step 3: Create fulfillment
        order_id = generate_order_id()
        with tracer.start_as_current_span("fulfillment.create") as fulfill_span:
            fulfill_span.set_attribute("order.id", order_id)
            await create_fulfillment_async(order_id)
        
        return {
            "id": order_id,
            "status": "created",
            "user_id": order_data.user_id,
            "amount": order_data.amount
        }

@app.get("/health")
async def health_check():
    return {"status": "ok"}

# Run with: opentelemetry-instrument uvicorn main:app --reload
```

## Database Instrumentation

### PostgreSQL with asyncpg

```python
import asyncpg
import asyncio
from opentelemetry import trace
from opentelemetry.trace import StatusCode
import hashlib

tracer = trace.get_tracer(__name__)

class DatabaseManager:
    def __init__(self, dsn: str):
        self.dsn = dsn
        self.pool = None
    
    async def init_pool(self):
        # asyncpg is automatically instrumented
        self.pool = await asyncpg.create_pool(self.dsn)
    
    async def create_user(self, user_data: dict):
        with tracer.start_as_current_span("db.user.create") as span:
            span.set_attribute("db.operation.type", "insert")
            span.set_attribute("db.table", "users")
            
            email_hash = hashlib.sha256(user_data["email"].encode()).hexdigest()[:16]
            span.set_attribute("user.email.hash", email_hash)
            
            async with self.pool.acquire() as connection:
                try:
                    user_id = await connection.fetchval(
                        """
                        INSERT INTO users (email, name, role) 
                        VALUES ($1, $2, $3) 
                        RETURNING id
                        """,
                        user_data["email"],
                        user_data["name"],
                        user_data["role"]
                    )
                    
                    span.set_attribute("user.created.id", str(user_id))
                    span.set_status(StatusCode.OK)
                    
                    return {
                        "id": str(user_id),
                        "email": user_data["email"],
                        "name": user_data["name"],
                        "role": user_data["role"]
                    }
                except Exception as e:
                    span.set_status(StatusCode.ERROR, str(e))
                    raise
    
    async def get_user(self, user_id: str):
        with tracer.start_as_current_span("db.user.get") as span:
            span.set_attribute("db.operation.type", "select")
            span.set_attribute("db.table", "users")
            span.set_attribute("user.lookup.id", user_id)
            
            async with self.pool.acquire() as connection:
                try:
                    row = await connection.fetchrow(
                        "SELECT id, email, name, role FROM users WHERE id = $1",
                        int(user_id)
                    )
                    
                    if row:
                        span.set_attribute("user.found", True)
                        return dict(row)
                    else:
                        span.set_attribute("user.found", False)
                        return None
                        
                except Exception as e:
                    span.set_status(StatusCode.ERROR, str(e))
                    raise
```

### MongoDB with Motor

```python
from motor.motor_asyncio import AsyncIOMotorClient
from opentelemetry import trace
from opentelemetry.trace import StatusCode
from datetime import datetime
import uuid

tracer = trace.get_tracer(__name__)

class MongoManager:
    def __init__(self, connection_string: str):
        # Motor is automatically instrumented
        self.client = AsyncIOMotorClient(connection_string)
        self.db = self.client.ecommerce
    
    async def create_order(self, order_data: dict):
        with tracer.start_as_current_span("db.order.create") as span:
            span.set_attribute("db.mongodb.collection", "orders")
            span.set_attribute("order.amount", order_data.get("amount", 0))
            span.set_attribute("user.id", order_data.get("user_id"))
            
            order = {
                "_id": str(uuid.uuid4()),
                "user_id": order_data["user_id"],
                "amount": order_data["amount"],
                "currency": order_data.get("currency", "USD"),
                "items": order_data.get("items", []),
                "created_at": datetime.utcnow(),
                "status": "created"
            }
            
            try:
                result = await self.db.orders.insert_one(order)
                span.set_attribute("order.id", str(result.inserted_id))
                span.set_status(StatusCode.OK)
                
                return {
                    "id": order["_id"],
                    "status": order["status"],
                    "amount": order["amount"]
                }
            except Exception as e:
                span.set_status(StatusCode.ERROR, str(e))
                raise
    
    async def get_orders_by_user(self, user_id: str):
        with tracer.start_as_current_span("db.orders.get_by_user") as span:
            span.set_attribute("db.mongodb.collection", "orders")
            span.set_attribute("user.id", user_id)
            
            try:
                cursor = self.db.orders.find({"user_id": user_id})
                orders = await cursor.to_list(length=100)
                
                span.set_attribute("orders.count", len(orders))
                span.set_status(StatusCode.OK)
                
                return orders
            except Exception as e:
                span.set_status(StatusCode.ERROR, str(e))
                raise
```

### Redis with aioredis

```python
import aioredis
import json
from opentelemetry import trace
from opentelemetry.trace import StatusCode

tracer = trace.get_tracer(__name__)

class CacheManager:
    def __init__(self, redis_url: str):
        self.redis_url = redis_url
        self.redis = None
    
    async def init_redis(self):
        # aioredis is automatically instrumented
        self.redis = aioredis.from_url(self.redis_url)
    
    async def cache_user(self, user_id: str, user_data: dict, ttl: int = 3600):
        with tracer.start_as_current_span("cache.user.set") as span:
            span.set_attribute("cache.operation", "set")
            span.set_attribute("cache.key.type", "user")
            span.set_attribute("user.id", user_id)
            span.set_attribute("cache.ttl", ttl)
            
            try:
                key = f"user:{user_id}"
                value = json.dumps(user_data)
                
                await self.redis.set(key, value, ex=ttl)
                
                span.set_attribute("cache.value.size", len(value))
                span.set_status(StatusCode.OK)
                
            except Exception as e:
                span.set_status(StatusCode.ERROR, str(e))
                raise
    
    async def get_cached_user(self, user_id: str):
        with tracer.start_as_current_span("cache.user.get") as span:
            span.set_attribute("cache.operation", "get")
            span.set_attribute("cache.key.type", "user")
            span.set_attribute("user.id", user_id)
            
            try:
                key = f"user:{user_id}"
                value = await self.redis.get(key)
                
                if value:
                    span.set_attribute("cache.hit", True)
                    span.set_attribute("cache.value.size", len(value))
                    return json.loads(value)
                else:
                    span.set_attribute("cache.hit", False)
                    return None
                    
            except Exception as e:
                span.set_status(StatusCode.ERROR, str(e))
                raise
```

## Advanced Patterns

### Custom Metrics

```python
from opentelemetry import metrics
from opentelemetry.metrics import Observation
import time
import functools

# Get meter
meter = metrics.get_meter(__name__)

# Create instruments
request_counter = meter.create_counter(
    name="http_requests_total",
    description="Total number of HTTP requests",
    unit="1",
)

request_duration = meter.create_histogram(
    name="http_request_duration_seconds",
    description="Duration of HTTP requests",
    unit="s",
)

active_connections = meter.create_up_down_counter(
    name="active_connections",
    description="Number of active connections",
    unit="1",
)

# Decorator for automatic metrics collection
def measure_time(operation_name: str):
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            
            try:
                result = await func(*args, **kwargs)
                
                # Record success metrics
                duration = time.time() - start_time
                request_duration.record(
                    duration,
                    attributes={
                        "operation": operation_name,
                        "status": "success"
                    }
                )
                
                request_counter.add(
                    1,
                    attributes={
                        "operation": operation_name,
                        "status": "success"
                    }
                )
                
                return result
                
            except Exception as e:
                # Record error metrics
                duration = time.time() - start_time
                request_duration.record(
                    duration,
                    attributes={
                        "operation": operation_name,
                        "status": "error"
                    }
                )
                
                request_counter.add(
                    1,
                    attributes={
                        "operation": operation_name,
                        "status": "error",
                        "error_type": type(e).__name__
                    }
                )
                
                raise
                
        return wrapper
    return decorator

# Usage
@measure_time("user_creation")
async def create_user_with_metrics(user_data: dict):
    with tracer.start_as_current_span("user.create") as span:
        # Business logic here
        user = await create_user_in_db(user_data)
        return user
```

### Error Tracking and Correlation

```python
import traceback
import logging
from opentelemetry import trace
from opentelemetry.trace import StatusCode

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(message)s'
)
logger = logging.getLogger(__name__)

class ErrorTracker:
    @staticmethod
    def capture_exception(error: Exception, context: dict = None):
        span = trace.get_current_span()
        span_context = span.get_span_context()
        
        # Set span status
        span.set_status(StatusCode.ERROR, str(error))
        
        # Add error attributes to span
        span.set_attributes({
            "exception.type": type(error).__name__,
            "exception.message": str(error),
            "exception.escaped": True
        })
        
        # Log structured error with trace correlation
        logger.error(json.dumps({
            "message": "Exception occurred",
            "trace_id": format(span_context.trace_id, "032x"),
            "span_id": format(span_context.span_id, "016x"),
            "exception": {
                "type": type(error).__name__,
                "message": str(error),
                "stacktrace": traceback.format_exc()
            },
            "context": context or {},
            "timestamp": datetime.utcnow().isoformat()
        }))

# Decorator for automatic error tracking
def track_errors(func):
    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        try:
            return await func(*args, **kwargs)
        except Exception as e:
            ErrorTracker.capture_exception(e, {
                "function": func.__name__,
                "args": str(args)[:200],  # Truncate for safety
                "kwargs": str(kwargs)[:200]
            })
            raise
    return wrapper

# Usage
@track_errors
async def risky_operation(user_id: str):
    with tracer.start_as_current_span("risky.operation") as span:
        span.set_attribute("user.id", user_id)
        
        # This might raise an exception
        result = await some_external_service(user_id)
        return result
```

### Async Background Tasks

```python
import asyncio
from opentelemetry import trace
from opentelemetry.trace import StatusCode

tracer = trace.get_tracer(__name__)

class BackgroundTaskManager:
    def __init__(self):
        self.tasks = set()
    
    async def create_task_with_context(self, coro, context_name: str, **attributes):
        """Create a background task that maintains trace context"""
        
        # Get current context
        current_span = trace.get_current_span()
        current_context = current_span.get_span_context()
        
        async def task_wrapper():
            # Create a new span linked to the original context
            with tracer.start_as_current_span(
                context_name,
                links=[trace.Link(current_context)]
            ) as task_span:
                
                # Add attributes
                for key, value in attributes.items():
                    task_span.set_attribute(key, value)
                
                task_span.set_attribute("task.background", True)
                
                try:
                    result = await coro
                    task_span.set_status(StatusCode.OK)
                    return result
                except Exception as e:
                    task_span.set_status(StatusCode.ERROR, str(e))
                    # Log error but don't re-raise (background task)
                    logger.error(f"Background task failed: {e}")
                finally:
                    # Clean up task reference
                    self.tasks.discard(task)
        
        # Create and track the task
        task = asyncio.create_task(task_wrapper())
        self.tasks.add(task)
        
        return task
    
    async def shutdown(self):
        """Wait for all background tasks to complete"""
        if self.tasks:
            await asyncio.gather(*self.tasks, return_exceptions=True)

# Usage
task_manager = BackgroundTaskManager()

async def process_order_with_background_tasks(order_data: dict):
    with tracer.start_as_current_span("order.process") as span:
        # Main order processing
        order = await create_order(order_data)
        
        # Start background tasks
        await task_manager.create_task_with_context(
            send_confirmation_email(order["user_email"]),
            "email.send_confirmation",
            order_id=order["id"],
            email_type="confirmation"
        )
        
        await task_manager.create_task_with_context(
            update_inventory(order["items"]),
            "inventory.update",
            order_id=order["id"],
            items_count=len(order["items"])
        )
        
        await task_manager.create_task_with_context(
            send_to_fulfillment_system(order),
            "fulfillment.queue",
            order_id=order["id"],
            priority="normal"
        )
        
        return order
```

## Structured Logging

### JSON Logger with Trace Correlation

```python
import json
import logging
import sys
from datetime import datetime
from opentelemetry import trace

class TraceAwareJSONFormatter(logging.Formatter):
    def format(self, record):
        # Get current span context
        span = trace.get_current_span()
        span_context = span.get_span_context()
        
        # Build log entry
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        
        # Add trace context if available
        if span_context.is_valid:
            log_entry.update({
                "trace_id": format(span_context.trace_id, "032x"),
                "span_id": format(span_context.span_id, "016x"),
            })
        
        # Add extra fields from record
        if hasattr(record, 'extra_fields'):
            log_entry.update(record.extra_fields)
        
        # Handle exceptions
        if record.exc_info:
            log_entry["exception"] = {
                "type": record.exc_info[0].__name__,
                "message": str(record.exc_info[1]),
                "stacktrace": self.formatException(record.exc_info)
            }
        
        return json.dumps(log_entry)

# Configure logging
def setup_logging():
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(TraceAwareJSONFormatter())
    
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(handler)

# Helper class for structured logging
class StructuredLogger:
    def __init__(self, name: str):
        self.logger = logging.getLogger(name)
    
    def info(self, message: str, **kwargs):
        record = self.logger.makeRecord(
            self.logger.name,
            logging.INFO,
            __file__,
            0,
            message,
            (),
            None
        )
        record.extra_fields = kwargs
        self.logger.handle(record)
    
    def error(self, message: str, error: Exception = None, **kwargs):
        record = self.logger.makeRecord(
            self.logger.name,
            logging.ERROR,
            __file__,
            0,
            message,
            (),
            (type(error), error, error.__traceback__) if error else None
        )
        record.extra_fields = kwargs
        self.logger.handle(record)

# Usage
logger = StructuredLogger(__name__)

async def business_operation(user_id: str):
    with tracer.start_as_current_span("business.operation") as span:
        span.set_attribute("user.id", user_id)
        
        logger.info("Starting business operation", 
                   user_id=user_id, 
                   operation="important_task")
        
        try:
            result = await perform_operation(user_id)
            
            logger.info("Business operation completed", 
                       user_id=user_id, 
                       result_count=len(result))
            
            return result
            
        except Exception as e:
            logger.error("Business operation failed", 
                        error=e, 
                        user_id=user_id)
            raise
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: app
        image: my-python-app:latest
        command: ["opentelemetry-instrument"]
        args: ["python", "-m", "gunicorn", "main:app", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
        ports:
        - containerPort: 8000
        env:
        # OpenTelemetry Configuration
        - name: OTEL_SERVICE_NAME
          value: "python-app"
        - name: OTEL_SERVICE_VERSION
          value: "1.0.0"
        - name: OTEL_METRICS_EXPORTER
          value: "otlp"
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        - name: OTEL_EXPORTER_OTLP_PROTOCOL
          value: "grpc"
        
        # Resource attributes
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.name=python-app,service.version=1.0.0,deployment.environment=production,k8s.namespace.name=$(NAMESPACE),k8s.pod.name=$(HOSTNAME),k8s.node.name=$(NODE_NAME)"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        
        # Application configuration
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: redis-url
        
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
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
```

## Production Considerations

### Graceful Shutdown

```python
import signal
import asyncio
from opentelemetry import trace, metrics

class Application:
    def __init__(self):
        self.shutdown_event = asyncio.Event()
        self.task_manager = BackgroundTaskManager()
        
    async def start(self):
        # Set up signal handlers
        for sig in [signal.SIGTERM, signal.SIGINT]:
            signal.signal(sig, self.signal_handler)
        
        # Start the application
        await self.run_server()
    
    def signal_handler(self, signum, frame):
        print(f"Received signal {signum}, shutting down...")
        asyncio.create_task(self.shutdown())
    
    async def shutdown(self):
        print("Starting graceful shutdown...")
        
        # 1. Stop accepting new requests
        self.shutdown_event.set()
        
        # 2. Wait for background tasks
        await self.task_manager.shutdown()
        
        # 3. Flush telemetry data
        tracer_provider = trace.get_tracer_provider()
        if hasattr(tracer_provider, 'force_flush'):
            tracer_provider.force_flush(timeout=10)
            
        meter_provider = metrics.get_meter_provider()
        if hasattr(meter_provider, 'force_flush'):
            meter_provider.force_flush(timeout=10)
        
        print("Shutdown complete")

# Usage with FastAPI
app_instance = Application()

@app.on_event("startup")
async def startup_event():
    setup_logging()
    await app_instance.start()

@app.on_event("shutdown")  
async def shutdown_event():
    await app_instance.shutdown()
```

### Performance Optimization

```python
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.sampling import TraceIdRatioBased, ParentBased

# Configure sampling for high-traffic applications
sampler = ParentBased(
    root=TraceIdRatioBased(0.1)  # Sample 10% of root spans
)

tracer_provider = TracerProvider(sampler=sampler)
trace.set_tracer_provider(tracer_provider)
```

## Troubleshooting

### Debug Configuration

```python
import os
import logging

# Enable OpenTelemetry debug logging
os.environ["OTEL_LOG_LEVEL"] = "debug"

# Set up debug logging
logging.basicConfig(level=logging.DEBUG)
logging.getLogger("opentelemetry").setLevel(logging.DEBUG)

# Check configuration
print("OpenTelemetry Configuration:")
for key, value in os.environ.items():
    if key.startswith("OTEL_"):
        print(f"{key}={value}")
```

### Common Issues

1. **No spans appearing**: Ensure `opentelemetry-instrument` is used to run the application
2. **Missing instrumentations**: Run `opentelemetry-bootstrap -a install` to install missing packages
3. **Connection errors**: Check collector endpoint and protocol settings
4. **Import errors**: Ensure all required packages are installed in the same environment

### Health Check for Telemetry

```python
from opentelemetry import trace, metrics

@app.get("/telemetry-health")
async def telemetry_health():
    try:
        # Check if tracer provider is working
        tracer = trace.get_tracer(__name__)
        with tracer.start_as_current_span("health_check") as span:
            span.set_attribute("check.type", "telemetry")
        
        # Check if meter provider is working  
        meter = metrics.get_meter(__name__)
        counter = meter.create_counter("health_check")
        counter.add(1, {"check": "telemetry"})
        
        return {"status": "ok", "telemetry": "active"}
        
    except Exception as e:
        return {"status": "error", "telemetry": str(e)}
```

## Production Checklist

- [ ] Auto-instrumentation enabled with `opentelemetry-instrument`
- [ ] Environment variables configured correctly
- [ ] Resource attributes include service, version, environment
- [ ] Sensitive data redaction implemented
- [ ] Structured logging with trace correlation
- [ ] Custom spans for business logic
- [ ] Metrics collection for key operations
- [ ] Error tracking and correlation
- [ ] Background task tracing
- [ ] Graceful shutdown with telemetry flushing
- [ ] Health checks for telemetry systems
- [ ] Performance impact measured and acceptable

## References

- [OpenTelemetry Python Documentation](https://opentelemetry.io/docs/languages/python/)
- [Python Auto-Instrumentation](https://pypi.org/project/opentelemetry-distro/)
- [BMAD Method Guide](../../bmad-method.md)
- [OTTL Guide](../ottl-guide.md)
- [Sensitive Data Protection](../sensitive-data.md)