//
//  AppDelegate.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firebse初期化
        FirebaseApp.configure()
        
        //GoogleAPIKey
        GMSServices.provideAPIKey(GoogleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(GooglePlacesAPIKey)
        
        // UserDefaultsの設定
        let ud = UserDefaults.standard
        let isLogin = ud.bool(forKey: "isLogin")
        
        // ログイン状態による条件分岐
        if isLogin == true {
            // ログイン中だったら
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        } else {
            // ログインしていなかったら
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        }
        return true
    }

}

