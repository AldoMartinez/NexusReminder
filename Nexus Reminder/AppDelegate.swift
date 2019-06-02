//
//  AppDelegate.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/17/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Si el usuario esta logeado, lo mando a la pantalla de actividades
        if UserDefaults.standard.bool(forKey: "userLogin") {
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarMain")
            let share = UIApplication.shared.delegate as? AppDelegate
            share?.window?.rootViewController = vc
        }
        // Override point for customization after application launch.
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor(red: 5/255, green: 57/255, blue: 110/255, alpha: 1)
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ActividadesModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        // ViewContext es como lo que se guarda el commit pero antes de hacer push
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // Se guardan los datos del ViewContext como si fuera el push
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

