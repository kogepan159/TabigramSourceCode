//
//  CustomButton.swift
//  Tabigram
//
//  Created by YukiNagai on 2021/02/04.
//

import Foundation
import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      commonInit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStartAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEndAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEndAnimation()
    }
}

// MARK: - Private functions
extension CustomButton {
    
    //影付きのボタンの生成
    internal func commonInit(){
       self.layer.cornerRadius = self.frame.height/3
    //    self.layer.shadowOffset = CGSize(width: 2, height: 2 )
     //   self.layer.shadowColor = UIColor.gray.cgColor
    //    self.layer.shadowRadius = 2
      //  self.layer.shadowOpacity = 1.0//
   }
    
    //ボタンが押された時のアニメーション
    internal func touchStartAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {() -> Void in
            //Buttonを押したときにどれだけ大きさが変化するか
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95);
            //わからん
            self.alpha = 0.9
        },completion: nil)
    }
    
    //ボタンから手が離れた時のアニメーション
    internal func touchEndAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
            self.alpha = 1
        },completion: nil)
    }
}
