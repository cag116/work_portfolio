import UIKit

class SelectTestVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var segueSender = ""
    var segueBackgroundColorReceive = UIColor()
    var segueBackgroundColorSend = UIColor()
    var tableView: UITableView  =   UITableView()
    
    var currentStudent:NSMutableArray = []
    
    //These are arrays that contain the raw list of information
    
    
    //This will keep the list of tests that are active
    var activeStandardTests:NSMutableArray = []
    
    
    //This is the filtered lsit of topics that gets setup when you select a test
    var standardTopicsFiltered:NSMutableArray = []
    
    //This gets changed to a realy value when you choose a test
    var selectedTest = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(segueBackgroundColorReceive)
        
        clearRadialTransitionElements()

        
        
        
        
        filterJSONNSArray()
        
        // Do any additional setup after loading the view, typically from a nib.
        //print(fetchedStandardTests.count)
        
        
        tableView.frame         =   CGRectMake(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height);
        tableView.delegate      =   self
        tableView.dataSource    =   self

        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
    }
    
    func filterJSONNSArray(){
        for i in 0...fetchedStandardTests.count-1{
            if let item = fetchedStandardTests[i] as? [String: Any]{
                if (item["activityStatus"] as? String == "active") {
                    activeStandardTests.add(item)
                }
            }
        }
        
        //print(activeStandardTests)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backgroundView = UIImageView()
        //backgroundView.image = UIImage(named: "background4d")
        backgroundView.backgroundColor = segueBackgroundColorReceive
        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.backgroundView = backgroundView
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeStandardTests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if let item = activeStandardTests[indexPath.row] as? [String: Any]{
            if let name = item["name"] as? String {
                cell.textLabel?.text = name.cleanAsciiToStandard()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = UIColor.white
            }
        }
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 3
        let alpha = 0.15 + (0.3*(1-(Double(indexPath.row)/Double(activeStandardTests.count))))
        
       // cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: CGFloat(alpha))
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = activeStandardTests[indexPath.row] as? [String: Any]{
            selectedTest = (item["id"] as? String)!
        }
        
        self.performSegue(withIdentifier: "SelectTestToSelectTopicSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectTestToSelectTopicSegue"){
            print("Moving to Select Topic")
            
            //This sets the filter for the topics on the next page
            setFilterForNextScreen(destinationArrayForFilter: &standardTopicsFiltered, inputArray: fetchedStandardTopics, filteringAttribute: "correspondingSTP", valueForFilter: selectedTest)
            
            //This passes important variables to the next screen
            let destinationVC = segue.destination as! SelectTopicVC
            destinationVC.segueBackgroundColorReceive = getRandomColor(tint: "dark")
            destinationVC.view.backgroundColor = destinationVC.segueBackgroundColorReceive
            
            destinationVC.standardTopicsFiltered = standardTopicsFiltered
            
            destinationVC.currentStudent = currentStudent
            destinationVC.segueSender = segueSender
            destinationVC.selectedTest = selectedTest
            
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
