# Hearth

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

Write logs.

```swift
logger.write("Hello, World!")
```

See the result.

```
Hello, World!
```

## Installation

To integrate Hearth into your Xcode project using Swift Package Manager, go to `File > Swift Packages > Add Package Dependency...` and add it using this URL:

```
https://github.com/aethe/hearth
```
