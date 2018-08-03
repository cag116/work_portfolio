//
//  resourceWebViewVC.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 1/4/17.
//  Copyright © 2017 Christopher Guirguis. All rights reserved.
//

import UIKit

class resourceWebViewVC: UIViewController,UIWebViewDelegate {
    
    var URLforWebView:String = ""
    
    let bottomNavBar = UINavigationBar()
    let rightNav = UINavigationItem(title: "");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        loadWebView()
        loadBottomBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWebView(){
        let resourceWebView = UIWebView()
        self.view.addSubview(resourceWebView)
        //The (-40) in the height below factors in the navigation bar height
        resourceWebView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height-40)
        resourceWebView.delegate = self
        if let url = URL(string: URLforWebView) {
            let request = URLRequest(url: url)
            resourceWebView.loadRequest(request)
        }
        
    }
    
    func loadBottomBar(){
        let bottomNavBar = UINavigationBar()
        self.view.addSubview(bottomNavBar)
        bottomNavBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        bottomNavBar.frame = CGRectMake(0, UIScreen.main.bounds.height-40, UIScreen.main.bounds.width, 40)
        
        let nextButton =  UIButton(type: .custom)
        //button.setImage(UIImage(named: "icon_right"), for: .normal)
        nextButton.addTarget(self, action: #selector(resourceWebViewVC.openURLInSafari(_:)), for: .touchDown)
        nextButton.frame = CGRectMake(0, 3, 110, 31)
        //nextButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 12, 1, -12)//move image to the right
        nextButton.backgroundColor = UIColor.clear
        let nextButtonLabel = UILabel(frame: CGRectMake(3, 6, 120, 20))
        nextButtonLabel.font = UIFont.systemFont(ofSize: 16)
        nextButtonLabel.text = "Open in Safari"
        nextButtonLabel.backgroundColor = UIColor.red
        nextButtonLabel.textAlignment = .center
        nextButtonLabel.textColor = UIColor.black
        nextButtonLabel.backgroundColor =   UIColor.clear
        nextButton.addSubview(nextButtonLabel)
        let nextBarButton = UIBarButtonItem(customView: nextButton)
        
        /*let previousButton =  UIButton(type: .custom)
        //button.setImage(UIImage(named: "icon_right"), for: .normal)
        previousButton.frame = CGRectMake(0, 0, 120, 31)
        //previousButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 12, 1, -12)//move image to the right
        previousButton.backgroundColor = UIColor.clear
        let previousButtonLabel = UILabel(frame: CGRectMake(0, 5, 130, 20))
        previousButtonLabel.font = UIFont.systemFont(ofSize: 12)
        previousButtonLabel.text = "Previous Question"
        previousButtonLabel.backgroundColor = UIColor.red
        previousButtonLabel.textAlignment = .left
        previousButtonLabel.textColor = UIColor.black
        previousButtonLabel.backgroundColor =   UIColor.clear
        previousButton.addSubview(previousButtonLabel)
        let previousBarButton = UIBarButtonItem(customView: previousButton)*/
        
        
        
        
        rightNav.rightBarButtonItem = nextBarButton;
        //rightNav.leftBarButtonItem = previousBarButton;
        
        bottomNavBar.setItems([rightNav], animated: false);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func openURLInSafari(_ button: UIBarButtonItem){
        UIApplication.shared.openURL(URL(string: URLforWebView)!)
    }
}

class tempVCTrial: UIViewController {
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
                
        
       
        
    }
    
  
}
