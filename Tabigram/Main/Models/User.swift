//
//  User.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import Foundation
import UIKit

class User: NSObject {
    var userName: String
    var email: String
    var image: String
    var visitedNumber: String
    var favoriteNumber: String
    var text: String
    
    init(userName: String, email: String, image: String, visitedNumber: String, favoriteNumber: String, text: String) {
        self.userName = userName
        self.email = email
        self.image = image
        self.visitedNumber = visitedNumber
        self.favoriteNumber = favoriteNumber
        self.text = text
    }
    
    func setDocument(document: [String: Any]) {
        if let userName = document["userName"] as? String {
            self.userName = userName
        }
        if let email = document["email"]as? String {
            self.email = email
        }
        if let image = document["image"]as? String {
            self.image =  image
        }
        if let visitedNumber = document["visitedNumber"] as? String {
            self.visitedNumber = visitedNumber
        }
        if let favoriteNumber = document["favoriteNumber"] as? String {
            self.favoriteNumber = favoriteNumber
        }
        if let text = document["text"] as? String {
            self.text = text
        }
    }
    
}
