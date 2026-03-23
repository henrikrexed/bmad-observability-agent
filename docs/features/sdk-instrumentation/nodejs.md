# Node.js OpenTelemetry Instrumentation

Comprehensive guide for instrumenting Node.js applications with OpenTelemetry to generate traces, logs, and metrics for production observability.

## Quick Start

### Installation

```bash
npm install @opentelemetry/auto-instrumentations-node
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

### Activation

**ESM Projects:**
```bash
export NODE_OPTIONS="--import @opentelemetry/auto-instrumentations-node/register"
node app.js
```

**CommonJS Projects:**
```bash
export NODE_OPTIONS="--require @opentelemetry/auto-instrumentations-node/register"
node app.js
```

## Environment Configuration

### Required Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_SERVICE_NAME` | `unknown_service` | Service identifier in telemetry |
| `OTEL_TRACES_EXPORTER` | `none` | **Must be `otlp`** to export traces |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4317` | Collector endpoint |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTEL_METRICS_EXPORTER` | `none` | Set to `otlp` to export metrics |
| `OTEL_LOGS_EXPORTER` | `none` | Set to `otlp` to export logs |
| `OTEL_EXPORTER_OTLP_HEADERS` | - | Authentication headers |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | `http/protobuf` | Protocol: `grpc`, `http/protobuf`, `http/json` |
| `OTEL_RESOURCE_ATTRIBUTES` | - | Additional attributes (e.g., `environment=prod`) |

### Protocol Configuration

⚠️ **Important**: When targeting a gRPC receiver (port 4317), explicitly set:
```bash
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
```

The auto-instrumentations package defaults to `http/protobuf`, which causes parse errors on gRPC receivers.

## Framework-Specific Setup

### Express.js

```javascript
// app.js
const express = require('express');
const { trace } = require('@opentelemetry/api');

const app = express();
const tracer = trace.getTracer('my-service');

// Middleware to add business context
app.use((req, res, next) => {
  const span = trace.getActiveSpan();
  if (span) {
    span.setAttributes({
      'user.id': req.headers['x-user-id'],
      'tenant.id': req.headers['x-tenant-id'],
      'request.id': req.headers['x-request-id']
    });
  }
  next();
});

// Custom span for business logic
app.post('/orders', async (req, res) => {
  return tracer.startActiveSpan('order.process', async (span) => {
    try {
      span.setAttributes({
        'order.id': req.body.orderId,
        'order.amount': req.body.amount
      });
      
      const result = await processOrder(req.body);
      span.setStatus({ code: SpanStatusCode.OK });
      res.json(result);
    } catch (error) {
      span.setStatus({ 
        code: SpanStatusCode.ERROR, 
        message: error.message 
      });
      res.status(500).json({ error: 'Failed to process order' });
    } finally {
      span.end();
    }
  });
});

app.listen(3000);
```

### Fastify

```javascript
// server.js
const fastify = require('fastify')({ logger: true });
const { trace, SpanStatusCode } = require('@opentelemetry/api');

const tracer = trace.getTracer('my-service');

// Hook to add context to all requests
fastify.addHook('onRequest', async (request) => {
  const span = trace.getActiveSpan();
  if (span) {
    span.setAttributes({
      'user.id': request.headers['x-user-id'],
      'route.handler': request.routerPath || request.url
    });
  }
});

// Business logic with custom spans
fastify.post('/api/users', async (request, reply) => {
  return tracer.startActiveSpan('user.create', async (span) => {
    try {
      span.setAttributes({
        'user.email.hash': sha256(request.body.email),
        'user.plan': request.body.plan
      });
      
      const user = await createUser(request.body);
      span.setStatus({ code: SpanStatusCode.OK });
      return user;
    } catch (error) {
      span.setStatus({ 
        code: SpanStatusCode.ERROR, 
        message: error.message 
      });
      throw error;
    } finally {
      span.end();
    }
  });
});

fastify.listen({ port: 3000 });
```

