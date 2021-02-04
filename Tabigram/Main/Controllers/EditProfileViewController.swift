//
//  EditProfileViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func changeImageButton() {
        
    }
    
    @IBAction func saveProfileButton() {
        self.dismiss(animated: true, completion: nil)
    }

}
