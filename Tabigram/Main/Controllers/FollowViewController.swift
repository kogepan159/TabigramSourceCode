//
//  FollowViewController.swift
//  Tabigram
//
//  Created by 優樹永井 on 2021/02/05.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var followTableView: UITableView!
    
    //Cloud FireStore用
    var db: Firestore!
    var user: CollectionReference!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backButton()
        makeProfileButton()
        
        followTableView.delegate = self
        followTableView.dataSource = self
        
        //カスタムセルの登録
        followTableView.register(UINib(nibName: "FollowCustomTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCustomTableViewCell")
        
        loadUsers()
        followTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCustomTableViewCell") as? FollowCustomTableViewCell {
            cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.height / 2
            cell.userImageView.layer.masksToBounds = true
            let rgba = UIColor(red: 115/255, green: 133/255, blue: 169/255, alpha: 1.0)
            cell.followButton.layer.borderWidth = 3.0
            cell.followButton.layer.borderColor = rgba.cgColor
            cell.followButton.layer.cornerRadius = 20
            
            if self.users.count != 0 {
                cell.userNameLabel.text = self.users[indexPath.row].userName
                cell.detailLabel.text = self.users[indexPath.row].text
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        followTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        <#code#>
    }
    //戻るボタン
    func backButton() {
        let button = UIButton()
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
    
    //ユーザプロフィールを表示
    func makeProfileButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        button.frame = CGRect(x: Int(screenwidth) - 60, y: 55, width: 45, height: 45)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "profile@2x.png"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height/2
        self.view.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(FollowViewController.toProfileButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ユーザボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toProfileButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Profile", sender: nil)
    }
    
    func loadUsers() {
        //self.users.removeAll()
        self.db = Firestore.firestore()
        self.user = db.collection("user")
        self.user.getDocuments { (querySnapshot, error) in
            if error != nil {
                print("何らかの理由で読み取りできませんでした。")
            } else {
                print("follow画面読み取りはできました")
                for val in querySnapshot!.documents {
                    let userName = val.get("userName") as! String
                    let email = val.get("email") as! String
                    let image = val.get("image") as! String
                    let visitedNumber = val.get("visitedNumber") as! String
                    let favoriteNumber = val.get("favoriteNumber") as! String
                    let text = val.get("text") as! String
                    let userArray = User(userName: userName, email: email, image: image, visitedNumber: visitedNumber, favoriteNumber: favoriteNumber, text: text)
                    self.users.append(userArray)
                    print(self.users.count)
                    self.followTableView.reloadData()
                    
                }
                print("ユーザ一覧取得完了")
            }
        }
    }
}
