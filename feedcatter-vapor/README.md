# FeedcatterVapor

💧 A project built with the Vapor web framework.

## Getting Started

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)


## Thoughts on using this.

- Swift tooling on VSCode is atrocious. It constantly gets bogged down in WSL2. This could be a WSL2 issue, but I do know Go ran fine.
- Using an ORM was a mistake, it brings in a horrible programming model if you don't want to do exact thing it was made for.
- Vapor testing is weirdly structured and wraps stuff too much.
- Didn't really test out error handling, so TBD on whether I like that.

## Benchmarking

Breakpoint test with k6 crashed at about 950 VUs.
Memory usage was around 75 MiB.

100 VUs 5m: 3500/s [avg=28.02ms min=8.21ms med=32.19ms max=71.14ms p(90)=38.21ms p(95)=39.87ms]

500 VUs 5m: 3500/s [avg=142.95ms min=59.34ms med=172.46ms max=254.36ms p(90)=186.22ms p(95)=190.05ms]

750 VUs 5m: 3500/s [avg=212.29ms min=76.11ms med=255.77ms max=365.23ms p(90)=278.05ms p(95)=284.54ms]
