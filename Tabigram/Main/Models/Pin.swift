//
//  Pin.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import Foundation
import UIKit
import GoogleMaps

class Pin: NSObject {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var title: String
    var user: String
    var detailMemo: String
    var status: Bool
    var area: String
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, user: String, detailMemo: String, status: Bool, area: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.user = user
        self.detailMemo = detailMemo
        self.status = status
        self.area = area
    }
    
}
