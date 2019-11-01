## Semver

[![Github CI Status](https://github.com/ddddxxx/Semver/workflows/CI/badge.svg)](https://github.com/ddddxxx/Semver/actions)
![supports](https://img.shields.io/badge/supports-Swift_PM%20%7C%20Carthage-brightgreen.svg)
![platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)

Semver is a Swift implementation of the [Semantic Versioning](http://semver.org/).

## Requirements

- Swift 5.0+

## Example

```swift
import Semver

// A leading "v" character is ignored.
let version = Semver("v1.3.8-rc.1+build.3")!

version > Semver("1.0.2+39f1d74")! // true
```

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add the project to your `Package.swift` file:

```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/ddddxxx/Semver")
    ]
)
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the project to your `Cartfile`:

```
github "ddddxxx/Semver"
```

### [CocoaPods](https://cocoapods.org)

Add the project to your `Podfile`:

```
pod 'Semver2'
```

## License

Semver is available under the MIT license. See the [LICENSE file](LICENSE).
