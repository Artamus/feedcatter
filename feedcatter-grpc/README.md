# FeedcatterGRPC

💧 A project built with grpc-swift-2.

## Thoughts on using this.

- Swift tooling on VSCode is atrocious. It constantly gets bogged down in WSL2. This could be a WSL2 issue, but I do know Go ran fine.
- Swift VSCode tooling can't figure out that a bunch of stuff actually compiles. (incl cannot find my Proto imports)
- Swift proto package keeps putting .pb.d and .pb.o files into project root.

## Benchmarking

Breakpoint test with k6 ran fine up to 10000 VUs (there's more headroom to test for).
Memory usage was wack, though (1.2 GiB).
``` 
iteration_duration: avg=961.97ms min=1.96ms med=83.75ms max=1m0s   p(90)=1.38s    p(95)=4.46s
iterations: 3140743 5126.944933/s
grpc_req_duration: avg=63.98ms  min=1.48ms med=57.38ms max=13.46s p(90)=101.62ms p(95)=126.92ms
```

500 VUs 5m: 3500/s [avg=128.25ms min=2.1ms   med=163.63ms max=220.26ms p(90)=182.25ms p(95)=186.33ms]

1000 VUs 5m: 5300/s [avg=41.08ms  min=1.61ms med=31.72ms max=702.58ms p(90)=64.48ms  p(95)=92.13ms]

2000 VUs 5m: 5150/s [avg=47.72ms  min=1.57ms med=39.38ms max=12.81s p(90)=75.08ms p(95)=94.86ms]
