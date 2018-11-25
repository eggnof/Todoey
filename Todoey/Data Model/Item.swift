//
//  Title.swift
//  Todoey
//
//  Created by Bryce Poole on 11/24/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import Foundation

//In order for a class to adopt the Encodable protocol all of its data types must be standard data types (Strings, Ints, Floats ect), no custom dataTypes!
class Item : Codable { //<-- Codable means an object conforms to both encoded and decodeed
    
    var title : String = ""
    var done : Bool = false
    
}
