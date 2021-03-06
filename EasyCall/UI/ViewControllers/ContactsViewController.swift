//
//  ContactsTableViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import CoreData
import FontAwesome_swift

class ContactsViewController: UIViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate {
     
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewFilters: UIView!
    @IBOutlet weak var buttonFilterAll: UIButton!
    @IBOutlet weak var buttonFilterFamily: UIButton!
    @IBOutlet weak var buttonFilterSenior: UIButton!
    @IBOutlet weak var buttonFilterDoctor: UIButton!
    @IBOutlet weak var buttonFilterEmergency: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fetchedResultController: NSFetchedResultsController<Contact>?
    
    var nameFilter: String?
    var profileFilter: String?
    var emergencyFilter: Int?
    
    var userToken: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButtonIcon = UIImage.fontAwesomeIcon(name: .userCog, style: .solid, textColor: .blue, size: CGSize(width: 35, height: 35))
        let leftBarButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.done, target: self, action: #selector(navigateToUserSettings))
        leftBarButton.image = leftButtonIcon
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigateToAddContact))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.navigationItem.title = "Mes contacts"
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")

        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        buttonFilterFamily.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        buttonFilterFamily.setTitle(String.fontAwesomeIcon(name: .users), for: .normal)
        buttonFilterSenior.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        buttonFilterSenior.setTitle(String.fontAwesomeIcon(name: .blind), for: .normal)
        buttonFilterDoctor.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        buttonFilterDoctor.setTitle(String.fontAwesomeIcon(name: .userMd), for: .normal)
        buttonFilterEmergency.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
        buttonFilterEmergency.setTitle(String.fontAwesomeIcon(name: .exclamationCircle), for: .normal)
        
        searchBar.delegate = self
        setHeaderStyle()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupFetchedResultController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.synchroniseWithAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func navigateToAddContact(){
        let addContactController = AddContactViewController(nibName: "AddContactViewController", bundle: nil)
        navigationController?.pushViewController(addContactController, animated: true)
    }
    
    @objc func navigateToUserSettings() {
        let userSettingsController = UserSettingsViewController(nibName: "UserSettingsViewController", bundle: nil)
        navigationController?.pushViewController(userSettingsController, animated: true)
    }
    
    // MARK: - Header style
    
    func setHeaderStyle() {
        self.viewFilters.backgroundColor = EasyCallStyle.colorSecondary
        self.buttonFilterAll.backgroundColor = EasyCallStyle.colorSecondary
        self.buttonFilterAll.setTitle("TOUS", for: .normal)
        self.buttonFilterFamily.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterSenior.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterDoctor.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterEmergency.backgroundColor = EasyCallStyle.colorPrimary
        self.searchBar.barTintColor = EasyCallStyle.colorPrimary
        self.searchBar.tintColor = EasyCallStyle.colorPrimary
    }
    
    // MARK: - Header interaction methods
    
    func setNameFilter(nameFilter: String?) {
        self.nameFilter = nameFilter
    }
    
    func setEmergencyFilter(emergencyFilter: Int?) {
        self.emergencyFilter = emergencyFilter
    }
    
    func setProfileFilter(profileFilter: String?) {
        self.profileFilter = profileFilter
    }
    
    func setProfileAndEmergencyFilters(profileFilter: String?, emergencyFilter: Int?) {
        self.setProfileFilter(profileFilter: profileFilter)
        self.setEmergencyFilter(emergencyFilter: emergencyFilter)
    }
    
    func resetFilters() {
        self.nameFilter = nil
        self.profileFilter = nil
        self.emergencyFilter = nil
    }
    
    func getNSPredicate() -> NSPredicate? {
        if let nameFilter = self.nameFilter, let emergencyFilter = self.emergencyFilter {
            return NSPredicate(format: "(firstName CONTAINS[c] '\(nameFilter)' OR lastName CONTAINS[c] '\(nameFilter)') AND isEmergencyUser == \(emergencyFilter)")
        } else if let nameFilter = self.nameFilter, let profileFilter = self.profileFilter {
            return NSPredicate(format: "(firstName CONTAINS[c] '\(nameFilter)' OR lastName CONTAINS[c] '\(nameFilter)') AND profile == %@", profileFilter)
        } else if let nameFilter = self.nameFilter {
            return NSPredicate(format: "firstName CONTAINS[c] '\(nameFilter)' OR lastName CONTAINS[c] '\(nameFilter)'")
        } else if let emergencyFilter = self.emergencyFilter {
            return NSPredicate(format: "isEmergencyUser == \(emergencyFilter)")
        } else if let profileFilter = self.profileFilter {
            return NSPredicate(format: "profile == %@", profileFilter)
        } else {
            return nil
        }
    }
    
    @IBAction func onTapFilter(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
             animations: {
                sender.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        },
             completion: { finish in
                UIButton.animate(withDuration: 0.2, animations: {
                    sender.transform = CGAffineTransform.identity
                })
        })
        switch(sender) {
        case self.buttonFilterFamily:
            self.setProfileAndEmergencyFilters(profileFilter: "FAMILLE", emergencyFilter: nil)
        case self.buttonFilterSenior:
            self.setProfileAndEmergencyFilters(profileFilter: "SENIOR", emergencyFilter: nil)
        case self.buttonFilterDoctor:
            self.setProfileAndEmergencyFilters(profileFilter: "MEDECIN", emergencyFilter: nil)
        case self.buttonFilterEmergency:
            self.setProfileAndEmergencyFilters(profileFilter: nil, emergencyFilter: 1)
        default :
            self.setProfileAndEmergencyFilters(profileFilter: nil, emergencyFilter: nil)
        }
        self.buttonFilterFamily.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterSenior.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterDoctor.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterEmergency.backgroundColor = EasyCallStyle.colorPrimary
        self.buttonFilterAll.backgroundColor = EasyCallStyle.colorPrimary
        sender.backgroundColor = EasyCallStyle.colorSecondary
        self.updatePredicateAndReloadData()
    }
    
    func searchBar(_: UISearchBar, textDidChange: String) {
        if textDidChange != "" {
            self.nameFilter = textDidChange
        } else {
            self.nameFilter = nil
        }
        self.updatePredicateAndReloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.updatePredicateAndReloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.setNameFilter(nameFilter: nil)
        self.updatePredicateAndReloadData()
    }
    
    // MARK: - Method to call, message and mail contact from application
    
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
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultController?.sections?[section].numberOfObjects ?? 0
    }
    
    func configureContactCell(cell: ContactTableViewCell, withContact contact: Contact?){
        cell.labelContactFirstName?.text = contact?.firstName ?? "Prénom"
        cell.labelContactFirstName.textColor = EasyCallStyle.colorPrimary
        cell.labelContactLastName?.text = contact?.lastName ?? "Nom"
        cell.labelContactLastName.textColor = EasyCallStyle.colorPrimary
        
        if let url = URL(string: contact?.gravatar ?? "") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.imageViewGravatar.image = UIImage(data: data)
                    }
                } else {
                    cell.imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
                    cell.imageViewGravatar.backgroundColor = EasyCallStyle.colorSecondary
                }
            }
        } else {
            cell.imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: .white, size: CGSize(width: 50, height: 50))
            cell.imageViewGravatar.backgroundColor = EasyCallStyle.colorSecondary
        }
        
        cell.contactPhoneNumber = contact?.phone
        cell.contactEmail = contact?.email
        
        cell.buttonPhone.setTitleColor(EasyCallStyle.colorSecondary, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        
        let contact = self.fetchedResultController?.object(at: indexPath)
        
        configureContactCell(cell: cell, withContact: contact)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: - Fetched results controller
    
    func setupFetchedResultController(){
        let loader = UIViewController.displaySpinner(onView: self.view)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key: "firstName", ascending: true)]
        fetchRequest.predicate = self.getNSPredicate()
        
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        self.fetchedResultController = resultController
        UIViewController.removeSpinner(spinner: loader)
    }
    
    func updatePredicateAndReloadData() {
        //print(self.nameFilter, self.profileFilter, self.emergencyFilter)
        DispatchQueue.main.async {
            self.fetchedResultController?.fetchRequest.predicate = self.getNSPredicate()
            self.fetchedResultController?.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key: "firstName", ascending: true)]
            try? self.fetchedResultController?.performFetch()
            self.tableView.reloadData()
        }
    }
    
    func synchroniseWithAPI() {
        let loader = UIViewController.displaySpinner(onView: self.view)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true), NSSortDescriptor(key: "firstName", ascending: true)]
        
        let results = try? context.fetch(fetchRequest)
        
        if let user = results?.first {
            self.userToken = user.token ?? ""
        } else {
            self.showSimpleAlert(alertTitle: "Erreur d'utilisateur", alertMessage: "Utilisateur introuvabe", actionTitle: "Ok")
            NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
            UIViewController.removeSpinner(spinner: loader)
            return
        }
        
        APIClient.instance.getContacts(token: self.userToken, onSuccess: { (contacts) in
            DispatchQueue.main.async {
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
                
                let results = try? context.fetch(fetchRequest)
                
                guard let contactsCoreData = results else {
                    return
                }
                
                // removing all contacts that are not on the server
                let listIdServer = contacts.map({ (contact) -> String in
                    contact["_id"] as! String
                })
                for contactCoreData in contactsCoreData {
                    if (!listIdServer.contains(contactCoreData.serverID ?? "")) {
                        context.delete(contactCoreData)
                    }
                }
                
                // updating or adding contacts
                for contact in contacts {
                    var foundContact: Contact?
                    
                    for contactCoreData in contactsCoreData {
                        if (contact["_id"] as? String == contactCoreData.serverID) {
                            foundContact = contactCoreData;
                            break;
                        }
                    }
                    // Updatading found countact
                    if let foundContact = foundContact {
                        foundContact.serverID = contact["_id"] as? String
                        foundContact.firstName = (contact["firstName"] as? String)?.capitalized
                        foundContact.lastName = (contact["lastName"] as? String)?.capitalized
                        foundContact.phone = contact["phone"] as? String
                        foundContact.profile = contact["profile"] as? String
                        foundContact.email = contact["email"] as? String
                        foundContact.gravatar = contact["gravatar"] as? String
                        foundContact.isFamilinkUser = contact["isFamilinkUser"] as! Bool
                        foundContact.isEmergencyUser = contact["isEmergencyUser"] as! Bool
                        // adding new contact
                    } else {
                        let c = Contact(context: context)
                        c.serverID = contact["_id"] as? String
                        c.firstName = (contact["firstName"] as? String)?.capitalized
                        c.lastName = (contact["lastName"] as? String)?.capitalized
                        c.phone = contact["phone"] as? String
                        c.profile = contact["profile"] as? String
                        c.email = contact["email"] as? String
                        c.gravatar = contact["gravatar"] as? String
                        c.isFamilinkUser = contact["isFamilinkUser"] as! Bool
                        c.isEmergencyUser = contact["isEmergencyUser"] as! Bool
                        context.insert(c)
                    }
                }
                
                try? context.save()
                UIViewController.removeSpinner(spinner: loader)
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: loader)
                switch(error) {
                case ApiError.InvalidToken:
                    self.showSimpleAlert(alertTitle: "Session expirée", alertMessage: "Veuillez vous reconnecter pour avoir de nouveau accès à vos contact.", actionTitle: "Ok")
                    NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
                    
                default:
                    print("Pas de connexion")
                }
            }
        })
    }
    
    // MARK: - Table view update and action
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailContactController = DetailContactViewController(nibName: "DetailContactViewController", bundle: nil)
        detailContactController.contact = fetchedResultController?.object(at: indexPath)
        navigationController?.pushViewController(detailContactController, animated: true)
  
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Supression") { (action, indexpath) in
            
            let contactDeleteAlert = UIAlertController(title: "Suppression de question", message: "Que voulez-vous faire ?", preferredStyle: .alert)
            
            let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive) { (action: UIAlertAction) in
                
                guard let contact = self.fetchedResultController?.object(at: indexPath) else {
                    return
                }
                APIClient.instance.deleteContact(token: self.userToken, id: contact.serverID ?? "incorrectID", onSuccess: {
                    DispatchQueue.main.async {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        
                        let context = appDelegate.persistentContainer.viewContext
                        context.delete(contact)
                    }
                    
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        switch(error) {
                            case ApiError.BadShapeId:
                                self.showSimpleAlert(alertTitle: "Erreur : BadShapeID", alertMessage: "Veuillez contacter les gérant de l'application.", actionTitle: "Ok")
                            case ApiError.InvalidToken:
                                self.showSimpleAlert(alertTitle: "Session expirée", alertMessage: "Veuillez vous reconnecter pour avoir de nouveau accès à vos contact.", actionTitle: "Ok")
                            default:
                                self.showSimpleAlert(alertTitle: "Pas de connexion internet ou serveur KO", alertMessage: "Vérifiez votre connection à Internet et essayez de vous connecter à nouveau.", actionTitle: "Ok")
                        }
                    }
                    
                })
            }
            let actionCancel = UIAlertAction(title: "Annuler", style: .default)
            
            contactDeleteAlert.addAction(actionCancel)
            contactDeleteAlert.addAction(actionDelete)
            self.present(contactDeleteAlert, animated: true, completion: nil)
            
        }
        return [deleteAction]
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    
    // MARK: - Alert message method
    
    func showSimpleAlert(alertTitle: String, alertMessage: String, actionTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
