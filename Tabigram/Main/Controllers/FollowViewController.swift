//
//  FollowViewController.swift
//  Tabigram
//
//  Created by 優樹永井 on 2021/02/05.
//

import UIKit

class FollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var followTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backButton()
        makeProfileButton()
        
        followTableView.delegate = self
        followTableView.dataSource = self
        
        //カスタムセルの登録
        followTableView.register(UINib(nibName: "FollowCustomTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowCustomTableViewCell")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCustomTableViewCell") as? FollowCustomTableViewCell {
            cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.height / 2
            cell.userImageView.layer.masksToBounds = true
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
}
