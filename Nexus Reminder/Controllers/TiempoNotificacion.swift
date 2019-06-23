//
//  TiempoNotificacion.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/13/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData

class TiempoNotificacion: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        configuracionInicial()
        fetchConfiguracion()
    }
    
    // MARK: Propiedades
    var opcionesSeleccionadas: [Int] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var configuraciones: [Configuracion] = []
    
    
    // MARK: Acciones
    @IBAction func hechoButton(_ sender: UIBarButtonItem) {
        self.tagsDeOpcionesSeleccionadas(data: tableView.indexPathsForSelectedRows ?? [])
        print("Cantidad de opciones seleccionadas: \(opcionesSeleccionadas)")
        if opcionesSeleccionadas.count >= 1 {
            UserDefaults.standard.set(self.opcionesSeleccionadas, forKey: "tiemposSeleccionados")
            Funciones().saveActividad()
            self.performSegue(withIdentifier: "tabBarSegue", sender: self)
        } else {
            Funciones().createAlerConfirmation(titulo: "¡Cuidado!", mensaje: "Selecciona al menos una opción", controlador: self, option: 1)
        }
    }
    
    // MARK: Funciones
    
    // Llena el array de las opciones seleccionadas con los tags
    func tagsDeOpcionesSeleccionadas(data: [IndexPath]) {
        self.opcionesSeleccionadas.removeAll()
        if data.count > 0 {
            for cell in data {
                if let tag = tableView.cellForRow(at: cell)?.tag {
                    self.opcionesSeleccionadas.append(tag)
                }
            }
        }
    }
    
    // Configuracion inicial
    func configuracionInicial() {
        let unaHora = Configuracion(context: self.context)
        unaHora.texto = "1 hora antes"
        unaHora.tag = 0
        let cincoHoras = Configuracion(context: self.context)
        cincoHoras.texto = "5 horas antes"
        cincoHoras.tag = 1
        let unDia = Configuracion(context: self.context)
        unDia.texto = "1 día antes"
        unDia.tag = 2
        let tresDias = Configuracion(context: self.context)
        tresDias.texto = "3 días antes"
        tresDias.tag = 3
        let unaSemana = Configuracion(context: self.context)
        unaSemana.texto = "1 semana antes"
        unaSemana.tag = 4
        Funciones().saveActividad()
    }
    // Obtiene la configuracion del usuario de las notificaciones
    func fetchConfiguracion() {
        let request: NSFetchRequest<Configuracion> = Configuracion.fetchRequest()
        do {
            configuraciones = try context.fetch(request)
            print(configuraciones)
        } catch {
            print("Error al obtener la configuracion de las notificaciones: \(error)")
        }
    }
    
    // MARK: Funciones del table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        configuraciones[indexPath.row].seleccionado = !configuraciones[indexPath.row].seleccionado
        print(tableView.cellForRow(at: indexPath)?.tag)
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

        return cell
    }
}