### NestJS

```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // OpenTelemetry is auto-initialized via NODE_OPTIONS
  // Add global middleware for request context
  app.use((req, res, next) => {
    const trace = require('@opentelemetry/api').trace;
    const span = trace.getActiveSpan();
    if (span) {
      span.setAttributes({
        'http.route': req.route?.path || req.url,
        'user.id': req.headers['x-user-id']
      });
    }
    next();
  });
  
  await app.listen(3000);
}
bootstrap();
```

```typescript
// user.service.ts
import { Injectable } from '@nestjs/common';
import { trace, SpanStatusCode } from '@opentelemetry/api';

@Injectable()
export class UserService {
  private readonly tracer = trace.getTracer('user-service');

  async createUser(userData: CreateUserDto): Promise<User> {
    return this.tracer.startActiveSpan('user.create', async (span) => {
      try {
        span.setAttributes({
          'user.role': userData.role,
          'user.department': userData.department
        });

        const user = await this.userRepository.create(userData);
        span.setStatus({ code: SpanStatusCode.OK });
        return user;
      } catch (error) {
        span.setStatus({ 
          code: SpanStatusCode.ERROR, 
          message: error.message 
        });
        throw error;
      } finally {
        span.end();
      }
    });
  }
}
```

## Database Instrumentation

### PostgreSQL with pg

```javascript
// Automatically instrumented by auto-instrumentations
const { Client } = require('pg');
const { trace } = require('@opentelemetry/api');

const client = new Client({
  host: 'localhost',
  database: 'myapp',
  user: 'user',
  password: 'password'
});

// Add custom business context to DB operations
async function getUserById(userId) {
  const span = trace.getActiveSpan();
  if (span) {
    span.setAttributes({
      'db.operation.type': 'select',
      'user.lookup.id': userId
    });
  }
  
  const result = await client.query('SELECT * FROM users WHERE id = $1', [userId]);
  return result.rows[0];
}
```

### MongoDB with mongoose

```javascript
// Automatically instrumented
const mongoose = require('mongoose');
const { trace } = require('@opentelemetry/api');

const UserSchema = new mongoose.Schema({
  email: String,
  name: String,
  createdAt: { type: Date, default: Date.now }
});

// Add middleware for operation tracking
UserSchema.pre('save', function() {
  const span = trace.getActiveSpan();
  if (span) {
    span.setAttributes({
      'db.mongodb.collection': 'users',
      'user.operation': this.isNew ? 'create' : 'update'
    });
  }
});

const User = mongoose.model('User', UserSchema);
```

### Redis

```javascript
// Redis operations are automatically instrumented
const redis = require('redis');
const { trace } = require('@opentelemetry/api');

const client = redis.createClient();

// Add business context to cache operations
async function getCachedUser(userId) {
  const span = trace.getActiveSpan();
  if (span) {
    span.setAttributes({
      'cache.operation': 'get',
      'cache.key.type': 'user',
      'user.id': userId
    });
  }
  
  return await client.get(`user:${userId}`);
}
```

## Advanced Instrumentation Patterns

### Custom SpanProcessor for Data Enhancement

