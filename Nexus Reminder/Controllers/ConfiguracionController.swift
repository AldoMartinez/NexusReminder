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
    
    @IBAction func cerrarSesionButton(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "userLogin")
        Funciones().setRootControllerTVC(storyboardID: "loginController", controller: self)
    }
}
