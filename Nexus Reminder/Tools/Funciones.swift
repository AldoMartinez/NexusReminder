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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var fetchActividadesRequest: NSFetchRequest<Actividad> = {
        let fetchRequest : NSFetchRequest<Actividad> = Actividad.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "fecha_limite", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }()
    
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
            let fetchConfiguracionRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Configuracion")
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let batchDeleteConfigRequest = NSBatchDeleteRequest(fetchRequest: fetchConfiguracionRequest)
            do {
                try context.execute(batchDeleteRequest)
                try context.execute(batchDeleteConfigRequest)
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
        notificationContent.sound = .default
        
        // Crea un trigger para saber cuando mostrar la notificacion
        let trigger = UNCalendarNotificationTrigger(dateMatching: fechaTrigger, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("notificación creada con exito")
    }
    
    // Se decide la cantidad y la frecuencia de las notificaciones por actividad
    func configurarNotificaciones(frecuencia: [Int], fechaActividad: Date) {
        let cantidad = frecuencia.count
        // Convierte una variable tipo Date en tipo DateComponents
        var notificationTrigger = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: fechaActividad)
        notificationTrigger.year = añoActual()
        for indice in 0..<cantidad {
            var texto = ""
            var newTriggerNotification = notificationTrigger
            switch frecuencia[indice] {
            case 0: // 1 hora antes
                if var horaActividad = newTriggerNotification.hour {
                    horaActividad = horaActividad - 1
                    newTriggerNotification.hour = horaActividad
                    texto = "1 hora"
                }
            case 1: // 5 horas antes
                if var horaActividad = newTriggerNotification.hour {
                    horaActividad = horaActividad - 5
                    newTriggerNotification.hour = horaActividad
                    texto = "5 horas"
                }
            case 2: // 1 dia antes
                if var diaActividad = newTriggerNotification.day {
                    diaActividad = diaActividad - 1
                    newTriggerNotification.day = diaActividad
                    texto = "1 día"
                    
                }
            case 3: // 3 dias antes
                if var diaActividad = newTriggerNotification.day {
                    diaActividad = diaActividad - 3
                    newTriggerNotification.day = diaActividad
                    texto = "3 días"
                }
            case 4: // 7 dias antes
                if var diaActividad = newTriggerNotification.day {
                    diaActividad = diaActividad - 7
                    newTriggerNotification.day = diaActividad
                    texto = "7 días"
                }
            default:
                break
            }
            if fechaEsValida(fechaActividad: newTriggerNotification) {
                self.createLocalNotification(fechaTrigger: newTriggerNotification, textoCompletador: texto)
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
    // Verifica si la fecha de la notificacion es menor a la fecha actual
    // True: si la fecha es mayor a la fecha actual
    // False: si la fecha es menor a la actual
    func fechaEsValida(fechaActividad: DateComponents) -> Bool {
        let fechaActual = Date()
        guard let fechaActividadDate = Calendar.current.date(from: fechaActividad) else { return false }
        if fechaActividadDate < fechaActual {
            return false
        }
        return true
    }
    // Retorna el año actual
    func añoActual() -> Int {
        let fechaActual = Date()
        let añoActual = Calendar.current.component(.year, from: fechaActual)
        return añoActual
    }
    
    // Retorna las actividades del Core Data
    func obtenerActividades() -> [Actividad] {
        var actividades: [Actividad] = []
        do {
            actividades = try self.context.fetch(fetchActividadesRequest)
        } catch {
            print("Ocurrió un error al obtener las actividades del Core Data: \(error)")
        }
        return actividades
    }
    // Elimina tanto las notificaciones pendientes como las mostradas
    func eliminarNotificaciones() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
