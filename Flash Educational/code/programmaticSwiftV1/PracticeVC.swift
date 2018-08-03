import UIKit
import WebImage
import PopupDialog
import Alamofire


class PracticeVC: UIViewController, UIScrollViewDelegate {
    
    var urlForExpandedImage = ""
    
    //These are arrays that contain the raw list of information
    
    
    //This is the filtered lsit of Topics and Subtopics
    var standardTopicsFiltered:NSMutableArray = []
    var standardSubtopicsFiltered:NSMutableArray = []
    
    //This gets changed to a real value when you choose a test
    
    var selectedQuestionIndex:Int = -1
    
    
    
    //This keeps track of whether or not the user has seen this before. It's value is passed fromthe CurrentSubtopicVC screen
    var repeatIndicator = String();
    
    let mainScrollView = UIScrollView(frame: CGRectMake(UIScreen.main.bounds.width/2, UIScreen.main.bounds.height/2, UIScreen.main.bounds.width, UIScreen.main.bounds.height))
    
    //This tracks the current chosen answer
    var sessionChosenAnswer = "none"
    
    //This array willl keep track of all my items
    var arrayOfScreenElements:[Any] = []
    
    var currentContentHeight = 0

    var arrayOfButtons:[[Any]] = []
    
    let bottomNavBar = UINavigationBar()
    let rightNav = UINavigationItem(title: "");
    
    var imageIndicatorsFromDB:[Any] = []
    var imageCache = [String:UIImage]()
    
