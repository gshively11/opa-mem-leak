package main

import (
	"context"
	"fmt"
	"os"

	"github.com/open-policy-agent/opa/ast"
	"github.com/open-policy-agent/opa/runtime"
	"github.com/open-policy-agent/opa/server"
)

func main() {
	ctx := context.Background()
	rt, err := initRuntime(ctx)
	if err != nil {
		fmt.Println("error:", err)
		os.Exit(1)
	}
	rt.StartServer(ctx)
}

func initRuntime(ctx context.Context) (*runtime.Runtime, error) {
	params := runtime.Params{}
	params.Addrs = &[]string{
		":8080",
	}
	params.Authentication = server.AuthenticationOff
	params.Authorization = server.AuthorizationBasic
	params.Logging = runtime.LoggingConfig{
		Level:  "error",
		Format: "json-pretty",
	}
	params.Filter = func(abspath string, info os.FileInfo, depth int) bool { return true }
	params.EnableVersionCheck = false
	params.SkipBundleVerification = false
	params.BundleVerificationConfig = nil
	params.ConfigOverrides = []string{
		"services.my_service.url=http://localhost:8888/",
		"discovery.name=example.discovery",
		"discovery.resource=/policy/discovery/bundle.tar.gz",
		"discovery.service=my_service",
	}
	params.PprofEnabled = true
	params.ErrorLimit = ast.CompileErrorLimitDefault
	rt, err := runtime.NewRuntime(ctx, params)
	if err != nil {
		return nil, err
	}
	return rt, nil
}
