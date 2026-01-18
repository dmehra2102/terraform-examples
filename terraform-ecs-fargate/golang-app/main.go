package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/mux"
)

type HealthResponse struct {
	Status      string    `json:"status"`
	Timestamp   time.Time `json:"timestamp"`
	Environment string    `json:"environment"`
	Version     string    `json:"version"`
}

type InfoResponse struct {
	Name        string            `json:"name"`
	Version     string            `json:"version"`
	Environment string            `json:"environment"`
	Region      string            `json:"region"`
	Port        string            `json:"port"`
	Uptime      string            `json:"uptime"`
	Config      map[string]string `json:"config"`
}

var (
	startTime  = time.Now()
	appVersion = "1.0.0"
	appName    = "golang-ecs-app"
)

func main() {
	port := getEnv("PORT", "8080")
	environment := getEnv("ENVIRONMENT", "development")
	region := getEnv("AWS_REGION", "ap-south-1")

	log.Printf("Starting %s v%s", appName, appVersion)
	log.Printf("Environment: %s", environment)
	log.Printf("Region: %s", region)
	log.Printf("Port: %s", port)

	// Create router
	router := mux.NewRouter()

	router.HandleFunc("/", handleHome).Methods("GET")
	router.HandleFunc("/health", handleHealth).Methods("GET")
	router.HandleFunc("/info", handleInfo).Methods("GET")
	router.HandleFunc("/api/echo", handleEcho).Methods("POST")

	router.Use(loggingMiddleware)

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		log.Printf("Server listening on port %s", port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	gracefulShutdown(server)
}

func handleHome(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]string{
		"message": "Welcome to Golang ECS Application",
		"version": appVersion,
		"status":  "running",
	}
	json.NewEncoder(w).Encode(response)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Context-Type", "application/json")
	response := HealthResponse{
		Status:      "healthy",
		Timestamp:   time.Now(),
		Environment: getEnv("ENVIRONMENT", "unknown"),
		Version:     appVersion,
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func handleInfo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	uptime := time.Since(startTime).Round(time.Second)

	// Example: Read configuration from environment
	config := map[string]string{
		"database": getEnv("DB_CONNECTION_STRING", "not_configured"),
		"api_key":  maskSecret(getEnv("API_KEY", "not_configured")),
	}

	response := InfoResponse{
		Name:        appName,
		Version:     appVersion,
		Environment: getEnv("ENVIRONMENT", "development"),
		Region:      getEnv("AWS_REGION", "us-east-1"),
		Port:        getEnv("PORT", "8080"),
		Uptime:      uptime.String(),
		Config:      config,
	}

	json.NewEncoder(w).Encode(response)
}

func handleEcho(w http.ResponseWriter, r *http.Request) {
	var payload map[string]any

	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	response := map[string]any{
		"echo":      payload,
		"timestamp": time.Now(),
		"server":    appName,
	}

	json.NewEncoder(w).Encode(response)
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next.ServeHTTP(w, r)

		log.Printf(
			"%s %s %s %s",
			r.Method,
			r.RequestURI,
			r.RemoteAddr,
			time.Since(start),
		)
	})
}

func gracefulShutdown(server *http.Server) {

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	sig := <-quit
	log.Printf("Received signal: %v. Starting graceful shutdown...", sig)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Printf("Server forced to shutdown: %v", err)
	}

	log.Println("Server stopped gracefully")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func maskSecret(secret string) string {
	if len(secret) <= 4 {
		return "****"
	}
	return secret[:4] + "****"
}
