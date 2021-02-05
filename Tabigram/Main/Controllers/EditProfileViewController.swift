//
//  EditProfileViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var visitedNumberLabel: UILabel!
    @IBOutlet var favoriteNumberLabel: UILabel!
    
    //画像用
    var image = ""
    
    //Cloud FireStore用
    var db: Firestore!
    var user: CollectionReference!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        
        loadUsers()
        
        backButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func changeImageButton() {
        
    }
    
    @IBAction func saveProfileButton() {
        self.db = Firestore.firestore()
        self.user = db.collection("user")
        let data = ["userName": self.nameLabel.text, "email": self.emailLabel.text, "image": image, "visitedNumber": self.visitedNumberLabel.text, "favoriteNumber": self.favoriteNumberLabel.text, "text": self.profileTextView.text] as [String : Any]
        let user = Auth.auth().currentUser
        if user != nil {
            self.user.document(Auth.auth().currentUser?.uid ?? "").setData(data) { (error) in
                if error != nil {
                    print("保存失敗です")
                } else {
                    let alertController = UIAlertController(title: "保存成功", message: "保存が成功しました", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alertController.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //ユーザ情報を読み込む
    func loadUsers() {
        self.db = Firestore.firestore()
        self.user = db.collection("user")
        self.user.whereField("userName", isEqualTo: Auth.auth().currentUser?.displayName)
        self.user.getDocuments { (querySnapshot, error) in
            if error != nil {
                print("何らかの理由で読み取りできませんでした。")
            } else {
                for val in querySnapshot!.documents {
                    let userName = val.get("userName") as! String
                    let email = val.get("email") as! String
                    let image = val.get("image") as! String
                    let visitedNumber = val.get("visitedNumber") as! String
                    let favoriteNumber = val.get("favoriteNumber") as! String
                    let text = val.get("text") as! String
                    let userArray = User(userName: userName, email: email, image: image, visitedNumber: visitedNumber, favoriteNumber: favoriteNumber, text: text)
                    self.users.append(userArray)
                    self.nameLabel.text = userName
                    self.emailLabel.text = email
                    self.visitedNumberLabel.text = String(visitedNumber)
                    self.favoriteNumberLabel.text = String(favoriteNumber)
                    self.profileTextView.text = text
                }
            }
        }
        
    }
    
    //戻るボタン
    func backButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        button.frame = CGRect(x: 15, y: 55, width: 45, height: 45)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "back@2x.png"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height/2
        self.view.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ProfileViewController.toBackButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // 戻るボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
