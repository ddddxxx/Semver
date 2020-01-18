//
//  SemverTests.swift
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

import XCTest
@testable import Semver

class SemverTests: XCTestCase {
    
    func testFromString() {
        for str in badVersionStrings {
            XCTAssertNil(Semver(str), "should not create Semver from '\(str)'")
        }
    }
    
    func testValidate() {
        func randArr<Element>(_ maxCount: Int, from source: [Element]) -> [Element] {
            (0..<Int.random(in: 0..<maxCount)).map { _ in source.randomElement()! }
        }
        for _ in 0..<100 {
            let ver = Semver(major: goodVersionNumbers.randomElement()!,
                             minor: goodVersionNumbers.randomElement()!,
                             patch: goodVersionNumbers.randomElement()!,
                             prerelease: randArr(5, from: goodSemverIdentifiers),
                             buildMetadata: randArr(5, from: goodSemverIdentifiers + badPrereleaseIdentifiers))
            XCTAssert(ver.isValid, "'\(ver)' should be valid")
        }
        for badVersionNumber in badVersionNumbers {
            XCTAssertFalse(Semver(major: badVersionNumber, minor: 0, patch: 0).isValid)
            XCTAssertFalse(Semver(major: 0, minor: badVersionNumber, patch: 0).isValid)
            XCTAssertFalse(Semver(major: 0, minor: 0, patch: badVersionNumber).isValid)
        }
        for badPrereleaseIdentifier in badPrereleaseIdentifiers {
            XCTAssertFalse(Semver(major: 0, minor: 0, patch: 0, prerelease: [badPrereleaseIdentifier]).isValid)
        }
        for badSemverIdentifier in badSemverIdentifiers {
            XCTAssertFalse(Semver(major: 0, minor: 0, patch: 0, prerelease: [badSemverIdentifier]).isValid)
            XCTAssertFalse(Semver(major: 0, minor: 0, patch: 0, buildMetadata: [badSemverIdentifier]).isValid)
        }
    }
    
    func testVersionEquality() {
        for (left, right) in notEqualVersionPairs {
            XCTAssertNotEqual(left, right)
            XCTAssertNotEqual(left.hashValue, right.hashValue)
            XCTAssertFalse(left === right)
            XCTAssertTrue(left !== right)
        }
        for (left, right) in swiftSemanticNotEqualVersionPairs {
            XCTAssertEqual(left, right)
            XCTAssertEqual(left.hashValue, right.hashValue)
            XCTAssertFalse(left === right)
            XCTAssertTrue(left !== right)
        }
        for (left, right) in equalVersionPairs {
            XCTAssertEqual(left, right)
            XCTAssertEqual(left.hashValue, right.hashValue)
            XCTAssertTrue(left === right)
            XCTAssertFalse(left !== right)
        }
    }
    
    func testVersionComparison() {
        let preSortedVersions = preSortedVersionStrings.map { Semver($0)! }
        for (v1, v2) in zip(preSortedVersions, preSortedVersions.dropFirst()) {
            XCTAssertLessThan(v1, v2)
        }
        let resorted = preSortedVersions.shuffled().sorted()
        XCTAssertEqual(preSortedVersions, resorted, "versions not sorted properly!")
    }
    
    static var allTests = [
        ("testFromString", testFromString),
        ("testValidate", testValidate),
        ("testVersionEquality", testVersionEquality),
        ("testVersionComparison", testVersionComparison),
    ]
}

