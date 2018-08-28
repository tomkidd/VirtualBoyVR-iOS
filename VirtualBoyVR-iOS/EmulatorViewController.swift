//
//  EmulatorViewController.swift
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 8/27/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//

import UIKit
import GLKit

class EmulatorViewController: GLKViewController {
    
//    weak var emulatorCore: PVEmulatorCore?
//    var gameAudio: OEGameAudio?
//    var controllerViewController: PVControllerViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    init(emulatorCore: PVEmulatorCore?) {
//        super.init()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
