# opa-mem-leak

Reproducing what appears to be a memory leak involving OPA's `http.send` builtin.

## Steps 

```bash
# in shell #1 (replace osx with linux if needed)
make build_osx
make start_osx

# in shell #2 
for i in {1..10000}; do curl -XPOST 'http://localhost:8080/v1/data/example/child/resource?pretty&explain=notes' -d "{\"input\":{\"jwt\":\"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNjA3OTYwMDA1LCJ0eXAiOiJqd3QiLCJhdXRoIjoiYmxhaCIsImZhY3RvcnMiOnsibG9naW4iOjE2MDc5NjAwMDUsIm90cCI6MTYwNzk2MDAwNX19.2x5xKKHbK8gfYsOT3nAVNyZkrImWjayAi4W-6KBQyJo\", \"cache_bust\": \"$i\"}}"; done

# in shell #3 
go tool pprof localhost:8080/debug/pprof/heap
top
svg
```

Shell #2 will take a while to run, so you can re-run shell #3 over time to see how the memory grows at the `topdown formatHTTPResponseToAST` node.

## Project Structure

```
cmd/
  mock_api/         # simple http server to response with random 4kb chunks, and also accept decision logs and status updates
  opa_server/       # wrapper around opa runtime/server for configuration
policy/
  child/            # the policy being targetted by the POST /v1/data call in the for loop
  discovery/        # discovery configuration
  global/           # policy referenced by child/
  system/           # authz policy
Makefile            # all the commands to build/run the example
```
