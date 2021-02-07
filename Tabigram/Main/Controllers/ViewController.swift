//
//  ViewController.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import GoogleMaps
import CoreLocation
import GoogleMaps
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
    
    //マーカー用
    var titleText = ""
    var detailMemo = ""
    var area = "Japan"
    
    //カスタムView用
//    var tappedMarker : GMSMarker?
//    var customInfoView : CustomInfoView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //現在のログインユーザーがいるかどうかの確認
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
        makeToHomeButton()
        
        //segmentControlを設定
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        let width = 200
        let widthGap = (screenwidth - Float(width)) / 2
        // セグメントに追加するテキストの設定
        let params = ["Open Mode", "Private Mode"]
        // UISegmentedControlを生成
        let mySegment = UISegmentedControl(items: params)
        mySegment.frame = CGRect(x: Int(widthGap), y: Int(self.mapView.bounds.height) - 55, width: Int(width), height: 40)
        // 選択されたセグメントの背景色の設定
        mySegment.tintColor = UIColor(red: 0.13, green: 0.61, blue: 0.93, alpha: 1.0)
        // セグメントの背景色の設定
        mySegment.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 1.00, alpha: 1.0)
        // 選択されたセグメントのフォントと文字色の設定
        mySegment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HiraKakuProN-W6", size: 12.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
        // セグメントのフォントと文字色の設定
        mySegment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HiraKakuProN-W3", size: 12.0)!,
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.30, green: 0.49, blue: 0.62, alpha: 1.0)
        ], for: .normal)
        // セグメントの選択
        mySegment.selectedSegmentIndex = 1
        // セグメントが変更された時に呼び出すメソッドの設定
        mySegment.addTarget(self, action: #selector(segmentChanged(_:)), for: UIControl.Event.valueChanged)
        // UISegmentedControlを追加
        self.mapView.addSubview(mySegment)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLocations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .fullScreen
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
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
    
    // セグメントが変更された時に呼び出されるメソッド
    @objc func segmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            //オープンモード
            self.loadOpenLocations()
        case 1:
            //プライベートモード
            self.loadLocations()
        default:
            break
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
        //一旦リセット
        self.visitedNumber = 0
        self.favoriteNumber = 0
        self.pins.removeAll()
        
        self.db = Firestore.firestore()
        self.place = db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
        if place.collectionID.count != 0 {
            //self.place.whereField("user", isEqualTo: Auth.auth().currentUser?.displayName)
            self.place.getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("何らかの理由で読み取りできませんでした。")
                } else {
                    if querySnapshot!.documents.count != 0 {
                        for val in querySnapshot!.documents {
                            let longitude = val.get("longitude") as! CLLocationDegrees
                            let latitude = val.get("latitude") as! CLLocationDegrees
                            let name = val.get("title") as! String
                            let memo = val.get("detailMemo") as! String
                            let user = val.get("user") as! String
                            let status = val.get("status") as! Bool
                            let area = val.get("area") as! String
                            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let colorRef = val.get("color") as! String
                            let color: UIColor!
                            if colorRef == "Red" {
                                color = UIColor.red
                            } else if colorRef == "Brown" {
                                color = UIColor.brown
                            } else if colorRef == "Blue" {
                                color = UIColor.blue
                            } else if colorRef == "Orange" {
                                color = UIColor.orange
                            } else if colorRef == "Black" {
                                color = UIColor.black
                            } else if colorRef == "White" {
                                color = UIColor.white
                            } else if colorRef == "Green" {
                                color = UIColor.green
                            } else if colorRef == "Yellow" {
                                color = UIColor.yellow
                            } else {
                                color = UIColor.black
                            }
                            self.showMaker(position: location, title: name, detailMemo: memo, status: status, color: color)
                            self.visitedNumber = (querySnapshot?.documents.count)!
                            let pin = Pin(latitude: latitude, longitude: longitude, title: name, user: user, detailMemo: memo, status: status, area: area, color: colorRef)
                            self.pins.append(pin)
                            if status == true {
                                self.favoriteNumber += 1
                            }
                        }
                        self.countVisitedLabel.text = String(self.visitedNumber)
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                    } else {
                        print("データがひとつもないです。。")
                    }
                }
            }
        }
    }
    
    //OpenModeの時に呼ばれるload用関数
    func loadOpenLocations() {
        //一旦リセット
        self.visitedNumber = 0
        self.favoriteNumber = 0
        self.pins.removeAll()
        
        self.db = Firestore.firestore()
        db.collectionGroup("place").getDocuments { (querySnapshot, error) in
            if error != nil {
                print("何らかの理由で読み取りできませんでした。")
            } else {
                if querySnapshot!.documents.count != 0 {
                    for val in querySnapshot!.documents {
                        let longitude = val.get("longitude") as! CLLocationDegrees
                        let latitude = val.get("latitude") as! CLLocationDegrees
                        let name = val.get("title") as! String
                        let memo = val.get("detailMemo") as! String
                        let user = val.get("user") as! String
                        let status = val.get("status") as! Bool
                        let area = val.get("area") as! String
                        let colorRef = val.get("color") as! String
                        let color: UIColor!
                        if colorRef == "Red" {
                            color = UIColor.red
                        } else if colorRef == "Brown" {
                            color = UIColor.brown
                        } else if colorRef == "Blue" {
                            color = UIColor.blue
                        } else if colorRef == "Orange" {
                            color = UIColor.orange
                        } else if colorRef == "Black" {
                            color = UIColor.black
                        } else if colorRef == "White" {
                            color = UIColor.white
                        } else if colorRef == "Green" {
                            color = UIColor.green
                        } else if colorRef == "Yellow" {
                            color = UIColor.yellow
                        } else {
                            color = UIColor.black
                        }
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        self.showMaker(position: location, title: name, detailMemo: memo, status: status, color: color)
                        self.visitedNumber = (querySnapshot?.documents.count)!
                        let pin = Pin(latitude: latitude, longitude: longitude, title: name, user: user, detailMemo: memo, status: status, area: area, color: colorRef)
                        self.pins.append(pin)
                        if status == true {
                            self.favoriteNumber += 1
                        }
                    }
                    self.countVisitedLabel.text = String(self.visitedNumber)
                    self.countFavoritedLabel.text = String(self.favoriteNumber)
                } else {
                    print("データがひとつもないです。。")
                }
            }
        }
        
    }
    
}

