//
//  CustomTableViewCell.swift
//  MyHealthApp
//
//  Created by Sohaib on 22/06/2018.
//  Copyright © 2018 Sohaib. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellDetailTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
