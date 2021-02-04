//
//  FrontViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import Firebase
import FirebaseAuth

class FrontViewController: UIViewController {
    
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startButton.layer.cornerRadius = 25
        startButton.layer.masksToBounds = true
    }
    
    @IBAction func logOut() {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
        } catch let signOutError as NSError {
            //error handling
        }
    }

}
