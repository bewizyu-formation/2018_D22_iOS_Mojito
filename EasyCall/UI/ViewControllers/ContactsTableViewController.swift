//
//  ContactsTableViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
     
    var fetchedResultController: NSFetchedResultsController<Contact>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.title = "Mes contacts"
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        tableView.register(UINib(nibName: "HeaderContactTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderContactTableViewCell")

        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        setupFetchedResultController()
    }
    
    func setupFetchedResultController(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        
        let resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        try? resultController.performFetch()
        
        self.fetchedResultController = resultController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.synchroniseWithAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
   
    // MARK: - Table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderContactTableViewCell") as! HeaderContactTableViewCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 87
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.fetchedResultController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultController?.sections?[section].numberOfObjects ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
       
        let contact = self.fetchedResultController?.object(at: indexPath)
        cell.labelContactFirstName?.text = contact?.firstName ?? "Prénom"
        cell.labelContactLastName?.text = contact?.lastName ?? "Nom"
        cell.imageViewGravatar.image = UIImage.fontAwesomeIcon(name: .userAlt, style: .solid, textColor: .blue, size: CGSize(width: 50, height: 50))
        
        cell.contactPhoneNumber = contact?.phone
        cell.contactEmail = contact?.email
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailContactController = DetailContactViewController(nibName: "DetailContactViewController", bundle: nil)
        detailContactController.contact = fetchedResultController?.object(at: indexPath)
        navigationController?.pushViewController(detailContactController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let colorPrimary = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        let colorSecondary = UIColor(red: 47/255, green: 177/255, blue: 249/255, alpha: 1)
        
        let smsAction = UITableViewRowAction(style: .normal, title: "SMS") { (action, indexpath) in
            let contact = self.fetchedResultController?.object(at: indexPath)
            self.open(scheme: "sms:\(contact?.phone ?? "phone")")
        }
        smsAction.backgroundColor = colorPrimary
        
        let mailAction = UITableViewRowAction(style: .normal, title: "Mail") { (action, indexpath) in
            let contact = self.fetchedResultController?.object(at: indexPath)
            self.open(scheme: "mail:\(contact?.email ?? "mail")")
        }
        mailAction.backgroundColor = colorSecondary
        
        return [smsAction, mailAction]
    }
    
    func synchroniseWithAPI() {
        // TODO: viré la connection du user et remplacer par la récupération du token
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        
        let results = try? context.fetch(fetchRequest)
        
        guard let users = results else {
            return
        }
        
        let tokenCD = users[0].token ?? ""
        
        APIClient.instance.getContacts(token: tokenCD, onSuccess: { (contacts) in
            DispatchQueue.main.async {
                
                print("test 2")
                
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
                        foundContact.firstName = contact["firstName"] as? String
                        foundContact.lastName = contact["lastName"] as? String
                        foundContact.phone = contact["phone"] as? String
                        foundContact.email = contact["email"] as? String
                        foundContact.gravatar = contact["gravatar"] as? String
                        foundContact.isFamilinkUser = contact["isFamilinkUser"] as! Bool
                        foundContact.isEmergencyUser = contact["isEmergencyUser"] as! Bool
                    // adding new contact
                    } else {
                        let c = Contact(context: context)
                        c.serverID = contact["_id"] as? String
                        c.firstName = contact["firstName"] as? String
                        c.lastName = contact["lastName"] as? String
                        c.phone = contact["phone"] as? String
                        c.email = contact["email"] as? String
                        c.gravatar = contact["gravatar"] as? String
                        c.isFamilinkUser = contact["isFamilinkUser"] as! Bool
                        c.isEmergencyUser = contact["isEmergencyUser"] as! Bool
                        context.insert(c)
                    }
                }
                
                try? context.save()
                self.tableView.reloadData()
            }
        }, onError: { (error) in
            switch(error) {
                case ApiError.InvalidToken:
                    let alert = UIAlertController(title: "Session expirée", message: "Veuillez vous reconnecter pour avoir de nouveau accès à vos contact.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Pas de connexion int", message: "Vérifiez votre connection à Internet et réessayez de vous connecter.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
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
}
