//
//  ViewController.swift
//  ios-swift-collapsible-table-section-in-grouped-section
//
//  Created by Yong Su on 5/31/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit
import AudioUnit
import MobileCoreServices
import Alamofire

class CreateVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //==============================
    //Define elements for the form
    //==============================
    
    let questionInput = UITextView()
    let answerOneInput = UITextView()
    let answerTwoInput = UITextView()
    let answerThreeInput = UITextView()
    let answerFourInput = UITextView()
    let answerFiveInput = UITextView()
    let answerSixInput = UITextView()
    let answerSevenInput = UITextView()
    let answerEightInput = UITextView()
    let explanationInput = UITextView()
    
    let usernameInput = UITextView()
    let passwordInput = UITextView()
    let confirmPasswordInput = UITextView()
    let emailInput = UITextView()
    let institutionIdInput = UITextView()
    
    let submitButton = UIButton()
    let errorLabel = UILabel()
    
    var correctAnswerChoice = ""
    
    var hierarchy:[Any] = []
    var sections = [Section]()
    
    var currentContentHeight:CGFloat = 20
    
    var spacingBetweenInputs:CGFloat = 8
    
    var inputArray:[[Any]] = []
    
    var mainSV = UIScrollView(frame: CGRectMake(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height))
    
    
    //==============================
    
    let picker = UIImagePickerController()
    var tagForCurrentPickerDestination = Int()
    
    let photoLibraryButton = UIButton()
    let cameraButton = UIButton()
    let photoPickCancelButton = UIButton()
    //==============================
    //==============================
    //==============================
    
    var segueSender = ""
    var segueBackgroundColorReceive = UIColor()
    var segueBackgroundColorSend = UIColor()
    
    var username:String = ""
    var currentStudent:NSArray = []
    
    //These are arrays that contain the raw list of information
    var fetchedStandardTests:NSArray = []
    var fetchedStandardTopics:NSArray = []
    var fetchedStandardSubtopics:NSArray = []
    
    //This will keep the list of tests that are active
    var activeStandardTests:NSMutableArray = []
    
    
    //This is the filtered lsit of topics that gets setup when you select a test
    var standardTopicsFiltered:NSMutableArray = []
    
        override func viewDidLoad() {
        super.viewDidLoad()
        clearRadialTransitionElements()
            picker.delegate = self
            
            self.view.clipsToBounds = true
        
            self.view.addSubview(mainSV)
            
            let nextButton = UIButton()
            nextButton.frame = CGRectMake(0, 0, 50, 50)
            nextButton.center = CGPoint(x: mainSV.center.x, y: UIScreen.main.bounds.height - 40)
            nextButton.setImage(UIImage(named: "right_filled_b"), for: .normal)
            //nextButton.backgroundColor = UIColor.orange
            nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            nextButton.layer.shadowOpacity = 0.5
            nextButton.layer.shadowRadius = 3
            nextButton.addTarget(self, action: #selector(CreateVC.goToHierarchy(_:)), for: .touchDown)
            
            
            self.view.addSubview(nextButton)
            
            
            cameraButton.frame = CGRectMake(0, 0, UIScreen.main.bounds.width/2, 70)
            cameraButton.center = CGPoint(x: mainSV.center.x/2, y: (UIScreen.main.bounds.height - cameraButton.frame.height/2) + cameraButton.frame.height)
            cameraButton.backgroundColor = UIColor.init(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
            cameraButton.setTitle("Camera",for: .normal)
            cameraButton.layer.shadowOffset = CGSize(width: 0, height: -1)
            cameraButton.layer.shadowOpacity = 0.5
            cameraButton.layer.shadowRadius = 3
            cameraButton.addTarget(self, action: #selector(CreateVC.photoFromCamera(_:)), for: .touchDown)
            self.view.addSubview(cameraButton)
            
            
            photoLibraryButton.frame = CGRectMake(0, 0, UIScreen.main.bounds.width/2, 70)
            photoLibraryButton.center = CGPoint(x: mainSV.center.x/2 + photoLibraryButton.frame.width, y: (UIScreen.main.bounds.height - photoLibraryButton.frame.height/2) + photoLibraryButton.frame.height)
            photoLibraryButton.backgroundColor = UIColor.init(red: 0.75, green: 0.6, blue: 0.48, alpha: 1)
            photoLibraryButton.setTitle("Library",for: .normal)
            photoLibraryButton.layer.shadowOffset = CGSize(width: 0, height: -1)
            photoLibraryButton.layer.shadowOpacity = 0.5
            photoLibraryButton.layer.shadowRadius = 3
            photoLibraryButton.addTarget(self, action: #selector(CreateVC.photoFromLibrary(_:)), for: .touchDown)
            self.view.addSubview(photoLibraryButton)

            photoPickCancelButton.frame = CGRectMake(0, 0, UIScreen.main.bounds.width, 30)
            photoPickCancelButton.center = CGPoint(x: mainSV.center.x - photoPickCancelButton.frame.width, y: UIScreen.main.bounds.height - (photoLibraryButton.frame.height + (photoPickCancelButton.frame.height/2)))
            photoPickCancelButton.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
            photoPickCancelButton.setTitle("Cancel",for: .normal)
            photoPickCancelButton.layer.shadowOffset = CGSize(width: 0, height: -1)
            photoPickCancelButton.layer.shadowOpacity = 0.5
            photoPickCancelButton.layer.shadowRadius = 3
            photoPickCancelButton.addTarget(self, action: #selector(CreateVC.clickCancelPhotoPick(_:)), for: .touchDown)
            self.view.addSubview(photoPickCancelButton)

        
            //currentContentHeight = 44 + statusBarHeight + (2*spacingBetweenInputs)
            print(currentContentHeight)
            inputArray = [[questionInput,"Question"],[answerOneInput,"Answer (A)"],[answerTwoInput,"Answer (B)"],[answerThreeInput,"Answer (C)"],[answerFourInput,"Answer (D)"],[answerFiveInput,"Answer (E)"],[answerSixInput,"Answer (F)"],[answerSevenInput,"Answer (G)"],[answerEightInput,"Answer (H)"],[explanationInput,"Explanation"]]
            
            let tapOutsideKeyboard = parameterizedTapGestureRecognizer(target: self, action: #selector(signUpVC.handleTapOutsideKeyboard(sender:)))
            
            tapOutsideKeyboard.numberOfTapsRequired = 1
            
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(tapOutsideKeyboard)
            
            loadInputs()
            
        // Initialize the sections array
        // Here we have three sections: Mac, iPad, iPhone
        
        
        
    }
    
    func handleTapOutsideKeyboard(sender: parameterizedTapGestureRecognizer){
        
        //Clear all first responder
        clearAllFirstResponders()
    }
    
    func clearAllFirstResponders(){
        for i in 0...inputArray.count-1{
            let currentInputForChecking = (inputArray[i] as Array)[0] as! UITextView
            if(currentInputForChecking.isFirstResponder == true){
                currentInputForChecking.resignFirstResponder()
                
            }
        }
    }
    func loadInputs(){
        let sideMargins:CGFloat = 25
        for i in 0...inputArray.count-1{
            print("hello")
            
            let constructionLabel = UILabel()
            constructionLabel.text = (inputArray[i] as Array)[1] as! String
            constructionLabel.frame = CGRect(x: sideMargins, y: currentContentHeight, width: UIScreen.main.bounds.width-(30 + (2*sideMargins)), height: 30)
            constructionLabel.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.25)
            constructionLabel.textAlignment = .center
            mainSV.addSubview(constructionLabel)
            
            let constructionAddImageButton = UIButton()
            constructionAddImageButton.frame = CGRect(x: sideMargins + (constructionLabel.frame.width), y: currentContentHeight, width: 30, height: 30)
            
            constructionAddImageButton.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
            mainSV.addSubview(constructionAddImageButton)
            constructionAddImageButton.addTarget(self, action: #selector(CreateVC.pickPhoto(_:)), for: .touchDown)
            constructionAddImageButton.tag = 34690000 + (i+1)
            
            let constructionAddImageButtonBackground = UIImageView()
            constructionAddImageButtonBackground.frame = CGRect(x: sideMargins + (constructionLabel.frame.width), y: currentContentHeight, width: 30, height: 30)
            constructionAddImageButtonBackground.image = UIImage(named: "plus_w")
            constructionAddImageButtonBackground.tag = 34690000 + (i+1) + 200
            mainSV.addSubview(constructionAddImageButtonBackground)
            
            
            let constructionInput = (inputArray[i] as Array)[0] as! UITextView
            let inputPlaceholder = (inputArray[i] as Array)[1] as! String
            constructionInput.frame = CGRect(x: sideMargins, y: currentContentHeight+constructionLabel.frame.height, width: UIScreen.main.bounds.width-(2*sideMargins), height: 100)
            
            constructionInput.tag = (i+1)
            constructionInput.delegate = self
            constructionInput.returnKeyType = .next
            constructionInput.textAlignment = .center
            
            constructionInput.isEditable = true
            
            constructionInput.text = (inputArray[i] as Array)[1] as! String
            
            //constructionInput.textColor = UIColor.white
            constructionInput.textColor = UIColor.lightGray
            constructionInput.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
            mainSV.addSubview(constructionInput)
            
            let constructionImageView = UIImageView()
            constructionImageView.tag = 34690000 + (i+1) + 100
            constructionImageView.frame = CGRect(x: sideMargins, y: currentContentHeight+constructionLabel.frame.height+constructionInput.frame.height, width: UIScreen.main.bounds.width-(2*sideMargins), height: 100)
            constructionImageView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)
            constructionImageView.contentMode = .scaleAspectFit //3
            constructionImageView.image = UIImage(named: "pictureForCreateVC_w")
            
            mainSV.addSubview(constructionImageView)
            
            
    
            
            
            
            self.currentContentHeight += constructionInput.frame.height + constructionLabel.frame.height + constructionImageView.frame.height + spacingBetweenInputs
            
            
            let underLine = UIView()
            underLine.frame = CGRect(x: sideMargins, y: currentContentHeight-spacingBetweenInputs, width: UIScreen.main.bounds.width-(2*sideMargins), height: 1)
            underLine.backgroundColor = UIColor.white
            mainSV.addSubview(underLine)
        }
        
        
        
        let constructionLabel = UILabel()
        constructionLabel.text = "Correct Answer"
        constructionLabel.frame = CGRect(x: sideMargins, y: currentContentHeight, width: UIScreen.main.bounds.width-(2*sideMargins), height: 30)
        constructionLabel.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.25)
        constructionLabel.textAlignment = .center
        mainSV.addSubview(constructionLabel)
        
        let backgroundForCorrectView = UIView()
        mainSV.addSubview(backgroundForCorrectView)
        backgroundForCorrectView.frame = CGRect(x: sideMargins, y: currentContentHeight, width: UIScreen.main.bounds.width-(2*sideMargins), height: 30)
        backgroundForCorrectView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        self.currentContentHeight += constructionLabel.frame.height + 10 //The 10 is to space the label from the circular buttons
        
        let correctAnswerPickerSpacing:CGFloat = 5
        let answerChoiceDimension = ((UIScreen.main.bounds.width-(2*sideMargins))/8) - correctAnswerPickerSpacing
        
        for j in 0...7{
            let correctAnswerPickerSpacing:CGFloat = 5
            let answerChoiceDimension = ((UIScreen.main.bounds.width-(2*sideMargins))/8) - correctAnswerPickerSpacing
            
            let correctAnswerPicker = parameterizedButton()
            correctAnswerPicker.tagForPass = "inactive"
            correctAnswerPicker.tagForPass2 = numberToLetter[j][0]
            correctAnswerPicker.tag = (4703800) + j
            correctAnswerPicker.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
            correctAnswerPicker.frame = CGRect(x: sideMargins + (CGFloat(j)*(answerChoiceDimension+correctAnswerPickerSpacing)) + correctAnswerPickerSpacing/2, y: currentContentHeight, width: answerChoiceDimension, height: answerChoiceDimension)
            correctAnswerPicker.layer.cornerRadius = correctAnswerPicker.frame.width/2
            correctAnswerPicker.addTarget(self, action: #selector(CreateVC.activateCorrectAnswer(_:)), for: .touchDown)
            correctAnswerPicker.setTitle(numberToLetter[j][1],for: .normal)
            mainSV.addSubview(correctAnswerPicker)
        }
        
        backgroundForCorrectView.frame = CGRect(x: backgroundForCorrectView.frame.origin.x, y:  backgroundForCorrectView.frame.origin.y + constructionLabel.frame.height, width: backgroundForCorrectView.frame.width, height: 10 + answerChoiceDimension + 10) /* the 10 on either side are for spacing*/
        
        
        currentContentHeight += backgroundForCorrectView.frame.height + constructionLabel.frame.height
        
        mainSV.contentSize.height = self.currentContentHeight + 50 //The 50 is for the "next" button
//        institutionIdInput.returnKeyType = .go
    }
    
    func activateCorrectAnswer(_ sender: parameterizedButton) {
        print(sender.tagForPass2)
        //This resets the previous chosen answer before setting a new one as active
        for j in 0...7{
            (self.view.viewWithTag((4703800) + j) as! parameterizedButton).tagForPass = "inactive"
            (self.view.viewWithTag((4703800) + j) as! parameterizedButton).backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        }
        
        sender.tagForPass = "active"
        sender.backgroundColor =  UIColor.init(red: 0.4, green: 1, blue: 0.55, alpha: 0.5)
            
        print(sender)
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            print(textView.tag)
            textView.text = (inputArray[textView.tag-1] as Array)[1] as! String
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        if (textField.tag != 6){
            self.view.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
        }
        if textField == institutionIdInput {
            //
            institutionIdInput.resignFirstResponder()
            
            textField.isFirstResponder
        }
        
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.backgroundColor = self.segueBackgroundColorReceive
        self.view.viewWithTag(536536)?.removeFromSuperview()
    }
    
    
    
    func submitNewUserRequest() {
        
        let parameters: Parameters = ["question": questionInput.text!, "uname":usernameInput.text!,"password":passwordInput.text!,"email":emailInput.text!,"personalInstitutionId":institutionIdInput.text!,"database":"student"]
        print(parameters)
        
        Alamofire.request("http://flasheducational.com/phpScripts/universalSignUpRegisterNewUser.php", method: .post, parameters: parameters) .responseString { response in
            print("Response String: \(response.result.value!)!")
            
            if(response.result.value! == "success"){
                consoleLog(msg: "User created successfully", level: 1)
                SweetAlert().showAlert("Account Created!", subTitle: "Login to begin!", style: AlertStyle.success, buttonTitle:"Let's go!", buttonColor:UIColor.colorFromRGB(0xD0D0D0)) { (isOtherButton) -> Void in
                    self.performSegue(withIdentifier: "unwindSignupToLoginSegue", sender: self)
                }
                
            } else {
                SweetAlert().showAlert("This one's on us...", subTitle: "Somethings seems to have gone wrong. Try again later!", style: AlertStyle.warning)
                //errorLabel.text = "Somethings seems to have gone wrong. Try again later!"
            }
            
            
            hideViewByTag(selfView: self.view!, tagForAction: 7777)
            
            
        }
        
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func clickCancelPhotoPick(_ sender: UIButton) {
        hidePhotoPick()
    }
    
    
    func hidePhotoPick() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            
            self.photoLibraryButton.center = CGPoint(x: self.mainSV.center.x/2 + self.photoLibraryButton.frame.width, y: (UIScreen.main.bounds.height - self.photoLibraryButton.frame.height/2) + self.photoLibraryButton.frame.height)
            self.cameraButton.center = CGPoint(x: self.mainSV.center.x/2, y: (UIScreen.main.bounds.height - self.cameraButton.frame.height/2)  + self.cameraButton.frame.height)
            self.photoPickCancelButton.center = CGPoint(x: self.mainSV.center.x-self.photoPickCancelButton.frame.width, y: self.photoPickCancelButton.center.y)
            
        }, completion:nil)
    }
    
    
    
    
    func pickPhoto(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            
            self.photoLibraryButton.center = CGPoint(x: self.mainSV.center.x/2 + self.photoLibraryButton.frame.width, y: (UIScreen.main.bounds.height - self.photoLibraryButton.frame.height/2) + self.photoLibraryButton.frame.height)
            self.cameraButton.center = CGPoint(x: self.mainSV.center.x/2, y: (UIScreen.main.bounds.height - self.cameraButton.frame.height/2)  + self.cameraButton.frame.height)
            self.photoPickCancelButton.center = CGPoint(x: self.mainSV.center.x-self.photoPickCancelButton.frame.width, y: self.photoPickCancelButton.center.y)
            
        }, completion: {
            (value: Bool) in
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut], animations: {
                self.photoLibraryButton.center = CGPoint(x: self.mainSV.center.x/2 + self.photoLibraryButton.frame.width, y: (UIScreen.main.bounds.height - self.photoLibraryButton.frame.height/2))
                self.cameraButton.center = CGPoint(x: self.mainSV.center.x/2, y: (UIScreen.main.bounds.height - self.cameraButton.frame.height/2))
                self.photoPickCancelButton.center = CGPoint(x: self.mainSV.center.x, y: self.photoPickCancelButton.center.y)
            }, completion: nil)
            
        })
        
      
        
        self.tagForCurrentPickerDestination = sender.tag
        print(self.tagForCurrentPickerDestination)
        
        (mainSV.viewWithTag(tagForCurrentPickerDestination) as! UIButton).removeTarget(self, action: #selector(CreateVC.pickPhoto(_:)), for: .touchDown)
        (mainSV.viewWithTag(tagForCurrentPickerDestination) as! UIButton).addTarget(self, action: #selector(CreateVC.removeImage(_:)), for: .touchDown)
        //(mainSV.viewWithTag(sender.tag + 200) as! UIImageView).image = UIImage(named: "x_w")
    }
    
    func photoFromLibrary(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.setEditing(true, animated: true)
        //picker.preferredContentSize = new SizeF()
        picker.sourceType = .photoLibrary
        //picker.mediaTypes = //UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func photoFromCamera(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.setEditing(true, animated: true)
        //picker.preferredContentSize = new SizeF()
        picker.sourceType = .camera
        //picker.mediaTypes = //UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    func removeImage(_ sender: UIButton) {
        (mainSV.viewWithTag(sender.tag) as! UIButton).removeTarget(self, action: #selector(CreateVC.removeImage(_:)), for: .touchDown)
        (mainSV.viewWithTag(sender.tag) as! UIButton).addTarget(self, action: #selector(CreateVC.pickPhoto(_:)), for: .touchDown)
        
        //(mainSV.viewWithTag(sender.tag + 200) as! UIImageView).image = UIImage(named: "plus_w")
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.view.viewWithTag(button.tag + 500)?.center = UIScreen.main.bounds.ce
            
            (self.mainSV.viewWithTag(sender.tag + 200) as! UIImageView).transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 0)))
            
            
        }, completion: nil)
        
        (mainSV.viewWithTag(sender.tag + 100) as! UIImageView).image = UIImage(named: "pictureForCreateVC_w")
    }
    
    
    //MARK: - Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage //2
        (mainSV.viewWithTag(tagForCurrentPickerDestination + 100) as! UIImageView).image = chosenImage //4
        //====(mainSV.viewWithTag(tagForCurrentPickerDestination + 200) as! UIImageView).image = UIImage(named: "x_w")
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            //self.view.viewWithTag(button.tag + 500)?.center = UIScreen.main.bounds.ce
            
            (self.mainSV.viewWithTag(self.tagForCurrentPickerDestination + 200) as! UIImageView).transform = CGAffineTransform(rotationAngle: CGFloat(degreesToRadians(degrees: 45)))
           
            
        }, completion: nil)
        dismiss(animated:true, completion: nil) //5
        
        hidePhotoPick()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        (mainSV.viewWithTag(tagForCurrentPickerDestination) as! UIButton).removeTarget(self, action: #selector(CreateVC.removeImage(_:)), for: .touchDown)
        (mainSV.viewWithTag(tagForCurrentPickerDestination) as! UIButton).addTarget(self, action: #selector(CreateVC.pickPhoto(_:)), for: .touchDown)
        hidePhotoPick()
        //====(mainSV.viewWithTag(tagForCurrentPickerDestination + 200) as! UIImageView).image = UIImage(named: "plus_w")
        dismiss(animated: true, completion: nil)
        
    }
    
    func goToHierarchy(_ sender: UIButton) {
        
        processForm()
        
    }
    
    func processForm(){
        var errorPresent = false
        var errorMessage = ""
        //Check if one answer has even been chosen
        var answerChosenMarker = false
        var answerChosenHasResponse = false
        for j in 0...7{
            if ((self.view.viewWithTag((4703800) + j) as! parameterizedButton).tagForPass == "active"){
                answerChosenMarker = true
                
                //The +2 in the viewWithTag statement accounts for the questions field
                print((self.view.viewWithTag(j+2) as! UITextView).text)
                if ((self.view.viewWithTag(j+2) as! UITextView).text != (inputArray[j+1] as Array)[1] as! String){
                    answerChosenHasResponse = true
                    correctAnswerChoice = (self.view.viewWithTag((4703800) + j) as! parameterizedButton).tagForPass2
                } else {
                    print((self.view.viewWithTag(j+2) as! UITextView).textColor)
                    print((self.view.viewWithTag(j+2) as! UITextView).text)
                }
                
            }
        }
        
        if answerChosenMarker{
            print(answerChosenMarker)
            if answerChosenHasResponse{
                print(answerChosenHasResponse)
            } else {
                errorPresent = true
                errorMessage = "Chosen answer has no content!"
            }
        } else {
            errorPresent = true
            errorMessage = "Choose a correct answer!"
        }
        
        //If no errors are encountered, continue here
        if errorPresent{
            SweetAlert().showAlert("Oops!", subTitle: errorMessage, style: AlertStyle.error)
        } else {
            showflashEducationLoader(parentView: self.view!)
            createPostString()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "CreateToHierarchySegue", sender: self)
            }
            
        }
    }
    func createPostString(){
        var ansArray:[String] = []
        for i in 2...10{
            print("++++++++++++++")
            print((self.view.viewWithTag(i) as! UITextView).text)
            print((inputArray[i-1] as Array)[1] as! String)
            if ((self.view.viewWithTag(i) as! UITextView).text == (inputArray[i-1] as Array)[1] as! String){
                ansArray.append("")
            } else {
                ansArray.append((self.view.viewWithTag(i) as! UITextView).text)
            }
        }
        
        
        var questionInsertParameters:NSMutableDictionary = ["table":"question","type":"multipleChoice","question":(self.view.viewWithTag(1) as! UITextView).text,"answerOne":ansArray[0],"answerTwo":ansArray[1],"answerThree":ansArray[2],"answerFour":ansArray[3],"answerFive":ansArray[4],"answerSix":ansArray[5],"answerSeven":ansArray[6],"answerEight":ansArray[7],"visibility":"public.active","explanation":ansArray[8],"correctAnswer":correctAnswerChoice,"tags":""]//,"contributor":,"image":]
        print(questionInsertParameters)
    }
    
    
    func createHierarchy(){
        
        sections = [Section]()
        for i in 0...fetchedStandardTests.count-1{
            if let test = fetchedStandardTests[i] as? [String: Any]{
                if (test["activityStatus"] as? String == "active") {
                    let sectionName = test["name"]! as! String
                    var sectionItems:[String] = []
                    print(test["name"]!)
                    for j in 0...fetchedStandardTopics.count-1{
                        if let topic = fetchedStandardTopics[j] as? [String: Any]{
                            if (topic["correspondingSTP"] as? String == test["id"] as? String) {
                                print("STP-Topic = Match")
                                print(topic["name"]!)
                                sectionItems.append(topic["name"]! as! String)
                            }
                        }
                    }
                    
                    let sectionComplete = Section(name: sectionName, items: sectionItems)
                    sections.append(sectionComplete)
                }
                
                
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.identifier == "CreateToHierarchySegue"){
            
            createHierarchy()
            
            print("Moving to Hierarchy")
            let destinationVC = segue.destination as! ExpandableHierarchyTableViewController
            destinationVC.fetchedStandardTests = fetchedStandardTests
            destinationVC.fetchedStandardTopics = fetchedStandardTopics
            destinationVC.fetchedStandardSubtopics = fetchedStandardSubtopics
            destinationVC.currentStudent = currentStudent
            destinationVC.segueBackgroundColorReceive = segueBackgroundColorSend
            destinationVC.username = username
            destinationVC.segueSender = segueSender
            destinationVC.hierarchy = hierarchy
            destinationVC.sections = sections
            
        }
    }

}
