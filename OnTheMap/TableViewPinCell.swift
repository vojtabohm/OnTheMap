//
//  TableViewPinCell.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit

class TableViewPinCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var icon: UIImageView!
    
    var studentLocation: StudentLocation? {
        didSet {
            guard let studentLocation = studentLocation else {
                return
            }
            self.title.text = studentLocation.firstName + " " + studentLocation.lastName
            self.subtitle.text = studentLocation.mediaURL
        }
    }
}
