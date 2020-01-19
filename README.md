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
💬 2020-01-19 17:39:05 +01:00 @AppDelegate:22: Hello, World!
```

## Installation

### Swift Package Manager

To integrate Hearth into your Xcode project using Swift Package Manager, go to `File > Swift Packages > Add Package Dependency...` and add it using this URL:

```
https://github.com/aethe/hearth
```

### Carthage

To integrate Hearth into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "aethe/hearth"
```

Then, run `carthage update` to build the framework and drag the built `Hearth.framework` into your Xcode project.
