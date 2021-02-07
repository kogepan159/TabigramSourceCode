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
import FirebaseStorage
import SDWebImage
import Photos
import NVActivityIndicatorView

class EditProfileViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var visitedNumberLabel: UILabel!
    @IBOutlet var favoriteNumberLabel: UILabel!
    
    //画像用
    private var imageUrl: String = ""
    
    //Cloud FireStore用
    var db: Firestore = Firestore.firestore()
    
    var user = User(userName: "", email: "", image: "", visitedNumber: "", favoriteNumber: "", text: "")
    
    private let storage = Storage.storage().reference()
    private var riversRef: StorageReference = StorageReference()
    private let meta = StorageMetadata()
    private var activityIndicatorView: NVActivityIndicatorView! //Load用
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        
        // Loadマーク対応
        activityIndicatorView = self.getActivityIndicatorView()
        self.view.addSubview(activityIndicatorView)
        
        self.db = Firestore.firestore()
        
        loadUsers()
        backButton()
    }
    
    // MARA: - Private
    private func showPickerView() {
        // 写真を選ぶビュー
        // メインスレッド対応
        DispatchQueue.main.async {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .savedPhotosAlbum
            pickerView.delegate = self
            self.present(pickerView, animated: true)
        }
    }
    
    private func showAccessSettingAlert() {
        // フォトライブラリへのアクセスが許可されていないため、アラートを表示する
        let alert = UIAlertController(title: "アクセスが許可されていません。", message: "フォトライブラリへのアクセスが許可されていません。端末のアプリ設定を開いて、変更する場合は設定を押下してください。", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                return
            }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        })
        let closeAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func userUpdateDate() {
       
        guard let user = Auth.auth().currentUser else { return }
        activityIndicatorView.startAnimating()
        db.collection("user").document(user.uid).updateData(["image": imageUrl, "text": self.profileTextView.text ?? ""]) { (error) in
            self.activityIndicatorView.stopAnimating()
            if error != nil {
                print("保存失敗です")
            } else {
                self.okAlert(title: "保存成功", message: "保存が成功しました")
            }
        }
    }
    
    //ユーザ情報を読み込む
    private func loadUsers() {
        guard let user = Auth.auth().currentUser else { return }
        activityIndicatorView.startAnimating()
        db.collection("user").document(user.uid).getDocument { (document, error) in
            self.activityIndicatorView.stopAnimating()
            if error != nil {
                print("何らかの理由で読み取りできませんでした。")
            } else {
                guard let document = document?.data() else {
                    self.okAlert(title: "データ存在しません。", message: "再度ログインし直してみてください")
                    return
                }
                self.user.setDocument(document: document)
                self.nameLabel.text = self.user.userName
                self.emailLabel.text = self.user.email
                self.visitedNumberLabel.text = self.user.visitedNumber
                self.favoriteNumberLabel.text = self.user.favoriteNumber
                self.profileTextView.text = self.user.text
                self.imageUrl = self.user.image
                self.profileImageView.sd_setImage(with: URL(string: self.user.image), completed: nil)
            }
        }
        
    }
    
    //戻るボタン
    private func backButton() {
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
    
    // MARA: - IBAction
    @IBAction func changeImageButton() {
        // 読み込み機能のみ許可
        switch (PHPhotoLibrary.authorizationStatus(for: .addOnly)) {
        case .notDetermined: // フォトライブラリへのアクセスについてユーザーから明示的な回答を得ていない。
            PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: { status in
                switch status {
                case .authorized:
                    self.showPickerView()
                    break
                default:
                    break
                }
            })
            break
        case .authorized, .limited: // フォトライブラリへのアクセスについてユーザーが明示的に「許可」をした。
            self.showPickerView()
            break
        default:
            self.showAccessSettingAlert()
            break
        }
        
    }
    
    @IBAction func saveProfileButton() {
        userUpdateDate()
    }
    
    // 戻るボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        // ログイン情報確認
        guard let uid = Auth.auth().currentUser?.uid else {
            self.okAlert(title: "ログイン情報がありません", message: "もう一度ログインし直してください")
            return
        }
        
        // 選択した写真を取得する
        guard let image = info[.originalImage] as? UIImage else  { return }
        guard let resizeImage = image.resized(toWidth: 400) else  { return }
        riversRef = storage.child( "user/" + uid + ".png")
        
        
        guard let imagaData = resizeImage.pngData() else  { return }
        activityIndicatorView.startAnimating()
        let _ = riversRef.putData(imagaData, metadata: meta) { metadata, error in
            self.activityIndicatorView.stopAnimating()
          guard let _ = metadata else {
            self.okAlert(title: "画像のアップロードに失敗しました", message: "再度設定していただくか、別の画像でお試しください。")
            return
          }
          // You can also access to download URL after upload.
        self.riversRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                self.okAlert(title: "画像のアップロードに失敗しました", message: "再度設定していただくか、別の画像でお試しください。")
                return
            }
            self.profileImageView.image = image
            self.imageUrl = downloadURL.absoluteString
            self.userUpdateDate()
          }
        }

        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
}
