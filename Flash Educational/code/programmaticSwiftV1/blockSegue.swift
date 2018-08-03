//
//  blockSegue.swift
//  customSeguePractice
//
//  Created by Christopher Guirguis on 1/12/17.
//  Copyright © 2017 Christopher Guirguis. All rights reserved.
//

import UIKit

class blockSegue: UIStoryboardSegue {
    override func perform() { //set the ViewControllers for the animation
        let window = UIApplication.shared.delegate?.window!
        let sourceView = self.source.view as UIView!
        let destinationView = self.destination.view as UIView!
        destinationView?.center = CGPoint(x: (sourceView?.center.x)!, y: (sourceView?.center.y)!)
        destinationView?.alpha = 0
        print(self.destination.view.backgroundColor)
        
        window?.insertSubview(destinationView!, aboveSubview: sourceView!)
        
        
        print(UIScreen.main.bounds)
        let objectHeight:CGFloat = 20;
        let objectWidth:CGFloat = 20;
        
        let blocksPerRow = (Int(round(Double(UIScreen.main.bounds.width/objectWidth))))
        let blocksPerColumn = (Int(round(Double(UIScreen.main.bounds.height/objectHeight))))
        print(blocksPerRow)
        print(blocksPerColumn)
        
        
        let containerView = UIView(frame: (sourceView?.frame)!)
        containerView.tag = 6666
        window?.addSubview(containerView)
        var pushed = 0
        
        for i in 0...Int(round(Double(blocksPerColumn))){
            for j in 0...Int(round(Double(blocksPerRow))){
                
                let view1 = UIView(frame: CGRect(x:0, y:0, width:objectWidth, height:objectHeight))
                    let randomExpansionOfIndex = arc4random_uniform(UInt32((blocksPerColumn-i)*10))
                    
                    
                    let thisBoxRightShift = (CGFloat(j) * objectWidth)
                    let totalBoxLeftShift = ((CGFloat(blocksPerRow)/2) * objectWidth)
                    let xCenter = /*Part 1*/(UIScreen.main.bounds.width/2) /*Part 2*/ + thisBoxRightShift /*Part 3*/ - totalBoxLeftShift
                    
                    let thisBoxUpShift = (CGFloat(i) * objectHeight)
                    let yCenter = /*Part 1*/ 0 + (objectHeight/2) /*Part 2*/ + thisBoxUpShift
                    //print(yCenter)
                    view1.center = CGPoint(x: xCenter, y: yCenter)
                containerView.addSubview(view1)//(view1, belowSubview: destinationView!)
                    //animatedBackgroundView.addSubview(view1)
                    view1.tag = ((i+1)*10000) + (j+1)
                view1.alpha = 0
                    //print(view1.tag)
                    //This sets the occasional random blue tint
                    let randomNumForTint = arc4random_uniform(80)
                    //This sets the alpha
                    let alphaRatio = (Double(randomExpansionOfIndex)/Double(10*blocksPerColumn))
                    let alpha = CGFloat(1-(0.35 + (0.65*(1-pow(alphaRatio,3)))))
                    //This sets the random conditions
                
                if (self.destination.view.backgroundColor == UIColor.white){
                    view1.backgroundColor = getRandomColor(tint:"dark"
                    )
                } else {
                    view1.backgroundColor = self.destination.view.backgroundColor
                }
                
                    
                //This sets the occasional random blue tint
                let randomNumForDelay = arc4random_uniform(80)
                //This sets the alpha
                let randomDelay = (Double(randomNumForDelay)/Double(80))
                    var columnOffset = (Double(i)/Double(blocksPerColumn))
                    var rowOffset = (Double(j)/Double(blocksPerRow))
                    
                    UIView.animate(withDuration: 0.3, delay: 0.3*(columnOffset + rowOffset)*randomDelay, options: [.curveEaseInOut], animations: {
                        
                        view1.alpha = 1
                        
                    }, completion: {
                        (value: Bool) in
                        UIView.animate(withDuration: 0.2, delay: 0.25, animations: {
                            destinationView?.alpha = 1
                            window?.viewWithTag(6666)?.alpha = 0
                        }, completion: {
                            (value: Bool) in
                            if (pushed == 0){
                                pushed = 1
                                
                                self.source.navigationController?.pushViewController(self.destination, animated: false)
                                //window?.viewWithTag(6666)?.removeFromSuperview()
                            }
                        })
                    })
                }
            }
        
        //create UIAnimation- change the views's position when present it 
        
}
}
