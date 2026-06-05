//
//  SignupViewController.swift
//  ExpenseManager
//
//  Created by Mac on 01/06/2026.
//

import UIKit
import Firebase
import FirebaseAuth


class SignupViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleTextField(usernameTextField)
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
    }
    
    // MARK: - IBActions
       @IBAction func signupBtnClicked(_ sender: UIButton) {
           guard let email = emailTextField.text, !email.isEmpty,
                 let password = passwordTextField.text, !password.isEmpty else {
               showAlert(message: "Please fill in all fields")
               return
           }
           
           Auth.auth().createUser(withEmail: email, password: password) { result, error in
               if let error = error {
                   self.showAlert(message: error.localizedDescription)
                   return
               }
               // Go to home screen
               self.navigateToHome()
           }
       }
    
    func navigateToHome() {
        DispatchQueue.main.async {
            let tabBar = self.storyboard?
                .instantiateViewController(withIdentifier: "MainTabBarController")
                as! UITabBarController
            tabBar.modalPresentationStyle = .fullScreen
            self.present(tabBar, animated: true)
        }
    }

    func showAlert(message: String) {
            let alert = UIAlertController(title: "Error",
                                         message: message,
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textField.borderStyle = .none
        
        // Left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
}
