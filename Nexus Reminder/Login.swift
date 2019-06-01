//
//  ViewController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/17/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        setupInputFields()
    }
    
    // MARK: Outlets
    @IBOutlet weak var matriculaTextField: UITextField!
    @IBOutlet weak var contrasenaTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Actions
    @IBAction func LoginButton(_ sender: UIButton) {
        obtenerActividades(matricula: matriculaTextField.text!, contrasena: contrasenaTextField.text!)
        performSegue(withIdentifier: "tabBarSegue", sender: self)
        UserDefaults.standard.set(true, forKey: "userLogin")
//        matriculaTextField.text = ""
//        contrasenaTextField.text = ""
//        loginButton.isEnabled = false
    }
    
    // MAR
    // Funcion que hace el request a la API
    func obtenerActividades(matricula: String, contrasena: String) {
        
        let datosPrueba = [
            ["actividades_pendientes" : [], "materia" : "Movilidad Academica"],
            ["materia" : "Redes neuronales", "actividades_pendientes" : [
                    [
                    "tarea" : "Actividad diagnostica",
                    "fecha_limite" : "22 de mayo"
                    ],
                    [
                    "tarea" : "Actividad diagnostica",
                    "fecha_limite" : "22 de mayo"
                    ]
                ]
            ],
            ["materia" : "Fisica 4", "actividades_pendientes" : [
                    [
                        "tarea" : "Actividad diagnostica",
                        "fecha_limite" : "22 de mayo"
                    ]
                ]
            ]
        ]
        
        let base = "http://18.191.89.218/nexusApi/"
        let separador = "nexusApiAldo"
        let url = base + matricula + separador + contrasena
        print(url)
        let urlRequest = URL(string: url)!
//        if let actividadesUsuario = datosPrueba as? [[String: Any]] {
//            var allActividades: [Actividad] = []
//            // Se recorren las materias para buscar si hay actividades pendientes
//            for materia in actividadesUsuario {
//                if let actividades = materia["actividades_pendientes"] as? [[String:String]]{
//                    if actividades.count != 0 {
//                        // Si hay actividad pendiente, se crea un Actividad
//                        for actividad in actividades {
//                            let nuevaActividad = Actividad(nombreActividad: actividad["tarea"] ?? "Desconocida", fechaLimite: actividad["fecha_limite"] ?? "--", datosMateria: materia)
//                            allActividades.append(nuevaActividad)
//                        }
//                    }
//                }
//            }
//            if allActividades.count == 0 {
//                print("No tienes actividades pendientes")
//            } else {
//                print(allActividades)
//                //UserDefaults.standard.set(allActividades, forKey: "actividades")
//            }
//        }
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                do {
                    // Convierte el response de la API en un objeto
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let actividadesUsuario = json as? [[String: Any]] {
                        var allActividades: [Actividad] = []
                        // Se recorren las materias para buscar si hay actividades pendientes
                        for materia in actividadesUsuario {
                            if let actividades = materia["actividades_pendientes"] as? [[String:String]]{
                                if actividades.count != 0 {
                                    // Si hay actividad pendiente, se crea un Actividad
                                    for actividad in actividades {
                                        let nuevaActividad = Actividad(nombreActividad: actividad["tarea"] ?? "Desconocida", fechaLimite: actividad["fecha_limite"] ?? "--", datosMateria: materia)
                                        allActividades.append(nuevaActividad)
                                    }
                                }
                            }
                        }
                        if allActividades.count == 0 {
                            print("No tienes actividades pendientes")
                        } else {
                            print(allActividades)
                        }

                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    @objc private func handleTextInputChange() {
        let isFormValid = matriculaTextField.text?.isEmpty == false && contrasenaTextField.text?.isEmpty == false
        if isFormValid {
            loginButton.isUserInteractionEnabled = true
            loginButton.isEnabled = true
        }
    }
    // Desabilita el teclado cuando se pulsa en otro lado de la pantalla
    @objc private func handleTapOnView() {
        matriculaTextField.resignFirstResponder()
        contrasenaTextField.resignFirstResponder()
    }
    
    private func resetInputFields() {
        matriculaTextField.text = ""
        contrasenaTextField.text = ""
        matriculaTextField.isUserInteractionEnabled = true
        contrasenaTextField.isUserInteractionEnabled = true
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
    }
    
    private func setupInputFields() {
        // matricula
        matriculaTextField.borderStyle = UITextField.BorderStyle.roundedRect
        matriculaTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        //matriculaTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        // contraseña
        contrasenaTextField.borderStyle = UITextField.BorderStyle.roundedRect
        contrasenaTextField.isSecureTextEntry = true
        //contrasenaTextField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        contrasenaTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        // Login button
        loginButton.layer.cornerRadius = 10
        loginButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

