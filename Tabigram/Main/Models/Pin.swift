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
    var status: Bool
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, status: Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.status = status
    }
    
}
