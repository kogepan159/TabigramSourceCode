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
    @IBOutlet var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        startButton.layer.cornerRadius = 25
        startButton.layer.masksToBounds = true
        
        startButton.isHidden = true
        logOutButton.isHidden = true
        
        labelChange()
    }
    
    func labelChange() {
        let label = UILabel()
        let label2 = UILabel()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        let screenheight = Float(UIScreen.main.bounds.size.height)
        let width = 350
        let height = 120
        let widthGap = (screenwidth - Float(width)) / 2
        let heightGap = (screenheight - Float(height)) / 2
        label.frame = CGRect(x: Int(widthGap), y: Int(heightGap), width: Int(width), height: Int(height))
        label.textColor = UIColor(red: 254/255, green: 237/255, blue: 202/255, alpha: 1.0)
        label.text = "Tabigram"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Billabong", size: 80)
        self.view.addSubview(label)
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveLinear, animations: {
            label.frame = CGRect(x: Int(widthGap), y: 70, width: Int(width), height: Int(height))
        }, completion: { (finished: Bool) in
            label.textColor = UIColor.black
            
            label2.frame = CGRect(x: Int(widthGap), y: Int(heightGap), width: Int(width), height: Int(height))
            label2.textColor = UIColor.black
            label2.text = "Record your memories of your trip"
            label2.textAlignment = NSTextAlignment.center
            label2.font = UIFont.italicSystemFont(ofSize: 20)
            self.view.addSubview(label2)
            
            self.startButton.isHidden = false
            self.logOutButton.isHidden = false
        })
        
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
