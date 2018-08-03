import UIKit

class SelectTopicVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var segueBackgroundColorReceive = UIColor()
    var segueBackgroundColorSend = UIColor()
    
    var segueSender = ""
    var tableView: UITableView  =   UITableView()
    
    var currentStudent:NSMutableArray = []
    
    //These are arrays that contain the raw list of information
    
    //This is the filtered lsit of Topics and Subtopics
    var standardTopicsFiltered:NSMutableArray = []
    var standardSubtopicsFiltered:NSMutableArray = []
    
    //This gets changed to a real value when you choose a test
    var selectedTest = "";
    var selectedTopic = "";
    //This gets passed to resourceView
    var selectedTopicPlaylistId = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        // Do any additional setup after loading the view, typically from a nib.
        print(standardTopicsFiltered.count)
        
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
        return self.standardTopicsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if let item = standardTopicsFiltered[indexPath.row] as? [String: Any]{
            let cellPadding:CGFloat = 8
            let counterWidth:CGFloat = 80
            if let name = item["name"] as? String {
                //cell.textLabel?.text = name.cleanAsciiToStandard()
                //cell.textLabel?.numberOfLines = 0
                //cell.textLabel?.textColor = UIColor.white
                
                let cellTitle = UILabel()
                cellTitle.backgroundColor = UIColor.clear
                cellTitle.textColor = UIColor.white
                cellTitle.font = UIFont.systemFont(ofSize: 13)
                cellTitle.textAlignment = .left
                cellTitle.frame = CGRectMake(cellPadding, 0, UIScreen.main.bounds.width-(counterWidth + (2*cellPadding)), 40)
                cellTitle.text = name.cleanAsciiToStandard()
                cell.addSubview(cellTitle)
                
                let subtopicCounter = UILabel()
                subtopicCounter.backgroundColor = UIColor.clear
                subtopicCounter.textColor = UIColor.white
                subtopicCounter.font = UIFont.systemFont(ofSize: 11)
                subtopicCounter.textAlignment = .center
                subtopicCounter.frame = CGRectMake(UIScreen.main.bounds.width-80, 0, 80, 40)
                subtopicCounter.text = (item["numberOfSubtopics"] as? String)! + " Topics"
                cell.addSubview(subtopicCounter)
            }
        }
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 3
        
        
        let alpha = 0.15 + (0.3*(1-(Double(indexPath.row)/Double(standardTopicsFiltered.count))))
        //cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(alpha))
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = standardTopicsFiltered[indexPath.row] as? [String: Any]{
            selectedTopic = (item["id"] as? String)!
            selectedTopicPlaylistId = (item["playlistId"] as? String)!
        }
        if (segueSender == "test"){
        self.performSegue(withIdentifier: "SelectTopicToSelectSubtopicSegue", sender: self)
        } else if (segueSender == "resources"){
            showflashEducationLoader(parentView: self.view!)
            DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SelectTopicToResourcesSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectTopicToSelectSubtopicSegue"){
            print("Moving to Select Subtopic")
            
            //This sets the filter for the topics on the next page
            setFilterForNextScreen(destinationArrayForFilter: &standardSubtopicsFiltered, inputArray: fetchedStandardSubtopics, filteringAttribute: "correspondingStandardTopic", valueForFilter: selectedTopic)
            
            //This passes important variables to the next screen
            let destinationVC = segue.destination as! SelectSubtopicVC
            
            destinationVC.standardTopicsFiltered = standardTopicsFiltered
            destinationVC.standardSubtopicsFiltered = standardSubtopicsFiltered
            
            destinationVC.currentStudent = currentStudent
            destinationVC.segueBackgroundColorReceive = getRandomColor(tint: "dark")
            destinationVC.view.backgroundColor = destinationVC.segueBackgroundColorReceive
            
            
            
        } else if (segue.identifier == "SelectTopicToResourcesSegue"){
            print("Moving to Resources")
            
            
            //This passes important variables to the next screen
            let destinationVC = segue.destination as! ResourcesVC
            destinationVC.selectedTopic = selectedTopic
            destinationVC.selectedTest = selectedTest
            
            destinationVC.fetchedStandardTests = fetchedStandardTests
            destinationVC.fetchedStandardTopics = fetchedStandardTopics
            destinationVC.fetchedStandardSubtopics = fetchedStandardSubtopics
            destinationVC.selectedTopicPlaylistId = selectedTopicPlaylistId
        }

    }
    
    func refreshButtonAction(_ sender: UIButton){
        
        showflashEducationLoader(parentView: self.view!)
        DispatchQueue.main.async {
            print("refresh pressed")
            updateAllAppData(standardizedTestArrayToSet: &fetchedStandardTests, standardSubtopicArrayToSet: &fetchedStandardSubtopics, standardTopicArrayToSet: &fetchedStandardTopics, pointerQuestionStandardSubtopicArrayToSet: &fetchedPointerQuestionStandardSubtopic)
            modifyArraysViaHierarchy(standardizedTestArrayForHierarchy: &fetchedStandardTests, standardSubtopicArrayForHierarchy: &fetchedStandardSubtopics, standardTopicArrayForHierarchy: &fetchedStandardTopics, subtopicQuestionCount: &subtopicQuestionCount)
            
            
            self.tableView.reloadData()
            self.view.viewWithTag(536536)?.removeFromSuperview()
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
