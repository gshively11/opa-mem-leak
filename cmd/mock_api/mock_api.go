package main

import (
	"crypto/sha1"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()

	r.HandleFunc(
		"/policy/discovery/bundle.tar.gz",
		func(w http.ResponseWriter, r *http.Request) {
			http.ServeFile(w, r, "policy/discovery/bundle.tar.gz")
		},
	)

	r.HandleFunc(
		"/policy/system/bundle.tar.gz",
		func(w http.ResponseWriter, r *http.Request) {
			http.ServeFile(w, r, "policy/system/bundle.tar.gz")
		},
	)

	r.HandleFunc(
		"/policy/global/bundle.tar.gz",
		func(w http.ResponseWriter, r *http.Request) {
			http.ServeFile(w, r, "policy/global/bundle.tar.gz")
		},
	)

	r.HandleFunc(
		"/policy/child/bundle.tar.gz",
		func(w http.ResponseWriter, r *http.Request) {
			http.ServeFile(w, r, "policy/child/bundle.tar.gz")
		},
	)

	r.HandleFunc(
		"/logs/child",
		func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			_, err := ioutil.ReadAll(r.Body)
			if err != nil {
				fmt.Println(err)
				return
			}
			// fmt.Println(body)
		},
	)

	r.HandleFunc(
		"/status/child",
		func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			_, err := ioutil.ReadAll(r.Body)
			if err != nil {
				fmt.Println(err)
				return
			}
			// fmt.Println(body)
		},
	)

	r.HandleFunc(
		"/some_data",
		func(w http.ResponseWriter, r *http.Request) {
			w.Header().Add("Cache-Control", "max-age=300")
			w.Header().Add("Content-Type", "text/plain")
			random := make([]byte, 4000)
			rand.Read(random)
			etag := fmt.Sprintf("\"%d-%s\"", len(random), fmt.Sprintf("%x", sha1.Sum(random)))
			w.Header().Add("Etag", etag)
			w.WriteHeader(http.StatusOK)
			w.Write(random)
		},
	)

	srv := &http.Server{
		Handler:      r,
		Addr:         ":8888",
		WriteTimeout: 5 * time.Second,
		ReadTimeout:  5 * time.Second,
	}

	fmt.Println(srv.ListenAndServe())
}
