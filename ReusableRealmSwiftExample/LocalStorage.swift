//
//  LocalStorage.swift
//  ReusableRealmSwiftExample
//
//  Created by Teddy on 11/24/23.
//

import Foundation
import RealmSwift

struct LocalStorageError: Error {
    enum ErorCode: Int {
        case realmObjectNil
        case entityObjectNil
    }

    let errorCode: ErorCode

    var description: String {
        switch errorCode {
        case .realmObjectNil:
            return " ⚠️ Error Realm Object is nil"
        case .entityObjectNil:
            return " ⚠️ Error Cannot find Realm Object By Type"
        }
    }
}

class LocalStorage {
    static let shared = LocalStorage()

    private init() {}

    private var realm: Realm? {
        return try? Realm()
    }

    func saveObject<T: Object>(_ object: T, update: Realm.UpdatePolicy) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.add(object, update: update)
        }
    }

    func saveObjects<T: Object>(_ objects: [T], update: Realm.UpdatePolicy) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.add(objects, update: update)
        }
    }

    func readObject<T: Object>(_ type: T.Type) -> T? {
        guard let realm = realm else { return nil }
        let results = realm.objects(type)
        return results.first
    }

    func readObjects<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> [T]? {
        guard let realm = realm else { return nil }

        if let predicate {
            return Array(realm.objects(type).filter(predicate))
        } else {
            return Array(realm.objects(type))
        }
    }

    func deleteObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.delete(object)
        }
    }

    func deleteObjects<T: Object>(_: T.Type, _ objects: [T]) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.delete(objects)
        }
    }

    func deleteAllObjectsByType<T: Object>(_: T.Type) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.delete(realm.objects(T.self))
        }
    }

    func deleteAll() throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        try realm.write {
            realm.deleteAll()
        }
    }

    func updateObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        let result = realm.object(ofType: T.self, forPrimaryKey: object.value(forKeyPath: T.primaryKey()!) as AnyObject)

        if let object = result {
            try? realm.write {
                realm.add(object, update: .all)
            }
        } else {
            throw LocalStorageError(errorCode: .entityObjectNil)
        }
    }

    func updateObjects<T: Object>(_ objects: [T]) throws {
        guard let realm = realm else { throw LocalStorageError(errorCode: .realmObjectNil) }

        let primaryKeys = objects.map { element -> Any in
            element.value(forKey: T.primaryKey()!) as Any
        }

        let response = realm.objects(T.self).filter("%@ IN %@", T.primaryKey()!, primaryKeys)

        if response.count != objects.count {
            throw LocalStorageError(errorCode: .entityObjectNil)
        }

        try? realm.write {
            realm.add(objects, update: .all)
        }
    }
}
