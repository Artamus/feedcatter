import http from "k6/http";
import { sleep, check } from "k6";

export const options = {
  // Key configurations for breakpoint in this section
  executor: "ramping-arrival-rate", //Assure load increase if the system slows
  stages: [
    { duration: "10m", target: 5000 }, // just slowly ramp-up to a HUGE load
  ],
  thresholds: {
    http_req_failed: [{ threshold: "rate<0.01", abortOnFail: true }],
    http_req_duration: ["p(99)<1000"],
  },
};

export default () => {
  let res = http.post("http://127.0.0.1:8080/foods", { name: "Bert" });
  check(res, { "status is 200": (res) => res.status === 200 });
};
