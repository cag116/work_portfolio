//
//  ViewController.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/16/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import UIKit
import WebImage
import AudioToolbox
import CoreData
import Alamofire
import FBSDKLoginKit





class ViewController: UIViewController,UITextFieldDelegate, SSRadioButtonControllerDelegate, FBSDKLoginButtonDelegate {
    //These are used for the background and loading animations
    var blocksPerRow:Int = 0
    var blocksPerColumn:Int = 0
    
    //These are used for user persistence and tracking the user's actions
    var persistentUser:[NSManagedObject] = []
    var usernameVal:String = ""
    var emailVal:String = ""
    
    var persistenceRadioButtonController: SSRadioButtonsController?
    
    var loginMethod = ""
    
    //These keep a record of all the items fetched from the database for the user to use
    
    
    
    
    //These are the actual elements in the page
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var rememberMeRadio: SSRadioButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    //This is what happens when you press the login button
    @IBAction func loginButton(_ sender: UIButton) {
        loginMethod = "native"
        userLoginAuthentication()
    }
    
    @IBAction func customFBLoginButton(_ sender: UIButton) {
        handleCustomFBLogin()
    }
    
    //These are the unwinds from the various pages
    @IBAction func unwindSignupToLogin(segue: UIStoryboardSegue) {}
    @IBAction func unwindMainMenuToLogin(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //This sets up the persistence radio button controller
        persistenceRadioButtonController = SSRadioButtonsController(buttons: rememberMeRadio)
        persistenceRadioButtonController!.delegate = self
        persistenceRadioButtonController!.shouldLetDeSelect = true
        
        //This gives a desginated tag to the radio button, itself
        self.rememberMeRadio.tag = 1000
        
        //This runs a function to begin modifying elements on the page
        elementModification()
        
        //This section sets up a gesture to close the keyboard when you tap outside it.
        let tapOutsideKeyboard = parameterizedTapGestureRecognizer(target: self, action: #selector(signUpVC.handleTapOutsideKeyboard(sender:)))
        tapOutsideKeyboard.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapOutsideKeyboard)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Remove != hide, becuse removing ensures there isnt a duplicate element when we create the loader again
        
        //This removes the animated background from the superview
        self.view.viewWithTag(8888)?.removeFromSuperview()
        
        //This clears the transition elements from block segues and radial block segues
        clearRadialTransitionElements()
        self.view.viewWithTag(536536)?.removeFromSuperview()
        showflashEducationLoader(parentView: self.view!)
        
        //This creates the background animation because it's needed to create the loader. the blocks in the loader use the bottom row of the background animation as a template
        setAnimatedBackground()
        //This hides the background because we dont want to see it until we decide the user is not persistent
        
        
        //This creates the loading animation first because that
        createLoadingAnimation()
        
        //This begins getting the question count within each subtopic. It's placed early on to ensure that it happens regardless of the persistence of the user
        Alamofire.request("http://flasheducational.com/phpScripts/fetch/unfiltered/all/countQuestionSubtopicRelation.php", method: .post, parameters: [:]) .responseString { response in
            //This prints the value of the repsonse string
            print("Response String: \(response.result.value!)")
            
            //The response string comes in the following format: [Subtopic ID]-[Number of Questions]---[Subtopic ID]-[Number of Questions]---(etc.)
            //The first split separate the entities into a list of [Subtopic ID]-[Number of Questions]
            var firstSplit = response.result.value!.components(separatedBy: "---")
            firstSplit.remove(at: firstSplit.count-1)
            print(firstSplit)
            
            //This loops through the list of [Subtopic ID]-[Number of Questions]
            for i in 0...firstSplit.count-1{
                //The second split separates each item of [Subtopic ID]-[Number of Questions] into a list of "Subtopic ID" and "Number of Questions"
                let secondSplit = firstSplit[i].components(separatedBy: "-")
                print(secondSplit)
                //This adds the second split result into a dictionary to be used later; it'll show the user how many questions are in a subtopic before they go that deep
                subtopicQuestionCount.setValue(secondSplit[1], forKey: secondSplit[0])
            }
            
            //This prints the dictionary
            print(subtopicQuestionCount)
            
            //This continues with the routine to check if a user is already logged in
            self.loginPersistenceRoutine()
        }
    }
    
