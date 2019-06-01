//
//  Actividad.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 5/31/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

struct Actividad {
    var materia: String
    var actividad: String
    var fechaLimite: String
    
    init(materia: String, actividad: String, fechaLimite: String) {
        self.materia = materia
        self.actividad = actividad
        self.fechaLimite = fechaLimite
    }
    
    init(nombreActividad: String, fechaLimite: String, datosMateria: [String:Any]) {
        if let materia = datosMateria["materia"] {
            self.materia = materia as! String
        } else {
                self.materia = "Materia desconocida"
        }
        self.actividad = nombreActividad
        self.fechaLimite = fechaLimite
    }
}