    override func viewDidLoad() {
        if Reachability.isInternetAvailable() == false {
            SweetAlert().showAlert("Uh oh!", subTitle: "Your internet is disconnected. Any answers you submit without internet will not be saved in your progress", style: AlertStyle.warning)
        }
        
        //Swipe reognizer for question changing
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(PracticeVC.rightSwiped(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(PracticeVC.leftSwiped(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        let infoButton = UIButton(type: .infoLight)
        
        
        let ratingButton =  UIButton(type: .custom)
        
        ratingButton.setImage(UIImage(named: "qualityStar_blue"), for: .normal)
        ratingButton.frame = CGRectMake(0, 0, 30, 30)
        //nextButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 12, 1, -12)//move image to the right
        ratingButton.backgroundColor = UIColor.clear
        let ratingButtonLabel = UILabel(frame: CGRectMake(3, 5, 120, 20))
        ratingButtonLabel.font = UIFont.systemFont(ofSize: 12)
        ratingButtonLabel.text = ""
        ratingButtonLabel.backgroundColor = UIColor.red
        ratingButtonLabel.textAlignment = .center
        ratingButtonLabel.textColor = UIColor.black
        ratingButtonLabel.backgroundColor =   UIColor.clear
        ratingButton.addSubview(ratingButtonLabel)
        
        
        
        infoButton.addTarget(self, action: #selector(PracticeVC.displayInfoForHelp(_:)), for: .touchDown)
        ratingButton.addTarget(self, action: #selector(PracticeVC.displayRatingModal(_:)), for: .touchDown)
        
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        let ratingBarButton = UIBarButtonItem(customView: ratingButton)
        
        navigationItem.setRightBarButtonItems([infoBarButton, ratingBarButton], animated: false)
        
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        consoleLog(msg: "=======", level: 1)
        consoleLog(msg: "Enter PracticeVC", level: 1)
        
        consoleLog(msg: "Index of Selected Q: " + String(selectedQuestionIndex), level: 1)
        super.viewDidLoad()
        setupScreen()
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.view.viewWithTag(scrollView.tag + 10)

    }
    
    func handleDoubleTap(sender: parameterizedTapGestureRecognizer) {
        print(sender.tagForPass)
        urlForExpandedImage = sender.tagForPass
        self.performSegue(withIdentifier: "PracticeVCToExpandedImageVCSegue", sender: self)
    }
    

    
    
    func setupScreen(){
        
        sessionChosenAnswer = "none"
        currentContentHeight = 0
        if let item = fetchedQuestions[selectedQuestionIndex] as? [String: Any]{
            consoleLog(msg: String(describing: item), level: 1)
            consoleLog(msg: "===================", level: 1)
            consoleLog(msg: "Setting Up Screen", level: 1)
        
            
            //These sections just setup the properties of the elements that will be in the page
            //This is the main scroll view
            
            imageIndicatorsFromDB = (item["image"] as! String).characters.split{$0 == "~"}.map(String.init)
            for i in 0...imageIndicatorsFromDB.count-1 {
                imageIndicatorsFromDB[i] = (imageIndicatorsFromDB[i] as! String).characters.split{$0 == "@"}.map(String.init)
            }
            print(imageIndicatorsFromDB)
            
            mainScrollView.backgroundColor = UIColor.white
            mainScrollView.center = self.view.center
            self.view.addSubview(mainScrollView)
            
            let bottomNavBar = UINavigationBar()
            self.view.addSubview(bottomNavBar)
            bottomNavBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
            bottomNavBar.frame = CGRectMake(0, UIScreen.main.bounds.height-40, UIScreen.main.bounds.width, 40)
            
            
            let nextButton =  UIButton(type: .custom)
            //button.setImage(UIImage(named: "icon_right"), for: .normal)
            nextButton.addTarget(self, action: #selector(PracticeVC.nextQuestionButton(_:)), for: .touchDown)
            nextButton.frame = CGRectMake(0, 0, 110, 31)
            //nextButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 12, 1, -12)//move image to the right
            nextButton.backgroundColor = UIColor.clear
            let nextButtonLabel = UILabel(frame: CGRectMake(3, 5, 120, 20))
            nextButtonLabel.font = UIFont.systemFont(ofSize: 12)
            nextButtonLabel.text = "Next Question"
            nextButtonLabel.backgroundColor = UIColor.red
            nextButtonLabel.textAlignment = .center
            nextButtonLabel.textColor = UIColor.black
            nextButtonLabel.backgroundColor =   UIColor.clear
            nextButton.addSubview(nextButtonLabel)
            let nextBarButton = UIBarButtonItem(customView: nextButton)
            
            let previousButton =  UIButton(type: .custom)
            //button.setImage(UIImage(named: "icon_right"), for: .normal)
            previousButton.addTarget(self, action: #selector(PracticeVC.previousQuestionButton(_:)), for: .touchDown)
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
            let previousBarButton = UIBarButtonItem(customView: previousButton)
            
            rightNav.title = ""
            
            
            rightNav.rightBarButtonItem = nextBarButton;
            rightNav.leftBarButtonItem = previousBarButton;
            
            bottomNavBar.setItems([rightNav], animated: false);
            
            //This is a list of all potential content labels. Its out here because some of them are referenced within fucntions, so they cant be within ght eif statements
            let questionLabel = UILabel()
            let answerALabel = UILabel()
            let answerBLabel = UILabel()
            let answerCLabel = UILabel()
            let answerDLabel = UILabel()
            let answerELabel = UILabel()
            let answerFLabel = UILabel()
            let answerGLabel = UILabel()
            let answerHLabel = UILabel()
            let explanationLabel = UILabel()
            
            let answerASelectButton = UIButton()
            let answerBSelectButton = UIButton()
            let answerCSelectButton = UIButton()
            let answerDSelectButton = UIButton()
            let answerESelectButton = UIButton()
            let answerFSelectButton = UIButton()
            let answerGSelectButton = UIButton()
            let answerHSelectButton = UIButton()
            let submitButton = UIButton()
            
            let questionBackgroundView = UIView()
            let answerABackgroundView = UIView()
            let answerBBackgroundView = UIView()
            let answerCBackgroundView = UIView()
            let answerDBackgroundView = UIView()
            let answerEBackgroundView = UIView()
            let answerFBackgroundView = UIView()
            let answerGBackgroundView = UIView()
            let answerHBackgroundView = UIView()
            let explanationBackgroundView = UIView()
            
            let answerAleftButton = UIImageView()
            let answerBleftButton = UIImageView()
            let answerCleftButton = UIImageView()
            let answerDleftButton = UIImageView()
            let answerEleftButton = UIImageView()
            let answerFleftButton = UIImageView()
            let answerGleftButton = UIImageView()
            let answerHleftButton = UIImageView()
            
            let imageForQ = UIImageView()
            let imageForA = UIImageView()
            let imageForB = UIImageView()
            let imageForC = UIImageView()
            let imageForD = UIImageView()
            let imageForE = UIImageView()
            let imageForF = UIImageView()
            let imageForG = UIImageView()
            let imageForH = UIImageView()
            let imageForExp = UIImageView()
            
            
            arrayOfButtons = [[questionLabel, false, false,questionBackgroundView,false,imageForQ],[answerALabel,answerASelectButton,"answerOne",answerABackgroundView,answerAleftButton,imageForA],[answerBLabel,answerBSelectButton,"answerTwo",answerBBackgroundView,answerBleftButton,imageForB],[answerCLabel,answerCSelectButton,"answerThree",answerCBackgroundView,answerCleftButton,imageForC],[answerDLabel,answerDSelectButton,"answerFour",answerDBackgroundView,answerDleftButton,imageForD],[answerELabel,answerESelectButton,"answerFive",answerEBackgroundView,answerEleftButton,imageForE],[answerFLabel,answerFSelectButton,"answerSix",answerFBackgroundView,answerFleftButton,imageForF],[answerGLabel,answerGSelectButton,"answerSeven",answerGBackgroundView,answerGleftButton,imageForG],[answerHLabel,answerHSelectButton,"answerEight",answerHBackgroundView,answerHleftButton,imageForH],[explanationLabel, false, "explanation", explanationBackgroundView, false, imageForExp]]
//***Q***/
            //This is the Question Object
            
            questionLabel.text = (item["question"] as! String).cleanAsciiToStandard();
            questionLabel.textColor = UIColor.black
            questionLabel.backgroundColor = UIColor.clear
            questionLabel.numberOfLines = 0
            questionLabel.frame = CGRectMake(10, 10, mainScrollView.frame.width-10, UIScreen.main.bounds.height)
            questionLabel.sizeToFit()
            
            
            var questionImageSpace:CGFloat = 0
            if ((imageIndicatorsFromDB[0] as! Array )[0] == "1"){
                questionImageSpace = 130
            }
            questionBackgroundView.backgroundColor = UIColor.white
            questionBackgroundView.frame = CGRectMake(0, 0, UIScreen.main.bounds.width, questionLabel.frame.height + 18 + questionImageSpace)
            
            mainScrollView.addSubview(questionBackgroundView)
            mainScrollView.addSubview(questionLabel)
            print("Quesiton label height: " + String(describing: questionLabel.frame.height))
            print("Nav height: " + String(describing: self.navigationController?.navigationBar.frame.height))
            //print("Sum" + String(describing: CGFloat(currentContentHeight) + questionLabel.frame.height + (self.navigationController?.navigationBar.frame.height)! + 10))
            print((imageIndicatorsFromDB[0] as! Array )[0])
            if ((imageIndicatorsFromDB[0] as! Array )[0] == "1"){
                let urlString = "http://www.flasheducational.com/imageResources/question" + (item["id"] as! String) + "Imageq." + (imageIndicatorsFromDB[0] as! Array )[1]
                print(urlString)
                
                
                let scrollV = UIScrollView()
                scrollV.frame = CGRectMake(0, CGFloat(currentContentHeight) + questionLabel.frame.height + /*the 44 refers to the height of the nav controller*/ 44 + 10 + 23, UIScreen.main.bounds.width, 120)
                
                scrollV.minimumZoomScale=1
                scrollV.maximumZoomScale=5
                scrollV.bounces=false
                scrollV.delegate=self;
                self.view.addSubview(scrollV)
                scrollV.backgroundColor = UIColor.clear
                scrollV.tag = 100
                
                
                imageForQ.backgroundColor = UIColor.clear
                
                imageForQ.sd_setImage(with: URL(string: urlString))
                imageForQ.tag = 110
                imageForQ.contentMode = .scaleAspectFit
                //mainScrollView.addSubview(imageForQ)
                imageForQ.frame = CGRectMake(0, 0, scrollV.frame.width, scrollV.frame.height)
                    
                
                
                
                
                scrollV.addSubview(imageForQ)
                
                
                let doubleTap = parameterizedTapGestureRecognizer(target: self, action: #selector(PracticeVC.handleDoubleTap(sender:)))
                doubleTap.tagForPass = urlString
                doubleTap.numberOfTapsRequired = 2
                
                scrollV.isUserInteractionEnabled = true
                scrollV.addGestureRecognizer(doubleTap)
                
                
                

                
                
            }
            
            
            
            currentContentHeight += Int(questionBackgroundView.frame.height)
            
            
            
            questionBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
            questionBackgroundView.layer.shadowOpacity = 0.4
            questionBackgroundView.layer.shadowRadius = 3
            
            
            
            //============================ BEGIN TRY LOOP
            //================
            for i in 1...(arrayOfButtons.count-2){
                let i0 = (arrayOfButtons[i][0] as! UILabel)
                let i1 = (arrayOfButtons[i][1] as! UIButton)
                let i2 = (arrayOfButtons[i][2] as! String)
                let i3 = (arrayOfButtons[i][3] as! UIView)
                let i4 = (arrayOfButtons[i][4] as! UIImageView)
                let i5 = (arrayOfButtons[i][5] as! UIImageView)
                if(item[i2] as? String != ""){
                    //This is the Answer (A) Object
                    
                    
                    
                    
                    
                    var imageSpace:CGFloat = 0
                    print((imageIndicatorsFromDB[i] as! Array )[0])
                    if ((imageIndicatorsFromDB[i] as! Array )[0] == "1"){
                        imageSpace = 90
                    }
                    let labelHeight = heightForLabel(text: (item[i2] as? String)!, font: UIFont.systemFont(ofSize: 17), width: UIScreen.main.bounds.width-50)
                    let alpha = 0.22 + Double(i)*(0.04)
                    mainScrollView.addSubview(i3)
                    i3.backgroundColor = UIColor.init(red: 0.420, green: 0.565, blue: 0.784, alpha: CGFloat(alpha))
                    i3.frame = CGRectMake(0, CGFloat(currentContentHeight), UIScreen.main.bounds.width, labelHeight+16+imageSpace)
                    
                    i3.layer.shadowOffset = CGSize(width: 0, height: 2)
                    i3.layer.shadowOpacity = 0.4
                    i3.layer.shadowRadius = 3
                    
                    mainScrollView.addSubview(i1)
                    
                    
                    if ((imageIndicatorsFromDB[i] as! Array )[0] == "1"){
                        let urlString = "http://www.flasheducational.com/imageResources/question" + (item["id"] as! String) + "Image" + numberToLetter[i-1][0] + "." + (imageIndicatorsFromDB[i] as! Array )[1]
                        
                        let scrollV = UIScrollView()
                        scrollV.frame = CGRectMake(0, CGFloat(currentContentHeight) + labelHeight + 44 + 10 + 23, UIScreen.main.bounds.width, 80)
                        
                        scrollV.minimumZoomScale=1
                        scrollV.maximumZoomScale=5
                        scrollV.bounces=false
                        scrollV.delegate=self;
                        self.view.addSubview(scrollV)
                        scrollV.backgroundColor = UIColor.clear
                        scrollV.tag = 100 + i
                        
                        
                        i5.backgroundColor = UIColor.clear

                        i5.tag = 110 + i
                        
                        i5.sd_setImage(with: URL(string: urlString))
                        i5.contentMode = .scaleAspectFit
                        //mainScrollView.addSubview(i5)
                        //i5.frame = CGRectMake(0, CGFloat(currentContentHeight) + 8 + labelHeight + 10, UIScreen.main.bounds.width, 80)
                        
                        i5.frame = CGRectMake(0, 0, scrollV.frame.width, scrollV.frame.height)
                        
                        
                        
                        
                        
                        scrollV.addSubview(i5)
                        
                        
                        let doubleTap = parameterizedTapGestureRecognizer(target: self, action: #selector(PracticeVC.handleDoubleTap(sender:)))
                        doubleTap.tagForPass = urlString
                        doubleTap.numberOfTapsRequired = 2
                        
                        scrollV.isUserInteractionEnabled = true
                        scrollV.addGestureRecognizer(doubleTap)
                    }
                    
                    i1.backgroundColor = UIColor.clear
                    i1.frame = CGRectMake(0, CGFloat(currentContentHeight), UIScreen.main.bounds.width, labelHeight+16+imageSpace)
                    i1.tag = (i-1)
                    i1.addTarget(self, action: #selector(PracticeVC.selectAnswer(_:)), for: .touchDown)
                    
                    currentContentHeight += Int(i3.frame.height)
                    
                    
                    
                    i0.text = (item[i2] as! String).cleanAsciiToStandard();
                    i0.textColor = UIColor.black
                    i0.font = UIFont.systemFont(ofSize: 17)
                    i0.backgroundColor = UIColor.clear
                    i0.numberOfLines = 0
                    i0.sizeToFit()
                    
                    mainScrollView.addSubview(i0)
                    
                    i0.topAnchor.constraint(equalTo: i3.topAnchor, constant:8).isActive = true
                    i0.leftAnchor.constraint(equalTo: questionLabel.leftAnchor, constant: 30).isActive = true
                    i0.rightAnchor.constraint(equalTo: self.view.rightAnchor,constant:-10).isActive = true
                    
                    
                    i0.translatesAutoresizingMaskIntoConstraints = false
                    
                    //This is for the (a) button/image next to the answer content
                    
                    i4.image = UIImage(named: (i2 + "Button"))
                    i4.translatesAutoresizingMaskIntoConstraints = false
                    mainScrollView.addSubview(i4)
                    i4.topAnchor.constraint(equalTo: i3.topAnchor, constant:8).isActive = true
                    i4.leftAnchor.constraint(equalTo: questionLabel.leftAnchor, constant: 0).isActive = true
                    i4.rightAnchor.constraint(equalTo: i0.leftAnchor, constant:-10).isActive = true
                    i4.heightAnchor.constraint(equalTo: i4.widthAnchor, constant:0).isActive = true
                    //answerAleftButton.contentMode = UIViewContentMode.scaleAspectFit
                    
                    
                    
                    
                }
                
                
                
            }
            
            //Add submit button
            mainScrollView.addSubview(submitButton)
            submitButton.backgroundColor = UIColor.init(red: 0.372, green: 0.594, blue: 1, alpha: 1)
            submitButton.frame = CGRectMake(0, CGFloat(currentContentHeight), UIScreen.main.bounds.width, 50)
            submitButton.setTitle("Submit",for: .normal)
            submitButton.addTarget(self, action: #selector(PracticeVC.submitAnswer(_:)), for: .touchDown)
            
            submitButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            submitButton.layer.shadowOpacity = 0.4
            submitButton.layer.shadowRadius = 3
            
            currentContentHeight += Int(submitButton.frame.height)
            
            //This factors in the height of the bottom nav bar
           
            currentContentHeight += 40
            
            
            //This sets the final size of the content in the ScrollView. This is what allows the view to actually scroll
            mainScrollView.contentSize.height = CGFloat(currentContentHeight)

            
        }
    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectAnswer(_ button: UIButton){
        for i in 1...(arrayOfButtons.count-2){
            (arrayOfButtons[i][1] as! UIButton).backgroundColor = UIColor.clear
        }
        consoleLog(msg: numberToLetter[button.tag][0], level: 3)
        sessionChosenAnswer = numberToLetter[button.tag][0]
        button.backgroundColor = UIColor.init(red: 1, green: 1, blue: 0.635, alpha: 1)
        
    }
    
    func rightSwiped(_ sender: UISwipeGestureRecognizer){
        print(sender.direction)
        
            executeForPreviousQ()
            print("right")
    }
    
    func leftSwiped(_ sender: UISwipeGestureRecognizer){
        print(sender.direction)
        
        executeForNextQ()
        print("left")
    }

    
    func nextQuestionButton(_ button: UIBarButtonItem){
        executeForNextQ()
    }
    func previousQuestionButton(_ button: UIBarButtonItem){
        executeForPreviousQ()
    }
    
    func executeForNextQ(){
        removeAllSubviewsFromMainScrollView()
        if (selectedQuestionIndex == (fetchedQuestions.count-1)){selectedQuestionIndex = 0} else {selectedQuestionIndex += 1}
        setupScreen()
    }
    func executeForPreviousQ(){
        removeAllSubviewsFromMainScrollView()
        if (selectedQuestionIndex == 0){selectedQuestionIndex = (fetchedQuestions.count-1)} else {selectedQuestionIndex -= 1}
        setupScreen()
    }
    
    
    
    func removeAllSubviewsFromMainScrollView(){
        //let ListOfSubviews = mainScrollView.subviews
        for view in mainScrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func submitAnswer(_ button: UIButton){
        
        
        
            showflashEducationLoader(parentView: self.view!)
        
        consoleLog(msg: ("Submitting Answer: " + sessionChosenAnswer), level: 2)
        
        
        
        
        if (sessionChosenAnswer != "none"){
            
            print("debug: x019g")
            
            
            if let item = fetchedQuestions[selectedQuestionIndex] as? [String: Any]{
                
                //This is used to pick whether the answer chosen is a new submission or an update
                repeatIndicator = (item["repeatIndicator"] as! String)
                consoleLog(msg: repeatIndicator, level: 1)
                
                if (repeatIndicator != "unanswered"){
                    consoleLog(msg: "Question previously answered", level: 1)
                } else {
                    consoleLog(msg: "Question previously unanswered", level: 1)
                }
               
                var argument = ""
                var parametersForFunc:Parameters = [:]
                
                
                if (sessionChosenAnswer == item["correctAnswer"] as? String){
                    (arrayOfButtons[0][3] as! UIView).backgroundColor = UIColor.init(red: 0.392, green: 1, blue: 0.588, alpha: 1)
                    rightNav.title = "Correct!"
                    argument += "correctOrIncorrect=correct"
            /*1*/    parametersForFunc.updateValue("correct", forKey: "correctOrIncorrect")
                    
                } else {
                    (arrayOfButtons[0][3] as! UIView).backgroundColor = UIColor.init(red: 1, green: 0.43, blue: 0.43, alpha: 1)
                    rightNav.title = "Try again!"
                    argument += "correctOrIncorrect=incorrect"
            /*1*/    parametersForFunc.updateValue("incorrect", forKey: "correctOrIncorrect")
                }
                //This condition makes sure not to submit a new entry for
                
            /*2*/    parametersForFunc.updateValue("s\(selectedSubtopic)", forKey: "correspondingQuiz")
            /*3*/    parametersForFunc.updateValue("entry", forKey: "table")
            /*4*/    parametersForFunc.updateValue(currentStudentID, forKey: "correspondingStudent")
            /*5*/    parametersForFunc.updateValue(((item["id"] as? String)!), forKey: "correspondingQuestion")
            /*6*/    parametersForFunc.updateValue(sessionChosenAnswer, forKey: "currentAnswerChosen")
                
                
                if (repeatIndicator == "unanswered"){
                    consoleLog(msg: "Submitting new entry", level: 1)
                    argument += "&firstAnswerChosen=\(sessionChosenAnswer)&currentAnswerChosen=\(sessionChosenAnswer)&correspondingQuiz=s\(selectedSubtopic)&correspondingStudent=\(currentStudentID)&correspondingQuestion=\((item["id"] as? String)!)&table=entry"
                    
            /*7s*/        parametersForFunc.updateValue(sessionChosenAnswer, forKey: "firstAnswerChosen")
                    
                    submitNewEntry(parameters: parametersForFunc, parentView: self.view!)
                } else {
                    consoleLog(msg: "Modifying existing entry", level: 1)
                    argument += "&currentAnswerChosen=\(sessionChosenAnswer)&correspondingQuiz=s\(selectedSubtopic)&correspondingStudent=\(currentStudentID)&correspondingQuestion=\((item["id"] as? String)!)&table=entry"

                    modifyExistingEntry(parameters: parametersForFunc, parentView: self.view!)
                }
            }
            
        } else {
            consoleLog(msg: "No answer chosen -> No entry submitted", level: 1)
            self.view.viewWithTag(536536)?.removeFromSuperview()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "PracticeVCToExpandedImageVCSegue"){
            print("Moving to Expanded Image")
            
            //This passes important variables to the next screen
            
            let destinationVC = segue.destination as! ExpandedImageVC
            
            destinationVC.urlString = urlForExpandedImage
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func displayInfoForHelp(_ sender: UIButton){
        if let item = fetchedQuestions[selectedQuestionIndex] as? [String: Any]{
            item["explanation"] as? String
            // Prepare the popup assets
            let title = "Explanation"
            var message = item["explanation"] as? String
            var tempImage = UIImage()
            let buttonOne = CancelButton(title: "OKAY") {}
            
            if ((imageIndicatorsFromDB[9] as! Array )[0] == "1"){
                showflashEducationLoader(parentView: self.view!)
                let urlString = "http://www.flasheducational.com/imageResources/question" + (item["id"] as! String) + "Imageexp." + (imageIndicatorsFromDB[9] as! Array )[1]
                print(urlString)
                
                SDWebImageDownloader.shared().downloadImage(with: URL(string: urlString), options: .highPriority, progress:nil, completed: {
                    (image, error, cacheType, url) in
                    tempImage = image!
    
                    let popup = PopupDialog(title: title, message: message, image: tempImage)
                    
                    
                    // Add buttons to dialog
                    // Alternatively, you can use popup.addButton([buttonOne, etc.])
                    // to add multiple buttons
                    popup.addButtons([buttonOne])
                    
                    self.view.viewWithTag(536536)?.removeFromSuperview()
                    // Present dialog
                    self.present(popup, animated: true, completion: nil)
                })
                //
                // Create the dialog
            } else {
                
                if (message == ""){
                    message = "No written explanation was provided for this question"
                }
                let popup = PopupDialog(title: title, message: message, image: tempImage)
                
                
                // Add buttons to dialog
                // Alternatively, you can use popup.addButton([buttonOne, etc.])
                // to add multiple buttons
                popup.addButtons([buttonOne])
                
                // Present dialog
                self.present(popup, animated: true, completion: nil)
            }
            
        }
    }
    
    func displayRatingModal(_ sender: UIButton){
        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
            
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "RATE", height: 60) {
            print("You rated \(ratingVC.qualityRating.rating.rounded()) stars " + "You rated \(ratingVC.difficultyRating.rating.rounded()) stars")
            
            
            if let item = fetchedQuestions[self.selectedQuestionIndex] as? [String: Any]{
                
                print(item["numberOfRatingEntries"] as? Int)
                let previousNumberOfQualityRatings = Double((item["numberOfRatingEntries"] as? String)!)!.rounded()
                print(item["numberOfRatingEntries"] as? Int)
                let previousNumberOfDifficultyRatings = Double((item["numberOfDifficultyRatingEntries"] as? String)!)!.rounded()
                let previousDifficultyRating = Double((item["difficultyRating"] as? String)!)!.rounded()
                let previousQualityRating = Double((item["rating"] as? String)!)!.rounded()
                
                let chosenQualityRating = Int(ratingVC.qualityRating.rating.rounded())
                let chosenDifficultyRating = Int(ratingVC.difficultyRating.rating.rounded())
                
                let newNumberofQualityRatings = previousNumberOfQualityRatings + 1
                let newNumberofDifficultyRatings = previousNumberOfDifficultyRatings + 1
                let newQualityRating = ((previousQualityRating * (previousNumberOfQualityRatings)) + Double(chosenQualityRating))/newNumberofQualityRatings
                let newDifficultyRating = ((previousDifficultyRating * (previousNumberOfDifficultyRatings)) + Double(chosenDifficultyRating))/newNumberofDifficultyRatings
                
                let dbqId = Int((item["id"] as? String)!)
                
                self.submitRatings(numberOfQualityRating: Int(newNumberofQualityRatings)
                    , numberOfDifficultyRating: Int(newNumberofDifficultyRatings), qualityRating: (newQualityRating), difficultyRating: (newDifficultyRating), dbqId:dbqId!)
            }
            
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func submitRatings(numberOfQualityRating:Int, numberOfDifficultyRating:Int, qualityRating:Double, difficultyRating:Double, dbqId:Int){
        print("=============")
        print("Submitting Ratings")
        print("-------------")
        print(numberOfQualityRating)
        print(numberOfDifficultyRating)
        print(qualityRating)
        print(difficultyRating)
        print(dbqId)
        print("=============")
        
        showflashEducationLoader(parentView: self.view!)
        
        // -- Update Quality rating -- //
        
        
        
        let qualityParameters: Parameters = ["id": dbqId, "rating":qualityRating,"numberOfRatingEntries":numberOfQualityRating, "table":"question"]
        print(qualityParameters)
        
        Alamofire.request("http://flasheducational.com/phpScripts/update/updateQuestionRatingAndTotalEntryRatingsByID.php", method: .post, parameters:qualityParameters) .responseString { response in
            
            //This prints the value of the repsonse string
            print("Response String: \(response.result.value!)")
            gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
        }
        
        
        // -- Update difficulty rating -- //
        
        let difficultyParameters: Parameters = ["id": dbqId, "difficultyRating":difficultyRating,"numberOfDifficultyRatingEntries":numberOfDifficultyRating, "table":"question"]
        print(difficultyParameters)
        
        Alamofire.request("http://flasheducational.com/phpScripts/update/updateQuestionDifficultyRatingAndTotalDifficultyEntryRatingsByID.php", method: .post, parameters: difficultyParameters) .responseString { response in
            //This prints the value of the repsonse string
            print("Response String: \(response.result.value!)")
            
            //This next function refreshes the entry data and the fetched questions. We do this to update whetheror not the question has been answered.
            gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
            
            self.view.viewWithTag(536536)?.removeFromSuperview()
            
        }
    

    }
    
    
    
}

