//
//  ConfiguracionViewController.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 7/5/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation
import GoogleMobileAds

class ConfiguracionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.rootViewController = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        let request = GADRequest()
        request.testDevices = ["91edbaa882c469d367e9322c89e96f6d", "25494902e9a1cc44c9164319aa84bc5c"]
        bannerView.load(request)
    }
    
    // MARK: Outlets
    @IBOutlet var bannerView: GADBannerView!
}
