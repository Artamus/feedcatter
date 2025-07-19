import http from "k6/http";
import { sleep, check } from "k6";

export const options = {
  vus: 5000,
  iterations: 1000000
};

export default function () {
  let res = http.post("http://127.0.0.1:8080/foods", { name: "Bert" });
  check(res, { "status is 200": (res) => res.status === 200 });
}
