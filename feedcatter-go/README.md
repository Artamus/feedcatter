# FeedcatterGo

## Benchmarking

### Breakpoint
Breakpoint test with k6 ran fine up to 2600 VUs, after which it failed due to P99 latencies hitting above 1s.
Memory usage seems to have hit around 2 GiB.
``` 
iteration_duration: avg=1.55s min=1.76ms med=1.54s max=3.5s p(90)=3.06s p(95)=3.27s
iterations: 1944838 3222.824487/s
grpc_req_duration: avg=1.55s min=1.37ms med=1.54s max=3.5s p(90)=3.05s p(95)=3.26s
```

### Create new food
100 VUs 5m: 3600/s [avg=27.13ms min=3.28ms med=31.48ms max=73.98ms p(90)=35.17ms p(95)=36.55ms]

500 VUs 5m: 3550/s [avg=140.16ms min=3.6ms   med=166.29ms max=285.21ms p(90)=178.78ms p(95)=182.47ms]

1000 VUs 5m: 3540/s [avg=281.17ms min=2.05ms med=335.3ms  max=441.53ms p(90)=356.81ms p(95)=362.2ms]

2000 VUs 5m: 3550/s [avg=562.09ms min=26.62ms  med=675.45ms max=777.76ms p(90)=702.17ms p(95)=708.97ms]

### Suggest food
Memory usage was ~450 MiB at 2000 VUs, proportionally lower for others.

100 VUs 5m: [avg=5.16ms min=302.24µs med=4.62ms max=50.55ms p(90)=9.49ms p(95)=11.31ms]

500 VUs 5m: [avg=25.8ms min=334.34µs med=24.81ms max=156.44ms p(90)=42.45ms p(95)=49.35ms]

1000 VUs 5m: [avg=53.21ms min=292.91µs med=52.11ms max=318.08ms p(90)=85.96ms  p(95)=99.02ms]

2000 VUs 5m: [avg=111.56ms min=286.69µs med=111.88ms max=783.7ms p(90)=170.47ms p(95)=194.37ms]
