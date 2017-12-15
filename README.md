## Semver

[![Build Status](https://travis-ci.org/ddddxxx/Semver.svg?branch=master)](https://travis-ci.org/ddddxxx/Semver)
![supports](https://img.shields.io/badge/supports-Carthage%20%7C%20Swift_PM-brightgreen.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)

Semver is a Swift implementation of the [Semantic Versioning](http://semver.org/).

## Requirements

- macOS 10.9+ / iOS 8.0+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9+
- Swift 4.0+

## Example

```swift
import Semver

// A leading "v" character is ignored.
let version = Semver("v1.3.8-rc.1+build.3")!

version > Semver("1.0.2+39f1d74")! // true
```

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add the project to your `Cartfile`:

```
github "ddddxxx/Semver"
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add the project to your `Package.swift` file:

```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/ddddxxx/Semver")
    ]
)
```

### [CocoaPods](https://cocoapods.org)

Add the project to your `Podfile`:

```
pod 'Semver2'
```

## License

Semver is available under the MIT license. See the [LICENSE file](LICENSE).
