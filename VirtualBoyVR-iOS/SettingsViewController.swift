//
//  SettingsViewController.swift
//  VirtualBoyVR-iOS
//
//  Created by Tom Kidd on 9/16/18.
//  Copyright © 2018 Tom Kidd. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var sbsSlider: UISlider!
    @IBOutlet weak var sbsValue: UILabel!
    @IBOutlet weak var scale: UIButton!
        
    let defaults = UserDefaults()
    
    let screenScales = [1: UIScreen.main.scale == 1.0 ? "1x (native)" : "1x",
                        1.25: "1.25x",
                        1.5: "1.5x",
                        1.75: "1.75x",
                        2: UIScreen.main.scale == 2.0 ? "2x (native)" : "2x",
                        2.25: "2.25x",
                        2.5: "2.5x",
                        2.75: "2.75x",
                        3: UIScreen.main.scale == 3.0 ? "3x (native)" : "3x",
                        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = Utilities.hexStringToUIColor(hex: "#cc0000")
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:Utilities.hexStringToUIColor(hex: "#cc0000"),
                              NSAttributedStringKey.font: UIFont(name: "VirtualLogo", size: 23)!]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes;
        self.navigationController?.navigationBar.isTranslucent = false

        sbsSlider.setValue(Float(defaults.integer(forKey: "sbs")), animated: false)
        sbsValue.text = "\(defaults.integer(forKey: "sbs"))"
        
        let s = defaults.float(forKey: "scale")
        
        switch s {
        case 1.0:
            scale.setTitle(UIScreen.main.scale == 1.0 ? "1x (native)" : "1x", for: .normal)
        case 1.25:
            scale.setTitle("1.25x", for: .normal)
        case 1.5:
            scale.setTitle("1.5x", for: .normal)
        case 1.75:
            scale.setTitle("1.75x", for: .normal)
        case 2.0:
            scale.setTitle(UIScreen.main.scale == 2.0 ? "2x (native)" : "2x", for: .normal)
        case 2.25:
            scale.setTitle("2.25x", for: .normal)
        case 2.5:
            scale.setTitle("2.5x", for: .normal)
        case 2.75:
            scale.setTitle("2.75x", for: .normal)
        case 3.0:
            scale.setTitle(UIScreen.main.scale == 3.0 ? "3x (native)" : "3x", for: .normal)
        default:
            scale.setTitle("ERROR", for: .normal)
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sbsValueChanged(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(.down), animated: true)
        defaults.set(Int(sender.value), forKey: "sbs")
        sbsValue.text = "\(Int(sender.value))"
    }
    
    @IBAction func resetSBS(_ sender: UIButton) {
        sbsSlider.setValue(60, animated: false)
        defaults.set(60, forKey: "sbs")
        sbsValue.text = "60"
    }
    
    @IBAction func chooseScale(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let screenScaleKeys = Array(screenScales.keys).sorted()
        for screenScaleKey in screenScaleKeys {
            
            alert.addAction(UIAlertAction(title: screenScales[screenScaleKey], style: .destructive, handler: { (action) in
                sender.setTitle(action.title, for: .normal)
                self.defaults.set(Float(screenScaleKey), forKey: "scale")
            }))
        }
        
        self.present(alert, animated: true, completion: nil)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