```javascript
// instrumentation.js
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { SpanKind, SpanStatusCode } = require('@opentelemetry/api');

class BusinessContextProcessor {
  constructor() {
    this.name = 'BusinessContextProcessor';
  }

  onStart(span, parentContext) {
    // Add standard metadata to all spans
    span.setAttributes({
      'service.version': process.env.SERVICE_VERSION || 'unknown',
      'deployment.environment': process.env.NODE_ENV || 'unknown'
    });
  }

  onEnd(span) {
    // Enhance spans based on their characteristics
    const attributes = span.attributes;
    
    // Classify span types
    if (attributes['http.method']) {
      span.setAttribute('span.type', 'http');
      
      // Add HTTP-specific classifications
      if (parseInt(attributes['http.status_code']) >= 400) {
        span.setAttribute('http.error_class', 
          parseInt(attributes['http.status_code']) >= 500 ? 'server_error' : 'client_error'
        );
      }
    }
    
    if (attributes['db.system']) {
      span.setAttribute('span.type', 'database');
      span.setAttribute('db.vendor', attributes['db.system']);
    }
    
    // Add performance classifications
    const duration = span.duration || 0;
    if (duration > 5000000000) { // 5 seconds in nanoseconds
      span.setAttribute('performance.slow', true);
    }
  }

  shutdown() {
    return Promise.resolve();
  }

  forceFlush() {
    return Promise.resolve();
  }
}

// Add to SDK configuration
const sdk = new NodeSDK({
  spanProcessors: [new BusinessContextProcessor()]
});

sdk.start();
```

### Error Tracking Integration

```javascript
// error-tracking.js
const { trace, SpanStatusCode } = require('@opentelemetry/api');

class ErrorTracker {
  static captureException(error, context = {}) {
    const span = trace.getActiveSpan();
    
    if (span) {
      // Set span status
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error.message
      });
      
      // Add error details as attributes
      span.setAttributes({
        'exception.type': error.constructor.name,
        'exception.message': error.message,
        'exception.stacktrace': error.stack,
        ...context
      });
    }
    
    // Also log structured error
    console.error({
      message: 'Unhandled error',
      error: {
        type: error.constructor.name,
        message: error.message,
        stack: error.stack
      },
      trace_id: span?.spanContext().traceId,
      span_id: span?.spanContext().spanId,
      ...context
    });
  }
}

// Global error handlers
process.on('uncaughtException', (error) => {
  ErrorTracker.captureException(error, { 
    source: 'uncaught_exception' 
  });
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  const error = reason instanceof Error ? reason : new Error(String(reason));
  ErrorTracker.captureException(error, { 
    source: 'unhandled_rejection',
    promise: promise.toString()
  });
});

module.exports = { ErrorTracker };
```

## Structured Logging Integration

### Pino Integration

```javascript
// logger.js
const pino = require('pino');
const { trace } = require('@opentelemetry/api');

const logger = pino({
  level: 'info',
  formatters: {
    bindings: () => ({}), // Remove hostname/pid noise
    level: (label) => ({ level: label.toUpperCase() })
  },
  base: undefined, // Remove default fields
});

// Helper to add trace context
function createLogger(name) {
  return {
    info: (msg, extra = {}) => {
      const span = trace.getActiveSpan();
      const spanContext = span?.spanContext();
      
      logger.info({
        ...extra,
        trace_id: spanContext?.traceId,
        span_id: spanContext?.spanId,
        service: name,
        timestamp: new Date().toISOString()
      }, msg);
    },
    
    error: (msg, error, extra = {}) => {
      const span = trace.getActiveSpan();
      const spanContext = span?.spanContext();
      
      logger.error({
        ...extra,
        error: {
          type: error?.constructor?.name,
          message: error?.message,
          stack: error?.stack
        },
        trace_id: spanContext?.traceId,
        span_id: spanContext?.spanId,
        service: name,
        timestamp: new Date().toISOString()
      }, msg);
    }
  };
}

module.exports = { createLogger };
```

### Winston Integration

```javascript
// winston-logger.js
const winston = require('winston');
const { trace } = require('@opentelemetry/api');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.errors({ stack: true }),
    winston.format.timestamp(),
    winston.format.json(),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      // Add trace context
      const span = trace.getActiveSpan();
      const spanContext = span?.spanContext();
      
      return JSON.stringify({
        timestamp,
        level: level.toUpperCase(),
        message,
        trace_id: spanContext?.traceId,
        span_id: spanContext?.spanId,
        ...meta
      });
    })
  ),
  transports: [
    new winston.transports.Console()
  ]
});

module.exports = logger;
```

