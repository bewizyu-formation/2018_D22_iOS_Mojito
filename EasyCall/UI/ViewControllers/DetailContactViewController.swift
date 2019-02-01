//
//  DetailContactViewController.swift
//  EasyCall
//
//  Created by formation 8 on 25/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SkyFloatingLabelTextField
import CoreData

class DetailContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    var contact : Contact!
    var fetchedResultController: NSFetchedResultsController<User>?
    var user : User!
    
    var rightBarButton : UIBarButtonItem!
    
    var alertConfirmDelete: UIAlertController!
    var alertNoConnection: UIAlertController!
    var alertValidUpdate: UIAlertController!
    var profilePicker: UIPickerView!
    var pickerData: [String] = [String]()
    @IBOutlet weak var profileTextField: UITextField!
    var isEditable: Bool = false
    var isEditMode : Bool = false
    var valueSelected : String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewGravatar: UIImageView!
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var invalidPhoneLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var invalidEmailLabel: UILabel!
    @IBOutlet weak var labelEmergency: UILabel!
    @IBOutlet weak var switchEmergency: UISwitch!
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var smsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        firstNameTextField.returnKeyType = .next
        lastNameTextField.returnKeyType = .next
        phoneTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self

        
        profilePicker = UIPickerView()
        profilePicker.delegate = self
        profileTextField.inputView = profilePicker
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.navigationController!.navigationBar.topItem!.title = "Liste"
        self.navigationItem.title = "Détail du contact"
        
        leaveEditMode()
        
        imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .userAlt, style: .solid, textColor: EasyCallStyle.colorPrimary, size: CGSize(width: 200, height: 200))
        
        buttonDelete.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        buttonDelete.setTitle(String.fontAwesomeIcon(name: .trashAlt), for: .normal)
        
        
        smsButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        smsButton.setTitle(String.fontAwesomeIcon(name: .sms), for: .normal)
        
        emailButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        emailButton.setTitle(String.fontAwesomeIcon(name: .envelope), for: .normal)
        
        phoneButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60, style: .solid)
        phoneButton.setTitle(String.fontAwesomeIcon(name: .phoneSquare), for: .normal)
        
        if let url = URL(string: contact?.gravatar ?? "") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.imageViewGravatar.image = UIImage(data: data)
                    }
                } else {
                    self.imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .userAlt, style: .solid, textColor: .blue, size: CGSize(width: 50, height: 50))
                }
            }
        } else {
            imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .userAlt, style: .solid, textColor: .blue, size: CGSize(width: 50, height: 50))
        }
    
        profilePicker.delegate = self
        profilePicker.dataSource = self
        
        labelEmergency.text = "Contact urgent"
        
        initContactValues()
        setupFetchedResultController()
        
        user = fetchedResultController?.object(at: indexPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        super.viewWillAppear(animated)
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
    
    
    /*
    * pickerView settings
    */
    
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
        self.valueSelected = profileTextField.text
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20.0
    }
    
    
    /*
    *   init edit mode or deinit edit mode
    */
    
    func initContactValues(){
        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        phoneTextField.text = contact.phone
        emailTextField.text = contact.email
        profileTextField.text = contact.profile
        if contact.isEmergencyUser == true {
            switchEmergency.isOn = true
        } else {
            switchEmergency.isOn = false
        }
    }
    
    func leaveEditMode(){
        isEditMode = false
        buttonEdit.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        buttonEdit.setTitle(String.fontAwesomeIcon(name: .pencilAlt), for: .normal)
        firstNameTextField.isEnabled = false
        lastNameTextField.isEnabled = false
        phoneTextField.isEnabled = false
        emailTextField.isEnabled = false
        profileTextField.isEnabled = false
        switchEmergency.isEnabled = false
    }
    
    func enterInEditMode(){
        isEditMode = true
        buttonEdit.titleLabel?.font = UIFont.fontAwesome(ofSize: 30, style: .solid)
        buttonEdit.setTitle(String.fontAwesomeIcon(name: .save), for: .normal)
        firstNameTextField.isEnabled = true
        lastNameTextField.isEnabled = true
        phoneTextField.isEnabled = true
        emailTextField.isEnabled = true
        profileTextField.isEnabled = true
        switchEmergency.isEnabled = true
    }
    
    /*
    * edit contact methods
    */
    func displayAlertViewForEditButton(){
        alertValidUpdate = UIAlertController(title: "Succès", message: "Les modifications on été enregistrées.", preferredStyle: UIAlertController.Style.alert)
        alertValidUpdate.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        alertNoConnection = UIAlertController(title: "Pas de connexion", message: "Vous devez être connecté à Internet pour supprimer un contact.", preferredStyle: UIAlertController.Style.alert)
        alertNoConnection.addAction(UIAlertAction(title: "OUI", style: .destructive) { (action:UIAlertAction) in
            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
        })
    }
    
    
    @IBAction func onEditTap(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
             animations: {
                sender.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        },
             completion: { finish in
                UIButton.animate(withDuration: 0.2, animations: {
                    sender.transform = CGAffineTransform.identity
                })
        })
        if isEditMode == false {
            enterInEditMode()
        }else {
            let loader = UIViewController.displaySpinner(onView: self.view)
            guard let phoneNumber = phoneTextField.text else {
                return
            }
            guard let firstName = firstNameTextField.text else {
                return
            }
            guard let lastName = lastNameTextField.text else {
                return
            }
            guard let mail = emailTextField.text else {
                return
            }
            
            var emergency = false
            if switchEmergency.isOn == true {
                emergency = true
            }
            
            displayAlertViewForEditButton()
            if phoneNumber.count == 10 && firstName.count > 2 && lastName.count > 2 && isValidEmail(testStr: mail){
                
                APIClient.instance.updateContact(token: user.token ?? "", id: contact.serverID ?? "badid", phone: phoneNumber, firstName: firstName.capitalized, lastName: lastName.capitalized, email: mail, profile: valueSelected ?? "FAMILLE", gravatar: contact.gravatar!, isFamilinkUser: false, isEmergencyUser: emergency, onSuccess: {
                    DispatchQueue.main.async {
                        self.leaveEditMode()
                        UIViewController.removeSpinner(spinner: loader)
                    }
                }) { (Error) in
                    DispatchQueue.main.async {
                        print(Error)
                        UIViewController.removeSpinner(spinner: loader)
                        self.present(self.alertNoConnection, animated: true, completion: nil)
                    }
                }
            }else {
                UIViewController.removeSpinner(spinner: loader)
                let alertWrongUpdate = UIAlertController(title: "Erreur!", message: "Un ou plusieurs champs ne sont pas bien remplis", preferredStyle: UIAlertController.Style.alert)
                alertWrongUpdate.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertWrongUpdate, animated: true, completion: nil)
            }
        }
    }
    
    /*
    * delete contact
    */
    
    func displayAlertViewForDeleteButton(){
        alertConfirmDelete = UIAlertController(title: "Suppression du contact!", message: "Etes-vous sûr de vouloir supprimer le contact?", preferredStyle: UIAlertController.Style.alert)
        alertNoConnection = UIAlertController(title: "Pas de connexion", message: "Vous devez être connecté à Internet pour supprimer un contact!", preferredStyle: UIAlertController.Style.alert)
        alertNoConnection.addAction(UIAlertAction(title: "OUI", style: .destructive) { (action:UIAlertAction) in
            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
        })
    }
    
    @IBAction func onDeleteTap(_ sender: Any) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        displayAlertViewForDeleteButton()
        alertConfirmDelete.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            APIClient.instance.deleteContact(token: self.user.token ?? "", id: self.contact.serverID ?? "badid", onSuccess: {
                UIViewController.removeSpinner(spinner: loader)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (Error) in
                UIViewController.removeSpinner(spinner: loader)
                DispatchQueue.main.async {
                    print(Error)
                    self.present(self.alertNoConnection, animated: true, completion: nil)
                }
            }
        }))
        
        alertConfirmDelete.addAction(UIAlertAction(title: "Ne pas supprimer", style: .cancel, handler: { (action: UIAlertAction!) in
            UIViewController.removeSpinner(spinner: loader)
        }))
        present(alertConfirmDelete, animated: true, completion: nil)
    }
   
    
    /*
    * interactions methods
    */
    @IBAction func onSMSTap(_ sender: Any) {
        open(scheme: "sms:\(contact.phone!)")
    }
    @IBAction func onMailTap(_ sender: Any) {
        open(scheme: "mail:\(contact.email!)")
    }
    @IBAction func onCallTap(_ sender: Any) {
        open(scheme: "tel:\(contact.phone!)")
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                (success) in
                    print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    
    /*
    * Validation texts
    */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    @IBAction func onEditingPhone(_ sender: UITextField) {
        if sender.text?.count ?? 0 == 10 {
            invalidPhoneLabel.isHidden = true
        } else if sender.text?.count ?? 0 < 10 {
            invalidPhoneLabel.isHidden = false
        } else {
            invalidPhoneLabel.isHidden = false
        }
    }

    @IBAction func onEditingMail(_ sender: UITextField) {
        if self.isValidEmail(testStr: sender.text ?? ""){
            invalidEmailLabel.isHidden = true
        } else {
            invalidEmailLabel.isHidden = false
        }
    }
    
    /*
     * KeyBoard managing
     */
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
        
        let activeField: UITextField? = [firstNameTextField, lastNameTextField, phoneTextField, emailTextField, firstNameTextField].first { $0.isFirstResponder }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        return true
    }
    
    /*
    * get user token for requests API
    */
    
    func setupFetchedResultController(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "token", ascending: true)]
        
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        self.fetchedResultController = resultController
    }
}
