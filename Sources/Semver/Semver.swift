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

public struct Semver {
    
    public let (major, minor, patch): (Int, Int, Int)
    public let prerelease: [String]
    public let metadata: String?
    
    public init(major: Int, minor: Int, patch: Int, prerelease: [String] = [], metadata: String? = nil) {
        // FIXME: deal with invalid arguments
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.metadata = metadata
    }
}

extension Semver: Equatable {
    
    // TODO: Swift semantic equality or Semver semantic equality
    public static func ==(lhs: Semver, rhs: Semver) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.prerelease == rhs.prerelease
    }
}

extension Semver: Hashable {
    
    public var hashValue: Int {
        var seed = 0
        hashCombine(seed: &seed, value: major)
        hashCombine(seed: &seed, value: minor)
        hashCombine(seed: &seed, value: patch)
        seed = prerelease.reduce(into: seed, hashCombine)
        if let metadata = metadata {
            hashCombine(seed: &seed, value: metadata)
        }
        return seed
    }
}
    
extension Semver: Comparable {
    
    // TODO: Swift semantic comparability or Semver semantic comparability
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
    
    private static let semverRegexPattern = "^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([\\da-zA-Z\\-]+(?:\\.[\\da-zA-Z\\-]+)*))?$"
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
        metadata = description[match.range(at: 5)]
    }
    
    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if !prerelease.isEmpty {
            result += "-" + prerelease.joined(separator: ".")
        }
        if let metadata = metadata,
            !metadata.isEmpty {
            result += "+" + metadata
        }
        return result
    }
}

extension Semver: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        guard let v = Semver(value) else {
            fatalError("failed to initialize `Semver` using string literal \"\(value)\".")
        }
        self = v
    }
}

// MARK: - Utilities

private func hashCombine<T: Hashable>(seed: inout Int, value: T) {
    let us = UInt(bitPattern: seed)
    let uv = UInt(bitPattern: value.hashValue)
    let mul: UInt = 0x9ddfea08eb382d69
    var a = (uv ^ us) &* mul
    a ^= (a >> 47)
    var b = (us ^ a) &* mul
    b ^= (b >> 47)
    let result = b &* mul
    seed = Int(bitPattern: result)
}

extension String {
    
    fileprivate subscript(nsRange: NSRange) -> String? {
        guard let r = Range(nsRange, in: self) else {
            return nil
        }
        return String(self[r])
    }
}

extension NSRegularExpression {
    
    fileprivate func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return matches(in: string, options: options, range: r)
    }
    
    fileprivate func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = []) -> NSTextCheckingResult? {
        let r = NSRange(string.startIndex..<string.endIndex, in: string)
        return firstMatch(in: string, options: options, range: r)
    }
}
