//
//  CreateAccountViewController.swift
//  EasyCall
//
//  Created by formation2 on 24/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var invalidPhoneLabel: UILabel!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var wrondConfirmPasswordLabel: UILabel!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var profileTextField: UITextField!
    
    var profilePicker: UIPickerView!
    var pickerData: [String] = [String]()
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Inscription"
        profilePicker = UIPickerView()
        profilePicker.delegate = self
        registerForKeyboardNotifications()
        
        firstNameTextField.returnKeyType = .next
        lastNameTextField.returnKeyType = .next
        phoneTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .next
        confirmPasswordTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        emailTextField.delegate = self
        profileTextField.delegate = self
        profileTextField.inputView = profilePicker
        
        buttonSignUp.setTitleColor(EasyCallStyle.colorPrimary, for: .normal)
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        APIClient.instance.getProfiles(onSuccess: { (profiles) in
            self.pickerData = profiles
            UIViewController.removeSpinner(spinner: loader)
            DispatchQueue.main.async {
                self.profilePicker.reloadComponent(0)
            }
        }, onError: { (error) in
            UIViewController.removeSpinner(spinner: loader)
            let loadProfilesFailedAlert = UIAlertController(title: "Chargement impossible", message: "une erreur inconnue est survenue", preferredStyle: UIAlertController.Style.alert)
            loadProfilesFailedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(loadProfilesFailedAlert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        })
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
        
        let activeField: UITextField? = [firstNameTextField, lastNameTextField, phoneTextField, passwordTextField, confirmPasswordTextField, emailTextField, profileTextField].first { $0.isFirstResponder }
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
    
    @IBAction func singUpPressed(_ sender: Any) {
        self.createAccount()
    }
    
    @IBAction func phoneEditingChanged(_ sender: UITextField) {
        if sender.text?.count ?? 0 == 10 {
            invalidPhoneLabel.isHidden = true
        } else if sender.text?.count ?? 0 < 10 {
            invalidPhoneLabel.isHidden = false
        } else {
            invalidPhoneLabel.isHidden = false
        }
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        if self.isValidEmail(testStr: sender.text ?? ""){
            invalidEmailLabel.isHidden = true
        } else {
            invalidEmailLabel.isHidden = false
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField: UITextField?
        
        switch textField {
        case lastNameTextField:
            nextTextField = firstNameTextField
        case firstNameTextField:
            nextTextField = phoneTextField
        case phoneTextField:
            nextTextField = passwordTextField
        case passwordTextField:
            nextTextField = confirmPasswordTextField
        case confirmPasswordTextField:
            nextTextField = emailTextField
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
    
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
        if passwordTextField.text == confirmPasswordTextField.text {
            wrongPasswordLabel.isHidden = true
        } else {
            wrongPasswordLabel.isHidden = false
        }
    }
    @IBAction func confirmPasswordEditingChanged(_ sender: UITextView) {
        if passwordTextField.text == confirmPasswordTextField.text {
            wrondConfirmPasswordLabel.isHidden = true
            wrongPasswordLabel.isHidden = true
        } else {
            wrondConfirmPasswordLabel.isHidden = false
        }
    }
    func createAccount(){
        let loader = UIViewController.displaySpinner(onView: self.view)
        if !firstNameTextField.text!.isEmpty && !(lastNameTextField.text?.isEmpty)! && passwordTextField.text == confirmPasswordTextField.text && self.isValidEmail(testStr: emailTextField.text ?? "") && phoneTextField.text?.count == 10 {
            
            APIClient.instance.createUser(phone: self.phoneTextField.text!,password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: self.emailTextField.text!, profile: self.pickerData[self.profilePicker.selectedRow(inComponent: 0)], onSuccess: { (userInfo) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    let creationAlert = UIAlertController(title: "Création réussie", message: "L'utilisateur " + userInfo[1] + " a bien été créé", preferredStyle: UIAlertController.Style.alert)
                    let navigateToLogin = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    creationAlert.addAction(navigateToLogin)
                    self.present(creationAlert, animated: true, completion: nil)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: loader)
                    guard let error = error as? ApiError else {
                        return
                    }
                    var apiError: String!
                    switch error {
                    case ApiError.UnknownError:
                        apiError = "Une erreur inconnue est survenue"
                    case ApiError.PhoneUnique:
                        apiError = "Le numéro de téléphone est déjà utilisé"
                    default:
                        apiError = "Une erreur inconnue est survenue"
                    }
                    let creationFailedAlert = UIAlertController(title: "Création impossible", message: apiError, preferredStyle: UIAlertController.Style.alert)
                    creationFailedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(creationFailedAlert, animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            UIViewController.removeSpinner(spinner: loader)
            let invalidFieldsAlert = UIAlertController(title: "Création impossible", message: "Les champs doivent être correctement renseignés", preferredStyle: UIAlertController.Style.alert)
            invalidFieldsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(invalidFieldsAlert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            wrondConfirmPasswordLabel.isHidden = false
            wrongPasswordLabel.isHidden = false
            invalidPhoneLabel.isHidden = false
            invalidEmailLabel.isHidden = false
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
}

