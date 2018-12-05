//
//  Data.swift
//  Todoey
//
//  Created by Bryce Poole on 12/4/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import Foundation
import RealmSwift

class RealmData: Object { //Object is a custom class of the RealmSwift archeticture for defining Realm Objects
    
    //When using Realm, you most declair properties that you want to save with @objc dynamic.
    //This lets Realm monitor them for changes and save any updates.
    @objc dynamic var name : String = ""
    @objc dynamic var age : Int = 0
}

