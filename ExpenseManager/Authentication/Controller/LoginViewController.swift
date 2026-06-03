//
//  LoginViewController.swift
//  ExpenseManager
//
//  Created by Mac on 01/06/2026.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
        setLeftIcon(emailTextField, imageName: "person")
        setLeftIcon(passwordTextField, imageName: "lock")
        setupButtons()
    }
    
    func setupButtons() {
        let googleImage = UIImage(named: "google")?.resized(to: CGSize(width: 24, height: 24))
        var googleConfig = googleBtn.configuration ?? .plain()
        googleConfig.image = googleImage
        googleConfig.imagePadding = 8
        googleConfig.imagePlacement = .leading
        googleBtn.configuration = googleConfig
        
        var appleConfig = appleBtn.configuration ?? .plain()
        appleConfig.image = UIImage(systemName: "apple.logo")?.resized(to: CGSize(width: 24, height: 24))
        appleConfig.imagePadding = 8
        appleConfig.imagePlacement = .leading
        appleConfig.baseForegroundColor = .black
        appleBtn.configuration = appleConfig
    }
    
    // MARK: - IBActions
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.navigateToHome()
        }
    }
    
    @IBAction func googleBtnClicked(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                self.navigateToHome()
            }
        }
    }
    
    @IBAction func appleBtnClicked(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Helpers
    func navigateToHome() {
        DispatchQueue.main.async {
            let controller = self.storyboard?
                .instantiateViewController(withIdentifier: "HomeViewController")
                as! HomeViewController
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
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
    }
    
    func setLeftIcon(_ textField: UITextField, imageName: String) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        iconView.image = UIImage(systemName: imageName)
        iconView.tintColor = .gray
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        container.addSubview(iconView)
        textField.leftView = container
        textField.leftViewMode = .always
    }
}

// MARK: - Apple Sign In
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let tokenData = appleIDCredential.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) else { return }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: token,
                rawNonce: "",
                fullName: appleIDCredential.fullName
            )
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                self.navigateToHome()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        showAlert(message: error.localizedDescription)
    }
}

// MARK: - Apple Presentation
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
