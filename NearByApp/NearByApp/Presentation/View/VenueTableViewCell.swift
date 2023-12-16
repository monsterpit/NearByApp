//
//  VenueTableViewCell.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//

import UIKit

class VenueTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setupCell(title: String,description: String){
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
}
