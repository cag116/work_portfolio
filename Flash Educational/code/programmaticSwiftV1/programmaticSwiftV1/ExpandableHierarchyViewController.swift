//
//  ExpandableHierarchyViewController.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 1/17/17.
//  Copyright © 2017 Christopher Guirguis. All rights reserved.
//

import UIKit

 //This array stores the subtopics you want to attach to
public var chosenSubtopicsForLinkage:[Int] = []

class ExpandableHierarchyTableViewController: UITableViewController {
    
    var cellLibrary = [Any]()
    
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
    
    var hierarchy:[Any] = []
    
    
    
    
    //
    // MARK: - Data
    //
    @IBOutlet var tableViewOutlet: UITableView!
    
    var headers = ["Click topics to link this question to","Categories"]
    
    
    var selectedCellIndexPath:NSIndexPath?
    var selectedCellSectionTag:Int = -1
    
    let selectedCellHeight: CGFloat = 144.0
    let unselectedCellHeight: CGFloat = 44.0
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearRadialTransitionElements()
        
        //hierarchySetup()
        
        // Initialize the sections array
        // Here we have three sections: Mac, iPad, iPhone
        
        let backButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: "initiateQuestionCreation")
        navigationItem.rightBarButtonItem = backButton
        
        
    }
    
    func initiateQuestionCreation(){
        print("Initiating Question Creation")
    }
    
    
    
    
    //This one should have theoretically been replaced by the function in the extension file (name of funciton = "hierarchyInitiation")
    /*
    func hierarchySetup(){
        for i in 0...fetchedStandardTests.count-1{
            if let test = fetchedStandardTests[i] as? [String: Any]{
                if (test["activityStatus"] as? String == "active") {
                    let testName = test["name"]! as! String
                    let testId = test["id"]! as! String
                    var testItems:[Any] = []
                    
                    for j in 0...fetchedStandardTopics.count-1{
                        if let topic = fetchedStandardTopics[j] as? [String: Any]{
                            if (topic["correspondingSTP"] as? String == test["id"] as? String) {
                                print("STP-Topic = Match")
                                
                                
                                let topicName = topic["name"]! as! String
                                let topicId = topic["id"]! as!String
                                let topicUpperCorrespondance = topic["correspondingSTP"]! as!String
                                var topicItems:[Any] = []
                                
                                for k in 0...fetchedStandardSubtopics.count-1{
                                    if let subtopic = fetchedStandardSubtopics[k] as? [String: Any]{
                                        if (subtopic["correspondingStandardTopic"] as? String == topic["id"] as? String) {
                                            print("Topic-Subtopic = Match")
                                            let subtopicName = subtopic["name"]! as! String
                                            let subtopicId = subtopic["id"]! as!String
                                            let subtopicUpperCorrespondance = subtopic["correspondingStandardTopic"]! as!String
                                            
                                            let constructedSubtopic = [subtopicName,subtopicId,subtopicUpperCorrespondance]
                                            topicItems.append(constructedSubtopic)
                                        }
                                    }
                                }
                                
                                let constructedTopic = [topicName,topicId,topicUpperCorrespondance,topicItems] as [Any]
                                testItems.append(constructedTopic)
                                
                            }
                        }
                        
                    }
                    
                    
                    let constructedtest = [testName,testId,testItems] as [Any]
                    hierarchy.append(constructedtest)
                }
                
                
            }
        }
        print(hierarchy)
    }
 */
    //
    // MARK: - Table view delegate
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case section:  return headers[section]
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        // For section 1, the total count is items count plus the number of headers
        var count = sections.count
        
        for section in sections {
            count += section.items.count
        }
        
        return count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.rowHeight
        }
        
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        
        // Header has fixed height
        if row == 0 {
            return 30.0
        }
        if selectedCellIndexPath == indexPath as NSIndexPath {
            return selectedCellHeight
        }
        
        return sections[section].collapsed! ? 0 : unselectedCellHeight
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title") as UITableViewCell!
            cell?.textLabel?.text = String(describing: chosenSubtopicsForLinkage.count) + " Subtopics Chosen"
            //Aribtrarily assigning this tag to use it later
            cell?.tag = 536
            return cell!
        }
        
        // Calculate the real section index and row index
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! HeaderCell
            cell.titleLabel.text = sections[section].name
            cell.toggleButton.tag = section
            cell.toggleButton.setTitle(sections[section].collapsed! ? "+" : "-", for: UIControlState())
            cell.toggleButton.addTarget(self, action: #selector(ExpandableHierarchyTableViewController.toggleCollapse), for: .touchUpInside)
            return cell
        } else {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! createTableViewTopiCell!
            
            cell?.cellLabel.text = sections[section].items[row - 1]
            cell?.tag = 1000000000 + (section*1000000) + (row*1000)
            print(1000000000 + (section*1000000) + (row*1000))
            var cellSVContentWidth:CGFloat = 0
            let subtopicArray = ((((hierarchy[section] as! [Any])[2] as! [Any])[row-1] as! [Any])[3] as! [Any])
            print(subtopicArray)
            print(subtopicArray.count)
            if (subtopicArray.count > 0){
                for subs in (cell?.cellSV.subviews)!{
                    
                    subs.removeFromSuperview()
                }
                for m in 0...(subtopicArray.count-1){
                    let subtopicArrayElement = subtopicArray[m] as! [Any]
                    let cellSVPiece = UILabel(frame: CGRectMake(cellSVContentWidth + 5, 5, 100, 70))
                    cellSVPiece.text = subtopicArrayElement[0] as! String
                    cellSVPiece.tag = Int(subtopicArrayElement[1] as! String)!
                    cellSVPiece.textColor = UIColor.white
                    cellSVPiece.textAlignment = .center
                    cellSVPiece.numberOfLines = 0
                    cellSVPiece.font = UIFont.systemFont(ofSize: 11)
                    
                    let tapOnSubtopic = parameterizedTapGestureRecognizer(target: self, action: #selector(ExpandableHierarchyTableViewController.tapToSelectSubtopic(sender:)))
                    tapOnSubtopic.numberOfTapsRequired = 1
                    tapOnSubtopic.IntTagForPass = cellSVPiece.tag
                    tapOnSubtopic.tagForPass = String(indexPath.row)
                    cellSVPiece.isUserInteractionEnabled = true
                    cellSVPiece.addGestureRecognizer(tapOnSubtopic)
                    
                    cell?.cellSV.addSubview(cellSVPiece)
                    cellSVPiece.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.2)
                    if (chosenSubtopicsForLinkage.count > 0){
                        for i in 0...chosenSubtopicsForLinkage.count-1{
                            if (chosenSubtopicsForLinkage[i] == cellSVPiece.tag){
                                cellSVPiece.backgroundColor = UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.2)
                            }
                        }
                    }
                    
                    cellSVContentWidth += cellSVPiece.frame.width + 5
                    
                }
                cell?.cellSV.contentSize.width = cellSVContentWidth
            }
            
            for subs in (cell?.cellSV.subviews)!{
                
                print(subs.frame)
            }
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //tableView.relad
        let section = getSectionIndex(indexPath.row)
        let row = getRowIndex(indexPath.row)
        
        if row == 0 {
            
        } else {
            if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath as NSIndexPath? {
                selectedCellIndexPath = nil
            } else {
                selectedCellIndexPath = indexPath as NSIndexPath?
                selectedCellSectionTag = section
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if selectedCellIndexPath != nil {
                // This ensures, that the cell is fully visible once expanded
                tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
            
            print("====")
            print(section)
            print(row)
            print("====")
            print(self.view.viewWithTag(1000000000 + (section*1000000) + (row*1000)))
            
            
        }
    }
    
    //
    // MARK: - Event Handlers
    //
    func toggleCollapse(_ sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = !collapsed!
        
        print(section)
        print(selectedCellSectionTag)
        if(section == selectedCellSectionTag ){
            selectedCellIndexPath = nil
            selectedCellSectionTag = -1
        }
        let indices = getHeaderIndices()
        
        let start = indices[section]
        let end = start + sections[section].items.count
        
        tableView.beginUpdates()
        for i in start ..< end + 1 {
            tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
    //
    // MARK: - Helper Functions
    //
    func getSectionIndex(_ row: NSInteger) -> Int {
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                return i
            }
        }
        
        return -1
    }
    
    func getRowIndex(_ row: NSInteger) -> Int {
        var index = row
        let indices = getHeaderIndices()
        
        for i in 0..<indices.count {
            if i == indices.count - 1 || row < indices[i + 1] {
                index -= indices[i]
                break
            }
        }
        
        return index
    }
    
    func getHeaderIndices() -> [Int] {
        var index = 0
        var indices: [Int] = []
        
        for section in sections {
            indices.append(index)
            index += section.items.count + 1
        }
        
        return indices
    }
    func tapToSelectSubtopic(sender: parameterizedTapGestureRecognizer){
        //This flag is a switch that turns flips if the subtopic ID is already in the list
        var flag = "add"
        if (chosenSubtopicsForLinkage.count > 0){
            for i in 0...chosenSubtopicsForLinkage.count-1{
                if (chosenSubtopicsForLinkage[i] == sender.IntTagForPass){
                    flag = String(i)
                }
            }
        }
        self.view.viewWithTag(sender.IntTagForPass)?.backgroundColor = UIColor.red
        if(flag == "add"){
            chosenSubtopicsForLinkage.append(sender.IntTagForPass)
            
            
            print(self.view.viewWithTag(sender.IntTagForPass))
            
            
            
            
            
        } else {
            chosenSubtopicsForLinkage.remove(at: Int(flag)!)
        }
        
        (self.view.viewWithTag(536) as! UITableViewCell!).textLabel?.text = String(describing: chosenSubtopicsForLinkage.count) + " Subtopics Chosen"
        print(chosenSubtopicsForLinkage)
        
        let indexPath = IndexPath(item: Int(sender.tagForPass)!, section: 1)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}



class createTableViewTopiCell: UITableViewCell {
    
    @IBOutlet var cellLabel: UILabel!
    @IBOutlet var cellSV: UIScrollView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
}
