//
//  ActividadesController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/30/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class ActividadesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        //actividades = UserDefaults.standard.array(forKey: "actividades") as! [Actividad]
    }
    // MARK: Variables
    var actividades: [Actividad] = []
    // MARK: Outlets
    @IBOutlet weak var bottomView: UIView!
    
//    let act = Actividad(materia: "Matematicas", actividad: "Ejercicio 1", fechaLimite: "22 de mayo del 2020")
//    let act2 = Actividad(materia: "Seguridad y criptografía", actividad: "Actividad fundamental que tiene que ser un ensayo con un limite de 3 cuartillas", fechaLimite: "22 de mayo del 2020")
//    var actividades: [Actividad] = []
    
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
        cell.actividadLabel.text = actividades[indexPath.row].actividad
        cell.fechaLimiteLabel.text = actividades[indexPath.row].fechaLimite
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