let badVersionStrings = [
    // no enough elements
    "",
    "1", ".1", "1.", ".",
    "1.1", "1.1.", "1..1", ".1.1", "1..", "..",
    "1.1-alpha", "1.1.-alpha", "1.1.1.-alpha",
    "1.1+42", "1.1.+42",
    "1.1.1-alpha..0",
    "1.1.1+a..1",
    // too many elements
    "1.1.1.1", "1.1.1.1.1",
    // empty components
    "1.1.1-", "1.1.1+",
    "1.1.1-+123", "1.1.1-beta+",
    // leading zeroes
    "01.1.1", "001.1.1", "1.01.1", "1.01.1", "1.1.01", "1.1.001",
    "1.1.1-01", "1.1.1-001",
    "1.1.1-alpha.01", "1.1.1-alpha.001",
    // invalid character
    "-1.1.1", "1.-1.1", "1.1.-1",
    "a.b.c", "1.a.b", "1.1.a", "1.a.1", "a.1.1",
    "*.1.1", "1.#.1", "1.1.^", "1_000_000.1.1",
    "1.1.1 ", "1.1.1- 1", "1.1.1-a ",
    "1.1.1-*", "1.1.1-alpha.#", "1.1.1-1.^.1",
    "1.1.1+h*23", "1.1.1-(1)", "1.1.1-1_000_000",
    "1.2.3-naïve", "1.2.3-蛤.foo", "1.2.3+😄.foo",
    "1.1.1-alpha.0+a#1", "1.1.1+ ", "1.1.1+hello world",
    // version number too large
    // FIXME: is this an invalid version?
    "9223372036854775808.0.0",
]

let goodVersionNumbers = [0, 1, 2, 42, 99999, .max, Int.random(in: 0..<9999)]
let badVersionNumbers = [-1, -2, -10086, Int.random(in: -9999..<0)]
let goodSemverIdentifiers = ["0", "0a", "0-", "42", "999999", "foo", "-bar-", "-", "-1"]
let badPrereleaseIdentifiers = ["01", "00000001", "00000000"]
let badSemverIdentifiers = ["", " ", "1_000_000", "(42)", "foo*", "#123", "é", "噫", "🤔"]

let notEqualVersionPairs: [(Semver, Semver)] = [
    ("3.0.0",           "3.0.0-alpha.0"),
    ("3.0.0",           "3.0.1"),
    ("3.0.0",           "3.1.0"),
    ("4.0.0",           "3.0.0"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.5"),
    ("3.0.0-alpha.0",   "3.0.0-beta.0"),
    ("3.0.0-alpha.0",   "3.0.0-boo"),
    ("3.0.0",           "3.1.1"),
    ("3.0.0-alpha.0",   "3.0.1-alpha.1")
].map { (Semver($0)!, Semver($1)!) }

let swiftSemanticNotEqualVersionPairs: [(Semver, Semver)] = [
    ("3.0.0",           "3.0.0+metadata"),
    ("3.0.1",           "3.0.1+metadata"),
    ("3.1.0",           "3.1.0+metadata"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.0+metadata"),
    ("3.0.0-beta.0",    "3.0.0-beta.0+metadata"),
    ("3.0.0-boo",       "3.0.0-boo+metadata"),
    ("3.0.0-alpha.0",   "v3.0.0-alpha.0+metadata"),
].map { (Semver($0)!, Semver($1)!) }

let equalVersionPairs: [(Semver, Semver)] = [
    ("3.0.0",           "3.0.0"),
    ("3.0.1",           "3.0.1"),
    ("3.1.0",           "3.1.0"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.0"),
    ("3.0.0-beta.0",    "3.0.0-beta.0"),
    ("3.0.0-boo",       "3.0.0-boo"),
    ("3.0.0",           "v3.0.0"),
].map { (Semver($0)!, Semver($1)!) }

let preSortedVersionStrings = [
    "0.0.1-alpha.0",
    "0.0.1",
    "0.0.2-alpha",
    "0.0.2-alpha.0",
    "0.0.2-alpha.0.1",
    "0.0.2",
    "0.0.3-aaa",
    "0.0.3-aaa.2",
    "0.0.3-aaa.11",
    "0.0.3-alpha.1",
    "0.1.0-alpha.3",
    "0.1.0-beta.2",
    "0.1.0-beta.3",
    "0.1.0-rc.1",
    "0.1.0",
    "1.0.0-1",
    "1.0.0-3",
    "1.0.0-11",
    "1.0.0-alpha.0",
    "1.0.0",
    "1.0.1",
    "1.1.0",
    "1.2.0",
    "2.0.0-1",
    "2.0.0--1",
    "2.0.0--2",
    "2.0.0-alpha.0"
]
