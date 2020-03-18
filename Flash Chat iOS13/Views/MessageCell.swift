//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Anh Dinh on 3/15/20.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    // similar to viewDidLoad
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // make the corner of the message bubble curve
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
