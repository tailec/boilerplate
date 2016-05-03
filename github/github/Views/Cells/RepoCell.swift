//
//  DiscoverCell.swift
//  Origin
//
//  Created by krawiecp on 15/01/2016.
//  Copyright © 2016 tailec. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var languageLabel: UILabel!
    @IBOutlet weak private var starsLabel: UILabel!
    
    @IBOutlet weak private var starsLabelLeadingConstraint: NSLayoutConstraint!
    
    func configure(title: String, description: String, language: String, stars: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        languageLabel.text = language
        starsLabel.text = stars
        
        starsLabelLeadingConstraint.constant = language.isEmpty ? 0 : 8
    }
}

