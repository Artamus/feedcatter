import { Client, StatusOK } from "k6/net/grpc";
import { check, sleep } from "k6";

export const options = {
  vus: 2000,
  duration: "5m",
};

const client = new Client();
client.load(["feedcatter"], "service.proto", "food.proto");

export default function () {
  client.connect("127.0.0.1:50051", { reflect: false, plaintext: true });

  const data = { name: "Burt" };
  const response = client.invoke(
    "feedcatter.FeedcatterService/CreateFood",
    data
  );

  check(response, {
    "status is OK": (r) => r && r.status === StatusOK,
  });

  client.close();
}
