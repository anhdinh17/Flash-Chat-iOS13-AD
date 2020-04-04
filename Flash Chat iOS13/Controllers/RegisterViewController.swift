//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        // .text is String optional, optional binding both email and password on same line
        // to make sure that neither of them is nil
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            // Codes from Firabase to register with email and password
            // this registration is saved on Firebase
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{ // if there's error
                    print(e.localizedDescription)
                } else{
                    // Navigate to the chatViewController when there's no error
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
                
            }
        }
    }
    
}
