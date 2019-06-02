//
//  ActividadesController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/30/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData

class ActividadesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        //actividades = UserDefaults.standard.array(forKey: "actividades") as! [Actividad]
        cargarActividades()
    }
    // MARK: Variables
    var actividades: [Actividad] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // MARK: Outlets
    @IBOutlet weak var bottomView: UIView!

    
    // MARK: Funciones
    func cargarActividades() {
        let request: NSFetchRequest<Actividad> = Actividad.fetchRequest()
        do {
            self.actividades = try self.context.fetch(request)
        } catch {
            print("Error al cargar las actividades: \(error)")
        }
    }
    
    func convertNexusDateToString(fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM d, HH:mm 'hrs.'"
        
        let dateNexus = formatter.string(from: fecha)
        return dateNexus
    }
    
    // MARK: Funciones del table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actividades.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actividadesCell", for: indexPath) as! ActividadesCell
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        cell.materiaLabel.text = actividades[indexPath.row].materia
        cell.actividadLabel.text = actividades[indexPath.row].nombre
        if let fechaLimite = actividades[indexPath.row].fecha_limite {
            cell.fechaLimiteLabel.text = convertNexusDateToString(fecha: fechaLimite)
        }
        
        cell.recuerdoDiaLabel.text = "Te quedan 3 dias para subir la tarea"
        
        // Da estilo al recuerdoDiaLabel
        cell.recuerdoDiaLabel.layer.cornerRadius = 8
        cell.recuerdoDiaLabel.layer.masksToBounds = true
        cell.recuerdoDiaLabel.backgroundColor = UIColor(red: 5/255, green: 57/255, blue: 110/255, alpha: 1)
        cell.recuerdoDiaLabel.textColor = UIColor.white

        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
}
