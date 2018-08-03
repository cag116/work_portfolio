//
//  blockSegue.swift
//  customSeguePractice
//
//  Created by Christopher Guirguis on 1/12/17.
//  Copyright © 2017 Christopher Guirguis. All rights reserved.
//

import UIKit

class radialBlockSegue: UIStoryboardSegue {
    override func perform() {
        
        //set the ViewControllers for the animation
        
        let sourceView = self.source.view as UIView!
        let destinationView = self.destination.view as UIView!
        
        
        let window = UIApplication.shared.delegate?.window!
        //set the destination View center
        let intermediateView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        intermediateView.backgroundColor = UIColor.blue
        self.source.navigationController?.pushViewController(self.destination, animated: false)
        
        // the Views must be in the Window hierarchy, so insert as a subview the destionation above the source
        //window?.insertSubview(destinationView!, aboveSubview: sourceView!)
        
        //create UIAnimation- change the views's position when present it
        /*
    override func perform() { //set the ViewControllers for the animation
        let window = UIApplication.shared.delegate?.window!
        let sourceView = self.source.view as UIView!
        let destinationView = self.destination.view as UIView!
        destinationView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        print(self.destination.view.backgroundColor)
        print(CGRectForSegue)
        
        
        window?.insertSubview(destinationView!, aboveSubview: sourceView!)
        
        
        
        
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseInOut], animations: {
            
            destinationView?.frame = sourceView!.frame
            
        }, completion: {
            (value: Bool) in
            
            window?.viewWithTag(6666)?.alpha = 0
            self.source.navigationController?.pushViewController(self.destination, animated: false)
        })
        
        //create UIAnimation- change the views's position when present it
        
    }*/
    }
}
