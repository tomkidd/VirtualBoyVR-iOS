//
//  HomeViewController.swift
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 8/30/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//

import UIKit
import PVSupport

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PVControllerManager.shared()
        PVSettingsModel.sharedInstance()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let game = PVGame()
        game.romPath = Bundle.main.resourcePath! + "/roms/Virtual_Boy_Wario_Land_(JU)_[!].vb"
        game.systemIdentifier = "com.provenance.vb"
        
        (segue.destination as! PVEmulatorViewController).game = game
        
        let config = PVEmulatorConfiguration.sharedInstance()
        
        (segue.destination as! PVEmulatorViewController).batterySavesPath = config.batterySavesPath(forROM: game.romPath)
        (segue.destination as! PVEmulatorViewController).biosPath = config.biosPath(forSystemID: game.systemIdentifier)
        (segue.destination as! PVEmulatorViewController).saveStatePath = config.saveStatePath(forROM: game.romPath)
        (segue.destination as! PVEmulatorViewController).systemID = game.systemIdentifier
        (segue.destination as! PVEmulatorViewController).modalTransitionStyle = .crossDissolve

        
    }

}
