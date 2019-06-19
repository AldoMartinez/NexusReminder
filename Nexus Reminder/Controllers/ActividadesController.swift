//
//  ActividadesController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/30/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ActividadesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullDownRefreshToTable()
        bottomView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        //actividades = UserDefaults.standard.array(forKey: "actividades") as! [Actividad]
        actualizarUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cargarActividades()
    }
    // MARK: Variables
    var actividades: [Actividad] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // MARK: Outlets
    @IBOutlet weak var bottomView: UIView!

    
    // MARK: Funciones
    
    func actualizarUI() {
        self.guardarActividadesCoreData(datosNexus: GlobalVariables.shared.jsonResponse)
        self.tableView.reloadData()
    }
    func addPullDownRefreshToTable() {
        // Detecta cuando el usuarios hace pull down a la tabla
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        refreshControl.tintColor = .black
    }
    @objc func refreshTableView() {
        requestToAPI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    func requestToAPI() {
//        guard
//            let matricula = UserDefaults.standard.string(forKey: "matricula"),
//            let contrasena = UserDefaults.standard.string(forKey: "contrasena")
//        else {
//            return
//        }
//        let base = "http://18.191.89.218/nexusApi/"
//        let separador = "nexusApiAldo"
//        var url = base + matricula + separador + contrasena
//        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = "https://pastebin.com/raw/B08wxr1d"
        guard let urlRequest = URL(string: url) else { return  }
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let respuesta = String(data: data, encoding: .utf8) {
                        // Verifica lo retornado por el servidor
                        switch respuesta {
                        case "0":
                            print("No hay materias disponibles")
                        case "1":
                            print("Matricula o contraseña incorrectas")
                        default:
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let actividadesUsuario = json as? [[String: Any]] {
                                GlobalVariables.shared.jsonResponse = actividadesUsuario
                                DispatchQueue.main.async {
                                    self.guardarActividadesCoreData(datosNexus: actividadesUsuario)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                } catch {
                    print("Ocurrio un error al hacer el request: \(error)")
                }
            }
        }
        task.resume()
    }
    // Se guardan las actividades en el core data y se crean las notificaciones
    func guardarActividadesCoreData(datosNexus: [[String:Any]]) {
        // Se recorren las materias para buscar si hay actividades pendientes
        print("Funcion para guardar actividades en core data")
        print(datosNexus)
        for materia in datosNexus {
            if let actividadesPendientes = materia["actividades_pendientes"] as? [[String:String]] {
                if actividadesPendientes.count != 0 {
                    // Si hay actividad pendiente, se guarda en la variable global actividadesPendientes
                    for actividad in actividadesPendientes {
                        // Valida si la actividad no esta registrada en el core data
                        if Funciones().actividadNueva(nombreActividad: actividad["tarea"] ?? "act", materia: materia["materia"] as? String ?? "Materia desconocida") {
                            let nuevaActividad = Actividad(context: self.context)
                            nuevaActividad.completada = false
                            nuevaActividad.materia = materia["materia"] as? String ?? "Materia desconocida"
                            nuevaActividad.nombre = actividad["tarea"]
                            if let fechaNexus = actividad["fecha_limite"] {
                                nuevaActividad.fecha_limite = self.convertToDate(fechaNexus: fechaNexus)
                                // Se crean las notificaciones para la actividad
                                let cantidadNotificaciones = UserDefaults.standard.integer(forKey: "cantidadNotificaciones")
                                if let tiempo = UserDefaults.standard.array(forKey: "tiemposSeleccionados") as? [Int] {
                                    Funciones().configurarNotificaciones(cantidad: cantidadNotificaciones, frecuencia: tiempo, fechaActividad: nuevaActividad.fecha_limite!)
                                } else {
                                    print("Ocurrió un error al generar la notificación")
                                }
                            }
                            print(nuevaActividad)
                            Funciones().saveActividad()
                        } else {
                            print("La actividad ya ha sido registrada")
                        }
                    }
                } else {
                    print("No hay actividades pendientes de \(materia["materia"])")
                }
            } else {
                print("No fue posible obtener las actividades pendientes")
            }
        }
        cargarActividades()
    }
    func cargarActividades() {
        let request: NSFetchRequest<Actividad> = Actividad.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            self.actividades = try self.context.fetch(request)
            print(self.actividades)
        } catch {
            print("Error al cargar las actividades: \(error)")
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            print("Contador: \(notifications.count)")
            for notificacion in notifications {
                print(notificacion.trigger)
            }
        }
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
    // Convierte la fecha Limite del core data (Date) a String
    func convertNexusDateToString(fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
//        formatter.dateFormat = "MMMM d, HH:mm 'hrs.'"
        formatter.dateFormat = "d 'de' MMMM, HH:mm 'hrs.'"
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
        
        cell.recuerdoDiaLabel.text = "  Te quedan 3 dias para subir la tarea"
        
        // Da estilo al recuerdoDiaLabel
        cell.recuerdoDiaLabel.layer.cornerRadius = 5
        cell.recuerdoDiaLabel.layer.masksToBounds = true
        cell.recuerdoDiaLabel.backgroundColor = UIColor(red: 5/255, green: 57/255, blue: 110/255, alpha: 1)
        cell.recuerdoDiaLabel.textColor = UIColor.white

        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
}
