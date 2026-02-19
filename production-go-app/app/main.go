package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type healthResponse struct {
	Status  string `json:"status"`
	Uptime  string `json:"uptime"`
	Version string `json:"version"`
}

var (
	startTime = time.Now()
	version = "v1.0.0"
)

func main(){
	mux := http.NewServeMux()

	mux.HandleFunc("/api/hello", func(w http.ResponseWriter, r *http.Request) {
		resp := map[string]string{
			"message" : "Hello from Go on Kubernetes",
			"time" : time.Now().UTC().Format(time.RFC3339),
		}
		_ = json.NewEncoder(w).Encode(resp)
	})


	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		h := healthResponse{
			Status: "ok",
			Uptime: time.Since(startTime).String(),
			Version: version,
		}

		_ = json.NewEncoder(w).Encode(h)
	})

	srv := &http.Server{
		Addr: ":8080",
		Handler: mux,
		ReadTimeout: 3 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout: 120 * time.Second,
	}

	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server failed: %s", err)
	}
}