//
//  ViewController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/17/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        setupInputFields()
        // Se agregra observadores para ejecutar los métodos de las vistas cuando aparecen los teclados
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: Métodos para mover la vista cuando aparece y desparece el teclado
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: Outlets
    @IBOutlet weak var matriculaTextField: UITextField!
    @IBOutlet weak var contrasenaTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Actions
    @IBAction func LoginButton(_ sender: UIButton) {
        obtenerActividades(matricula: matriculaTextField.text!, contrasena: contrasenaTextField.text!)
    }
    
    // MARK: Funciones
    // Funcion que hace el request a la API
    func obtenerActividades(matricula: String, contrasena: String) {
        var statusCode: Int = 2
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
        var url = base + matricula + separador + contrasena
        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        print(url)
        guard let urlRequest = URL(string: url) else {
            Funciones().createAlerConfirmation(titulo: "Error", mensaje: "La contraseña no debe contener espacios en blanco", controlador: self, option: 2)
            self.resetInputFields()
            return
        }
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
                    if let respuesta = String(data: data, encoding: .utf8) {
                        // Verifica lo retornado por el servidor
                        if respuesta != "Matricula o contraseña incorrecta" {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let actividadesUsuario = json as? [[String: Any]] {
                                // Se recorren las materias para buscar si hay actividades pendientes
                                for materia in actividadesUsuario {
                                    if let actividades = materia["actividades_pendientes"] as? [[String:String]]{
                                        if actividades.count != 0 {
                                            // Si hay actividad pendiente, se crea un Actividad
                                            for actividad in actividades {
                                                let nuevaActividad = Actividad(context: self.context)
                                                nuevaActividad.completada = false
                                                nuevaActividad.materia = materia["materia"] as? String ?? "Materia desconocida"
                                                nuevaActividad.nombre = actividad["tarea"]
                                                if let fechaNexus = actividad["fecha_limite"] {
                                                    nuevaActividad.fecha_limite = self.convertToDate(fechaNexus: fechaNexus)
                                                }
                                                print(nuevaActividad)
                                                Funciones().saveActividad()
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            statusCode = 0
                        }
                    }
                } catch {
                    print(error)
                    statusCode = 1
                }
            }
            self.validarRequest(status: statusCode)
        }
        task.resume()
    }
    
    // Funcion que valida el login, si es correcto, lo manda al controllador de actividades (default)
    func validarRequest(status: Int) {
        DispatchQueue.main.async {
            switch status {
            case 0:
                print("Matricula o contraseña incorrectas")
                Funciones().createAlerConfirmation(titulo: "Datos incorrectos", mensaje: "La matrícula o contraseña no coinciden", controlador: self, option: 2)
                self.resetInputFields()
            case 1:
                print("Error")
                Funciones().createAlerConfirmation(titulo: "Error", mensaje: "Ocurrió un error desconocido", controlador: self, option: 2)
            default:
                self.performSegue(withIdentifier: "tabBarSegue", sender: self)
                UserDefaults.standard.set(true, forKey: "userLogin")
            }
        }
        
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
        //loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
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
    
    // MARK: Métodos para la manipulación del modelo de datos
    // Convierte la fecha limite de nexus en formato Date
    func convertToDate(fechaNexus: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM d, HH:mm 'hrs.'"
        
        guard let dateNexus = formatter.date(from: fechaNexus) else { return Date() }
        return dateNexus
    }
}

