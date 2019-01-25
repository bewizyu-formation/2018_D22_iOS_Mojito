//
//  ContactTableViewCell.swift
//  EasyCall
//
//  Created by formation 8 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var labelContactFirstName: UILabel!
    @IBOutlet weak var labelContactLastName: UILabel!
    @IBOutlet weak var imageViewGravatar: UIImageView!
    
    @IBOutlet weak var buttonPhone: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageViewGravatar.image = UIImage(named: "iconUser")
        let imagePhone = UIImage(named: "iconPhone")
        buttonPhone.setImage(imagePhone, for: .normal)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