    func elementModification(){
        //These lines setup the attributed placeholders for the sign in screen. They had to be done here because I needed to change the color (hence they are attributed)
        usernameInput.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.6)])
        passwordInput.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.6)])
    }
    
    
    func loginPersistenceRoutine(){
        //If there is a persistent user then login
        if (checkForUser() == true){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginToMainMenuSegue", sender: self)
            }
        } else {
        //if there is no persistent user then check facebook
            if (FBSDKAccessToken.current() == nil){
                print("No user logged in via Facebook")
                
                self.view.viewWithTag(536536)?.removeFromSuperview()
            } else {
                print("=====================")
                print(FBSDKAccessToken.current())
                getEmailAddress()
            }

            
            
        }
    }
    
    func checkForUser() -> Bool {
        //Get core data
        getCurrentCoreData()
        
        //Assemble fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PersistentUser")
        //Perform fetch
        do {
            persistentUser = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        //This is what happens when you finally update the array
        if (persistentUser.count > 0){
            print("There are " + String(persistentUser.count) + " items in this fetch")
            print(persistentUser[0].value(forKeyPath: "username")!)
            //This sets the usernameVal to the current persistent user in order to pass it through the segue
            usernameVal = persistentUser[0].value(forKeyPath: "username") as! String
            
            return true
        } else {
            return false
        }
    }
    
    
    func userLoginAuthentication() {
        DispatchQueue.main.async {
        showflashEducationLoader(parentView: self.view!)
        }
        //Check the internet connection
        if Reachability.isInternetAvailable() == false {
            self.view.viewWithTag(536536)?.removeFromSuperview()
            SweetAlert().showAlert("Uh oh!", subTitle: "Your internet is disconnected. This software will not work without internet", style: AlertStyle.warning)
        } else {
            
            //This hides the keyboard for the sake of user accessibility
            clearAllFirstResponders()
            
            //This defines the parameters for the user fetch
            let parameters: Parameters = ["database": "student", "uname":usernameInput.text!,"password":passwordInput.text!]
            print(parameters)
            
            //This is the HTTPRequest to check the user's login credentials
            Alamofire.request("http://flasheducational.com/phpScripts/universalLoginUserAuthentication.php", method: .post, parameters: parameters) .responseString { response in
                
                //This prints the response from the HTTPRequest
                print("Response String: \(response.result.value!)!")
                
                //This is what happens if the user enters valid credentials
                if(response.result.value! == "userAuthenticated"){
                    //Set their username to be passed through the segue
                    self.usernameVal = self.usernameInput.text!
                    
                    //Perform segue to the next screen
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginToMainMenuSegue", sender: self)
                    }
                } else if(response.result.value! == "userDoesntExist"){
                    //This is what happens if the username entered does not exist
                    consoleLog(msg: "Username invalid", level: 3)
                    self.view.viewWithTag(536536)?.removeFromSuperview()
                    SweetAlert().showAlert("Who are you?", subTitle: "The username you entered does not exist", style: AlertStyle.error)
                    
                    //Vibrate phone
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    
                    
                    
                } else if(response.result.value! == "passwordDoesntMatchUsername"){
                    //This is what happens if the password entered is invalid
                    consoleLog(msg: "Username invalid", level: 3)
                    self.view.viewWithTag(536536)?.removeFromSuperview()
                    SweetAlert().showAlert("Lose your keys?", subTitle: "Password is incorrect", style: AlertStyle.error)
                    
                    //Vibrate phone
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    
                    
                }
            }
        }
    }
    
    func setUser(usernameForSave: String){
        //Gets the core data
        getCurrentCoreData()
        print("Adding new user: " + usernameForSave)
            
        //Create instance of entity "PersistentUser" in managedContext (which we defined globally as the CoreData)
        let entity = NSEntityDescription.entity(forEntityName: "PersistentUser", in: managedContext)!
        
        //Assign NSEntityDescription to NSManagedObject
        let userToInsert = NSManagedObject(entity: entity, insertInto: managedContext)
            
        //Assign username value of NSManagedObject to value of "usernameForSave"; That value is passed into this function as a parameter
        userToInsert.setValue(usernameForSave, forKeyPath: "username")
            
        //Attempt appending managedContext
        do {
            try managedContext.save()
            persistentUser.append(userToInsert)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //This function handles taps outside the Keyboard
    func handleTapOutsideKeyboard(sender: parameterizedTapGestureRecognizer){
       clearAllFirstResponders()
    }
    
    //This function hides the keyboard
    func clearAllFirstResponders(){
        //Clear all first responder
        if(usernameInput.isFirstResponder == true){
            usernameInput.resignFirstResponder()
        } else if(passwordInput.isFirstResponder == true){
            passwordInput.resignFirstResponder()
        }
    }
    
    //This function shifts which UITextField is the first responder.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //The textfield will resign First Responder
        textField.resignFirstResponder()
        
        //If the previously active textfield was the usernameInput then the passwordInput will take up responsibility as First Responder
        if textField == usernameInput {
            passwordInput.becomeFirstResponder()
        } else if textField == passwordInput {
            //If the previously active textfield was the passwordInput then the passwordInput will resign first responder and the userLoginAuthetnication() will be executed
            passwordInput.resignFirstResponder()
            userLoginAuthentication()
        }
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //This is what happens when you move to the Main Menu
        if (segue.identifier == "LoginToMainMenuSegue"){
            //This persists the user if they user activated the corresponding radio button
            if((persistenceRadioButtonController?.selectedButton()?.tag) != nil){
                setUser(usernameForSave: usernameVal)
            }
            
            //These fetch data from the SQL database
            updateAllAppData(standardizedTestArrayToSet: &fetchedStandardTests, standardSubtopicArrayToSet: &fetchedStandardSubtopics, standardTopicArrayToSet: &fetchedStandardTopics, pointerQuestionStandardSubtopicArrayToSet: &fetchedPointerQuestionStandardSubtopic)
            
            //-- The function above should replace these lines below --//
            /*fetchAllAnything(table: "standardizedTest", arrayToSet: &self.fetchedStandardTests)
            fetchAllAnything(table: "pointerQuestionStandardSubtopic", arrayToSet: &self.fetchedPointerQuestionStandardSubtopic)
            fetchAllAnything(table: "standardTopic", arrayToSet: &self.fetchedStandardTopics)
            fetchAllAnything(table: "standardSubtopic", arrayToSet: &self.fetchedStandardSubtopics)*/
            
            consoleLog(msg: "Checkpoint VC.100001", level: 5)
            //This fetches the user from teh SQL database
            //If the user is logging in with facebook where the email is already associated with a native account, then we fetch the student by their email. otherwise we fetch by the username. This is because they've already chosen a username through the native signup, but the facebook has its own native "id" which we use as the username when a user creates an account through facebook initially
            print(loginMethod)
            if (loginMethod == "facebook"){
                generalFetch(arrayToSet: &currentStudent, argument: "argument=SELECT * FROM student WHERE email = \"\(emailVal)\"")
            } else {
                generalFetch(arrayToSet: &currentStudent, argument: "argument=SELECT * FROM student WHERE username = \"\(usernameVal)\"")
            }
            
            if let item = currentStudent[0] as? [String: Any]{
                currentStudentID = (item["id"] as! String!)!
                appendFlashLog()
            }
            consoleLog(msg: "Checkpoint VC.100002", level: 5)
            //This begins setup of the hierarchy. It isn't used unless the user goes to create a new question. We do this here because the time it takes to complete wouldnt be acceptable to the consumer later in the app, but they expect a sort of delay when the app first launches
            consoleLog(msg: "Checkpoint VC.100003", level: 5)
            modifyArraysViaHierarchy(standardizedTestArrayForHierarchy: &fetchedStandardTests, standardSubtopicArrayForHierarchy: &fetchedStandardSubtopics, standardTopicArrayForHierarchy: &fetchedStandardTopics, subtopicQuestionCount: &subtopicQuestionCount)
            consoleLog(msg: "Checkpoint VC.100006", level: 5)
            let destinationVC = segue.destination as! MainMenuVC
            
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoginToMainMenuSegue") {
            print("here")
        }
    }*/
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setAnimatedBackground(){
        
        let animatedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        animatedBackgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
        animatedBackgroundView.tag = 8888
        animatedBackgroundView.isHidden = false
        animatedBackgroundView.alpha = 1
        self.view.addSubview(animatedBackgroundView)
        
        
        
        let objectHeight:CGFloat = 20;
        let objectWidth:CGFloat = 20;
        
        
        
        blocksPerRow = (Int(round(Double(UIScreen.main.bounds.width/objectWidth))))
        print(blocksPerRow)
        blocksPerColumn = (Int(round(Double(UIScreen.main.bounds.height/objectHeight))))
        print(blocksPerColumn)
        
        for i in 0...Int(round(Double(blocksPerColumn))){
            for j in 0...Int(round(Double(blocksPerRow))){
                let view1 = viewWithStringTag(frame: CGRectMake(0, 0, objectWidth, objectHeight))
                let randomExpansionOfIndex = arc4random_uniform(UInt32((blocksPerColumn-i)*10))
                
                
                let thisBoxRightShift = (CGFloat(j) * objectWidth)
                let totalBoxLeftShift = ((CGFloat(blocksPerRow)/2) * objectWidth)
                let xCenter = /*Part 1*/(UIScreen.main.bounds.width/2) /*Part 2*/ + thisBoxRightShift /*Part 3*/ - totalBoxLeftShift
                
                let thisBoxUpShift = (CGFloat(i) * objectHeight)
                
                let yCenter = /*Part 1*/(UIScreen.main.bounds.height)-(objectHeight/2) /*Part 2*/ - thisBoxUpShift
                //print(yCenter)
                view1.center = CGPoint(x: xCenter, y: 0)
                animatedBackgroundView.addSubview(view1)
                view1.tag = ((i+1)*10000) + (j+1)
                //print(view1.tag)
                //This sets the occasional random blue tint
                let randomNumForTint = arc4random_uniform(80)
                //This sets the alpha
                let alphaRatio = (Double(randomExpansionOfIndex)/Double(10*blocksPerColumn))
                let alpha = CGFloat(1-(0.35 + (0.65*(1-pow(alphaRatio,3)))))
                //This sets the random conditions
                if (randomNumForTint == 1){view1.backgroundColor = UIColor.init(red: 46/255, green: 107/255, blue: 163/255, alpha: alpha + 0.15)}
                else if (randomNumForTint == 2){view1.backgroundColor = UIColor.init(red: 132/255, green: 187/255, blue: 238/255, alpha: alpha + 0.15)}
                else if (randomNumForTint == 3){view1.backgroundColor = UIColor.init(red: 67/255, green: 139/255, blue: 206/255, alpha: alpha + 0.15)}
                else if (randomNumForTint == 4){view1.backgroundColor = UIColor.init(red: 108/255, green: 188/255, blue: 255/255, alpha: alpha + 0.15)}
                else{view1.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: alpha)}
                
                
                //let randomDurationOffset = arc4random_uniform(UInt32(blocksPerRow))
                var randomDurationOffset = (Double(arc4random_uniform(UInt32(blocksPerRow)))/Double(blocksPerRow))
                
                UIView.animate(withDuration: 0.7 + (1.4*randomDurationOffset), delay: randomDurationOffset, options: [.curveEaseInOut], animations: {
                    
                    view1.center = CGPoint(x: view1.center.x, y: yCenter)
                    
                }, completion: nil)
                
                randomDurationOffset = (Double(arc4random_uniform(UInt32(blocksPerRow)))/Double(blocksPerRow))
                
                UIView.animate(withDuration: 2.0 + 2*randomDurationOffset, delay: randomDurationOffset, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                    
                    view1.alpha = 0
                    
                }, completion: nil)
            }
        }
        self.view.sendSubview(toBack: animatedBackgroundView)
        

    }
    
    func createLoadingAnimation(){
        
        
        //Create Loader Background
        let loaderBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loaderBackgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
        loaderBackgroundView.tag = 7777
        loaderBackgroundView.isHidden = false
        loaderBackgroundView.alpha = 0
        self.view.addSubview(loaderBackgroundView)
        self.view.sendSubview(toBack: loaderBackgroundView)
        
        for i in 1...blocksPerRow+1{
            let tagNumber = /*This is the row #*/ (1*10000) + /*This is the column #*/  i
            _ = (Double(arc4random_uniform(30))/Double(30))
            let modelView = self.view.viewWithTag(tagNumber)
            let view2 = viewWithStringTag()
            view2.frame = (modelView?.frame)!
            view2.center = (modelView?.center)!
            view2.backgroundColor = UIColor.white
            let alpha:CGFloat = CGFloat(i) / CGFloat(self.blocksPerColumn)
            view2.alpha = alpha
            loaderBackgroundView.addSubview(view2)
            view2.layer.cornerRadius = CGFloat(1)*CGFloat(i)
            
           
            
            
            UIView.animate(withDuration: 0.7, delay: (1.0)*Double(i)/Double(blocksPerRow), options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                
                
                
                view2.center = CGPoint(x:
                (self.view.viewWithTag(tagNumber)?.center.x)!, y: (self.view.viewWithTag(tagNumber)?.center.y)! - 70)
                
                
            }, completion: nil)
            
         
        }
        
 
    }
    
    
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        loginMethod = "facebook"
        
        //getEmailAddress()
        
    }
    
    func getEmailAddress() {
        self.loginMethod = "facebook"
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err)
                return
            }
            print(result)
            print(result as! NSDictionary)
            let fetchedUserInfo = result as! NSDictionary
            let tempEmail = fetchedUserInfo.value(forKeyPath: "email") as! String
            //Username will be an ID if the student is logging in with facebook
            let tempUsername = fetchedUserInfo.value(forKeyPath: "id") as! String
            self.usernameVal = tempUsername
            let tempName = fetchedUserInfo.value(forKeyPath: "name") as! String
            self.checkUserInfoAgainstDB(usernameForParam: tempUsername, emailForParam: tempEmail, nameForParam: tempName)
            print(tempEmail)
            
        }
    }
    
    func checkUserInfoAgainstDB(usernameForParam:String,emailForParam:String,nameForParam:String) {
        
        
        let parameters: Parameters = ["uname":usernameForParam,"email":emailForParam,"database":"student"]
        print(parameters)
        
        Alamofire.request("http://flasheducational.com/phpScripts/universalSignUpCheckExistingUser.php", method: .post, parameters: parameters) .responseString { response in
            print("Response String: \(response.result.value!)")
            
            self.emailVal = emailForParam
            
            if(response.result.value! == "userExists" || response.result.value! == "emailInUse"){
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginToMainMenuSegue", sender: self)
                }
                
                
            } else if(response.result.value! == "userIsUnique"){
                self.submitNewUserRequest(usernameForParam: usernameForParam, emailForParam: emailForParam, nameForParam: nameForParam)
            }
            
            
            
            
            
            
            
        }
        
        
        
        
        
        
        
    }
    
    func submitNewUserRequest(usernameForParam:String,emailForParam:String,nameForParam:String){
        //let postString = "fname=\()&lname=\(lastNameInput.text!)&uname=\(usernameInput.text!)&password=\(passwordInput.text!)&email=\(emailInput.text!)&personalInstitutionId=\(institutionIdInput.text!)&database=student"
        let parameters: Parameters = ["fname": nameForParam.components(separatedBy: " ")[0],"lname": nameForParam.components(separatedBy: " ")[1], "uname":usernameForParam,"password":"","email":emailForParam,"personalInstitutionId":"","database":"student"]
        print(parameters)
        print("here")
        Alamofire.request("http://flasheducational.com/phpScripts/universalSignUpRegisterNewUser.php", method: .post, parameters: parameters) .responseString { response in
            
            print("Response String: \(response.result.value!)!")
            
            if(response.result.value! == "success"){
                consoleLog(msg: "User created successfully", level: 1)
                SweetAlert().showAlert("Welcome!", subTitle: "Looks like this is your first time!!", style: AlertStyle.success, buttonTitle:"Let's go!", buttonColor:UIColor.colorFromRGB(0xD0D0D0)) { (isOtherButton) -> Void in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginToMainMenuSegue", sender: self)
                    }
                }
                
            } else {
                SweetAlert().showAlert("This one's on us...", subTitle: "Somethings seems to have gone wrong. Try again later!", style: AlertStyle.warning)
                //errorLabel.text = "Somethings seems to have gone wrong. Try again later!"
            }
            
            
            hideViewByTag(selfView: self.view!, tagForAction: 7777)
            
            
        }
        
        
        
        
    }
    
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err)
                return
            } else {
                
                
               // self.getEmailAddress()
            }
            
            
        }
    }
    
    
}


