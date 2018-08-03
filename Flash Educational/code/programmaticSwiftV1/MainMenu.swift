//
//  ViewController.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/16/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import FBSDKLoginKit

//This is a temporary fix


class MainMenuVC: UIViewController {
    
    var segueBackgroundColorSend = UIColor()
    
    //These are declarations of items within this view controller
    
    var segueSender = ""
    //These just set the screen heights and widths for later use
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //Variables For Online Data
    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var cellButtons = [["Study","MainMenuToSelectTestSegue"],["Resources","MainMenuToSelectTestSegue"],/*["Create","MainMenuToCreateSegue"],["Account"],*/["Logout"]]
    
    let mainScrollView = UIScrollView(frame: CGRectMake(0,0,UIScreen.main.bounds.width, UIScreen.main.bounds.height))
    
    let diamondDimensions = (UIScreen.main.bounds.width/2)*((sqrt(2))/2)
    
    
    override func viewDidLoad() {
        //This clears the transition elements from both types of custom segues
        clearRadialTransitionElements()
        
        if Reachability.isInternetAvailable() == false {
            SweetAlert().showAlert("Uh oh!", subTitle: "Your internet is disconnected. This software will not work without internet", style: AlertStyle.warning)
        } else {
        
            //These will fetch information from the database
            
        }
        
        super.viewDidLoad()
        
        //This sets up the items on the screen.
        
        
        //This is just verification for me as a dev
        print("here")
        
        print(currentStudent)
        createDiamondBackground()
        createDiamondMenu()
        
        
    }
    
