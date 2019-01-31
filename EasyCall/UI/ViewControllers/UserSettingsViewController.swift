//
//  LogoutViewController.swift
//  EasyCall
//
//  Created by formation2 on 29/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import CoreData
class UserSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var validateAndCancelStackView: UIStackView!
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    var profilePicker: UIPickerView!
    var pickerData: [String] = [String]()
    var userToken: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Mon compte"
        registerForKeyboardNotifications()
        
        profilePicker = UIPickerView()
        profilePicker.delegate = self
        profileTextField.inputView = profilePicker
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        let results = try? context.fetch(fetchRequest)
        
        guard let user = results?.first else {
            return
        }
        profileTextField.text = user.profile
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        emailTextField.text = user.email
        userToken = user.token
        
        firstNameTextField.returnKeyType = .next
        lastNameTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        profileTextField.delegate = self
        
        self.editButton.backgroundColor = EasyCallStyle.colorPrimary
        self.cancelButton.backgroundColor = EasyCallStyle.colorPrimary
        self.validateButton.backgroundColor = EasyCallStyle.colorPrimary
        self.logoutButton.backgroundColor = UIColor.red
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
        
        let activeField: UITextField? = [firstNameTextField, lastNameTextField, emailTextField, profileTextField].first { $0.isFirstResponder }
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
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        changeEditable(true)
        sender.isHidden = true
        validateAndCancelStackView.isHidden = false
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
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        profileTextField.text = pickerData[row]
        profileTextField.resignFirstResponder()
    }
    
    func changeEditable(_ isEditable: Bool){
        lastNameTextField.isEnabled = isEditable
        firstNameTextField.isEnabled = isEditable
        emailTextField.isEnabled = isEditable
        profileTextField.isEnabled = isEditable
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        let results = try? context.fetch(fetchRequest)
        
        guard let user = results?.first else {
            return
        }
        profileTextField.text = user.profile
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        emailTextField.text = user.email
        
        changeEditable(false)
        validateAndCancelStackView.isHidden = true
        editButton.isHidden = false
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func disconnectButtonPressed(_ sender: Any) {
        
        let connectionAlert = UIAlertController(title: "Attention", message: "Etes vous sûr de vouloir vous deconnecter ?", preferredStyle: UIAlertController.Style.alert)
        let navigateToLogin = UIAlertAction(title: "OUI", style: .destructive) { (action:UIAlertAction) in
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
            
            try? context.save()
            
            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
        }
        let cancelLogout = UIAlertAction(title: "NON", style: .cancel, handler: nil)
        connectionAlert.addAction(cancelLogout)
        connectionAlert.addAction(navigateToLogin)
        self.present(connectionAlert, animated: true, completion: nil)
    }
    @IBAction func validateButtonPressed(_ sender: Any) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        if !firstNameTextField.text!.isEmpty && !(lastNameTextField.text?.isEmpty)! && isValidEmail(testStr: emailTextField.text ?? "") {
            APIClient.instance.updateUser(token: userToken, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, profile: profileTextField.text!, onSuccess: { (newUserInfo) in
                DispatchQueue.main.async {
                    self.updateUserInfo(newUserInfo)
                    self.changeEditable(false)
                    self.validateAndCancelStackView.isHidden = true
                    self.editButton.isHidden = false
                    UIViewController.removeSpinner(spinner: loader)
                }
            }) { (error) in
                UIViewController.removeSpinner(spinner: loader)
                guard let apiError = error as? ApiError else {
                    return
                }
                DispatchQueue.main.async {
                    if apiError == ApiError.InvalidToken {
                        let updateAlert = UIAlertController(title: "Modification impossible", message: "Votre session a expiré", preferredStyle: UIAlertController.Style.alert)
                        let navigateToLogin = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
                        }
                        updateAlert.addAction(navigateToLogin)
                        self.present(updateAlert, animated: true, completion: nil)
                    } else {
                        let updateAlert = UIAlertController(title: "Modification impossible", message: "Une erreur inconnue est survenue", preferredStyle: UIAlertController.Style.alert)
                        let unknownError = UIAlertAction(title: "OK", style: .default, handler: nil)
                        updateAlert.addAction(unknownError)
                        self.present(updateAlert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            UIViewController.removeSpinner(spinner: loader)
            let updateAlert = UIAlertController(title: "Modification impossible", message: "Votre session a expiré", preferredStyle: UIAlertController.Style.alert)
            let navigateToLogin = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                // NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
            }
            updateAlert.addAction(navigateToLogin)
            self.present(updateAlert, animated: true, completion: nil)
        }
    }
    
    func updateUserInfo(_ newInfo: [String]){
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
        
        user.token = self.userToken
        user.phone = newInfo[0]
        user.firstName = newInfo[1]
        user.lastName = newInfo[2]
        user.email = newInfo[3]
        user.profile = newInfo[4]
        
        context.insert(user)
        
        try? context.save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField: UITextField?
        
        switch textField {
        case lastNameTextField:
            nextTextField = firstNameTextField
        case firstNameTextField:
            nextTextField = emailTextField
        case emailTextField:
            nextTextField = profileTextField
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
