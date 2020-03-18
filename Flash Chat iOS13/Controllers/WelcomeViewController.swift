//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    // hide the navigation bar when app first loads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // habit
        navigationController?.isNavigationBarHidden = true
    }
    
    // when we go to next screen, the welcome page will disappear,
    // and we set the navigationbar back on again
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated) // habit
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var charIndex = 0.0 // this is for time delay for each letter
        let titleText = K.appName
        for letter in titleText{
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in // closure
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
       
    }
    
}