extension ViewController: GMSMapViewDelegate {
    
    //マーカーを打ち込む
    func showMaker(position: CLLocationCoordinate2D, title: String, detailMemo: String, status: Bool, color: UIColor) {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.snippet = detailMemo
        
        if status == true && color == UIColor.brown {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                //marker.icon = GMSMarker.markerImage(with: UIColor.green)
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .white
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .brown
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else if status == true && color == UIColor.blue {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .white
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .blue
                markerView.addSubview(label)
                marker.iconView = markerView

            }
        } else if status == true && color == UIColor.orange {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .white
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .orange
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else if status == true && color == UIColor.black {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .white
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .black
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else if status == true && color == UIColor.white {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .gray
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .white
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else if status == true && color == UIColor.green {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .gray
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .green
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else if status == true && color == UIColor.yellow {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                
                //オリジナルのマーカーアイコンを作成
                let label = UILabel(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                label.text = "♡"
                label.font = UIFont.systemFont(ofSize: 30.0)
                label.textAlignment = .center
                label.textColor = .gray
                let markerView = UIView(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
                markerView.layer.cornerRadius = 20.0
                markerView.backgroundColor = .yellow
                markerView.addSubview(label)
                marker.iconView = markerView
            }
        } else {
            if marker.title?.count != 0 {
                marker.appearAnimation = GMSMarkerAnimation.pop
                //マーカーをmapviewに表示
                marker.map = self.mapView
                marker.icon = GMSMarker.markerImage(with: UIColor.red)

                
            }
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
            self.loadLocations()
            for text in alert.textFields! {
                if text.tag == 1 {
                    self.titleText = text.text ?? "nil"
                } else {
                    self.detailMemo = text.text ?? "nil"
                }
            }
            print(self.titleText)
            print(self.detailMemo)
            //マーカーを生成する（タイトルをつけた時のみ）
            self.showMaker(position: coordinate, title: self.titleText, detailMemo: self.detailMemo, status: false , color: UIColor.red)
            //生成したpinを配列で保存する→保存ボタンでまとめてFirebaseで保存
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, title: self.titleText, user: (Auth.auth().currentUser?.displayName)!, detailMemo: self.detailMemo, status: false, area: self.area, color: "red")
            self.pins.append(pin)
            self.savePins()
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        //textfiled1の追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "場所名を記入"
            text.tag  = 1
        })
        //textfiled2の追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "一番の思い出を記入"
            text.tag  = 2
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    //マーカーをタップした時に呼ばれる関数
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        tappedMarker = marker
//        customInfoView?.layer.cornerRadius = 8
//        customInfoView?.center = mapView.projection.point(for: marker.position)
//        self.mapView.addSubview(customInfoView!)
//        return false
//    }
//
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        return UIView()
//    }
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        customInfoView?.removeFromSuperview()
//    }
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        let position = tappedMarker?.position
//        customInfoView?.center = mapView.projection.point(for: position!)
//        customInfoView?.center.y -= 140
//    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if marker.icon == GMSMarker.markerImage(with: UIColor.red) {
            let alertController = UIAlertController(title: "お気に入りの場所に登録しますか？", message: "お気に入りの国を世界中に作ろう！", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["status": true]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
                alertController.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let actionSheet: UIAlertController = UIAlertController(title: "選択肢を表示", message: "好きなピンを選択してください", preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Brown", style: .default,handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Brown"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "Blue", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Blue"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "Orange", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Orange"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "Black", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Black"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "White", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "White"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "Green", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Green"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.addAction(UIAlertAction(title: "Yellow", style: .default, handler: {(action: UIAlertAction!) -> Void in
                for pin in self.pins {
                    if marker.position.latitude == pin.latitude {
                        self.countFavoritedLabel.text = String(self.favoriteNumber)
                        self.db = Firestore.firestore()
                        self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                        self.place.document(String(pin.latitude) + String(pin.longitude)).updateData(["color": "Yellow"]) { err in
                            if let err = err {
                            } else {
                                self.loadLocations()
                            }
                        }
                    }
                }
            })
            )
            actionSheet.popoverPresentationController?.sourceView = self.mapView
            self.present(actionSheet, animated: true, completion: nil)

        }
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
                    print("削除成功")
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
        label.frame = CGRect(x: Int(widthGap), y: 50, width: Int(width), height: 70)
        label.textColor = UIColor.black
        label.text = "Tabigram"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Billabong", size: 50)
        self.mapView.addSubview(label)
    }
    
    //Homeに戻る透明なボタンを表示
    func makeToHomeButton() {
        let button = UIButton()
        let screenwidth = Float(UIScreen.main.bounds.size.width)
        let width = 200
        let widthGap = (screenwidth - Float(width)) / 2
        button.frame = CGRect(x: Int(widthGap), y: 50, width: Int(width), height: 70)
        self.mapView.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ViewController.toHomeButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ユーザボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toHomeButton(_ sender: UIButton) {
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
        self.mapView.addSubview(button)
        //ボタンで実行する処理
        button.addTarget(self, action: #selector(ViewController.toProfileButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // ユーザボタンが押された時に呼ばれるメソッド（保存する）
    @objc func toProfileButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Profile", sender: nil)
    }
    
    //ピンを保存する関数
    func savePins() {
        self.db = Firestore.firestore()
        self.place = db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
        for i in pins {
            //self.area = self.areaCalculate(latitude: i.latitude, longitude: i.longitude)
            let data = ["latitude":i.latitude, "longitude":i.longitude, "title":i.title, "user": Auth.auth().currentUser?.displayName!, "detailMemo": self.detailMemo, "status":false, "area": area] as [String : Any]
            let user = Auth.auth().currentUser
            if user != nil {
                self.place.document(String(i.latitude) + String(i.longitude)).setData(data) { (error) in
                    //self.place.addDocument(data: data) { (error) in
                    if error != nil {
                        print("保存失敗です")
                    } else {
                        let alertController = UIAlertController(title: "保存成功", message: "保存が成功しました", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.pins = [Pin]()
                            self.db = Firestore.firestore()
                            self.place = self.db.collection("user").document(Auth.auth().currentUser!.uid).collection("place")
                            self.place.getDocuments { (querySnapshot, error) in
                                self.visitedNumber = (querySnapshot?.documents.count)!
                                self.countVisitedLabel.text = String(self.visitedNumber)
                                
                                //国ごとにマーカーの色を変える
                                //querySnapshot?.documents.area
                                //switch caseとかで書く
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
    
    //ピンを保存するときにエリアの情報も一緒に保存する
    //    func areaCalculate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
    //
    //        //国名を返す
    //        return
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
        showMaker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: place.name!, detailMemo: "", status: false, color: UIColor.red)
        
        //生成したpinを配列で保存する→保存ボタンでまとめてFirebaseで保存
        let pin = Pin(latitude: latitude, longitude: longitude, title: place.name!, user: (Auth.auth().currentUser?.displayName)!, detailMemo: "", status: false, area: area, color: "red")
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
        button.frame = CGRect(x: 15, y: 55, width: 45, height: 45)
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
        //        let autocompleteController = GMSAutocompleteViewController()
        //        autocompleteController.delegate = self
        //        present(autocompleteController, animated: true, completion: nil)
        self.performSegue(withIdentifier: "Follow", sender: nil)
    }
    
}





