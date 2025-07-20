# FeedcatterGRPC

💧 A project built with grpc-swift-2.

## Thoughts on using this.

- Swift tooling on VSCode is atrocious. It constantly gets bogged down in WSL2. This could be a WSL2 issue, but I do know Go ran fine.
- Swift VSCode tooling can't figure out that a bunch of stuff actually compiles. (incl cannot find my Proto imports)
- Swift proto package keeps putting .pb.d and .pb.o files into project root.

## Benchmarking

### Breakpoint
Breakpoint test with k6 ran fine up to 10000 VUs (there's more headroom to test for).
Memory usage was wack, though (1.2 GiB).
``` 
iteration_duration: avg=961.97ms min=1.96ms med=83.75ms max=1m0s   p(90)=1.38s    p(95)=4.46s
iterations: 3140743 5126.944933/s
grpc_req_duration: avg=63.98ms  min=1.48ms med=57.38ms max=13.46s p(90)=101.62ms p(95)=126.92ms
```

### Create new food
100 VUs 5m: 3500/s [avg=26.62ms min=1.9ms  med=30.46ms max=162.96ms p(90)=36.4ms  p(95)=39.92ms]

500 VUs 5m: 3500/s [avg=128.25ms min=2.1ms   med=163.63ms max=220.26ms p(90)=182.25ms p(95)=186.33ms]

1000 VUs 5m: 5300/s [avg=41.08ms  min=1.61ms med=31.72ms max=702.58ms p(90)=64.48ms  p(95)=92.13ms]

2000 VUs 5m: 5150/s [avg=47.72ms  min=1.57ms med=39.38ms max=12.81s p(90)=75.08ms p(95)=94.86ms]

### Suggest food
100 VUs 5m: 4700/s [avg=5.97ms  min=1.08ms med=4.75ms  max=45.8ms  p(90)=11.63ms p(95)=14ms]

500 VUs 5m: 4500/s [avg=6.06ms   min=1.07ms med=4.32ms  max=563.63ms p(90)=12.55ms p(95)=16.38ms]

1000 VUs 5m: 4500/s [avg=5.81ms   min=1.07ms med=3.65ms  max=1.97s  p(90)=10.71ms p(95)=15.13ms]

2000 VUs 5m: 4500/s [avg=7.02ms   min=1.06ms med=4.08ms  max=12.78s p(90)=11.04ms p(95)=15.23ms]
