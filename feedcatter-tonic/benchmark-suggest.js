import { Client, StatusOK } from "k6/net/grpc";
import { check, sleep } from "k6";

export const options = {
  vus: 2000,
  duration: "5m",
};

const client = new Client();
client.load(["proto"], "service.proto", "food.proto");

export default function () {
  client.connect("[::1]:50051", { reflect: false, plaintext: true });

  const response = client.invoke(
    "feedcatter.FeedcatterService/SuggestFood",
    {}
  );

  check(response, {
    "status is OK": (r) => r && r.status === StatusOK,
  });

  client.close();
}
