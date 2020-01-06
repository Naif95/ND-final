//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Naif on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTourist")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        try? dataController.viewContext.save()
        
    }
}

