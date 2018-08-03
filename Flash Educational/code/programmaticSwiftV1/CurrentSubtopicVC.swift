//
//  CurrentSubtopicVC.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/20/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import UIKit
import PopupDialog

class CurrentSubtopicVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var segueBackgroundColorReceive = UIColor()
    var segueBackgroundColorSend = UIColor()
    
    
    var currentStudent:NSMutableArray = []
    
    var tableView: UITableView  =   UITableView()
    
    //These are arrays that contain the raw list of information
    
    //These next two is technically filtered from the moment it is gather by PHP
    
    
    
    //This keeps track of all relevant entries
    
    
    
    //This is the filtered lsit of Topics and Subtopics
    var standardTopicsFiltered:NSMutableArray = []
    var standardSubtopicsFiltered:NSMutableArray = []
    
    //This gets changed to a real value when you choose a test
    
    var selectedQuestionIndex:Int = -1
    //This variable is changed when you pick a question or come back to this screen. It gets carried over to the practiceVC and keeps track of whether or not you have an entry for this question yet
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let item = currentStudent[0] as? [String: Any]{
            
            currentStudentID = (item["id"] as! String!)!
        }
        
        if (fetchedQuestions.count == 0){
            let noQuestionsView = UIView()
            let noQuestionsIcon = UIImageView()
            let noQuestionsLabel = UILabel()
            
            noQuestionsView.frame = UIScreen.main.bounds
            noQuestionsView.backgroundColor = UIColor.clear
            
            noQuestionsIcon.frame = CGRectMake((UIScreen.main.bounds.width/2) - 45, (UIScreen.main.bounds.height/2) - 145, 90, 90)
            noQuestionsIcon.image = UIImage(named: "qa_g")
            
            noQuestionsLabel.frame = CGRectMake(40, (UIScreen.main.bounds.height/2) - 40, UIScreen.main.bounds.width-80, 50)
            noQuestionsLabel.numberOfLines = 0
            noQuestionsLabel.textAlignment = .center
            noQuestionsLabel.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
            noQuestionsLabel.text = "There are no practice questions for this topic yet"
            
            self.view.addSubview(noQuestionsView)
            noQuestionsView.addSubview(noQuestionsIcon)
            noQuestionsView.addSubview(noQuestionsLabel)
        }
        
        consoleLog(msg: "Repeat Indicator reset to 0", level: 5)
                
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(CurrentSubtopicVC.displayInfoForHelp(_:)), for: .touchDown)
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        
        let refreshButton =  UIButton(type: .custom)
        
        refreshButton.setImage(UIImage(named: "refresh_blue"), for: .normal)
        refreshButton.frame = CGRectMake(0, 0, 30, 30)
        //nextButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 12, 1, -12)//move image to the right
        refreshButton.backgroundColor = UIColor.clear
        let refreshButtonLabel = UILabel(frame: CGRectMake(3, 5, 120, 20))
        refreshButtonLabel.font = UIFont.systemFont(ofSize: 12)
        refreshButtonLabel.text = ""
        refreshButtonLabel.backgroundColor = UIColor.red
        refreshButtonLabel.textAlignment = .center
        refreshButtonLabel.textColor = UIColor.black
        refreshButtonLabel.backgroundColor =   UIColor.clear
        refreshButton.addSubview(refreshButtonLabel)
        refreshButton.addTarget(self, action: #selector(CurrentSubtopicVC.refreshButtonAction(_:)), for: .touchDown)
        let refreshBarButton = UIBarButtonItem(customView: refreshButton)
        
        
        

        navigationItem.setRightBarButtonItems([infoBarButton, refreshBarButton], animated: false)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        print(fetchedQuestions.count)
        
        
        tableView.register(questionTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        tableView.frame         =   CGRectMake(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backgroundView = UIImageView()
        //backgroundView.image = UIImage(named: "background4d")
        backgroundView.backgroundColor = segueBackgroundColorReceive
        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.backgroundView = backgroundView
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:questionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! questionTableViewCell
        if let item = fetchedQuestions[indexPath.row] as? [String: Any]{
            let cellPadding:CGFloat = 8
            let qualityWidth:CGFloat = 80
            
            
                
                for subs in (cell.subviews){
                    
                    subs.removeFromSuperview()
                }
                
                let cellTitle = UILabel()
                cellTitle.backgroundColor = UIColor.clear
                cellTitle.textColor = UIColor.white
                cellTitle.font = UIFont.systemFont(ofSize: 13)
                cellTitle.textAlignment = .left
                cellTitle.numberOfLines = 0
                cellTitle.frame = CGRectMake(cellPadding, 0, UIScreen.main.bounds.width-(qualityWidth + (2*cellPadding)), 40)
                cellTitle.text = (item["id"] as? String)! + ": " + (item["question"] as? String)!.cleanAsciiToStandard()
                cell.addSubview(cellTitle)
            
                let qualityDimension_afterPadding = (qualityWidth/2) - cellPadding
                let qualityPadding = cellPadding/2
            
            let qualityImage = UIImageView()
            cell.addSubview(qualityImage)
            qualityImage.frame = CGRectMake(cellTitle.frame.width + (2*cellPadding), qualityPadding, qualityDimension_afterPadding, qualityDimension_afterPadding)
            
            let difficultyImage = UIImageView()
            cell.addSubview(difficultyImage)
            difficultyImage.frame = CGRectMake(cellTitle.frame.width + (2*cellPadding) + qualityDimension_afterPadding + qualityPadding, qualityPadding, qualityDimension_afterPadding, qualityDimension_afterPadding)
            
            if (item["numberOfRatingEntries"] as? String != "0"){
                //let qualityRating = (item["rating"] as? Double)
                let roundedQualityRating = Int(Double((item["rating"] as? String)!)!.rounded())
                qualityImage.image = UIImage(named: "qualityStar_" + String(describing: roundedQualityRating))
                print(roundedQualityRating)
            } else {
                qualityImage.image = UIImage(named: "qualityStar_g")
            }
            
            if (item["numberOfDifficultyRatingEntries"] as? String != "0"){
                //let qualityRating = (item["rating"] as? Double)
                let roundedQualityRating = Int(Double((item["difficultyRating"] as? String)!)!.rounded())
                difficultyImage.image = UIImage(named: "circledForDifficulty_" + String(describing: roundedQualityRating))
                print(roundedQualityRating)
            } else {
                difficultyImage.image = UIImage(named: "circledForDifficulty_0")
            }
            
            //cell.textLabel?.text = (item["id"] as? String)! + ": " + (item["question"] as? String)!
            //cell.textLabel?.numberOfLines = 0
            //cell.textLabel?.textColor = UIColor.white
            
            cell.selectionStyle = .none
            
            
            
            
            
            
            let alpha = 0.15 + (0.3*(1-(Double(indexPath.row)/Double(fetchedQuestions.count))))
            cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(0))
            cell.backgroundColor = item["previousAnswer"] as? UIColor
            
            
        }
        
        
        
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hererereree")
        selectedQuestionIndex = indexPath.row
        
        //-- These next section used to set the repeat indicator as you picked the question. This caused problems when you changed questions on the next screen. Because of that, I set that information into the dictionary of the question itself when they're loaded in the "SeletTopicVC"
        /*
        if let item = fetchedQuestions[indexPath.row] as? [String: Any]{
            if entryArray.count != 0{
                for i in 0...entryArray.count-1{
                    if let entryItem = entryArray[i] as? [String: Any]{
                        if ((entryItem["correspondingQuestion"] as? String) == (item["id"] as? String)){
                            print((entryItem["correspondingQuestion"] as? String)! + " = " + (item["id"] as? String)!)
                            if ((entryItem["correctOrIncorrect"] as? String) == "correct"){
                                repeatIndicator = 1
                                
                            } else {
                                repeatIndicator = 2
                            }
                        }
                    }
                }
                
            }
        }
        
        */
        self.performSegue(withIdentifier: "CurrentSubtopicToPracticeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "CurrentSubtopicToPracticeSegue"){
            print("Moving to Practice")
            
            //This sets the filter for the topics on the next page
            setFilterForNextScreen(destinationArrayForFilter: &standardSubtopicsFiltered, inputArray: fetchedStandardSubtopics, filteringAttribute: "correspondingStandardTopic", valueForFilter: selectedTopic)
            
            //This passes important variables to the next screen
            
            let destinationVC = segue.destination as! PracticeVC
            
            
            destinationVC.standardTopicsFiltered = standardTopicsFiltered
            destinationVC.standardSubtopicsFiltered = standardSubtopicsFiltered
            
            
            destinationVC.selectedQuestionIndex = selectedQuestionIndex
            
            
            
        }
    }
    
    func displayInfoForHelp(_ sender: UIButton){
        
        
        let title = "What does it mean?"
        let message = "The stars on the right tell you how the community is rating the quality of each question, while the circles tell you the difficulty. Each of the ratings is done on a 1-5 scale. If the rating is grey, that means nobody has rated it yet! Be the first!"
        let tempImage = UIImage(named: "sampleRatings")
        let buttonOne = CancelButton(title: "OKAY") {}
        
        
        let popup = PopupDialog(title: title, message: message, image: tempImage)
            
            
            // Add buttons to dialog
            // Alternatively, you can use popup.addButton([buttonOne, etc.])
            // to add multiple buttons
            popup.addButtons([buttonOne])
            
            // Present dialog
            self.present(popup, animated: true, completion: nil)
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func refreshButtonAction(_ sender: UIButton){
        
            showflashEducationLoader(parentView: self.view!)
        DispatchQueue.main.async {
            print("refresh pressed")
            //updateAllAppData(standardizedTestArrayToSet: &self.fetchedStandardTests, standardSubtopicArrayToSet: &self.fetchedStandardSubtopics, standardTopicArrayToSet: &self.fetchedStandardTopics, pointerQuestionStandardSubtopicArrayToSet: &self.fetchedPointerQuestionStandardSubtopic)
            
            if let item = self.currentStudent[0] as? [String: Any]{
                let currentStudentID = (item["id"] as! String!)!
                
                gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
            }
            
            self.tableView.reloadData()
            self.view.viewWithTag(536536)?.removeFromSuperview()
        }
        
    }
    
}
