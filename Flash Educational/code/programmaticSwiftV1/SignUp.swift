import UIKit
import AudioToolbox
import Alamofire

class signUpVC:UIViewController, UITextFieldDelegate {
   
    let firstNameInput = jitterableTextfield()
    let lastNameInput = jitterableTextfield()
    let usernameInput = jitterableTextfield()
    let passwordInput = jitterableTextfield()
    let confirmPasswordInput = jitterableTextfield()
    let emailInput = jitterableTextfield()
    let institutionIdInput = jitterableTextfield()
    
    let submitButton = UIButton()
    let errorLabel = UILabel()
    
    
    
    var currentContentHeight:CGFloat = 0
    
    var spacingBetweenInputs:CGFloat = 8
    
    var inputArray:[[Any]] = []
    
    
    override func viewDidLoad() {
        
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        
        
         currentContentHeight = 44 + statusBarHeight + (2*spacingBetweenInputs)
        print(currentContentHeight)
        inputArray = [[firstNameInput,"First name"],[lastNameInput,"Last name"],[usernameInput,"Username"],[passwordInput,"Password (8-20 Characters)"],[confirmPasswordInput,"Confirm Password"],[emailInput,"E-mail"],[institutionIdInput,"Institution ID (Optional)"]]
        
        let tapOutsideKeyboard = parameterizedTapGestureRecognizer(target: self, action: #selector(signUpVC.handleTapOutsideKeyboard(sender:)))
        
        tapOutsideKeyboard.numberOfTapsRequired = 1
        
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapOutsideKeyboard)
        
        loadInputs()
        loadOthers()
    }
    
    func handleTapOutsideKeyboard(sender: parameterizedTapGestureRecognizer){
        
        //Clear all first responder
        clearAllFirstResponders()
    }
    
    func clearAllFirstResponders(){
        for i in 0...inputArray.count-1{
            let currentInputForChecking = (inputArray[i] as Array)[0] as! jitterableTextfield
            if(currentInputForChecking.isFirstResponder == true){
                currentInputForChecking.resignFirstResponder()
                
            }
        }
    }
    func loadInputs(){
        for i in 0...inputArray.count-1{
            print("hello")
            let constructionInput = (inputArray[i] as Array)[0] as! jitterableTextfield
            let inputPlaceholder = (inputArray[i] as Array)[1] as! String
            constructionInput.frame = CGRect(x: 50, y: currentContentHeight, width: UIScreen.main.bounds.width-100, height: 30)
            constructionInput.backgroundColor = UIColor.clear
            constructionInput.tag = i
            constructionInput.delegate = self
            constructionInput.returnKeyType = .next
            constructionInput.textAlignment = .center
            constructionInput.textColor = UIColor.white
            constructionInput.attributedPlaceholder = NSAttributedString(string: inputPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.6)])
            self.view.addSubview(constructionInput)
            
            
            
