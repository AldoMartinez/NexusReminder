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
        // Default: UIViewController
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
    func createLocalNotification(fechaTrigger: DateComponents, textoCompletador: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Actividad pendiente"
        notificationContent.body = "Tienes una actividad pendiente que se cierra en \(textoCompletador)"
        
        // Crea un trigger para saber cuando mostrar la notificacion
        let trigger = UNCalendarNotificationTrigger(dateMatching: fechaTrigger, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("notificación creada con exito")
    }
    
    // Se decide la cantidad y la frecuencia de las notificaciones por actividad
    func configurarNotificaciones(cantidad: Int, frecuencia: [Int], fechaActividad: Date) {
        // Convierte una variable tipo Date en tipo DateComponents
        var notificationTrigger = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: fechaActividad)
        for indice in 0..<cantidad {
            switch frecuencia[indice] {
            case 0: // 1 hora antes
                if var horaActividad = notificationTrigger.hour {
                    horaActividad = horaActividad - 1
                    notificationTrigger.hour = horaActividad
                    let texto = "1 hora"
                    self.createLocalNotification(fechaTrigger: notificationTrigger, textoCompletador: texto)
                }
            case 1: // 5 horas antes
                if var horaActividad = notificationTrigger.hour {
                    horaActividad = horaActividad - 5
                    notificationTrigger.hour = horaActividad
                    let texto = "5 horas"
                    self.createLocalNotification(fechaTrigger: notificationTrigger, textoCompletador: texto)
                }
            case 2: // 1 dia antes
                if var diaActividad = notificationTrigger.day {
                    diaActividad = diaActividad - 1
                    notificationTrigger.day = diaActividad
                    let texto = "1 día"
                    self.createLocalNotification(fechaTrigger: notificationTrigger, textoCompletador: texto)
                }
            case 3: // 3 dias antes
                if var diaActividad = notificationTrigger.day {
                    diaActividad = diaActividad - 3
                    notificationTrigger.day = diaActividad
                    let texto = "3 días"
                    self.createLocalNotification(fechaTrigger: notificationTrigger, textoCompletador: texto)
                }
            case 4: // 5 dias antes
                if var diaActividad = notificationTrigger.day {
                    diaActividad = diaActividad - 7
                    notificationTrigger.day = diaActividad
                    let texto = "7 días"
                    self.createLocalNotification(fechaTrigger: notificationTrigger, textoCompletador: texto)
                }
            default:
                break
            }
        }
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
