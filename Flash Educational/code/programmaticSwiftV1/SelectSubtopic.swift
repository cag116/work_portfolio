import UIKit

class SelectSubtopicVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var segueBackgroundColorReceive = UIColor()
    var segueBackgroundColorSend = UIColor()
    
    var tableView: UITableView  =   UITableView()
    
    var currentStudent:NSMutableArray = []
    
    
    //This is for HTTPRequests
    var responseString:NSString = ""
    //These are arrays that contain the raw list of information
    
    
    //-- These next two is technically filtered from the moment it is gather by PHP --//
    //^^^^^^ This is the difference between the arrays directly above and below this ^^^^^^
    
    var fetchedPointerForSelectedSubtopicToQuestions:NSMutableArray = []
    
    var entryArray:NSMutableArray = []
    
    //This is the filtered lsit of Topics and Subtopics
    var standardTopicsFiltered:NSMutableArray = []
    var standardSubtopicsFiltered:NSMutableArray = []
    
    //This gets changed to a real value when you choose a test
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        // Do any additional setup after loading the view, typically from a nib.
        print(standardSubtopicsFiltered.count)
        
        tableView.frame         =   CGRectMake(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
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
        
        
        
        //navigationItem.rightBarButtonItem = refreshBarButton
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.viewWithTag(536536)?.removeFromSuperview()
        let backgroundView = UIImageView()
        //backgroundView.image = UIImage(named: "background4d")
        backgroundView.backgroundColor = segueBackgroundColorReceive
        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.backgroundView = backgroundView
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.standardSubtopicsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if let item = standardSubtopicsFiltered[indexPath.row] as? [String: Any]{
            let cellPadding:CGFloat = 8
            let counterWidth:CGFloat = 80
            if let name = item["name"] as? String {
                //cell.textLabel?.text = name.cleanAsciiToStandard()
                //cell.textLabel?.numberOfLines = 0
                //cell.textLabel?.textColor = UIColor.white
                
                for subs in (cell.subviews){
                    
                    subs.removeFromSuperview()
                }
                
                let cellTitle = UILabel()
                cellTitle.backgroundColor = UIColor.clear
                cellTitle.textColor = UIColor.white
                cellTitle.font = UIFont.systemFont(ofSize: 13)
                cellTitle.textAlignment = .left
                cellTitle.numberOfLines = 0
                cellTitle.frame = CGRectMake(cellPadding, 0, UIScreen.main.bounds.width-(counterWidth + (2*cellPadding)), 40)
                cellTitle.text = name.cleanAsciiToStandard()
                cell.addSubview(cellTitle)

                
                let questionCounter = UILabel()
                questionCounter.backgroundColor = UIColor.clear
                questionCounter.textColor = UIColor.white
                questionCounter.font = UIFont.systemFont(ofSize: 11)
                questionCounter.textAlignment = .center
                questionCounter.frame = CGRectMake(UIScreen.main.bounds.width-80, 0, 80, 40)
                questionCounter.text = (item["numberOfQuestions"] as! String) + " Q's"
                
                    cell.addSubview(questionCounter)
            }
        }
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 3
        
        let alpha = 0.15 + (0.3*(1-(Double(indexPath.row)/Double(standardSubtopicsFiltered.count))))
        cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(0))
        
        cell.selectionStyle = .none
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //put create loader here because the dimensions were being skewed if placed in "viewdidload:
        
        showViewByTag(selfView: self.view!, tagForAction: 7777)
        if let item = standardSubtopicsFiltered[indexPath.row] as? [String: Any]{
            selectedSubtopic = (item["id"] as? String)!
        }
        showflashEducationLoader(parentView: self.view!)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SelectSubtopicToCurrentSubtopicSegue", sender: self)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectSubtopicToCurrentSubtopicSegue"){
            print("Moving to Current Subtopic")
            
            

            //This will reset the questions because it changes everytime you pick a new subtopic
            
                
                gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
            
            
            //This passes important variables to the next screen
            let destinationVC = segue.destination as! CurrentSubtopicVC
            
            destinationVC.segueBackgroundColorReceive = getRandomColor(tint: "dark")
            destinationVC.view.backgroundColor = destinationVC.segueBackgroundColorReceive
            
            destinationVC.standardTopicsFiltered = standardTopicsFiltered
            destinationVC.standardSubtopicsFiltered = standardSubtopicsFiltered
            
            destinationVC.currentStudent = currentStudent
            
            
            
            
        }
        
        hideViewByTag(selfView: self.view!, tagForAction: 7777)
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
            refreshQuestionSubtopicCount_COPYofOriginalFromLogin(subtopicQuestionCount: &subtopicQuestionCount)
            print("refresh pressed")
            updateAllAppData(standardizedTestArrayToSet: &fetchedStandardTests, standardSubtopicArrayToSet: &fetchedStandardSubtopics, standardTopicArrayToSet: &fetchedStandardTopics, pointerQuestionStandardSubtopicArrayToSet: &fetchedPointerQuestionStandardSubtopic)
            modifyArraysViaHierarchy(standardizedTestArrayForHierarchy: &fetchedStandardTests, standardSubtopicArrayForHierarchy: &fetchedStandardSubtopics, standardTopicArrayForHierarchy: &fetchedStandardTopics, subtopicQuestionCount: &subtopicQuestionCount)
            
            
            self.tableView.reloadData()
            self.view.viewWithTag(536536)?.removeFromSuperview()
        }
        
    }
    
    
}
