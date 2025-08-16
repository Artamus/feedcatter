package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"github.com/Artamus/feedcatter/feedcatter-go"
	pb "github.com/Artamus/feedcatter/feedcatter-go/feedcatter"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"google.golang.org/grpc"
)

func main() {
	port := 50051
	lis, err := net.Listen("tcp", fmt.Sprintf("localhost:%d", port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	var opts []grpc.ServerOption
	grpcServer := grpc.NewServer(opts...)

	dsn := "postgres://postgres:postgres@localhost:5432/feedcatter?sslmode=disable"

	dbConfig, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		panic(err)
	}
	dbConfig.MaxConns = 16

	pool, err := pgxpool.NewWithConfig(context.Background(), dbConfig)
	if err != nil {
		panic(err)
	}
	sqldb := stdlib.OpenDBFromPool(pool)
	db := bun.NewDB(sqldb, pgdialect.New())

	// sqldb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(dsn)))
	// db := bun.NewDB(sqldb, pgdialect.New())
	foodRepository := feedcatter.NewDatabaseFoodRepository(db)
	feedcatter := feedcatter.NewServer(foodRepository)
	pb.RegisterFeedcatterServiceServer(grpcServer, feedcatter)
	grpcServer.Serve(lis)
}
