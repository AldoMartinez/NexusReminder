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

class ConfiguracionTiempoNotificaciones: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        fetchConfiguracion()
    }
    
    // MARK: Propiedades
    var opcionesSeleccionadas: [Int] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var configuraciones: [Configuracion] = []
    var indexPathsCeldasSeleccionadas: [IndexPath] = []
    
    // MARK: Outlets
    @IBOutlet var cancelarButton: UIBarButtonItem!
    
    // MARK: Acciones
    @IBAction func editarButton(_ sender: UIBarButtonItem) {
        
        
        if opcionesSeleccionadas.count >= 1 {
            UserDefaults.standard.set(self.opcionesSeleccionadas, forKey: "tiemposSeleccionados")
            self.dismiss(animated: true, completion: nil)
            Funciones().saveActividad()
        } else {
            Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Selecciona al menos una opción", controlador: self, option: 1)
        }
    }
    @IBAction func cancelarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Funciones
    
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
        do {
            configuraciones = try context.fetch(request)
            print(configuraciones)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indices = tableView.indexPathsForSelectedRows {
            indexPathsCeldasSeleccionadas = indices
        }
        //configuraciones[indexPath.row].seleccionado = !configuraciones[indexPath.row].seleccionado
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let indices = tableView.indexPathsForSelectedRows {
            indexPathsCeldasSeleccionadas = indices
        }
        //configuraciones[indexPath.row].seleccionado = !configuraciones[indexPath.row].seleccionado
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuraciones.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configuracionCell", for: indexPath)
        
        let configuracion = configuraciones[indexPath.row]
        
        cell.textLabel?.text = configuracion.texto
        cell.tag = Int(configuracion.tag)

        if configuracion.seleccionado {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEditing {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
                Funciones().createAlerConfirmation(titulo: "Error", mensaje: "Debes seleccionar al menos una opción", controlador: self, option: 1)
            }
        }
    }
}