            self.currentContentHeight += constructionInput.frame.height + spacingBetweenInputs
            
            
            let underLine = UIView()
            underLine.frame = CGRect(x: 50, y: currentContentHeight-spacingBetweenInputs, width: UIScreen.main.bounds.width-100, height: 1)
            underLine.backgroundColor = UIColor.white
            self.view.addSubview(underLine)
        }
        institutionIdInput.returnKeyType = .go
    }
    
    func loadOthers(){
        submitButton.frame = CGRect(x: (UIScreen.main.bounds.width/2)-25, y: currentContentHeight + (3*spacingBetweenInputs), width: 50, height: 50)
        submitButton.setBackgroundImage(UIImage(named: "plus_blue"), for: UIControlState.normal)
        
        currentContentHeight += (3*spacingBetweenInputs) + 50
        self.view.addSubview(submitButton)
        
        submitButton.addTarget(self, action: #selector(signUpVC.processFormButtonSender(_:)), for: .touchDown)
        
        //This is the addition of the error label
        
        errorLabel.textAlignment = .center
        errorLabel.frame = CGRect(x: 75, y: currentContentHeight + (3*spacingBetweenInputs), width: UIScreen.main.bounds.width - 150, height: 50)
        errorLabel.backgroundColor = UIColor.clear
        errorLabel.numberOfLines = 0
        errorLabel.text = ""
        errorLabel.textColor = UIColor.init(red: 1, green: 0.394, blue: 0.394, alpha: 1)
        
        currentContentHeight += (3*spacingBetweenInputs) + 50
        self.view.addSubview(errorLabel)
        
        
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
            processForm()
            textField.isFirstResponder
        }
        
        return true;
    }
    func processFormButtonSender(_ button: UIButton){
        processForm()
    }
    
    func processForm(){
        clearAllFirstResponders()
        
        //This resets the error label
        errorLabel.text = ""
        consoleLog(msg: "========", level: 1)
        consoleLog(msg: "Begin Processing Form", level: 1)
        //This marker is a switch than gets flipped anytime the user tries to submit an invalid entry into a textfield
        var validMarker = "valid"
        
        if(firstNameInput.text == ""){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Who are you?", subTitle: "We won't know who you are without a first name!", style: AlertStyle.warning)
            //errorLabel.text = "Please enter a first name"
            firstNameInput.jitter()
            
        } else if(lastNameInput.text == ""){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Who are you?", subTitle: "We won't know who you are without a last name!", style: AlertStyle.warning)
            //errorLabel.text = "Please enter a last name"
            lastNameInput.jitter()
            
        } else if(usernameInput.text == ""){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Be creative!", subTitle: "Pick out a username that fits you!", style: AlertStyle.warning)
            //errorLabel.text = "Please enter a username"
            usernameInput.jitter()
            
        } else if(passwordInput.text == ""){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Shh!", subTitle: "Gotta keep your content private with a password!", style: AlertStyle.warning)
            //errorLabel.text = "Please enter a password"
            passwordInput.jitter()
            
        } else if((passwordInput.text?.characters.count)! < 8 || (passwordInput.text?.characters.count)! > 20){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Keep it secure!", subTitle: "Password must be between 8 and 20 characters in length!", style: AlertStyle.warning)
            //errorLabel.text = "Password must be between 8 and 20 characters in length"
            passwordInput.jitter()
        } else if(passwordInput.text != confirmPasswordInput.text){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("Whoopsie!", subTitle: "Looks like your password don't match!", style: AlertStyle.warning)
            //errorLabel.text = "Passwords don't match"
            passwordInput.jitter()
            confirmPasswordInput.jitter()
        } else if(emailInput.text == ""){
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            validMarker = "invalid"
            SweetAlert().showAlert("How can we reach you?", subTitle: "We use this to send you loooooads of spam...of course we're kidding!", style: AlertStyle.warning)
            //errorLabel.text = "Please enter an email address"
            emailInput.jitter()
        }
        
        //Check if all the above is valid and move onto registration
        if(validMarker == "valid"){
            print("Credentials Valid; Checking Database")
            checkUserInfoAgainstDB()
        }
        
    }

    func checkUserInfoAgainstDB() {
        showViewByTag(selfView: self.view!, tagForAction: 7777)
        
        let parameters: Parameters = ["uname":usernameInput.text!,"email":emailInput.text!,"database":"student"]
        print(parameters)
        
        Alamofire.request("http://flasheducational.com/phpScripts/universalSignUpCheckExistingUser.php", method: .post, parameters: parameters) .responseString { response in
            print("Response String: \(response.result.value!)!")
            
            if(response.result.value! == "userExists"){
                SweetAlert().showAlert("Be unique!", subTitle: "This username is already taken; try another one!", style: AlertStyle.warning)
                //errorLabel.text = "This username is already taken; try another one."
                hideViewByTag(selfView: self.view!, tagForAction: 7777)
                
            } else if(response.result.value! == "emailInUse"){
                SweetAlert().showAlert("You look familiar...", subTitle: "This email is already taken; try another one!", style: AlertStyle.warning)
                hideViewByTag(selfView: self.view!, tagForAction: 7777)
                //errorLabel.text = "This email is already in use; try another email."
                
            } else if(response.result.value! == "userIsUnique"){
                self.submitNewUserRequest()
            }
            
            
            
            
            
            
            
        }
        

        
        
        
        
        
    }
    
    func submitNewUserRequest() {
        //let postString = "fname=\()&lname=\(lastNameInput.text!)&uname=\(usernameInput.text!)&password=\(passwordInput.text!)&email=\(emailInput.text!)&personalInstitutionId=\(institutionIdInput.text!)&database=student"
        let parameters: Parameters = ["fname": firstNameInput.text!, "lname": lastNameInput.text!, "uname":usernameInput.text!,"password":passwordInput.text!,"email":emailInput.text!,"personalInstitutionId":institutionIdInput.text!,"database":"student"]
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
}
