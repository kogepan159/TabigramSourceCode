//
//  UIViewController+Extension.swift
//  Tabigram
//
//  Created by Junya Kengo on 2021/02/07.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
    
    // 標準アラート
    func okAlert(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // Reloadマーク
    func getActivityIndicatorView() -> NVActivityIndicatorView {
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60), type: NVActivityIndicatorType.ballPulse, color: UIColor.black, padding: 0)
        activityIndicatorView.center = self.view.center // 位置を中心に設定
        return activityIndicatorView
    }
}
