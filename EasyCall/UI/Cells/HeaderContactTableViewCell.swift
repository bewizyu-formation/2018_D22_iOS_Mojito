//
//  HeaderContactTableViewCell.swift
//  EasyCall
//
//  Created by formation 8 on 24/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class HeaderContactTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonAll: UIButton!
    @IBOutlet weak var buttonFamily: UIButton!
    @IBOutlet weak var buttonSenior: UIButton!
    @IBOutlet weak var buttonDoctor: UIButton!
    @IBOutlet weak var buttonEmergency: UIButton!
    @IBOutlet weak var searchBarContact: UISearchBar!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    @IBAction func onButtonTapped(_ sender: UIButton) {
        let colorPrimary = UIColor(red: 255/255, green: 108/255, blue: 0/255, alpha: 1)
        let colorSecondary = UIColor(red: 254/255, green: 203/255, blue: 152/255, alpha: 1)
        let buttonTapped = sender
        buttonAll.backgroundColor = colorPrimary
        buttonFamily.backgroundColor = colorPrimary
        buttonSenior.backgroundColor = colorPrimary
        buttonDoctor.backgroundColor = colorPrimary
        buttonEmergency.backgroundColor = colorPrimary
        buttonTapped.backgroundColor = colorSecondary
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