    func createDiamondBackground(){
        var rowCounter:CGFloat = -1
        var diamondLayoutCounter = 0
        
        for i in 0...40{
            
            var xCenter:CGFloat = 0
            let yCenter:CGFloat = (rowCounter+1)*(UIScreen.main.bounds.width/4)
            
            if (diamondLayoutCounter == 0){
                xCenter = 0
                diamondLayoutCounter = 1
            } else if (diamondLayoutCounter == 1){
                xCenter = ((UIScreen.main.bounds.width/2))
                diamondLayoutCounter = 2
            }  else if (diamondLayoutCounter == 2){
                xCenter = ((UIScreen.main.bounds.width))
                diamondLayoutCounter = 3
                rowCounter += 1
            }  else if (diamondLayoutCounter == 3){
                xCenter = ((UIScreen.main.bounds.width/2)-(UIScreen.main.bounds.width/4))
                diamondLayoutCounter = 4
            }  else if (diamondLayoutCounter == 4){
                xCenter = ((UIScreen.main.bounds.width/2)-(UIScreen.main.bounds.width/4)) + (UIScreen.main.bounds.width/2)
                diamondLayoutCounter = 0
                rowCounter += 1
            }
            
            
            
            
            let diamondView = UIView(frame: CGRect(x: 0, y: 0, width: diamondDimensions, height: diamondDimensions))
            diamondView.backgroundColor = getRandomColor(tint:"")
            diamondView.alpha = 0.6
            
            diamondView.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 45)))
            diamondView.center = CGPoint(x: xCenter, y: yCenter)
            mainScrollView.addSubview(diamondView)
        }
        
    }
    
    func createDiamondMenu(){
        
        mainScrollView.backgroundColor = UIColor.black
        self.view.addSubview(mainScrollView)
        
        
        //== These variables help setup the row system ==//
        //This first variable offsets the diamonds in the x dimension
        var diamondLayoutCounter = 0
        var rowCounter:CGFloat = 0
        
        
        for i in 0...cellButtons.count-1{
            
            
            var xCenter:CGFloat = 0
            let yCenter:CGFloat = (rowCounter+1)*(UIScreen.main.bounds.width/4)
            
            //This will setup the x and y dimensions
            if (diamondLayoutCounter == 0){
                xCenter = ((UIScreen.main.bounds.width/2)-(UIScreen.main.bounds.width/4)) + CGFloat(diamondLayoutCounter)*((UIScreen.main.bounds.width/2))
                
                
                diamondLayoutCounter = 1
            } else if (diamondLayoutCounter == 1){
                xCenter = ((UIScreen.main.bounds.width/2)-(UIScreen.main.bounds.width/4)) + CGFloat(diamondLayoutCounter)*((UIScreen.main.bounds.width/2))
                
                diamondLayoutCounter = 2
                rowCounter += 1
            }  else if (diamondLayoutCounter == 2){
                xCenter = ((UIScreen.main.bounds.width/2))
                
                diamondLayoutCounter = 0
                rowCounter += 1
            }
            
            
            let diamondView = UIView(frame: CGRect(x: 0, y: 0, width: diamondDimensions, height: diamondDimensions))
            diamondView.backgroundColor = getRandomColor(tint:"dark")
            diamondView.tag = 13500 + i
            diamondView.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 45)))
            diamondView.center = CGPoint(x: xCenter, y: yCenter)
            mainScrollView.addSubview(diamondView)
            
            let imageViewOffset:CGFloat = 10
            let diamondImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width/4)-(imageViewOffset+5), height: (UIScreen.main.bounds.width/4)-(imageViewOffset+5)))
            diamondImageView.backgroundColor = UIColor.clear
            diamondImageView.tag = 13600 + i
            diamondImageView.center = CGPoint(x: xCenter, y: yCenter-imageViewOffset)
            diamondImageView.image = UIImage(named: self.cellButtons[i][0] + "_w")
            mainScrollView.addSubview(diamondImageView)
            
            
            let diamondLabel = UILabel(frame: (frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width/4)-imageViewOffset, height: 2*imageViewOffset)))
            diamondLabel.backgroundColor = UIColor.clear
            diamondLabel.center = CGPoint(x: xCenter, y: diamondImageView.center.y + (diamondImageView.frame.height/2) + imageViewOffset)
            diamondLabel.text = self.cellButtons[i][0]
            diamondLabel.tag = 13700 + i
            diamondLabel.textAlignment = .center
            diamondLabel.textColor = UIColor.white
            mainScrollView.addSubview(diamondLabel)
            
            let diamondButton = parameterizedButton(frame: CGRect(x: 0, y: 0, width: diamondDimensions, height: diamondDimensions))
            diamondButton.backgroundColor = UIColor.clear
            diamondButton.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 45)))
            diamondButton.center = CGPoint(x: xCenter, y: yCenter)
            diamondButton.addTarget(self, action: #selector(MainMenuVC.diamondDoSegue(_:)), for: .touchDown)
            diamondButton.IntTagForPass = i
            diamondButton.tag = 13000 + i
            mainScrollView.addSubview(diamondButton)
            diamondButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            diamondButton.layer.shadowOpacity = 0.4
            diamondButton.layer.shadowRadius = 3
            
            
            
            
        }
    }
    
    func diamondDoSegue(_ button: parameterizedButton){
        
        let windowCenter = UIApplication.shared.delegate?.window!?.center
        print("test")
        let newView = UIView(frame: CGRectMake(0, 0, diamondDimensions, diamondDimensions))
        newView.center = CGPoint(x: self.view.viewWithTag(button.tag + 500)!.center.x, y: self.view.viewWithTag(button.tag + 500)!.center.y + 64)
        newView.backgroundColor = self.view.viewWithTag(button.tag + 500)!.backgroundColor
        self.segueBackgroundColorSend = self.view.viewWithTag(button.tag + 500)!.backgroundColor!
        newView.tag = 6662
        newView.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 45)))
        print("test2")
        
        
        let newImageView = UIImageView()
        newImageView.image = UIImage(named: self.cellButtons[button.IntTagForPass][0] + "_w")
        
        newImageView.frame = self.view.viewWithTag(button.tag + 600)!.frame
        print("test3")
        newImageView.center = CGPoint(x: self.view.viewWithTag(button.tag + 600)!.center.x, y: self.view.viewWithTag(button.tag + 600)!.center.y + 64)
        print("test4")
        newImageView.tag = 6663
        
        let modelLabel = self.view.viewWithTag(button.tag + 700)! as! UILabel
        let newViewLabel = UILabel()
        newViewLabel.frame = modelLabel.frame
        newViewLabel.backgroundColor = modelLabel.backgroundColor
        newViewLabel.center = CGPoint(x: modelLabel.center.x, y: modelLabel.center.y + 64)
        newViewLabel.text = modelLabel.text
        newViewLabel.textColor = modelLabel.textColor
        newViewLabel.textAlignment = .center
        newViewLabel.tag = 6664
        
        let squarePathElement = UIView()
        squarePathElement.frame = CGRectMake(0, 0, 15, 15)
        squarePathElement.backgroundColor = UIColor.white
        squarePathElement.center = CGPoint(x:  (windowCenter?.x)!-50, y: (windowCenter?.y)!+115)
        squarePathElement.layer.cornerRadius = 10
        squarePathElement.tag = 6665
        
        
        let window = UIApplication.shared.delegate?.window!
        window?.addSubview(newView)
        window?.addSubview(newImageView)
        window?.addSubview(newViewLabel)
        window?.addSubview(squarePathElement)
        
        
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut,.autoreverse,.repeat], animations: {
                squarePathElement.center = CGPoint(x: (windowCenter?.x)!+50, y: squarePathElement.center.y)
            }, completion:nil)
        
        
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.view.viewWithTag(button.tag + 500)?.center = UIScreen.main.bounds.ce
            
            newView.transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 0)))
            newView.frame = (window?.frame)!
            newImageView.frame = CGRectMake(0, 0, 100, 100)
            newImageView.center = CGPoint(x: newView.center.x, y: newView.center.y-30)
            newViewLabel.center = CGPoint(x: newView.center.x, y: newImageView.frame.origin.y + newImageView.frame.height + 30)
            
        }, completion: {
            (value: Bool) in
            if (button.IntTagForPass == 0){
                self.segueSender = "test"
                self.doSegue(segueID: self.cellButtons[button.IntTagForPass][1])
            } else if (button.IntTagForPass == 1){
                self.segueSender = "resources"
                self.doSegue(segueID: self.cellButtons[button.IntTagForPass][1])
            } else if (button.IntTagForPass == 3){
                self.doSegue(segueID: self.cellButtons[button.IntTagForPass][1])
            } else if (button.IntTagForPass == 2){
                self.batchDeleteAllPersistentUser()
                if (FBSDKAccessToken.current() == nil){
                    print("No user logged in via Facebook")
                } else {
                    print("=====================")
                    print(FBSDKAccessToken.current())
                    FBSDKLoginManager().logOut()
                }
                self.performSegue(withIdentifier: "unwindMainMenuToLoginSegue", sender: self)
            }
            
        })
        
        
 
        
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.identifier == "MainMenuToSelectTestSegue"){
            print("Moving to Select Test")
            let destinationVC = segue.destination as! SelectTestVC
            
            destinationVC.currentStudent = currentStudent
            destinationVC.segueBackgroundColorReceive = segueBackgroundColorSend
            
            destinationVC.segueSender = segueSender
        }
        else if (segue.identifier == "MainMenuToCreateSegue"){
            print("Moving to Create")
            let destinationVC = segue.destination as? CreateVC
            destinationVC?.fetchedStandardTests = fetchedStandardTests
            destinationVC?.fetchedStandardTopics = fetchedStandardTopics
            destinationVC?.fetchedStandardSubtopics = fetchedStandardSubtopics
            destinationVC?.currentStudent = currentStudent
            destinationVC?.segueBackgroundColorReceive = segueBackgroundColorSend
            
            destinationVC?.hierarchy = hierarchy
            
        }
    }
    
    func batchDeleteAllPersistentUser(){
        getCurrentCoreData()
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentUser")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let result = try managedContext.execute(request)
            print("User removed from persistence")
        } catch let error as NSError {
            print("Could not execute. \(error), \(error.userInfo)")
        }
        
    }
    
    func doSegue(segueID: String){
        self.performSegue(withIdentifier: segueID, sender: self)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide the navigation bar on the this view controller
        
        
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

