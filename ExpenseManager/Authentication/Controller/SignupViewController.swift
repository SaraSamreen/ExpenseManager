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
        guard let username = usernameTextField.text, !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(message: "Please enter a username")
            return
        }
        
        guard username.trimmingCharacters(in: .whitespaces).count >= 3 else {
            showAlert(message: "Username must be at least 3 characters")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            showAlert(message: "Please enter a valid email address")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter a password")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(message: "Password must be at least 6 characters")
            return
        }
        
        showLoader()
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.hideLoader()
                self.showAlert(message: error.localizedDescription)
                return
            }
            
            // ✅ Save username to Firebase Auth profile
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { error in
                self.hideLoader()
                self.navigateToHome()
            }
        }}
    
    // MARK: - Helpers
    func showLoader() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tag = 999
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        view.isUserInteractionEnabled = false
    }

    func hideLoader() {
        view.viewWithTag(999)?.removeFromSuperview()
        view.isUserInteractionEnabled = true
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

    
