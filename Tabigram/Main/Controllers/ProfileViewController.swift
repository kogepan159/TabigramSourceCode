//
//  ProfileViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var profileTextView: UITextView!
    @IBOutlet var visitedNumberLabel: UILabel!
    @IBOutlet var favoriteNumberLabel: UILabel!
    
    //Cloud FireStore用
    var db: Firestore!
    var user: CollectionReference!
    
    var explanationText = "旅の思い出を記録するアプリです。" + "\n" + "訪れた国、場所、土地できっと素敵な思い出ができたと思います。" + "\n" + "ぜひTabigramでそんな旅の思い出を貯めてみてください。"
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //profileTextView.text = explanationText
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        
        editProfileButton()
        backButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userName = Auth.auth().currentUser?.displayName
        self.nameLabel.text = userName
        
        loadUsers()
    }
    
    //ユーザプロフィールを表示
    func editProfileButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        button.frame = CGRect(x: Int(screenwidth) - 60, y: 55, width: 45, height: 45)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "editProfileImage@2x.png"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height/2
        self.view.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ProfileViewController.toProfileButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ユーザボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toProfileButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "EditProfile", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .fullScreen
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
                    self.emailLabel.text = email
                    self.visitedNumberLabel.text = String(visitedNumber)
                    self.favoriteNumberLabel.text = String(favoriteNumber)
                    self.profileTextView.text = text
                }
            }
        }
        
    }
    
    
}
