//
//  MealDB.swift
//  FoodTracker
//
//  Created by jhonny on 7/24/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import Foundation
import RealmSwift

class MealDB: Object {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var photo: NSData? = nil
    dynamic var rating = 0
    dynamic var latitud: Double = 0
    dynamic var longitud: Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
