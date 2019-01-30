//
//  LoginViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var loginView: UIView!
    @IBOutlet weak var mainScrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connexion"
        
        phoneErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        forgotPasswordButton.setTitleColor(EasyCallStyle.colorPrimary, for: .normal)
        signInButton.backgroundColor = EasyCallStyle.colorPrimary
        signUpButton.backgroundColor = EasyCallStyle.colorSecondary
        
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        
        //Remplacer "empty.png" par le logo
        let imageLogo = UIImage(named: "empty.png")
        logo.image = imageLogo
        
        registerForKeyboardNotifications()
        
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name:UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // Don't forget to unregister when done
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your application might not need or want this behavior.
        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        
        let activeField: UITextField? = [phoneTextField, passwordTextField].first { $0.isFirstResponder }
        if let activeField = activeField {
            if aRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y-kbSize.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @IBAction func onPhoneValueChange(_ sender: Any) {
        if phoneTextField.text?.count != 10 {
            phoneErrorLabel.isHidden = false
        }else{
            phoneErrorLabel.isHidden = true
        }
    }
    
    @IBAction func onPasswordValueChange(_ sender: Any) {
        if passwordTextField.text?.count != 4 {
            passwordErrorLabel.isHidden = false
        }else{
            passwordErrorLabel.isHidden = true
        }
    }
    
    @IBAction func signInTouch(_ sender: Any) {
        
        print("connection")
        
        if phoneTextField.text?.count == 10 && passwordTextField.text?.count == 4 {
            
            APIClient.instance.login(phone: self.phoneTextField.text!, password: self.passwordTextField.text!, onSuccess: { (token) in
                print("logged")
                APIClient.instance.getCurrentUser(token: token, onSuccess: { (userInfo) in
                    print("get current user")
                    DispatchQueue.main.async {
                        
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        
                        let context = appDelegate.persistentContainer.viewContext
                        
                        let fetchRequest = NSFetchRequest<User>(entityName: "User")
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
                        
                        let results = try? context.fetch(fetchRequest)
                        
                        guard let users = results else {
                            return
                        }
                        
                        for user in users{
                            context.delete(user)
                        }
                        
                        let user = User(context: context)
                        
                        user.token = token
                        user.phone = userInfo[0]
                        user.firstName = userInfo[1]
                        user.lastName = userInfo[2]
                        user.email = userInfo[3]
                        user.profile = userInfo[4]
                        
                        context.insert(user)
                        
                        try? context.save()
                        
                        let connectionAlert = UIAlertController(title: "Connexion réussie", message: "Vous etes maintenant connecté", preferredStyle: UIAlertController.Style.alert)
                        let navigateToLogin = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
                        }
                        connectionAlert.addAction(navigateToLogin)
                        self.present(connectionAlert, animated: true, completion: nil)
                        
                        
                    }
                }, onError: { (error) in
                    guard let error = error as? ApiError else {
                        return
                    }
                    var apiError: String!
                    switch error {
                    case ApiError.InvalidPassword:
                        apiError = "Mot de passe non valide"
                    case ApiError.UnknownUser:
                        apiError = "Numéro de téléphone inconnu"
                    default:
                        apiError = "Une erreur inconnue est survenue"
                    }
                    let connectionFailedAlert = UIAlertController(title: "Connexion impossible", message: apiError, preferredStyle: UIAlertController.Style.alert)
                    connectionFailedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(connectionFailedAlert, animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                })
                
                
            }) { (error) in
                print(error)
                DispatchQueue.main.async{
                        let alertController = UIAlertController(title: "Erreur de connexion", message: "Numéro de téléphone ou mot de passe incorrect", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default ){ action in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true)
                }
            }
            
        }
        
    } 
    
    //A décommenter quand les pages existeront
    
    @IBAction func signUpTouch(_ sender: Any) {
        
         let vc = CreateAccountViewController(
         nibName: "CreateAccountViewController",
         bundle: nil)
         navigationController?.pushViewController(vc,
         animated: true)
    }
    
    @IBAction func forgotPasswordTouch(_ sender: Any) {
        
        let alertForgotPassword = UIAlertController(title: "Problème de mémoire ?", message: "IL NE FAUT JAMAIS OUBLIER SON MOT DE PASSE !", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default ){ action in
            self.dismiss(animated: true, completion: nil)
        }
        alertForgotPassword.addAction(okAction)
        self.present(alertForgotPassword, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField: UITextField?
        
        switch textField {
        case phoneTextField:
            nextTextField = passwordTextField
        default:
            textField.resignFirstResponder()
        }
        
        guard let nextResponder = nextTextField else {
            return true
        }
        
        nextResponder.becomeFirstResponder()
        scrollView.scrollRectToVisible(nextResponder.frame, animated: true)
        
        return true
    }
}

