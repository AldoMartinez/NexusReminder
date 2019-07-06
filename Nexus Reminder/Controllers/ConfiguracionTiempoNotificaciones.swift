//
//  ConfiguracionTiempoNotificaciones
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/13/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import GoogleMobileAds

class ConfiguracionTiempoNotificaciones: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        fetchConfiguracion()
        configurarBanner()
    }
    
    // MARK: Propiedades
    var opcionesSeleccionadas: [Int] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var configuraciones: [Configuracion] = []
    var indexPathsCeldasSeleccionadas: [IndexPath] = []
    
    // MARK: Outlets
    @IBOutlet var cancelarButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bannerView: GADBannerView!
    
    // MARK: Acciones
    @IBAction func editarButton(_ sender: UIBarButtonItem) {
        
        
        if opcionesSeleccionadas.count >= 1 {
            UserDefaults.standard.set(self.opcionesSeleccionadas, forKey: "tiemposSeleccionados")
            self.dismiss(animated: true, completion: nil)
            Funciones().saveActividad()
        } else {
            Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Selecciona al menos una opción", controlador: self, option: 2)
        }
    }
    @IBAction func cancelarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Funciones
    // Configuracion necesaria para mostrar el banner de google
    func configurarBanner() {
        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["91edbaa882c469d367e9322c89e96f6d", "25494902e9a1cc44c9164319aa84bc5c"]
        self.bannerView.load(request)
    }
    
    // Llena el array de las opciones seleccionadas con los tags
    func guardarUserDefaultsYCoreData(data: [IndexPath]) {
        // Resetea los valores de la configuracion de core data
        for configuracion in configuraciones {
            configuracion.seleccionado = false
        }
        
        self.opcionesSeleccionadas.removeAll()
        // Recorre el array de los indices de las celdas seleccionadas
        for index in data {
            if let tag = tableView.cellForRow(at: index)?.tag {
                self.opcionesSeleccionadas.append(tag)
            }
            configuraciones[index.row].seleccionado = true
        }
        UserDefaults.standard.set(self.opcionesSeleccionadas, forKey: "tiemposSeleccionados")
        Funciones().saveActividad()
    }
    
    // Obtiene la configuracion del usuario de las notificaciones
    func fetchConfiguracion() {
        let request: NSFetchRequest<Configuracion> = Configuracion.fetchRequest()
        request.returnsObjectsAsFaults = true
        request.sortDescriptors = [NSSortDescriptor(key: "tag", ascending: true)]
        do {
            configuraciones = try context.fetch(request)
        } catch {
            print("Error al obtener la configuracion de las notificaciones: \(error)")
        }
    }
    
    // Guarda la configuracion de las notificaciones
    func guardarConfiguracionNotificaciones() {
        // Elimina las notificaciones actuales
        Funciones().eliminarNotificaciones()
        
        // Guarda la nueva configuracion en User Defaults y en Core Data
        self.guardarUserDefaultsYCoreData(data: self.indexPathsCeldasSeleccionadas)
        
        let actividades = Funciones().obtenerActividades()
        for actividad in actividades {
            if let tiempos = UserDefaults.standard.array(forKey: "tiemposSeleccionados") as? [Int] {
                Funciones().configurarNotificaciones(frecuencia: tiempos, fechaActividad: actividad.fecha_limite!)
            } else {
                print("Ocurrió un error al generar la notificación")
            }
        }
        print("Cantidad de opciones seleccionadas: \(opcionesSeleccionadas)")
    }
    
    // MARK: Funciones del table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indices = tableView.indexPathsForSelectedRows {
            indexPathsCeldasSeleccionadas = indices
        }
        //configuraciones[indexPath.row].seleccionado = !configuraciones[indexPath.row].seleccionado
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let indices = tableView.indexPathsForSelectedRows {
            indexPathsCeldasSeleccionadas = indices
        }
        //configuraciones[indexPath.row].seleccionado = !configuraciones[indexPath.row].seleccionado
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuraciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configuracionCell", for: indexPath)
        
        let configuracion = configuraciones[indexPath.row]
        
        cell.textLabel?.text = configuracion.texto
        cell.tag = Int(configuracion.tag)

        if configuracion.seleccionado {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEditing {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        // Al dar clic en el botón Done
        if !editing {
            if indexPathsCeldasSeleccionadas.count > 0 {
                guardarConfiguracionNotificaciones()
                UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
                    print("Contador: \(notifications.count)")
                    for notificacion in notifications {
                        print(notificacion.trigger)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                Funciones().createAlerConfirmation(titulo: "Error", mensaje: "Debes seleccionar al menos una opción", controlador: self, option: 2)
            }
        }
    }
}
