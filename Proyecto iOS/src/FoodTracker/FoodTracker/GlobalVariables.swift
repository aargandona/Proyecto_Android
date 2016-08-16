//
//  GlobalVariables.swift
//  FoodTracker
//
//  Created by Diego Alejandro Orellana Lopez on 7/29/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import Foundation

class GlobalVariables {
    
    // These are the properties you can store in your singleton
    var meals = [Meal]()
    
    
    // Here is how you would get to it without there being a global collision of variables.
    // , or in other words, it is a globally accessable parameter that is specific to the
    // class.
    class var sharedManager: GlobalVariables {
        struct Static {
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
}