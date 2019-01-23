//
//  NavigationViewController.swift
//  EasyCall
//
//  Created by formation2 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var contactsViewController: ContactsTableViewController!
    var loginViewController: LoginViewController!
    var loginNavigationController: UINavigationController!
    var contactsNavigationController: UINavigationController!

    var isConnected: Bool = true
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isConnected){
            contactsViewController = ContactsTableViewController(nibName: nil, bundle: nil)
            
            contactsNavigationController = UINavigationController(rootViewController: contactsViewController)
            addChild(contactsNavigationController)
            view.addSubview(contactsNavigationController.view)
            contactsNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contactsNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                contactsNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                contactsNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                contactsNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
            contactsNavigationController.didMove(toParent: self)
        } else {
            loginViewController = LoginViewController(nibName: nil, bundle: nil)
            
            loginNavigationController = UINavigationController(rootViewController: loginViewController)
            addChild(loginNavigationController)
            view.addSubview(loginNavigationController.view)
            loginNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loginNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                loginNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                loginNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                loginNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
            loginNavigationController.didMove(toParent: self)
        }

    }

    func changeDisplayedController(animated : Bool) {
        if isConnected {
            contactsNavigationController.view.isHidden = false
            loginNavigationController.view.isHidden = true
        } else {
            contactsNavigationController.view.isHidden = true
            loginNavigationController.view.isHidden = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
