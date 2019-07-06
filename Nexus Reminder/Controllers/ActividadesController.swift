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
import GoogleMobileAds

class ActividadesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullDownRefreshToTable()
        bottomView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)

        actualizarUI()
        configurarBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Actualiza los mensajes de las actividades
        self.tableView?.reloadData()
        // Notifica a la app cuando la app retornará al foreground
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    // Función que se ejecuta cuando la app entrará al foreground despues de estar en l background
    @objc func willEnterForeground() {
        print("Entrará a la aplicacion despues del background")
        validarActividadesVencidas()
        cargarActividades()
    }
    // MARK: Variables
    //var actividades: [Actividad] = []
    var dataTask: URLSessionDataTask?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = Actividad.fetchRequest()
        // Valida que solo capture las actividades que no esten vencidas
        fetchRequest.predicate = NSPredicate(format: "vencida == %@", NSNumber(value: false))
        let sortDescriptor = NSSortDescriptor(key: "fecha_limite", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: Outlets
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bannerView: GADBannerView!
    
    
    // MARK: Funciones
    // Verifica que las actividades no estén vencidas
    func validarActividadesVencidas() {
        print("Actividades antes de validar su fecha")
        print(self.fetchedResultsController.fetchedObjects)
        guard let cantidadObjetos = self.fetchedResultsController.fetchedObjects?.count else { return }
        for indice in 0..<cantidadObjetos {
            if let actividad = self.fetchedResultsController.fetchedObjects?[indice] as? Actividad {
                var fechaLimite = Calendar.current.dateComponents([.minute, .hour, .day, .month], from: actividad.fecha_limite ?? Date())
                fechaLimite.year = Funciones().añoActual()
                let actividadNoVencida = Funciones().fechaEsValida(fechaActividad: fechaLimite)
                actividad.vencida = !actividadNoVencida
                Funciones().saveActividad()
            }
        }
    }
    
    // Configuracion necesaria para mostrar el banner de google
    func configurarBanner() {
        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["91edbaa882c469d367e9322c89e96f6d", "25494902e9a1cc44c9164319aa84bc5c"]
        self.bannerView.load(request)
    }
    
    func actualizarUI() {
        guardarActividadesCoreData(datosNexus: GlobalVariables.shared.jsonResponse)
    }
    func addPullDownRefreshToTable() {
        // Detecta cuando el usuarios hace pull down a la tabla
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
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
        dataTask?.cancel()
        guard
            let matricula = UserDefaults.standard.string(forKey: "matricula"),
            let contrasena = UserDefaults.standard.string(forKey: "contrasena")
        else {
            return
        }
        let base = "http://18.191.89.218/nexusApi/"
        let separador = "nexusApiAldo"
        var url = base + matricula + separador + contrasena
        url = url.trimmingCharacters(in: .whitespacesAndNewlines)
//        let url = "https://pastebin.com/raw/B08wxr1d"
        guard let urlRequest = URL(string: url) else { return }
        
        let urlSesion = URLSession(configuration: .ephemeral)
        
        dataTask = urlSesion.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print("Ocurrió un error con el servidor: \(error.localizedDescription)")
            } else if let data = data {
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
        })
        dataTask?.resume()
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
                            nuevaActividad.vencida = false
                            nuevaActividad.materia = materia["materia"] as? String ?? "Materia desconocida"
                            nuevaActividad.nombre = actividad["tarea"]
                            if let fechaNexus = actividad["fecha_limite"] {
                                nuevaActividad.fecha_limite = self.convertToDate(fechaNexus: fechaNexus)
                                // Se crean las notificaciones para la actividad
                                if let tiempo = UserDefaults.standard.array(forKey: "tiemposSeleccionados") as? [Int] {
                                    Funciones().configurarNotificaciones(frecuencia: tiempo, fechaActividad: nuevaActividad.fecha_limite!)
                                } else {
                                    print("Ocurrió un error al generar la notificación")
                                }
                            }
                            print(nuevaActividad)
                            Funciones().saveActividad()
                            print("Actividad guardada correctamente")
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
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Hubo un error al obtener el listado de las actividades")
        }
        for section in fetchedResultsController.sections! {
            print("Seccion \(section): \(section.numberOfObjects) objetos")
        }
        self.tableView?.reloadData()
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "actividadesCell", for: indexPath) as! ActividadesCell
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        guard let actividad = fetchedResultsController.object(at: indexPath) as? Actividad else { return cell }
        cell.materiaLabel.text = actividad.materia
        cell.actividadLabel.text = actividad.nombre
        if let fechaLimite = actividad.fecha_limite {
            cell.fechaLimiteLabel.text = convertNexusDateToString(fecha: fechaLimite)
        }

        cell.recuerdoDiaLabel.text = Funciones().obtenerMensajeTiempoRestante(fechaActividad: actividad.fecha_limite!)

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
