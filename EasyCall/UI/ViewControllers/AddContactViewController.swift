//
//  AddContactViewController.swift
//  EasyCall
//
//  Created by formation2 on 29/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileTextField: UITextField!
    @IBOutlet weak var isEmergencyContactSwitch: UISwitch!
    @IBOutlet weak var isEasyCallUserSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emptyLastNameLabel: UILabel!
    @IBOutlet weak var emptyFirstNameLabel: UILabel!
    @IBOutlet weak var invalidPhoneLabel: UILabel!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var buttonAddContact: UIButton!
    
    var userToken : String!
    var profilePicker: UIPickerView!
    var pickerData: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Créer un Contact"
        
        registerForKeyboardNotifications()
        
        firstNameTextField.returnKeyType = .next
        lastNameTextField.returnKeyType = .next
        phoneTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
        profilePicker = UIPickerView()
        profilePicker.delegate = self
        profileTextField.inputView = profilePicker
        
        buttonAddContact.backgroundColor = EasyCallStyle.colorPrimary
        
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
        userToken = user.token
    }
    override func viewWillAppear(_ animated: Bool) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        APIClient.instance.getProfiles(onSuccess: { (profiles) in
            self.pickerData = profiles
            DispatchQueue.main.async {
                self.profilePicker.reloadComponent(0)
            }
            UIViewController.removeSpinner(spinner: loader)
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
        
        let activeField: UITextField? = [firstNameTextField, lastNameTextField, phoneTextField, emailTextField, profileTextField].first { $0.isFirstResponder }
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
    
    @IBAction func emailEditingDidChanged(_ sender: UITextField) {
        if isValidEmail(testStr: sender.text ?? "") {
            invalidEmailLabel.isHidden = true
        } else {
            invalidEmailLabel.isHidden = false
        }
    }
    
    @IBAction func phoneEditingDidChanged(_ sender: UITextField) {
        if sender.text?.count ?? 0 == 10{
            invalidPhoneLabel.isHidden = true
        } else if sender.text?.count ?? 0 < 10 {
            invalidPhoneLabel.isHidden = false
        } else {
            invalidPhoneLabel.isHidden = false
        }
    }
    @IBAction func lastNameEditingChanged(_ sender: UITextField) {
        if sender.text?.isEmpty ?? false {
            emptyLastNameLabel.isHidden = false
        } else {
            emptyLastNameLabel.isHidden = true
        }
    }
    @IBAction func firstNameEditingDidChanged(_ sender: UITextField) {
        if sender.text?.isEmpty ?? false {
            emptyFirstNameLabel.isHidden = false
        } else {
            emptyFirstNameLabel.isHidden = true
        }
    }
    
    @IBAction func addContactButtonPressed(_ sender: UIButton) {
        createContact()
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func createContact(){
        let loader = UIViewController.displaySpinner(onView: self.view)
        if !firstNameTextField.text!.isEmpty && !(lastNameTextField.text?.isEmpty)! && self.isValidEmail(testStr: emailTextField.text ?? "") && phoneTextField.text?.count == 10 {
            APIClient.instance.createContact(token: userToken, phone: phoneTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, profile: profileTextField.text!, gravatar: "https://www.gravatar.com/avatar/", isFamilinkUser: isEasyCallUserSwitch.isOn, isEmergencyUser: isEmergencyContactSwitch.isOn, onSuccess: { (contactInfo) in
                DispatchQueue.main.async {
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
                    let contact = Contact(context: context)
                    contact.email = contactInfo["email"] as? String
                    contact.firstName = contactInfo["firstName"] as? String
                    contact.lastName = contactInfo["lastName"] as? String
                    contact.gravatar = contactInfo["gravatar"] as? String
                    contact.phone = contactInfo["phone"] as? String
                    contact.profile = contactInfo["profile"] as? String
                    contact.serverID = contactInfo["_id"] as? String
                    contact.isEmergencyUser = contactInfo["isEmergencyUser"] as! Bool
                    contact.isFamilinkUser = contactInfo["isFamilinkUser"] as! Bool
                    
                    context.insert(contact)
                    
                    user.addToContacts(contact)
                    
                    try? context.save()
                    UIViewController.removeSpinner(spinner: loader)
                    self.navigationController?.popViewController(animated: true)
                }
                
                
            }) { (error) in
                UIViewController.removeSpinner(spinner: loader)
                DispatchQueue.main.async {
                    guard let error = error as? ApiError else {
                        return
                    }
                    var apiError: String!
                    switch error {
                    case ApiError.InvalidToken:
                        apiError = "Session non valide, veuillez vous reconnecter"
                    default:
                        apiError = "Une erreur inconnue est survenue"
                    }
                    let addContactAlert = UIAlertController(title: "Création impossible", message: apiError, preferredStyle: UIAlertController.Style.alert)
                    let navigateToLogin = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                        NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
                    }
                    addContactAlert.addAction(navigateToLogin)
                    self.present(addContactAlert, animated: true, completion: nil)
                }
            }
        } else {
            UIViewController.removeSpinner(spinner: loader)
            invalidEmailLabel.isHidden = false
            invalidPhoneLabel.isHidden = false
            emptyLastNameLabel.isHidden = false
            emptyFirstNameLabel.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField: UITextField?
        
        switch textField {
        case lastNameTextField:
            nextTextField = firstNameTextField
        case firstNameTextField:
            nextTextField = phoneTextField
        case phoneTextField:
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
}

