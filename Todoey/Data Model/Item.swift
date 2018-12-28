//
//  Item.swift
//  Todoey
//
//  Created by Bryce Poole on 12/6/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object { //Object is a realm class for realm Objects
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?

    
    //Define what is the parent object of this class.
        //fromType: Category.self - refers to the object type that is the parent of this object
        //property: "items" — refers to the name of the property in the parent class that defines its relationship to this object
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