## Kubernetes Deployment

### Deployment YAML with Auto-Instrumentation

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: app
        image: my-nodejs-app:latest
        ports:
        - containerPort: 3000
        env:
        # OpenTelemetry Configuration
        - name: NODE_OPTIONS
          value: "--require @opentelemetry/auto-instrumentations-node/register"
        - name: OTEL_SERVICE_NAME
          value: "nodejs-app"
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
        
        # Resource attributes from Kubernetes
        - name: OTEL_RESOURCE_ATTRIBUTES
          value: "service.name=nodejs-app,service.version=1.0.0,deployment.environment=production,k8s.namespace.name=$(NAMESPACE),k8s.pod.name=$(HOSTNAME),k8s.node.name=$(NODE_NAME)"
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
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service and Ingress

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app-service
  labels:
    app: nodejs-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: nodejs-app

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nodejs-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nodejs-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nodejs-app-service
            port:
              number: 80
```

## Performance Optimization

### Sampling Configuration

```javascript
// For high-traffic applications, implement sampling
const { TraceIdRatioBasedSampler, ParentBasedSampler } = require('@opentelemetry/sdk-trace-base');

const sdk = new NodeSDK({
  sampler: new ParentBasedSampler({
    root: new TraceIdRatioBasedSampler(0.1) // Sample 10% of traces
  }),
});
```

### Resource Optimization

```javascript
// Optimize resource usage for production
const sdk = new NodeSDK({
  spanProcessors: [
    new BatchSpanProcessor(exporter, {
      maxQueueSize: 1000,
      maxExportBatchSize: 100,
      scheduledDelayMillis: 1000,
      exportTimeoutMillis: 30000
    })
  ],
});
```

## Troubleshooting

### Common Issues

**1. No telemetry data appearing:**
```bash
# Check environment variables
echo $OTEL_TRACES_EXPORTER  # Should be "otlp"
echo $NODE_OPTIONS          # Should contain --require or --import

# Check for connection errors
export OTEL_LOG_LEVEL=debug
node app.js
```

**2. ESM/CommonJS mismatch:**
```bash
# For ES modules (package.json has "type": "module")
export NODE_OPTIONS="--import @opentelemetry/auto-instrumentations-node/register"

# For CommonJS (default)
export NODE_OPTIONS="--require @opentelemetry/auto-instrumentations-node/register"
```

**3. Protocol mismatch:**
```bash
# For gRPC collectors (port 4317)
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"

# For HTTP collectors (port 4318) 
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
```

### Debug Configuration

```javascript
// debug-config.js
const { DiagConsoleLogger, DiagLogLevel, diag } = require('@opentelemetry/api');

// Enable debug logging
diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);

// Log all environment variables
console.log('OpenTelemetry Configuration:');
Object.keys(process.env)
  .filter(key => key.startsWith('OTEL_'))
  .forEach(key => {
    console.log(`${key}=${process.env[key]}`);
  });
```

## Production Checklist

- [ ] Service name set appropriately
- [ ] Resource attributes include environment, version, cluster info
- [ ] Sensitive data redaction implemented
- [ ] Sampling configured for high-traffic services
- [ ] Error handling and graceful shutdown implemented
- [ ] Health check endpoints exclude from tracing
- [ ] Log correlation with trace context configured
- [ ] Performance impact measured and acceptable
- [ ] Collector endpoint and authentication configured
- [ ] Monitoring alerts for instrumentation health set up

## References

- [OpenTelemetry Node.js Documentation](https://opentelemetry.io/docs/languages/js/getting-started/nodejs/)
- [Auto-Instrumentation Package](https://www.npmjs.com/package/@opentelemetry/auto-instrumentations-node)
- [BMAD Method Guide](../../bmad-method.md)
- [OTTL Guide](../ottl-guide.md)
- [Sensitive Data Protection](../sensitive-data.md)