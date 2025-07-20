import { Rate } from "k6/metrics";
import { Client, StatusOK } from "k6/net/grpc";
import { check, sleep } from "k6";

const grpc_requests_failed = new Rate("grpc_requests_failed");

export const options = {
  // Key configurations for breakpoint in this section
  executor: "ramping-arrival-rate", //Assure load increase if the system slows
  stages: [
    { duration: "10m", target: 10000 }, // just slowly ramp-up to a HUGE load
  ],
  thresholds: {
    grpc_requests_failed: [{ threshold: "rate<0.01", abortOnFail: true }],
    grpc_req_duration: ["p(99) < 1000"],
  },
};

const client = new Client();
client.load(["Sources/Protos"], "service.proto", "food.proto");

export default () => {
  client.connect("127.0.0.1:31415", { reflect: false, plaintext: true });

  const data = { name: "Bart" };
  const response = client.invoke(
    "feedcatter.FeedcatterService/CreateFood",
    data
  );

  grpc_requests_failed.add(response.status !== StatusOK);

  client.close();
};
