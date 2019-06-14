//
//  ConfiguracionNotificacion.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/13/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
class CantidadNotificacion: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.isEditing = true
        //tableView.allowsSelectionDuringEditing = true
    }
    
    // MARK: Propiedades
    var cantidadSeleccionada: Int = 0
    
    // MARK: Acciones
    @IBAction func siguienteButton(_ sender: UIBarButtonItem) {
        if cantidadSeleccionada != 0 {
            performSegue(withIdentifier: "cantidadSegue", sender: self)
        } else {
            Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Es necesario seleccionar una opción", controlador: self, option: 1)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cantidadSegue" {
            if let vc = segue.destination as? TiempoNotificacion {
                vc.cantidadNotificaciones = cantidadSeleccionada
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Valida que solo se pueda seleccionar una opción
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            cantidadSeleccionada = 0
        } else {
            for cell in tableView.visibleCells {
                cell.accessoryType = .none
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if let cantidad = tableView.cellForRow(at: indexPath)?.tag {
                cantidadSeleccionada = cantidad
                print(cantidadSeleccionada)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
