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
    
    @IBOutlet weak var phoneInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        phoneErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        phoneInput.delegate = self
        passwordInput.delegate = self
        
        //Remplacer "empty.png" par le logo
        let imageLogo = UIImage(named: "empty.png")
        logo.image = imageLogo
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardHeight =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        mainScrollViewBottomConstraint.constant = -keyboardHeight.height/3
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        mainScrollViewBottomConstraint.constant = 0
    }
    
    @IBAction func onPhoneValueChange(_ sender: Any) {
        if phoneInput.text?.count != 10 {
            phoneErrorLabel.isHidden = false
        }else{
            phoneErrorLabel.isHidden = true
        }
    }
    
    @IBAction func onPasswordValueChange(_ sender: Any) {
        if passwordInput.text?.count != 4 {
            passwordErrorLabel.isHidden = false
        }else{
            passwordErrorLabel.isHidden = true
        }
    }
    
   
    
    @IBAction func signInTouch(_ sender: Any) {
        
        print("connection")
        
        if phoneInput.text?.count == 10 && passwordInput.text?.count == 4 {
            
            APIClient.instance.login(phone: self.phoneInput.text!, password: self.passwordInput.text!, onSuccess: { (token) in
                print("logged")
                APIClient.instance.getCurrentUser(token: token, onSuccess: { (userInfo) in
                    print("get current user")
                    DispatchQueue.main.async {
                        
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        
                        let context = appDelegate.persistentContainer.viewContext
                        
                        let user = User(context: context)
                    
                        let fetchRequest = NSFetchRequest<User>(entityName: "User")
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
                        
                        let results = try? context.fetch(fetchRequest)
                        
                        
                        
                        guard let users = results else {
                            return
                        }
                        
                        for user in users{
                            context.delete(user)
                        }
                        
                        try? context.save()
                        
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
        /*
         let vc = ForgotPasswordViewController(
         nibName: "ForgotPasswordViewController",
         bundle: nil)
         navigationController?.pushViewController(vc,
         animated: true)*/
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField: UITextField?
        
        switch textField {
        case phoneInput:
            nextTextField = passwordInput
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
    
    /*@objc func doneClicked() {
        view.endEditing(true)
    }*/

}

