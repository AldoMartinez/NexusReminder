//
//  Funciones.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/31/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData

class Funciones {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func setRootControllerVC (storyboardID: String, controller: UIViewController) {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        
        let initialViewController = controller.storyboard!.instantiateViewController(withIdentifier: storyboardID)
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    func setRootControllerTVC (storyboardID: String, controller: UITableViewController) {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        
        let initialViewController = controller.storyboard!.instantiateViewController(withIdentifier: storyboardID)
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    // Guarda la actividad en Core Data
    func saveActividad() {
        do {
            try self.context.save()
        } catch {
            print("Ocurrió un error al guardar el Context: \(error)")
        }
    }
    // Elimina todo los registros de una etidad (Core Data)
    func deleteActividades() {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Actividad")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            // Error Handling
            print("Ocurrio un error al eliminar todos los registros: \(error)")
        }
    }
}
