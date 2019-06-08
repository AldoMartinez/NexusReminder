//
//  ViewController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/17/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        setupInputFields()
        // Se agrega observadores para ejecutar los métodos de las vistas cuando aparecen los teclados
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        pedirPermisoNotificaciones()
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
    // Pide permiso al usuario para poder mandarle notificaciones
    func pedirPermisoNotificaciones() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Excelente")
            } else {
                print("De lo que te pierdes")
            }
        }
    }
    // Funcion que hace el request a la API
    func obtenerActividades(matricula: String, contrasena: String) {
        var statusCode: Int = 2
        
        let base = "http://18.191.89.218/nexusApi/"
        let separador = "nexusApiAldo"
//        var url = base + matricula + separador + contrasena
//        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
//        print(url)
        var url = "https://pastebin.com/raw/PYfe7RGt"
        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        print(url)
        guard let urlRequest = URL(string: url) else {
            Funciones().createAlerConfirmation(titulo: "Error", mensaje: "La contraseña no debe contener espacios en blanco", controlador: self, option: 2)
            self.resetInputFields()
            return
        }
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

            if let data = data {
                do {
                    if let respuesta = String(data: data, encoding: .utf8) {
                        // Verifica lo retornado por el servidor
                        if respuesta != "Matricula o contraseña incorrecta" {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let actividadesUsuario = json as? [[String: Any]] {
                                GlobalVariables.shared.jsonResponse = actividadesUsuario
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
                UserDefaults.standard.set(self.matriculaTextField.text, forKey: "matricula")
                UserDefaults.standard.set(self.contrasenaTextField.text, forKey: "contrasena")
//                Funciones().createLocalNotification(titulo: "Actividad pendiente", mensaje: "Tienes una actividad que se cierra en 1 hora")
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
    
}

