//
//  Funciones.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/31/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class Funciones {
    
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
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                try context.save()
            } catch {
                print("Ocurrió un error al guardar el Context: \(error)")
            }
        }
        
    }
    // Elimina todo los registros de una etidad (Core Data)
    func deleteActividades() {
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
    
    // Crea una alerta de confirmación
    func createAlerConfirmation(titulo: String, mensaje: String, controlador: Any, option: Int) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Entendido", style: .default, handler: nil)
        alert.addAction(okButton)
        // Option
        // 1: UITableViewController
        // 2: UIViewController
        switch option {
        case 1:
            if let controller = controlador as? UITableViewController {
                controller.present(alert, animated: true, completion: nil)
            }
        default:
            if let controller = controlador as? UIViewController {
                controller.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Crea una local notification
    func createLocalNotification(titulo: String, mensaje: String, fecha: DateComponents, subtitulo: String = "") {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = titulo
        notificationContent.subtitle = subtitulo
        notificationContent.body = mensaje
//        var fecha = DateComponents(
//        // Junio 5, 16:50
//        fecha.day = 4
//        fecha.month = 6
//        fecha.hour = 16
//        fecha.minute = 53
        
        // Crea un trigger para saber cuando mostrar la notificacion
        let trigger = UNCalendarNotificationTrigger(dateMatching: fecha, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Compara si el nombre de la actividad ya se encuentra en Core Data
    func actividadNueva(nombreActividad: String, materia: String) -> Bool {
        let contextPrueba = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest = NSFetchRequest<Actividad>(entityName: "Actividad")
        request.predicate = NSPredicate(format: "nombre == %@ AND materia == %@", argumentArray: [nombreActividad, materia])
        var results: [NSManagedObject] = []
        do {
            results = try contextPrueba.fetch(request)
        } catch {
            print("Error al comparar las actividades con Core Data: \(error)")
        }
        if results.count > 0 {
            print("Actividad ya registrada")
            return false
        } else {
            print("Es necesario agregar la actividad")
            return true
        }
    }
}
