//
//  CustomInfoView.swift
//  Tabigram
//
//  Created by 優樹永井 on 2021/02/06.
//

import UIKit
import Foundation

class CustomInfoView: UIView {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> CustomInfoView {
        let customInfoView = Bundle.main.loadNibNamed("CustomInfoView", owner: self, options: nil)?[0] as! CustomInfoView
        return customInfoView
    }
    
    @IBAction func toUserButton() {
        
    }
    
}
