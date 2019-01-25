//
//  ContactsTableViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    var contacts = [ContactMock]()
    var contactsFiltered = [ContactMock]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.title = "Mes contacts"
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        tableView.register(UINib(nibName: "HeaderContactTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderContactTableViewCell")

        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contacts = [
            ContactMock(firstName: "mathis",lastName: "seigle"),
            ContactMock(firstName: "etienne",lastName: "graff")
        ]
        print(contacts)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
   
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count;
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
       
        cell.labelContactFirstName?.text = contacts[indexPath.row]._firstName
        cell.labelContactLastName?.text = contacts[indexPath.row]._lastName
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Une fois l'ecran detail créé, faire la navigation vers celui-ci
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let mailAction = UITableViewRowAction(style: .normal, title: "Mail") { (action, indexpath) in
            
        }
        
        let smsAction = UITableViewRowAction(style: .normal, title: "SMS") { (action, indexpath) in
            
        }
        smsAction.backgroundColor = UIColor.blue
        return [mailAction,smsAction]
    }
    
}

//Supprimer une fois coredata et api mis en place
class ContactMock {
    var _firstName : String
    var _lastName : String
    
    init(firstName : String, lastName : String) {
        _firstName = firstName
        _lastName = lastName
    }
}
