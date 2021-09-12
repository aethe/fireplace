# 🔥 Hearth

A lightweight and extendable logger for writing console and file based logs in Swift.

## Usage

### Basics

Create a logger.

```swift
let logger = Logger()
```

Attach the logger to the console or a file (or both).

```swift
logger.attach(to: Console())
logger.attach(to: File()!)
```

Write messages.

```swift
logger.write("Hello, World!")
```

See the result.

```
Hello, World!
```

### Logger

A logger is an intermediate layer between the app that produces messages, and logs that consume messages.

To connect a logger to a new log, use the `attach(to:)` method.

```swift
logger.attach(to: Console())
```

When attaching a logger to a new log, it's possible to specify what kind of messages will be recorded into this log. The example below only records UI related messages of `warning` and `error` levels and works only in debug environment.

```swift
logger.attach(
    to: Console(),
    levels: .include([.warning, .error]),
    tags: .include(["ui"]),
    environment: .debug
)
```

When a log is no longer needed, a logger can be detached from it.

```swift
logger.detach(from: myLog)
```

After all logs have been attached, write messages with the `write()` method.

```swift
logger.write("Hello, World!")
```

By default, messages have the `info` level and no tags. To change these, provide them explicitly in the `write()` method.

```swift
logger.write(
    "Hello, World!",
    level: .warning,
    tags: ["ui"]
)
```

## Installation

To integrate Hearth into your Xcode project using Swift Package Manager, go to `File > Swift Packages > Add Package Dependency...` and add it using this URL:

```
https://github.com/aethe/hearth
```
