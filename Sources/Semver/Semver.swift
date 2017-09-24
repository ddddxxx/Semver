//
//  Semver.swift
//  Semver
//
//  Created by 邓翔 on 2017/5/2.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

public struct Semver {
    
    public let (major, minor, patch): (Int, Int, Int)
    public let prerelease: [String]
    public let metadata: String?
    
    public init(major: Int, minor: Int, patch: Int, prerelease: [String] = [], metadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.metadata = metadata
    }
}

extension Semver: Equatable {
    
    // FIXME: Swift semantic equality or SemVer semantic equality
    public static func ==(lhs: Semver, rhs: Semver) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.prerelease == rhs.prerelease
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
        
        for (lpr, rpr) in zip(lhs.prerelease, rhs.prerelease) {
            if lpr == rpr {
                continue
            }
            // FIXME: big integer
            switch (Int(lpr), Int(rpr)) {
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case let (l?, r?):
                return l < r
            case (nil, nil):
                return lpr < rpr
            }
        }
        
        return lhs.prerelease.count < rhs.prerelease.count
    }
}

extension Semver: LosslessStringConvertible {
    
    private static let semverRegexPattern = "^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([\\da-zA-Z\\-]+(?:\\.[\\da-zA-Z\\-]+)*))?(?:\\+([\\da-zA-Z\\-]+(?:\\.[\\da-zA-Z\\-]+)*))?$"
    private static let semverRegex = try! NSRegularExpression(pattern: semverRegexPattern)
    
    public init?(_ description:String) {
        guard let match = Semver.semverRegex.firstMatch(in: description) else {
            return nil
        }
        guard let major = Int(description[match.range(at: 1)]!),
            let minor = Int(description[match.range(at: 2)]!),
            let patch = Int(description[match.range(at: 3)]!) else {
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
        if let metadata = metadata {
            result += "+" + metadata
        }
        return result
    }
}

// MARK: - Utilities

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
