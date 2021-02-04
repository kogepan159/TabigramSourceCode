//
//  ViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    //Cloud FireStore用
    var db: Firestore!
    var place: CollectionReference!
    
    //カウント用
    var visitedNumber = 0
    var favoriteNumber = 0
    @IBOutlet var countVisitedLabel: UILabel!
    @IBOutlet var countFavoritedLabel: UILabel!
    
    //配列
    var worldArray = [String]()
    var dayArray = [String]()
    var memoArray = [String]()

    //mapViewを表示させる（マップの表示）
    @IBOutlet var mapView: GMSMapView!
    //位置情報の使用
    var pins = [Pin]()
    var locationManager = CLLocationManager()
    
    //マーカーがお気に入りかどうかを判定するための変数
    var markerStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //現在のログインユーザーがいるかどうかrの確認
        print(Auth.auth().currentUser?.displayName!)
        userCheck()
        
        // フォント種をTime New Roman、サイズを10に指定
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Billabong", size: 30)!]
        
        //マップのデリゲート設定
        mapView.delegate = self
        //位置情報使用の許可
        locationManager.requestWhenInUseAuthorization()
        //現在地の取得
        mapView.isMyLocationEnabled = true
        //現在地を取得するボタンをセット
        mapView.settings.myLocationButton = true
        
        //各種Map関連の関数呼び出し
        makeTitleLabel()
        makeMap()
        makeSearchButton()
        makeProfileButton()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(35.68154,139.752498)
        marker.title = "The Imperial Palace"
        marker.snippet = "Tokyo"
        marker.map = mapView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLocations()
    }
    
    //きちんとログインされているかどうかを審査する関数
    func userCheck() {
        let ud = UserDefaults.standard
        let user = Auth.auth().currentUser
        if user != nil {
            ud.set(true, forKey: "isLogin")
            ud.synchronize()
        } else {
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
            } catch let signOutError as NSError {
            }
        }
    }
    
    /*  ここからMap関連のコード  */
    ///地図を生成、GMSCameraPositionで緯度経度を指定
    func makeMap() {
        // 現在地の緯度経度
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        //表示する時の中心となる場所を指定する（nilに注意）
        if let unwrappedLatitude = latitude {
            //位置情報の使用を許可されてる時（現在地を中心に表示）
            let camera = GMSCameraPosition.camera(withLatitude: unwrappedLatitude, longitude: longitude!, zoom: 15.0)
            mapView.camera = camera
        } else {
            //位置情報を許可しない場合＆初回（新宿駅を中心に表示する）
            let camera = GMSCameraPosition.camera(withLatitude: 35.690167, longitude: 139.700359, zoom: 15.0)
            mapView.camera = camera
        }
    }
    
    //ピン読み取り
    func loadLocations() {
        self.db = Firestore.firestore()
        self.place = db.collection("place")
        if place.collectionID.count != 0 {
            self.place.whereField("user", isEqualTo: Auth.auth().currentUser?.displayName)
            self.place.getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("何らかの理由で読み取りできませんでした。")
                } else {
                    for val in querySnapshot!.documents {
                        let longitude = val.get("longitude") as! CLLocationDegrees
                        let latitude = val.get("latitude") as! CLLocationDegrees
                        let name = val.get("title") as! String
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        self.showMaker(position: location, title: name)
                        self.visitedNumber = (querySnapshot?.documents.count)!
                        self.countVisitedLabel.text = String(self.visitedNumber)
                    }
                }
            }
        }
    }
    
}

extension ViewController: GMSMapViewDelegate {
    
    //マーカーを打ち込む
    func showMaker(position: CLLocationCoordinate2D, title: String) {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.snippet = title
        //場所名が記入された時のみマーカーを生成
        if marker.title?.count != 0 {
            marker.appearAnimation = GMSMarkerAnimation.pop
            //マーカーをmapviewに表示
            marker.map = self.mapView
        }
    }
    
