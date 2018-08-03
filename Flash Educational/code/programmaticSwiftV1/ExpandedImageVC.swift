//
//  ExpandedImageVC.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/27/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import Foundation
import UIKit
import WebImage

class ExpandedImageVC: UIViewController, UIScrollViewDelegate {
    
    var urlString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        let scrollV = UIScrollView()
        scrollV.frame = CGRectMake(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        scrollV.minimumZoomScale=1
        scrollV.maximumZoomScale=5
        scrollV.bounces=false
        scrollV.delegate=self;
        self.view.addSubview(scrollV)
        scrollV.backgroundColor = UIColor.clear
        scrollV.tag = 100
        
        let image = UIImageView()
        image.backgroundColor = UIColor.clear
        image.sd_setImage(with: URL(string: urlString))
        print(urlString)
        image.tag = 110
        image.contentMode = .scaleAspectFit
        
        image.frame = CGRectMake(0, 0, scrollV.frame.width, scrollV.frame.height)
        
        
        
        
        
        scrollV.addSubview(image)

        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.view.viewWithTag(scrollView.tag + 10)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
