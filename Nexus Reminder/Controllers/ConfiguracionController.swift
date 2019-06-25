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
        let alerta = UIAlertController(title: "¿Estas seguro de cerrar sesión?", message: "Todas las notificaciones de tus actividades se perderán", preferredStyle: .alert)
        let continuarButton = UIAlertAction(title: "Continuar", style: .default) { (UIAlertAction) in
            self.eliminarConfiguracion()
        }
        let cancelarButton = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alerta.addAction(cancelarButton)
        alerta.addAction(continuarButton)
        
        present(alerta, animated: true, completion: nil)
    }
    
    // Elimina toda la configuracion del usuario
    func eliminarConfiguracion() {
        Funciones().eliminarNotificaciones()
        UserDefaults.standard.set(false, forKey: "userLogin")
        UserDefaults.standard.removeObject(forKey: "matricula")
        UserDefaults.standard.removeObject(forKey: "contrasena")
        Funciones().setRootControllerTVC(storyboardID: "loginController", controller: self)
        Funciones().deleteActividades()
        Funciones().saveActividad()
        print("Configuracion eliminada")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(200)
        } else {
            return CGFloat(0)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            // Carga la vista para el header y muestra la matricula con la que esta logeado
            let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! HeaderView
            
            if let matricula = UserDefaults.standard.string(forKey: "matricula") {
                headerView.matriculaTextField.text = "Matrícula: \(matricula)"
            }
            headerView.logoImage.setRounded()
            return headerView
        }
        return UIView()
    }
}
