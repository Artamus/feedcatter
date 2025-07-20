import http from "k6/http";
import { sleep, check } from "k6";

export const options = {
  vus: 750,
  duration: "5m",
};

export default function () {
  let res = http.get("http://127.0.0.1:8080/foods/suggestion");
  check(res, { "status is 200": (res) => res.status === 200 });
}
