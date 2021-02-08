//
//  FollowCustomTableViewCell.swift
//  Tabigram
//
//  Created by 優樹永井 on 2021/02/05.
//

import UIKit

class FollowCustomTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func follow() {
        
    }
    
}
