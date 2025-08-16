# FeedcatterTonic

## Benchmarking

### Breakpoint
Breakpoint test with k6 ran fine up to ? VUs, after which it failed due to P99 latencies hitting above 1s.
Memory usage seems to have hit around 150 MiB.


### Create new food
100 VUs 5m: 3500/s [avg=27.73ms min=10.47ms med=32.48ms max=60.59ms p(90)=35.9ms  p(95)=36.85m]

500 VUs 5m: 3500/s [avg=143.27ms min=17.58ms med=172.91ms max=261.29ms p(90)=186.45ms p(95)=190.08ms]

1000 VUs 5m: 3500/s [avg=287.12ms min=16.53ms med=347.54ms max=428.24ms p(90)=371.65ms p(95)=377.28ms]

2000 VUs 5m: 3500/s [avg=572.9ms min=19.96ms  med=694.74ms max=791.59ms p(90)=734.23ms p(95)=741.68ms]

### Suggest food
Memory usage was ~160 MiB at 2000 VUs.

100 VUs 5m: 11000/s [avg=7.65ms min=402µs   med=7.67ms max=34.97ms p(90)=9.35ms  p(95)=10.06ms]

500 VUs 5m: 10500/s [avg=46.17ms min=4.92ms  med=45.62ms max=76.16ms p(90)=50.47ms p(95)=51.23ms]

1000 VUs 5m: 10300/s [avg=95.22ms min=3.3ms   med=95.12ms max=170ms p(90)=102.55ms p(95)=103.62ms]

2000 VUs 5m: 10000/s [avg=198.15ms min=22.53ms med=199.36ms max=349.78ms p(90)=214.74ms p(95)=219.41ms]
