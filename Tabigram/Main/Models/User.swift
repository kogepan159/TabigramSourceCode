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
    
}
