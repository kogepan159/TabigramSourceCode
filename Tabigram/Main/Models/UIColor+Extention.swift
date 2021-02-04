//
//  UIColor+Extention.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import Foundation
import UIKit

extension UIColor {
    
    static var backGroundBlack: UIColor {
        return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)
    }
    static var barBlack: UIColor{
        return UIColor(red: 0.063, green: 0.063, blue: 0.063, alpha: 1)
    }
    static var tabmanOrange: UIColor{
        return UIColor(red: 0.804, green: 0.255, blue: 0.263, alpha: 1)
        //UIColor(red: 1, green: 0.569, blue: 0.047, alpha: 1)
    }
    static var selectedGray: UIColor{
        return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }
    
    
    func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    
}
