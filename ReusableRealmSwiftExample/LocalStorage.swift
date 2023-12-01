//
//  LocalStorage.swift
//  ReusableRealmSwiftExample
//
//  Created by Teddy on 11/24/23.
//

import Foundation
import RealmSwift

//
//  LocalStorage.swift
//  Huskit
//
//  Created by Ming on 2023/01/09.
//

import Foundation
import RealmSwift

enum LocalStorageEror: LocalizedError {
    case realmObjectNil
    case entityObjectNil

    var description: String {
        switch self {
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

    /**
      Realm.UpdatePolicy: 동일한 기본 키를 가진 개체가 이미 존재하는 경우 수행할 작업
      `error`: Object가 Primary Key를 갖지 않는 경우 사용. Exception Throw
      `modify`: 기존 객체에서 새 값과 다른 속성만 덮어씀
      `all`: 기존 객체의 모든 프로퍼티를 변경되지 않은 경우에도 새 값으로 덮어씁니다
     */
    func saveObject<T: Object>(_ object: T, update: Realm.UpdatePolicy = .all) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        try realm.write {
            realm.add(object, update: update)
        }
    }

    /**
      Realm.UpdatePolicy: 동일한 기본 키를 가진 개체가 이미 존재하는 경우 수행할 작업
      `error`: Object가 Primary Key를 갖지 않는 경우 사용. Exception Throw
      `modify`: 기존 객체에서 새 값과 다른 속성만 덮어씀
      `all`: 기존 객체의 모든 프로퍼티를 변경되지 않은 경우에도 새 값으로 덮어씁니다
     */
    func saveObjects<T: Object>(_ objects: [T], update: Realm.UpdatePolicy = .all) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        try realm.write {
            realm.add(objects, update: update)
        }
    }

    func readObject<T: Object>(_ object: T) -> T? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: T.self, forPrimaryKey: object.value(forKeyPath: T.primaryKey()!) as AnyObject)
    }

    func readAllObjectsByType<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> [T]? {
        guard let realm = realm else { return nil }

        if let predicate {
            return Array(realm.objects(type).filter(predicate))
        } else {
            return Array(realm.objects(type))
        }
    }

    func deleteObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        let targetObject = readObject(object)

        guard let targetObject else { throw LocalStorageEror.entityObjectNil }
        
        try realm.write {
            realm.delete(targetObject)
        }
    }

    func deleteObjects<T: Object>(objects: [T]) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        try realm.write {
            realm.delete(objects)
        }
    }

    func deleteAllObjectsByType<T: Object>(_: T.Type) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        try realm.write {
            realm.delete(realm.objects(T.self))
        }
    }

    func deleteAll() throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        try realm.write {
            realm.deleteAll()
        }
    }

    func updateObject<T: Object>(_ object: T) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        let result = realm.object(ofType: T.self, forPrimaryKey: object.value(forKeyPath: T.primaryKey()!) as AnyObject)

        if let object = result {
            try? realm.write {
                realm.add(object)
            }
        } else {
            throw LocalStorageEror.entityObjectNil
        }
    }

    func updateObjects<T: Object>(_ objects: [T]) throws {
        guard let realm = realm else { throw LocalStorageEror.realmObjectNil }

        let primaryKeys = objects.map { element -> Any in
            element.value(forKey: T.primaryKey()!) as Any
        }

        let response = realm.objects(T.self).filter("%@ IN %@", T.primaryKey()!, primaryKeys)

        if response.count != objects.count {
            throw LocalStorageEror.entityObjectNil
        }

        try? realm.write {
            realm.add(objects)
        }
    }
}
