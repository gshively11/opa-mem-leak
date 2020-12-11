package system.authz

default allow = false

# Allow POST /v1/data/example/child/resource
allow {
	input.method == "POST"
	input.path[0] == "v1"
	input.path[1] == "data"
}

# Allow GET /health
allow {
	input.method == "GET"
	input.path[0] == "health"
}

# Allow pprof debugging
allow {
	input.method == "GET"
	input.path[0] == "debug"
}
