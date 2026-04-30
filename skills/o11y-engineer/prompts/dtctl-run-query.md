Help user construct and execute DQL queries:
1. Identify data source (logs, traces, metrics, events, entities)
2. Build query with proper syntax:
   ```dql
   fetch logs
   | filter dt.entity.service == "my-service"
   | filter loglevel == "ERROR"
   | sort timestamp desc
   | limit 100
   ```
3. Add aggregations if needed (summarize, timeseries)
4. Optimize query performance
5. Execute via dtctl or Dynatrace API
6. Format and explain results
