package main

import (
	"feedcatter-go"
	"fmt"
	"log"
	"net"

	pb "github.com/Artamus/feedcatter/feedcatter-go/feedcatter"
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
	feedcatter := feedcatter.NewServer()
	pb.RegisterFeedcatterServer(grpcServer, feedcatter)
	grpcServer.Serve(lis)
}
