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
        sleep(2)
        
        // Trae datos del servidor cada minuto
        UIApplication.shared.setMinimumBackgroundFetchInterval(10)
//        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let newData: [[String: Any]] = [
            [
                "materia" : "Estructura de datos",
                "actividades_pendientes" : [
                    [
                        "tarea" : "Actividad fundamental 7",
                        "fecha_limite" : "junio 25, 17:20 hrs."
                    ]
                ]
            ]
        ]
        if UserDefaults.standard.bool(forKey: "userLogin") {
            NSLog("user login true", "")
            // Ejecuta el request al servidor
            let st = UIStoryboard(name: "Main", bundle: nil)
            if let vc = st.instantiateViewController(withIdentifier: "ActividadesController") as? ActividadesController {
                NSLog("vc creado", "")
//                guard
//                    let matricula = UserDefaults.standard.string(forKey: "matricula"),
//                    let contrasena = UserDefaults.standard.string(forKey: "contrasena")
//                    else {
//                        return
//                }
//                NSLog("matricula y contraseñas creadas", "")
//                let base = "http://18.191.89.218/nexusApi/"
//                let separador = "nexusApiAldo"
//                var url = base + matricula + separador + contrasena
//                url = url.trimmingCharacters(in: .whitespacesAndNewlines)
//                guard let urlRequest = URL(string: url) else { return }
//                print(urlRequest)
                var url = "https://pastebin.com/raw/B08wxr1d"
                let urlRequest = URL(string: url)
                URLSession.shared.dataTask(with: urlRequest!) { (data, response, error) in
                    NSLog("URLSesion creada", "")
                    guard let data = data, error == nil else {
                        completionHandler(.failed)
                        return
                    }
                    do {
                        
                        if let respuesta = String(data: data, encoding: .utf8) {
                            // Verifica lo retornado por el servidor
                            switch respuesta {
                            case "0":
                                break
                                //print("No hay materias disponibles")
                            case "1":
                                break
                                //print("Matricula o contraseña incorrectas")
                            default:
                                NSLog("json actualizado", "done")
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                if let actividadesUsuario = json as? [[String: Any]] {
                                    //print(GlobalVariables.shared.jsonResponse)
                                    DispatchQueue.main.async {
                                        GlobalVariables.shared.jsonResponse = newData
                                        vc.actualizarUI()
                                        completionHandler(.newData)
                                    }
                                    
                                }
                            }
                        }
                    } catch {
                        //print("Ocurrio un error al hacer el request: \(error)")
                        completionHandler(.noData)
                    }
                }.resume()
            } else {
                NSLog("Error al crear actividades controller", "")
            }
        } else {
            NSLog("El usuario no ha iniciado sesión", "")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        self.saveContext()
    }
    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        let st = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = st.instantiateViewController(withIdentifier: "ActividadesController") as? ActividadesController {
//            print("app entrara al foreground")
//            vc.tableView.reloadData()
//        }
//    }
    
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

