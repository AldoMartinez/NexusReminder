//
//  TiempoNotificacion.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/13/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class TiempoNotificacion: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    // MARK: Acciones
    @IBAction func hechoButton(_ sender: UIBarButtonItem) {
        if let celdasSeleccionadas = tableView.indexPathsForSelectedRows?.count {
            if cantidadNotificaciones == celdasSeleccionadas {
                self.tagsDeOpcionesSeleccionadas(data: tableView.indexPathsForSelectedRows!)
                UserDefaults.standard.set(self.opcionesSeleccionadas, forKey: "tiemposSeleccionados")
                UserDefaults.standard.set(self.cantidadNotificaciones, forKey: "cantidadNotificaciones")
                self.performSegue(withIdentifier: "tabBarSegue", sender: self)
            } else {
                Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Debes seleccionar \(cantidadNotificaciones) opciones", controlador: self, option: 1)
            }
        } else {
            Funciones().createAlerConfirmation(titulo: "", mensaje: "No has seleccionado ninguna opción", controlador: self, option: 1)
        }
    }
    
    // MARK: Funciones
    
    // Llena el array de las opciones seleccionadas con los tags
    func tagsDeOpcionesSeleccionadas(data: [IndexPath]) {
        for cell in data {
            if let tag = tableView.cellForRow(at: cell)?.tag {
                self.opcionesSeleccionadas.append(tag)
            }
        }
    }
    
    // MARK: Propiedades
    var cantidadNotificaciones: Int = 0
    var opcionesSeleccionadas: [Int] = []
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let celdasSeleccionadas = tableView.indexPathsForSelectedRows?.count {
            if celdasSeleccionadas > cantidadNotificaciones {
                Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Solo puedes seleccionar \(cantidadNotificaciones) opciones", controlador: self, option: 1)
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            }
        }
    }
}
