## Semver

[![Github CI Status](https://github.com/ddddxxx/Semver/workflows/CI/badge.svg)](https://github.com/ddddxxx/Semver/actions)
![supports](https://img.shields.io/badge/supports-Swift_PM%20%7C%20Carthage-brightgreen.svg)
![platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)

Semver is a Swift implementation of the [Semantic Versioning](http://semver.org/).

## Requirements

- Swift 5.0+

## Usage

### Quick Start

```swift
import Semver

// A leading "v" character is ignored.
let version = Semver("v1.3.8-rc.1+build.3")!

version > Semver("1.0.2+39f1d74")! // true
```

### Equality

The `Equatable` conformance respect Semver semantic equality and ignore build metadata. This also affect `Comparable` and `Hashable`.

You can use `===` and `!==` to take build metadata into account.

```swift
let v1 = Version("1.0.0+100")!
let v2 = Version("1.0.0+200")!

v1 == v2 // true
v1 <= v2 // true
v1.hashValue == v2.hashValue // true
Set([v1, v2]).count == 1 // ❗️true

v1 === v2 // false
v1 !== v2 // true
```

### Validity Check

The member wise initializer `Semver.init(major:minor:patch:prerelease:buildMetadata:)` doesn't perform validity checks on its fields. It's possible to form an invalid version. You can manually validate a version using `Semver.isValid`.

```swift
let version = Semver(major: 0, minor: 0, patch: -1) // invalid version 0.0.-1
version.isValid // false
```

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add the project to your `Package.swift` file:

```swift
package.dependencies += [
    .package(url: "https://github.com/ddddxxx/Semver", .upToNextMinor("0.2.0"))
]
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the project to your `Cartfile`:

```
github "ddddxxx/Semver"
```

## License

Semver is available under the MIT license. See the [LICENSE file](LICENSE).
