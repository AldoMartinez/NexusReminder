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
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnView)))
        setupInputFields()
        // Se agrega observadores para ejecutar los métodos de las vistas cuando aparecen los teclados
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        pedirPermisoNotificaciones()
        // Configuracion del banner
        //self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.delegate = self
        //addBannerViewToView(bannerView)
        
        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["91edbaa882c469d367e9322c89e96f6d", "25494902e9a1cc44c9164319aa84bc5c"]
        self.bannerView.load(request)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error con el banner: \(error.localizedDescription)")
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
    var dataTask: URLSessionDataTask?
    
    // MARK: Outlets
    @IBOutlet weak var matriculaTextField: UITextField!
    @IBOutlet weak var contrasenaTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var bannerView: GADBannerView!
    
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
                print("Permiso de notificación concedido")
            } else {
                print("Permiso de notificación denegado")
            }
        }
    }
    // Funcion que hace el request a la API
    func obtenerActividades(matricula: String, contrasena: String) {
        var statusCode: Int = 2
        dataTask?.cancel()
        let base = "http://18.191.89.218/nexusApi/"
        let separador = "nexusApiAldo"
        var url = base + matricula + separador + contrasena
        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
//        print(url)
//        var url = "https://pastebin.com/raw/B08wxr1d"
//        let urlRequest = URL(string: url)
        guard let urlRequest = URL(string: url) else {
            Funciones().createAlerConfirmation(titulo: "Error", mensaje: "La contraseña no debe contener espacios en blanco", controlador: self, option: 2)
            self.resetInputFields()
            return
        }
        let urlSesion = URLSession(configuration: .ephemeral)
        dataTask = urlSesion.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    if let respuesta = String(data: data, encoding: .utf8) {
                        print(respuesta)
                        // Verifica lo retornado por el servidor
                        switch respuesta {
                        case "0":
                            statusCode = 0
                            print("No hay materias disponibles")
                        case "1":
                            print("Matricula o contraseña incorrectas")
                            statusCode = 1
                        default:
                            statusCode = 0
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let actividadesUsuario = json as? [[String: Any]] {
                                GlobalVariables.shared.jsonResponse = actividadesUsuario
                                print(GlobalVariables.shared.jsonResponse)
                            }
                        }
                    }
                } catch {
                    print(error)
                    statusCode = 2
                }
            }
            self.validarRequest(status: statusCode)
        })
        dataTask?.resume()
//        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//
//            if let data = data {
//                do {
//                    if let respuesta = String(data: data, encoding: .utf8) {
//                        print(respuesta)
//                        // Verifica lo retornado por el servidor
//                        switch respuesta {
//                        case "0":
//                            print("No hay materias disponibles")
//                        case "1":
//                            print("Matricula o contraseña incorrectas")
//                            statusCode = 1
//                        default:
//                            let json = try JSONSerialization.jsonObject(with: data, options: [])
//
//                            if let actividadesUsuario = json as? [[String: Any]] {
//                                GlobalVariables.shared.jsonResponse = actividadesUsuario
//                                print(GlobalVariables.shared.jsonResponse)
//                            }
//                        }
//                    }
//                } catch {
//                    print(error)
//                    statusCode = 2
//                }
//            }
//            self.validarRequest(status: statusCode)
//        }
//        task.resume()
    }
    
    // Funcion que valida el login, si es correcto, lo manda al controllador de actividades (default)
    func validarRequest(status: Int) {
        DispatchQueue.main.async {
            switch status {
            case 0:
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                UserDefaults.standard.set(true, forKey: "userLogin")
                UserDefaults.standard.set(self.matriculaTextField.text, forKey: "matricula")
                UserDefaults.standard.set(self.contrasenaTextField.text, forKey: "contrasena")
            case 1:
                print("Matricula o contraseña incorrectas")
                Funciones().createAlerConfirmation(titulo: "Datos incorrectos", mensaje: "La matrícula o contraseña no coinciden", controlador: self, option: 2)
                self.resetInputFields()
            case 2:
                print("Error")
                Funciones().createAlerConfirmation(titulo: "Error", mensaje: "Ocurrió un error desconocido", controlador: self, option: 2)
            default:
                break
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
    // Pone en blanco los textfields
    private func resetInputFields() {
        matriculaTextField.text = ""
        contrasenaTextField.text = ""
        matriculaTextField.isUserInteractionEnabled = true
        contrasenaTextField.isUserInteractionEnabled = true
        
        loginButton.isEnabled = false
        //loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
    }
    // Da diseño a los textfields
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

