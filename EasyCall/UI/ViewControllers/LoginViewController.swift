//
//  LoginViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController {
    
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
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connexion"
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        phoneInput.keyboardType = UIKeyboardType.numberPad
        passwordInput.keyboardType = UIKeyboardType.numberPad
        
        phoneErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        //Remplacer "empty.png" par le logo
        let imageLogo = UIImage(named: "empty.png")
        logo.image = imageLogo
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        phoneInput.inputAccessoryView = keyboardToolBar
        passwordInput.inputAccessoryView = keyboardToolBar
        
        
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
        
        if phoneInput.text?.count == 10 && passwordInput.text?.count == 4 {
          
            //TODO: Appel API

        }
        
    }
    
    @IBAction func signUpTouch(_ sender: Any) {
        let vc = SignUpViewController(
            nibName: "SignUpViewController",
            bundle: nil)
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    @IBAction func forgotPasswordTouch(_ sender: Any) {
        let vc = ForgotPasswordViewController(
            nibName: "ForgotPasswordViewController",
            bundle: nil)
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
}

