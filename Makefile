GOLANG_VERSION := 1.15
OPA_VERSION := 0.25.2
PWD := $(shell pwd)

build_osx:
	@# gofmt project files
	@echo "Formatting project files"
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-w /usr/src/myapp \
		golang:$(GOLANG_VERSION) \
			gofmt -w ./cmd/opa_server/*.go ./cmd/mock_api/*.go
	@# fmt rego files
	@docker run \
		--rm \
		-v "$(PWD)/policy:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			fmt -w  /tmp/policy
	@# build bundles
	@echo "Building OPA bundles"
	@docker run \
		--rm \
		-v "$(PWD)/policy/child:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/discovery:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/global:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/system:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@# build osx
	@echo "Building osx binaries..."
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-v go-modules:/go/pkg/mod \
		-w /usr/src/myapp \
		-e GOOS=darwin \
		-e GOARCH=amd64 \
		-e CGO_ENABLED=0 \
		golang:$(GOLANG_VERSION) \
			go build \
				-o bin/opa_server_darwin_amd64 \
				./cmd/opa_server
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-v go-modules:/go/pkg/mod \
		-w /usr/src/myapp \
		-e GOOS=darwin \
		-e GOARCH=amd64 \
		-e CGO_ENABLED=0 \
		golang:$(GOLANG_VERSION) \
			go build \
				-o bin/mock_api_darwin_amd64 \
				./cmd/mock_api

build_linux:
	@# gofmt project files
	@echo "Formatting project files"
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-w /usr/src/myapp \
		golang:$(GOLANG_VERSION) \
			gofmt -w ./cmd/opa_server/*.go ./cmd/mock_api/*.go
	@# fmt rego files
	@docker run \
		--rm \
		-v "$(PWD)/policy:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			fmt -w  /tmp/policy
	@# build bundles
	@echo "Building OPA bundles"
	@docker run \
		--rm \
		-v "$(PWD)/policy/child:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/discovery:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/global:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@docker run \
		--rm \
		-v "$(PWD)/policy/system:/tmp/policy" \
		openpolicyagent/opa:$(OPA_VERSION) \
			build \
				--bundle /tmp/policy \
				--output /tmp/policy/bundle.tar.gz
	@# build linux
	@echo "Building linux binaries..."
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-v go-modules:/go/pkg/mod \
		-w /usr/src/myapp \
		-e GOOS=linux \
		-e GOARCH=amd64 \
		-e CGO_ENABLED=0 \
		golang:$(GOLANG_VERSION) \
			go build \
				-o bin/opa_server_linux_amd64 \
				./cmd/opa_server
	@docker run \
		--rm \
		-v "$(PWD):/usr/src/myapp" \
		-v go-modules:/go/pkg/mod \
		-w /usr/src/myapp \
		-e GOOS=linux \
		-e GOARCH=amd64 \
		-e CGO_ENABLED=0 \
		golang:$(GOLANG_VERSION) \
			go build \
				-o bin/mock_api_linux_amd64  \
				./cmd/mock_api


start_osx:
	@(trap 'kill 0' SIGINT; ./bin/mock_api_darwin_amd64 & ./bin/opa_server_darwin_amd64)

start_linux:
	@(trap 'kill 0' SIGINT; ./bin/mock_api_linux_amd64 & ./bin/opa_server_linux_amd64)
