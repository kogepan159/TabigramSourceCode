//
//  certificateViewController1.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit

class certificateViewController1: UIViewController {

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.backgroundColor = UIColor.clear
    }
    
    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
