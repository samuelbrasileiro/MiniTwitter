//
//  TweetTableViewCell.swift
//  CoreDataApp
//
//  Created by Samuel Brasileiro on 16/08/20.
//  Copyright © 2020 Samuel Brasileiro. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet var userName: UILabel!
    
    @IBOutlet var tweetText: UITextView!
    
    @IBOutlet var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemGray6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
