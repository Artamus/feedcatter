package main

import (
	"database/sql"
	"fmt"
	"log"
	"net"

	"github.com/Artamus/feedcatter/feedcatter-go"
	pb "github.com/Artamus/feedcatter/feedcatter-go/feedcatter"
	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"github.com/uptrace/bun/driver/pgdriver"
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
	sqldb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(dsn)))
	db := bun.NewDB(sqldb, pgdialect.New())
	foodRepository := feedcatter.NewDatabaseFoodRepository(db)
	feedcatter := feedcatter.NewServer(foodRepository)
	pb.RegisterFeedcatterServiceServer(grpcServer, feedcatter)
	grpcServer.Serve(lis)
}