    //長押しした場所の緯度経度をとってくる
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "場所", message: "場所名を記入してください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        //okした時の処理
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //マーカーを生成する（タイトルをつけた時のみ）
            self.showMaker(position: coordinate, title: (alert.textFields?.first?.text)!)
            //生成したpinを配列で保存する→保存ボタンでまとめてFirebaseで保存
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, title: (alert.textFields?.first?.text)!, status: false)
            self.pins.append(pin)
            self.savePins()
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "場所名を記入"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let alertController = UIAlertController(title: "お気に入りの場所に登録しますか？", message: "お気に入りの国を世界中に作ろう！", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            marker.icon = GMSMarker.markerImage(with: .blue)
            //self.updatePins()
            alertController.dismiss(animated: true, completion: nil)

        })
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //マーカーのウィンドウを長押した時の処理
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        guard pins.count != 0 else {
            print("消せないよ")
            return
        }
        let alert = UIAlertController(title: "ピンの削除", message: "ピンを削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let latitude = marker.position.latitude
            let longitude = marker.position.longitude
            let name = marker.title
            for pin in self.pins {
                if pin.longitude == longitude && pin.latitude == latitude && pin.title == name {
                    //マーカー除去
                    marker.map = nil
                    let index = self.pins.index(of: pin)
                    self.pins.remove(at: index!)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //ユーザプロフィールを表示
    func makeTitleLabel() {
        let label = UILabel()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        let width = 200
        let widthGap = (screenwidth - Float(width)) / 2
        label.frame = CGRect(x: Int(widthGap), y: 5, width: Int(width), height: 70)
        label.textColor = UIColor.black
        label.text = "Tabigram"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Billabong", size: 50)
        self.mapView.addSubview(label)
    }
    
    //ユーザプロフィールを表示
    func makeProfileButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        button.frame = CGRect(x: Int(screenwidth) - 60, y: 15, width: 45, height: 45)
        button.backgroundColor = UIColor.white
        button.setImage(UIImage(named: "profile@2x.png"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height/2
        self.mapView.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ViewController.toProfileButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ユーザボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toProfileButton(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let second = storyboard.instantiateViewController(withIdentifier: "Profile")
        self.present(second, animated: true, completion: nil)
    }
    
    //ピンを保存する関数
    func savePins() {
        self.db = Firestore.firestore()
        self.place = db.collection("place")
        for i in pins {
            let data = ["latitude":i.latitude,"longitude":i.longitude,"title":i.title,"user": Auth.auth().currentUser?.displayName, "status":false] as [String : Any]
            let user = Auth.auth().currentUser
            if user != nil {
                self.place.addDocument(data: data) { (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        let alertController = UIAlertController(title: "保存成功", message: "保存が成功しました", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.pins = [Pin]()
                            self.db = Firestore.firestore()
                            self.place = self.db.collection("place")
                            self.place.getDocuments { (querySnapshot, error) in
                                self.visitedNumber = (querySnapshot?.documents.count)!
                                self.countVisitedLabel.text = String(self.visitedNumber)
                            }
                            alertController.dismiss(animated: true, completion: nil)
                        })
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //ピンをお気に入り登録する時の関数
//    func updatePins() {
//        self.db = Firestore.firestore()
//        self.place = db.collection("place")
//        for i in pins {
//            let data = ["latitude":i.latitude,"longitude":i.longitude,"title":i.title,"user": Auth.auth().currentUser?.displayName, "status":true] as [String : Any]
//            let user = Auth.auth().currentUser
//            if user != nil {
//                self.place.collectionID.
//            }
//        }
//    }
    
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    // 検索して選択した場所の情報を取得
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView.camera = camera
        
        //検索場所にマーカーを打つ
        showMaker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: place.name!)
        
        //生成したpinを配列で保存する→保存ボタンでまとめてFirebaseで保存
        let pin = Pin(latitude: latitude, longitude: longitude, title: place.name!, status: false)
        self.pins.append(pin)
        
        dismiss(animated: true, completion: nil)
    }
    //取得できなかった時に呼ばれる
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    //キャンセルボタンのアクション
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //検索画面を表示させるボタン
    func makeSearchButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        button.frame = CGRect(x: 15, y: 15, width: 45, height: 45)
        button.backgroundColor = UIColor.white
        //UIColor(red: 226/255, green: 224/255, blue: 212/255, alpha: 1.0)
        button.setImage(UIImage(named: "search@2x.png"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.height / 2
        self.mapView.addSubview(button)
        
        //ボタンに影をつける
        button.layer.shadowOffset = CGSize(width: 45, height: 45 )
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = button.frame.height/2
        button.layer.shadowOpacity = 1.0
        
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ViewController.buttonEvent(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ボタンが押された時に呼ばれるメソッド（検索ウィンドウを表示させる）
    @objc func buttonEvent(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
}





