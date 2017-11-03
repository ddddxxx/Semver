//
//  SemverTests.swift
//
//  This file is part of Semver.
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
    
    func testParserErrors() {
        for str in badVersionStrings {
            XCTAssertNil(Semver(str), "'\(str)' should be nil")
        }
    }
    
    func testVersionEquality() {
        for (left, right) in notEqualVersionPairs {
            XCTAssertNotEqual(Semver(left)!, Semver(right)!, "'\(left)' and '\(right)' should not be equal")
        }
        
        for (left, right) in equalVersionPairs {
            XCTAssertEqual(Semver(left)!, Semver(right)!, "'\(left)' and '\(right)' should be equal")
        }
    }
    
    func testVersionComparison() {
        let sortedVersions = versionStringsToBeSort.map { Semver($0)! }.sorted()
        let preSortedVersions = preSortedVersionStrings.map { Semver($0)! }
        
        XCTAssertEqual(sortedVersions, preSortedVersions, "Versions not sorted properly!")
    }
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
    // invalid character
    "-1.1.1", "1.-1.1", "1.1.-1",
    "a.b.c", "1.a.b", "1.1.a", "1.a.1", "a.1.1",
    "*.1.1", "1.#.1", "1.1.^",
    "1.1.1-*", "1.1.1-alpha.#", "1.1.1-1.^.1",
    "1.1.1+h*23", "1.1.1-alpha.0+a#1",
    "1.2.3-蛤.foo", "1.2.3+😄.foo",
    // version number too large
    // FIXME: is this an invalid version?
    "9223372036854775808.0.0",
]

let notEqualVersionPairs: [(String, String)] = [
    ("3.0.0",           "3.0.0-alpha.0"),
    ("3.0.0",           "3.0.1"),
    ("3.0.0",           "3.1.0"),
    ("4.0.0",           "3.0.0"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.5"),
    ("3.0.0-alpha.0",   "3.0.0-beta.0"),
    ("3.0.0-alpha.0",   "3.0.0-boo"),
    ("3.0.0",           "3.1.1"),
    ("3.0.0-alpha.0",   "3.0.1-alpha.1")
]

let equalVersionPairs: [(String, String)] = [
    ("3.0.0",           "3.0.0"),
    ("3.0.1",           "3.0.1"),
    ("3.1.0",           "3.1.0"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.0"),
    ("3.0.0-beta.0",    "3.0.0-beta.0"),
    ("3.0.0-boo",       "3.0.0-boo"),
    ("3.0.0",           "3.0.0+metadata"),
    ("3.0.1",           "3.0.1+metadata"),
    ("3.1.0",           "3.1.0+metadata"),
    ("3.0.0-alpha.0",   "3.0.0-alpha.0+metadata"),
    ("3.0.0-beta.0",    "3.0.0-beta.0+metadata"),
    ("3.0.0-boo",       "3.0.0-boo+metadata"),
    ("3.0.0",           "v3.0.0"),
    ("3.0.0-alpha.0",   "v3.0.0-alpha.0+metadata"),
]

let versionStringsToBeSort = [
    "0.1.0-rc.1",
    "0.0.1-alpha.0",
    "0.0.1",
    "0.0.2-alpha.0",
    "0.0.2-alpha.0.1",
    "0.0.2",
    "0.0.3-aaa.11",
    "0.0.3-aaa.2",
    "0.0.3-aaa",
    "0.0.3-alpha.1",
    "0.1.0-beta.2",
    "0.1.0-beta.3",
    "0.1.0",
    "1.0.1",
    "1.0.0-alpha.0",
    "1.0.0",
    "0.0.2-alpha",
    "1.1.0",
    "0.1.0-alpha.3",
    "1.2.0",
    "2.0.0-alpha.0",
    "2.0.0-1",
    "1.0.0-1",
    "1.0.0-3",
    "1.0.0-11",
]

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
    "2.0.0-alpha.0"
]
