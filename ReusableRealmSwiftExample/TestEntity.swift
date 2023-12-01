//
//  TestEntity.swift
//  ReusableRealmSwiftExample
//
//  Created by Teddy on 11/30/23.
//

import RealmSwift

class TestEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: Int
    
    override init() {
        super.init()
    }
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
}



