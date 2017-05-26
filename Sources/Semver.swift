//
//  Semver.swift
//  Semver
//
//  Created by 邓翔 on 2017/5/2.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

public enum SemverParseError: Error {
    case emptyString
    case invalidCharacterInNormalVersion
    case invalidCharacterInPreReleaseVersion
    case invalidCharacterInMetadata
    case parseNormalVersionFailed
    case parsePreReleaseVersionFailed
}

public struct Semver {
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let preRelease: PreRelease?
    public let metadata: String?
    
    public init(major: Int, minor: Int, patch: Int, preRelease: PreRelease? = nil, metadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.preRelease = preRelease
        self.metadata = metadata
    }
    
    public init(_ string:String) throws {
        if string.isEmpty {
            throw SemverParseError.emptyString
        }
        
        let scanner = Scanner(string: string)
        var normalVersionString: NSString? = nil
        guard scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "-+"), into: &normalVersionString) else {
            throw SemverParseError.parseNormalVersionFailed
        }
        
        let normalVersionComponents = try parseNormalVersionString(normalVersionString! as String)
        
        major = normalVersionComponents[0]
        minor = normalVersionComponents[1]
        patch = normalVersionComponents[2]
        
        if scanner.isAtEnd {
            preRelease = nil
            metadata = nil
            return
        }
        if string[string.index(string.startIndex, offsetBy: scanner.scanLocation)] == "-" {
            scanner.scanLocation += 1
            var preReleaseInfo:NSString? = nil
            guard scanner.scanUpTo("+", into: &preReleaseInfo) else {
                throw SemverParseError.parsePreReleaseVersionFailed
            }
            preRelease = try PreRelease(preReleaseInfo! as String)
        } else {
            preRelease = nil
        }
        
        if scanner.isAtEnd {
            metadata = nil
            return
        }
        let index = string.index(string.startIndex, offsetBy: scanner.scanLocation + 1)
        let meta = string.substring(from: index)
        for component in meta.components(separatedBy: ".") {
            guard !component.isEmpty, component.rangeOfCharacter(from: CharacterSet.semverAllowed.inverted) == nil else {
                throw SemverParseError.invalidCharacterInMetadata
            }
        }
        self.metadata = meta
        return
    }
}

// MARK: - Nested Types

extension Semver {
    
    public enum PreRelease {
        case alpha(Int?)
        case beta(Int?)
        case arbitrary([Identifier])
    }
}

extension Semver.PreRelease {
    
    public enum Identifier {
        case number(Int)
        case string(String)
    }
}

extension Semver.PreRelease {
    
    public init(_ components: [String]) throws {
        if components.isEmpty {
            throw SemverParseError.parsePreReleaseVersionFailed
        } else if components.count == 1 {
            switch components[0] {
            case "alpha":
                self = .alpha(nil)
            case "beta":
                self = .beta(nil)
            default:
                break
            }
        } else if components.count == 2 {
            switch (components[0], Int(components[1])) {
            case ("alpha", let v?):
                self = .alpha(v)
            case ("beta", let v?):
                self = .beta(v)
            default:
                break
            }
        }
        
        let arr = try components.map { (str) -> Semver.PreRelease.Identifier in
            guard !str.isEmpty, str.rangeOfCharacter(from: CharacterSet.semverAllowed.inverted) == nil else {
                throw SemverParseError.invalidCharacterInMetadata
            }
            
            if let num = Int(str) {
                return .number(num)
            }
            return .string(str)
        }
        
        self = .arbitrary(arr)
    }
    
    public init(_ string: String) throws {
        try self.init(string.components(separatedBy: "."))
    }
}

// MARK: - Comparision

extension Semver: Comparable {
    
    public static func ==(lhs: Semver, rhs: Semver) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.preRelease == rhs.preRelease
    }
    
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
        
        switch (lhs.preRelease, rhs.preRelease) {
        case let (left?, right?):
            return left < right
        case (_, nil):
            return true
        default:
            return false
        }
    }
}

extension Semver.PreRelease: Comparable {
    
    public static func ==(lhs: Semver.PreRelease, rhs: Semver.PreRelease) -> Bool {
        switch (lhs, rhs) {
        case let (.alpha(left), .alpha(right)):
            return left == right
        case let (.beta(left), .beta(right)):
            return left == right
        case let (.arbitrary(left), .arbitrary(right)):
            return left == right
        default:
            return false
        }
    }
    
    public static func <(lhs: Semver.PreRelease, rhs: Semver.PreRelease) -> Bool {
        let lArray = lhs.array
        let rArray = rhs.array
        
        for (left, right) in zip(lArray, rArray) {
            if left == right {
                continue
            }
            return left < right
        }
        
        return lArray.count < rArray.count
    }
    
    private var array: [Identifier] {
        switch self {
        case .alpha(nil):
            return [.string("alpha")]
        case let .alpha(v?):
            return [.string("alpha"), .number(v)]
        case .beta(nil):
            return [.string("beta")]
        case let .beta(v?):
            return [.string("beta"), .number(v)]
        case let .arbitrary(arr):
            return arr
        }
    }
}

extension Semver.PreRelease.Identifier: Comparable {
    
    public static func ==(lhs: Semver.PreRelease.Identifier, rhs: Semver.PreRelease.Identifier) -> Bool {
        switch (lhs, rhs) {
        case let (.number(left), .number(right)):
            return left == right
        case let (.string(left), .string(right)):
            return left == right
        default:
            return false
        }
    }
    
    
    public static func <(lhs: Semver.PreRelease.Identifier, rhs: Semver.PreRelease.Identifier) -> Bool {
        switch (lhs, rhs) {
        case (.number, .string):
            return true
        case (.string, .number):
            return false
        case let (.number(left), .number(right)):
            return left < right
        case let (.string(left), .string(right)):
            return left < right
        }
    }
}

// MARK: - String Conversion

extension Semver: CustomStringConvertible {
    
    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if let preRelease = preRelease {
            result += "-\(preRelease)"
        }
        if let metadata = metadata {
            result += "+\(metadata)"
        }
        return result
    }
}

extension Semver.PreRelease: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .alpha(x?):
            return "alpha.\(x)"
        case .alpha(nil):
            return "alpha"
        case let .beta(x?):
            return "beta.\(x)"
        case .beta(nil):
            return "beta"
        case let .arbitrary(ids):
            return ids.map({ $0.description }).joined(separator: ".")
        }
    }
}

extension Semver.PreRelease.Identifier: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .number(n):
            return "\(n)"
        case let .string(s):
            return s
        }
    }
}

// MARK: -

private func parseNormalVersionString(_ string:String) throws -> [Int] {
    let components = string.components(separatedBy: ".")
    
    let result = try components.map { (str) -> Int in
        guard let num = Int(str) else {
            throw SemverParseError.invalidCharacterInNormalVersion
        }
        return num
    }
    
    guard result.count == 3 else {
        throw SemverParseError.parseNormalVersionFailed
    }
    
    return result
}

extension CharacterSet {
    
    private static var englishLetters: CharacterSet {
        let lowercase = CharacterSet(charactersIn: "a"..."z")
        let uppercase = CharacterSet(charactersIn: "A"..."Z")
        return lowercase.union(uppercase)
    }
    
    fileprivate static var semverAllowed: CharacterSet {
        let hyphen = CharacterSet(charactersIn: "-.")
        return hyphen.union(.englishLetters).union(.decimalDigits)
    }
}
