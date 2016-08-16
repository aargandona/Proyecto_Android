//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 5/26/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//  See LICENSE.txt for this sample’s licensing information.
//

import UIKit


class Meal {
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var latitud: Double
    var longitud: Double
    var id: String
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, latitud: Double, longitud: Double, id: String) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        
        self.latitud = latitud
        self.longitud = longitud
        
        self.id = id;
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }
    }
}