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
