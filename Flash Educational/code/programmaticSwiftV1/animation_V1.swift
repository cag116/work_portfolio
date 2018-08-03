//
//  Jitterable.swift
//  ProtocolSuperAwesomeTime
//
//  Created by Caleb Stultz on 9/14/16.
//  Copyright © 2016 Caleb Stultz. All rights reserved.
//

import UIKit

protocol Jitterable {}
class jitterableTextfield:UITextField, Jitterable {
    
}

extension Jitterable where Self: UIView {
    func jitter() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: self.center.x + 5.0, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
}
