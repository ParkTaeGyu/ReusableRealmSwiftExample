//
//  ReusableRealmSwiftExampleTests.swift
//  ReusableRealmSwiftExampleTests
//
//  Created by Teddy on 11/24/23.
//

@testable import ReusableRealmSwiftExample
import XCTest

final class ReusableRealmSwiftExampleTests: XCTestCase {
    var localStorage = LocalStorage.shared

    func testLocalStorageSaveObject() throws {
        let testEntity1 = TestEntity(id: 1)
        let testEntity2 = TestEntity(id: 1)

        try localStorage.saveObject(testEntity1)
        try localStorage.saveObject(testEntity2)

        let readObjects = localStorage.readAllObjectsByType(TestEntity.self)

        XCTAssertEqual(readObjects?.count, 1)
    }

    func testLocalStorageDeleteObject() throws {
        let testEntity1 = TestEntity(id: 1)
        let testEntity2 = TestEntity(id: 1)

        try localStorage.saveObject(testEntity1)

        try localStorage.deleteObject(testEntity2)

        let readObjects = localStorage.readAllObjectsByType(TestEntity.self)

        XCTAssertEqual(readObjects?.count, 0)
    }

    func testLocalStorageReadObject() throws {
        let testEntity1 = TestEntity(id: 1)
        let testEntity2 = TestEntity(id: 2)

        let readObject1 = localStorage.readObject(testEntity1)
        let readObject2 = localStorage.readObject(testEntity2)
        let readObjects = localStorage.readAllObjectsByType(TestEntity.self)

        XCTAssertEqual(readObject1, testEntity1)
        XCTAssertEqual(readObject2, testEntity2)
        XCTAssertEqual(readObjects?.count, 2)
    }
}
