//
//  Category.swift
//  Todoey
//
//  Created by Bryce Poole on 12/6/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    
    //Define forward relationship for our database. Creates a List to hold the objects that can be children of this class.
    let items = List<Item>()
}
