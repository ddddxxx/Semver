//
//  Semver.swift
//
//  This file is part of Semver. - https://github.com/ddddxxx/Semver
//  Copyright (c) 2017 Xander Deng
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//

import Foundation

/// Represents a version conforming to [Semantic Versioning 2.0.0](http://semver.org).
public struct Semver {
    
    public let major: Int
    
    public let minor: Int
    
    public let patch: Int
    
    public let prerelease: [String]
    
    public let buildMetadata: [String]
    
    public init(major: Int, minor: Int, patch: Int, prerelease: [String] = [], buildMetadata: [String] = []) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.buildMetadata = buildMetadata
    }
    
    public var prereleaseString: String? {
        return prerelease.isEmpty ? nil : prerelease.joined(separator: ".")
    }
    
    public var buildMetadataString: String? {
        return buildMetadata.isEmpty ? nil : buildMetadata.joined(separator: ".")
    }
    
    public var isPrerelease: Bool {
        return !prerelease.isEmpty
    }
}

extension Semver: Equatable {
    
    /// Semver semantic equality. Build metadata is ignored.
    public static func ==(lhs: Semver, rhs: Semver) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.prerelease == rhs.prerelease
    }
    
    /// Swift semantic equality.
    public static func ===(lhs: Semver, rhs: Semver) -> Bool {
        return (lhs == rhs) && (lhs.buildMetadata == rhs.buildMetadata)
    }
    
    /// Swift semantic unequality.
    public static func !==(lhs: Semver, rhs: Semver) -> Bool {
        return !(lhs === rhs)
    }
}

extension Semver: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(prerelease)
    }
}
    
extension Semver: Comparable {
    
    public static func <(lhs: Semver, rhs: Semver) -> Bool {
        guard lhs.major == rhs.major else {
            return lhs.major < rhs.major
        }

        guard lhs.minor == rhs.minor else {
            return lhs.minor < rhs.minor
        }

        guard lhs.patch == rhs.patch else {
            return lhs.patch < rhs.patch
        }
        
        guard lhs.prerelease.isEmpty == rhs.prerelease.isEmpty else {
            return rhs.prerelease.isEmpty
        }
        
        return lhs.prerelease.lexicographicallyPrecedes(rhs.prerelease) { lpr, rpr in
            if lpr == rpr { return false }
            // FIXME: deal with big integers
            switch (UInt(lpr), UInt(rpr)) {
            case let (l?, r?):  return l < r
            case (_?, nil):     return true
            case (nil, _?):     return false
            case (nil, nil):    return lpr < rpr
            }
        }
    }
}

extension Semver: LosslessStringConvertible {
    
    private static let semverRegexPattern = #"^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([\da-zA-Z\-]+(?:\.[\da-zA-Z\-]+)*))?$"#
    private static let semverRegex = try! NSRegularExpression(pattern: semverRegexPattern)
    
    public init?(_ description:String) {
        guard let match = Semver.semverRegex.firstMatch(in: description) else {
            return nil
        }
        guard let major = Int(description[match.range(at: 1)]!),
            let minor = Int(description[match.range(at: 2)]!),
            let patch = Int(description[match.range(at: 3)]!) else {
                // version number too large
                return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
        prerelease = description[match.range(at: 4)]?.components(separatedBy: ".") ?? []
        buildMetadata = description[match.range(at: 5)]?.components(separatedBy: ".") ?? []
    }
    
    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if !prerelease.isEmpty {
            result += "-" + prerelease.joined(separator: ".")
        }
        if !buildMetadata.isEmpty {
            result += "+" + buildMetadata.joined(separator: ".")
        }
        return result
    }
}

extension Semver: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        guard let v = Semver(value) else {
            preconditionFailure("failed to initialize `Semver` using string literal '\(value)'.")
        }
        self = v
    }
}

// MARK: Foundation Extensions

extension Bundle {
    
    /// Use `CFBundleShortVersionString` key
    public var semanticVersion: Semver? {
        return (infoDictionary?["CFBundleShortVersionString"] as? String).flatMap(Semver.init(_:))
    }
}

extension ProcessInfo {
    
    @available(macOS 10.10, iOS 8.0, tvOS 9.0, watchOS 2.0, *)
    var operatingSystemSemanticVersion: Semver {
        let v = operatingSystemVersion
        return Semver(major: v.majorVersion, minor: v.minorVersion, patch: v.patchVersion)
    }
}

// MARK: - Utilities

private extension String {
    
    subscript(nsRange: NSRange) -> String? {
        guard let r = Range(nsRange, in: self) else {
            return nil
        }
        return String(self[r])
    }
}

private extension NSRegularExpression {
    
    func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return matches(in: string, options: options, range: r)
    }
    
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = []) -> NSTextCheckingResult? {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return firstMatch(in: string, options: options, range: r)
    }
}
