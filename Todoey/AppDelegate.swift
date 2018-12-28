//
//  AppDelegate.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    // Override point for customization after application launch.
    
    //Runs as soon as application opens
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  
        
        //Get the path to your Realm database
//        print( Realm.Configuration.defaultConfiguration.fileURL )
        
        //Try to create new Realm database
        do{
            _ = try Realm()// New Realm Database object
        }catch{
            print("Error loading data from Realm: \(error)")
        }
        
        return true
    }    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
}

