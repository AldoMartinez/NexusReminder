//
//  ConfiguracionController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/31/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class ConfiguracionController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func cerrarSesionButton(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "userLogin")
        UserDefaults.standard.removeObject(forKey: "matricula")
        UserDefaults.standard.removeObject(forKey: "contrasena")
        Funciones().setRootControllerTVC(storyboardID: "loginController", controller: self)
        Funciones().deleteActividades()
        Funciones().saveActividad()
    }
}
