import { Client, StatusOK } from "k6/net/grpc";
import { check, sleep } from "k6";

export const options = {
  vus: 500,
  iterations: 10000
};

const client = new Client();
client.load(["Sources/Protos"], "service.proto", "food.proto");

export default function () {
  client.connect("127.0.0.1:31415", { reflect: false, plaintext: true });

  const data = { name: "Bert" };
  const response = client.invoke(
    "feedcatter.FeedcatterService/CreateFood",
    data
  );

  check(response, {
    "status is OK": (r) => r && r.status === StatusOK,
  });

  client.close();
}
