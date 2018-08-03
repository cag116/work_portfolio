//
//  extensions.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/20/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire
// ---------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------- //
// ----------------------------   CENTRAL ARRAYS   ---------------------------- //
// ---------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------- //

public var fetchedStandardTests:NSMutableArray = []
public var fetchedStandardTopics:NSMutableArray = []
public var fetchedStandardSubtopics:NSMutableArray = []
public var fetchedPointerQuestionStandardSubtopic:NSMutableArray = []



public var hierarchy:[Any] =  []
public var subtopicQuestionCount:NSMutableDictionary = [:]

public var currentStudent:NSMutableArray = []
public var currentStudentID:String = ""

public var selectedTest = "";
public var selectedTopic = "";
public var selectedSubtopic = "";

//These are mainly used in the CurrentSubtopicVC and PracticeVC
public var fetchedQuestions:NSMutableArray = []
public var entryArray:NSMutableArray = []
public var fetchedPointerForSelectedSubtopicToQuestions:NSMutableArray = []



// ---------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------- //
// -------------------------   CENTRAL ARARAYS END   -------------------------- //
// ---------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------- //

func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

func degreesToRadians(degrees:Double) -> Double{
return (M_PI * Double(degrees) / 180.0)

}

extension Int {

    func isDivisibleBy(divisibleBy:Int) -> Bool{
        if (round(Double(self)/Double(divisibleBy)) == Double(self)/Double(divisibleBy)){
            return true
        } else {
            return false
        }
    }
}
var managedContext:NSManagedObjectContext = NSManagedObjectContext()

let statusBarHeight:CGFloat = 20
let navBarHeight:CGFloat = 44

var logLevel = 5

func consoleLog(msg:String, level:Int){
    if (level <= logLevel){
        print(msg)
    }
}
var numberToLetter = [["a","A"],["b","B"],["c","C"],["d","D"],["e","E"],["f","F"],["g","G"],["h","H"],["i","I"],["j","J"],["k","K"],["l","L"],["m","M"],["n","N"],["o","O"],["p","P"],["q","Q"],["r","R"],["s","S"],["t","T"],["u","U"],["v","V"],["w","W"],["x","X"],["y","Y"],["z","Z"]]

func appendFlashLog (){
    
    let parameters:Parameters = ["user":currentStudentID,"page":"Login","device":"iOS"]
    
    Alamofire.request("http://flasheducational.com/appendLog.php", method: .post, parameters:parameters) .responseString { response in
        
        print("Log Appended || " + String(describing: parameters))
        
    }
    
    
}

func submitNewEntry (parameters:Parameters, parentView:UIView){
    
    Alamofire.request("http://flasheducational.com/phpScripts/insert/insertNewEntry.php", method: .post, parameters:parameters) .responseString { response in
        
        //This prints the value of the repsonse string
        print("Response String: \(response.result.value!)")
        
        gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
        
        parentView.viewWithTag(536536)?.removeFromSuperview()
        
    }
    
    
}

func modifyExistingEntry (parameters:Parameters, parentView:UIView){
    
    Alamofire.request("http://flasheducational.com/phpScripts/update/updateEntryCurrentAnswerChosenByID.php", method: .post, parameters:parameters) .responseString { response in
        
        //This prints the value of the repsonse string
        print("Response String: \(response.result.value!)")
        
        gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic: &fetchedQuestions, entryArrayForFetch: &entryArray, fetchedPointerForSelectedSubtopicToQuestions: &fetchedPointerForSelectedSubtopicToQuestions, subTopicIdForFetch: selectedSubtopic, studentIdForFetch: currentStudentID)
        
        parentView.viewWithTag(536536)?.removeFromSuperview()
        
        
    }
    
    
    }

func generalFetch (arrayToSet:inout NSMutableArray, argument:String){
    //responseString is the return message from HTTP requests
    
    var responseString:NSString = ""
    
    var currentFetchArray:NSMutableArray = []
    //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
    var marker = "incomplete"
    //This is the URL for the HTTPRequest
    let request = NSMutableURLRequest(url: NSURL(string: "http://flasheducational.com/phpScripts/fetch/generalFetch.php")! as URL)
    //This is the method
    request.httpMethod = "POST"
    //This is the argument for the HTTPRequest
    let postString = argument
    print(postString)
    // ~I THINK~ this is the execution of the HTTPRequest
    request.httpBody = postString.data(using: String.Encoding.utf8)
    
    //This is the beginning of processing the request
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
            
        }
        
        //This sets the value of the responseString
        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
//        print(responseString)
        
        //This is what happens when nothing is found on the DB; Most likely this would happen if your table was written incorrectly in the post argument
        if(responseString == "nothingFetched"){
            marker = "complete"
            print(responseString)
        } else {
            //print(responseString)
            //Convert JSON to Attributed Array
            let fetchedDataArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray
            currentFetchArray = fetchedDataArray
            print("Item count = \(fetchedDataArray.count)")
            marker = "complete"
            
            
            
        }
        
    }
    
    task.resume()
    
    //This is the timer being reset
    var timer = 0
    
    //This loop serves two purposes: (1) it serves as a timer, but (2) MORE IMPORTANTLY it allows the request to finish before continuing on. Had to use this method in order to accomodate the "inou" variable
    while marker != "complete" {
        usleep(1000)
        timer += 1
    }
    
    
    print("Waited " + String(timer) + " ms")
    
    //This sets the value of the arrayToSet; This couldn't be done earlier in the code (in the seciton of analyzing the responseString) becuase for some reason we cant use "inout" within an asynchronous request. I don't fully understand this, tbh
    arrayToSet = currentFetchArray
    print("Just finished general fetch: " + argument)
}

func fetchMultipleAnything(table:String, qIDList:String, arrayToSet:inout NSMutableArray){
    var currentFetch:NSMutableArray = []
    //This will be what ever the post returns; its getting reset here
    var responseString:NSString = ""
    //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
    var marker = "incomplete"
    //This is the URL for the HTTPRequest
    let request = NSMutableURLRequest(url: NSURL(string: "http://flasheducational.com/phpScripts/fetch/unfiltered/multiple/fetchAnythingByMultipleId.php")! as URL)
    //This is the method
    request.httpMethod = "POST"
    //This is the argument for the HTTPRequest
    let postString = "table=\(table)&idList=\(qIDList)"
    print(postString)
    // ~I THINK~ this is the execution of the HTTPRequest
    request.httpBody = postString.data(using: String.Encoding.utf8)
    
    //This is the beginning of processing the request
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
            
        }
        
        //This sets the value of the responseString
        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        print(responseString)
        
        //This is what happens when nothing is found on the DB; Most likely this would happen if your table was written incorrectly in the post argument
        if(responseString == "nothingFetched"){
            marker = "complete"
        } else {
            //Convert JSON to Attributed Array
            let fetchedDataArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray
            currentFetch = fetchedDataArray
            print("Item count = \(fetchedDataArray.count)")
            marker = "complete"
            
            
        }
    }
    
    task.resume()
    
    //This is the timer being reset
    var timer = 0
    
    //This loop serves two purposes: (1) it serves as a timer, but (2) MORE IMPORTANTLY it allows the request to finish before continuing on. Had to use this method in order to accomodate the "inou" variable
    while marker != "complete" {
        usleep(1000)
        timer += 1
    }
    
    
    print("Waited " + String(timer) + " ms")
    
    //This sets the value of the arrayToSet; This couldn't be done earlier in the code (in the seciton of analyzing the responseString) becuase for some reason we cant use "inout" within an asynchronous request. I don't fully understand this, tbh
    arrayToSet = currentFetch
    
    print("fetched " + table + " by qIDList " + qIDList)
}


func fetchAllAnything(table:String, arrayToSet:inout NSMutableArray){
    //responseString is the return message from HTTP requests
    var responseString:NSString = ""
    
    var currentFetchArray:NSArray = []
    //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
    var marker = "incomplete"
    //This is the URL for the HTTPRequest
    let request = NSMutableURLRequest(url: NSURL(string: "http://flasheducational.com/phpScripts/fetch/unfiltered/all/fetchAllAnything.php")! as URL)
    //This is the method
    request.httpMethod = "POST"
    //This is the argument for the HTTPRequest
    let postString = "table=\(table)"
    print(postString)
    // ~I THINK~ this is the execution of the HTTPRequest
    request.httpBody = postString.data(using: String.Encoding.utf8)
    
    //This is the beginning of processing the request
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
            
        }
        
        //This sets the value of the responseString
        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        //print(self.responseString)
        
        //This is what happens when nothing is found on the DB; Most likely this would happen if your table was written incorrectly in the post argument
        if(responseString == "nothingFetched"){
            marker = "complete"
        } else {
            //Convert JSON to Attributed Array
            let fetchedDataArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
            currentFetchArray = fetchedDataArray
            print("Item count = \(fetchedDataArray.count)")
            marker = "complete"
            
            
            
        }
    }
    
    task.resume()
    
    //This is the timer being reset
    var timer = 0
    
    //This loop serves two purposes: (1) it serves as a timer, but (2) MORE IMPORTANTLY it allows the request to finish before continuing on. Had to use this method in order to accomodate the "inou" variable
    while marker != "complete" {
        usleep(1000)
        timer += 1
    }
    
    
    print("Waited " + String(timer) + " ms")
    
    //This sets the value of the arrayToSet; This couldn't be done earlier in the code (in the seciton of analyzing the responseString) becuase for some reason we cant use "inout" within an asynchronous request. I don't fully understand this, tbh
    arrayToSet = currentFetchArray as! NSMutableArray
    print("Just finished fetching " + table)
}



func showViewByTag(selfView:UIView, tagForAction:Int){
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
        selfView.viewWithTag(tagForAction)?.alpha = 1
    }, completion: {
        (value: Bool) in
        
    })
    print(String(tagForAction) + " Shown")
}

func hideViewByTag(selfView:UIView, tagForAction:Int){
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
        selfView.viewWithTag(tagForAction)?.alpha = 0
    }, completion: {
        (value: Bool) in
        
    })
    print(String(tagForAction) + " hidden")
}
extension UIViewController {
    
    
    
    
    //This function runs to filter the topics before you get to the next screen
    func setFilterForNextScreen(destinationArrayForFilter: inout NSMutableArray, inputArray: NSArray, filteringAttribute: String, valueForFilter: String){
        destinationArrayForFilter = []
        for i in 0...(inputArray.count-1){
            if let item = inputArray[i] as? [String: Any]{
                if (item[filteringAttribute] as? String) == valueForFilter{
                    consoleLog(msg: "matchTrue", level: 3)
                    destinationArrayForFilter.add(item)
                } else {
                    consoleLog(msg: "matchFalse", level: 3)
                }
            }
        }
        
        
    }

    //This func gives me the size of a dynamic label
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
        
    }

}

class parameterizedTapGestureRecognizer:UITapGestureRecognizer {
    var tagForPass:String = ""
    var IntTagForPass:Int = -1
}

class parameterizedButton:UIButton {
    var tagForPass:String = ""
    var tagForPass2:String = ""
    var IntTagForPass:Int = -1
}

func getCurrentCoreData(){
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return
    }
    
    // 1
    managedContext =
        appDelegate.persistentContainer.viewContext
}

func fetchResourcesLocalServer (argument:String) -> Array<Any>{
    var resources = String()
    
    
    //responseString is the return message from HTTP requests
    consoleLog(msg: "======", level: 1)
    consoleLog(msg: "Begin Fetch Server Resrouces", level: 1)
    var responseString:NSString = ""
    
    //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
    var marker = "incomplete"
    //This is the URL for the HTTPRequest
    let request = NSMutableURLRequest(url: NSURL(string: "http://flasheducational.com/phpScripts/itemizeDirectory.php")! as URL)
    
    //This is the method
    request.httpMethod = "POST"
    //This is the argument for the HTTPRequest
    let postString = argument
    consoleLog(msg: postString, level: 2)
    // ~I THINK~ this is the execution of the HTTPRequest
    request.httpBody = postString.data(using: String.Encoding.utf8)
    //This is the beginning of processing the request
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard error == nil && data != nil else {
            consoleLog(msg: "error=\(error)", level: 1)
            return
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            consoleLog(msg: "statusCode should be 200, but is \(httpStatus.statusCode)", level: 1)
            consoleLog(msg: "response = \(response)", level: 1)
            
        }
        
        //This sets the value of the responseString
        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        //        print(responseString)
        
        //This is what happens when nothing is found on the DB; Most likely this would happen if your table was written incorrectly in the post argument
        if(responseString == "Error"){
            marker = "complete"
            consoleLog(msg: responseString as String, level: 1)
        } else {
            //print(responseString)
            //Convert JSON to Attributed Array
            consoleLog(msg:(responseString as String), level: 1)
            consoleLog(msg: "Argument: " + argument, level: 2)
            marker = "complete"
            
            
            
        }
        
    }
    
    task.resume()
    
    //This is the timer being reset
    var timer = 0
    
    //This loop serves two purposes: (1) it serves as a timer, but (2) MORE IMPORTANTLY it allows the request to finish before continuing on. Had to use this method in order to accomodate the "inou" variable
    while marker != "complete" {
        usleep(1000)
        timer += 1
    }
    
    
    consoleLog(msg: "Waited " + String(timer) + " ms", level: 1)
    
    //This sets the value of the arrayToSet; This couldn't be done earlier in the code (in the seciton of analyzing the responseString) becuase for some reason we cant use "inout" within an asynchronous request. I don't fully understand this, tbh
    consoleLog(msg: "End **", level: 1)
    consoleLog(msg: "======", level: 1)
    
    var resourceList:[String] = []
    resources = responseString as String
    if (resources != ""){
        resourceList = resources.components(separatedBy: "</item>")
        //IMPORTANT!! This next line removes a blank array entry, because the split before this makes an empty element after the final "</item>"
        resourceList.remove(at: resourceList.count-1)
        for i in 0...resourceList.count-1{
            //print(resourceList[i])
            //print(resourceList[i].components(separatedBy: "<item>")[1])
            resourceList[i] = resourceList[i].components(separatedBy: "<item>")[1]
        }
    } else {
        
    }
    
    return resourceList as Array
}
extension String{
    func cleanStringToURL() -> String{
        var cleaned = ""
        cleaned = self.replacingOccurrences(of: " ", with: "%20")
        return cleaned
    }
    
    func cleanAsciiToStandard() -> String{
        var cleaned = ""
        cleaned = self.replacingOccurrences(of: "&34;", with: "\"")
        cleaned = self.replacingOccurrences(of: "&39;", with: "'")
        return cleaned
    }
}

class viewWithStringTag: UIView {
    var stringTag:String = ""
}

func getRandomColor(tint:String) -> UIColor{
    var randomNumForTint = 0
    if (tint == "dark"){
        randomNumForTint = Int(arc4random_uniform(3))
    } else {
        randomNumForTint = Int(arc4random_uniform(6))
    }
    var backgroundColor = UIColor()
    //This sets the random conditions
    if (randomNumForTint == 0){backgroundColor = UIColor.init(red: 46/255, green: 107/255, blue: 163/255, alpha: 1)}
    else if (randomNumForTint == 1){backgroundColor = UIColor.init(red: 25/255, green: 57/255, blue: 130/255, alpha: 1)}
    else if (randomNumForTint == 2){backgroundColor = UIColor.init(red: 48/255, green: 78/255, blue: 148/255, alpha: 1)}
    else if (randomNumForTint == 3){backgroundColor = UIColor.init(red: 18/255, green: 47/255, blue: 115/255, alpha: 1)}
    else if (randomNumForTint == 4){backgroundColor = UIColor.init(red: 132/255, green: 187/255, blue: 238/255, alpha: 1)}
    else if (randomNumForTint == 5){backgroundColor = UIColor.init(red: 67/255, green: 139/255, blue: 206/255, alpha: 1)}
    else if (randomNumForTint == 6){backgroundColor = UIColor.init(red: 108/255, green: 188/255, blue: 255/255, alpha: 1)}
    
    
    return backgroundColor
}

func clearRadialTransitionElements(){
    let window = UIApplication.shared.delegate?.window!
    
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
        window?.viewWithTag(6662)?.alpha = 0
        window?.viewWithTag(6663)?.alpha = 0
        window?.viewWithTag(6664)?.alpha = 0
        window?.viewWithTag(6665)?.alpha = 0
        window?.viewWithTag(6666)?.alpha = 0
    }, completion: {
        (value: Bool) in
        window?.viewWithTag(6662)?.isHidden = true
        window?.viewWithTag(6663)?.isHidden = true
        window?.viewWithTag(6664)?.isHidden = true
        window?.viewWithTag(6665)?.isHidden = true
        window?.viewWithTag(6666)?.isHidden = true
        window?.viewWithTag(6662)?.removeFromSuperview()
        window?.viewWithTag(6663)?.removeFromSuperview()
        window?.viewWithTag(6664)?.removeFromSuperview()
        window?.viewWithTag(6665)?.removeFromSuperview()
        window?.viewWithTag(6666)?.removeFromSuperview()
    })
}

func hierarchyInitiation(standardTest:NSArray, standardTopics:NSArray, standardSubtopics:NSArray) -> [Any]{
    var hierarchy:[Any] = []
    for i in 0...standardTest.count-1{
        if let test = standardTest[i] as? [String: Any]{
            if (test["activityStatus"] as? String == "active") {
                let testName = test["name"]! as! String
                let testId = test["id"]! as! String
                var testItems:[Any] = []
                
                for j in 0...standardTopics.count-1{
                    if let topic = standardTopics[j] as? [String: Any]{
                        if (topic["correspondingSTP"] as? String == test["id"] as? String) {
                            print("STP-Topic = Match")
                            
                            
                            let topicName = topic["name"]! as! String
                            let topicId = topic["id"]! as!String
                            let topicUpperCorrespondance = topic["correspondingSTP"]! as!String
                            var topicItems:[Any] = []
                            
                            for k in 0...standardSubtopics.count-1{
                                if let subtopic = standardSubtopics[k] as? [String: Any]{
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
    return(hierarchy)
}

struct Section {
    var name: String!
    var items: [String]!
    var collapsed: Bool!
    
    init(name: String, items: [String], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

func showflashEducationLoader(parentView:UIView){
    
    
    
    let flashLoaderBackground = UIView()
    flashLoaderBackground.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
    flashLoaderBackground.frame.size = parentView.frame.size
    flashLoaderBackground.center = parentView.center
    flashLoaderBackground.tag = 536536
    parentView.addSubview(flashLoaderBackground)
    
    let flashLoaderImage = UIImageView()
    flashLoaderImage.image = UIImage(named: "AlternateColorLogo_400x400")
    flashLoaderImage.frame.size = CGSize(width: 100, height: 100)
    flashLoaderImage.center = parentView.center
    flashLoaderBackground.addSubview(flashLoaderImage)
    
    let squarePathElement = UIView()
    squarePathElement.frame = CGRectMake(0, 0, 15, 15)
    squarePathElement.backgroundColor = UIColor.white
    squarePathElement.center = CGPoint(x:  (parentView.center.x)-50, y: (parentView.center.y)+70)
    squarePathElement.layer.cornerRadius = 10
    
    flashLoaderBackground.addSubview(squarePathElement)
    
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut,.autoreverse,.repeat], animations: {
        squarePathElement.center = CGPoint(x: (parentView.center.x)+50, y: squarePathElement.center.y)
    }, completion:nil)
    
    
}
    
func updateAllAppData(standardizedTestArrayToSet:inout NSMutableArray, standardSubtopicArrayToSet:inout NSMutableArray, standardTopicArrayToSet:inout NSMutableArray, pointerQuestionStandardSubtopicArrayToSet:inout NSMutableArray){
    
    fetchAllAnything(table: "standardizedTest", arrayToSet: &standardizedTestArrayToSet)
    
    fetchAllAnything(table: "pointerQuestionStandardSubtopic", arrayToSet: &pointerQuestionStandardSubtopicArrayToSet)
    
    fetchAllAnything(table: "standardTopic", arrayToSet: &standardTopicArrayToSet)
    
    fetchAllAnything(table: "standardSubtopic", arrayToSet: &standardSubtopicArrayToSet)
}

func pointerFetchPi(table:String, arrayToSet:inout NSMutableArray, parentId:String){
    var currentFetch:NSMutableArray = []
    //This will be what ever the post returns; its getting reset here
    var responseString:NSString = ""
    //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
    var marker = "incomplete"
    //This is the URL for the HTTPRequest
    let request = NSMutableURLRequest(url: NSURL(string: "http://flasheducational.com/phpScripts/universalPointerFetchPi.php")! as URL)
    //This is the method
    request.httpMethod = "POST"
    //This is the argument for the HTTPRequest
    let postString = "table=\(table)&parentId=\(parentId)"
    print(postString)
    // ~I THINK~ this is the execution of the HTTPRequest
    request.httpBody = postString.data(using: String.Encoding.utf8)
    
    //This is the beginning of processing the request
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
            
        }
        
        //This sets the value of the responseString
        responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        //print(self.responseString)
        
        //This is what happens when nothing is found on the DB; Most likely this would happen if your table was written incorrectly in the post argument
        if(responseString == "noPointersFetched"){
            marker = "complete"
        } else {
            //Convert JSON to Attributed Array
            let fetchedDataArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray
            currentFetch = fetchedDataArray
            print("Item count = \(fetchedDataArray.count)")
            marker = "complete"
            
            
            
        }
    }
    
    task.resume()
    
    //This is the timer being reset
    var timer = 0
    
    //This loop serves two purposes: (1) it serves as a timer, but (2) MORE IMPORTANTLY it allows the request to finish before continuing on. Had to use this method in order to accomodate the "inou" variable
    while marker != "complete" {
        usleep(1000)
        timer += 1
    }
    
    
    print("Waited " + String(timer) + " ms")
    
    //This sets the value of the arrayToSet; This couldn't be done earlier in the code (in the seciton of analyzing the responseString) becuase for some reason we cant use "inout" within an asynchronous request. I don't fully understand this, tbh
    arrayToSet = currentFetch
    print("fetched all " + table + " by parentId " + parentId)
}


func gatherUniqueDataFor_currentSubtopicVC(filteredQuestionForThisSubtopic:inout NSMutableArray, entryArrayForFetch:inout NSMutableArray, fetchedPointerForSelectedSubtopicToQuestions:inout NSMutableArray, subTopicIdForFetch:String, studentIdForFetch:String){
    filteredQuestionForThisSubtopic = []
    //This will fetch all the related pointer and then questions
    if Reachability.isInternetAvailable() == false {
        SweetAlert().showAlert("Uh oh!", subTitle: "Your internet is disconnected. This software will not work without internet", style: AlertStyle.warning)
    } else {
        pointerFetchPi(table: "pointerQuestionStandardSubtopic", arrayToSet: &fetchedPointerForSelectedSubtopicToQuestions, parentId: subTopicIdForFetch)
        print(fetchedPointerForSelectedSubtopicToQuestions.count)
        if (fetchedPointerForSelectedSubtopicToQuestions.count != 0){
            var qIDListForMultipleFetch = "(";
            for i in 0...fetchedPointerForSelectedSubtopicToQuestions.count-1{
                
                if let item = fetchedPointerForSelectedSubtopicToQuestions[i] as? [String: Any]{
                    //print(item)
                    if(i != 0){
                        qIDListForMultipleFetch += ","
                    }
                    qIDListForMultipleFetch += (item["childId"] as? String)!
                    //fetchQuestionById(table:"question", qID: (item["childId"] as? String)!)
                }
                
                
                
            }
            qIDListForMultipleFetch += ")"
            print(qIDListForMultipleFetch)
            fetchMultipleAnything(table: "question", qIDList: qIDListForMultipleFetch, arrayToSet: &filteredQuestionForThisSubtopic)
            print(filteredQuestionForThisSubtopic.count)
            
            
            
            //This will start to work with the entries to figure out what has been seen before
            
            
                
                
                let stringForFetch = "argument=SELECT * FROM entry WHERE correspondingStudent = \(studentIdForFetch) AND correspondingQuiz =  \"s\(subTopicIdForFetch)\""
                generalFetch(arrayToSet: &entryArrayForFetch, argument: stringForFetch)
            consoleLog(msg: "debug: fsd97f7g", level: 5)
                print(entryArrayForFetch)
                for fetchedQ in filteredQuestionForThisSubtopic{
                    if let questionItem = fetchedQ as? [String: Any]{
                        
                        (fetchedQ as! NSMutableDictionary).setValue(UIColor.clear, forKey: "previousAnswer")
                        (fetchedQ as! NSMutableDictionary).setValue("unanswered", forKey: "repeatIndicator")
                        
                        if entryArrayForFetch.count != 0{
                            //This line will set a default value of "unanswered" in order to just creates the "key" in the dictionary. otherwise an error could return because the key didnt exist. The next few if statements change it to the proper value based on the students history
                            
                            for i in 0...entryArrayForFetch.count-1{
                                if let entryItem = entryArrayForFetch[i] as? [String: Any]{
                                    if ((entryItem["correspondingQuestion"] as? String) == (questionItem["id"] as? String)){
                                        print((entryItem["correspondingQuestion"] as? String)! + " = " + (questionItem["id"] as? String)!)
                                        
                                        
                                        //End default entry here^^
                                        
                                        
                                        if ((entryItem["correctOrIncorrect"] as? String) == "correct"){
                                            print("correct")
                                            (fetchedQ as! NSMutableDictionary).setValue(UIColor.init(red: 85/255, green: 150/255, blue: 103/255, alpha: 1), forKey: "previousAnswer")
                                            (fetchedQ as! NSMutableDictionary).setValue("correct", forKey: "repeatIndicator")
                                            print(fetchedQ)
                                            
                                        } else {
                                            print("incorrect")
                                            (fetchedQ as! NSMutableDictionary).setValue(UIColor.init(red: 150/255, green: 55/255, blue: 65/255, alpha: 1), forKey: "previousAnswer")
                                            (fetchedQ as! NSMutableDictionary).setValue("incorrect", forKey: "repeatIndicator")
                                            print(fetchedQ)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
                
            
            
        }
    }
}

func modifyArraysViaHierarchy(standardizedTestArrayForHierarchy:inout NSMutableArray, standardSubtopicArrayForHierarchy:inout NSMutableArray, standardTopicArrayForHierarchy:inout NSMutableArray, subtopicQuestionCount:inout NSMutableDictionary){
    let hierarchy:[Any] = hierarchyInitiation(standardTest: standardizedTestArrayForHierarchy, standardTopics: standardTopicArrayForHierarchy, standardSubtopics: standardSubtopicArrayForHierarchy)
    print(hierarchy)
    consoleLog(msg: "Checkpoint VC.100004", level: 5)
    
    //This code cycles through all the subtopics and adds a value to their dictionary entry
    //The added value is the number of questions associated with each of the subtopics
    for i in 0...standardSubtopicArrayForHierarchy.count-1{
        
        
        if let item = standardSubtopicArrayForHierarchy[i] as? [String: Any]{
            
            if let subtopicId = item["id"] as? String {
                print("trialToFix")
                
                if (subtopicQuestionCount.value(forKey: subtopicId) != nil){
                    let questionCountFromDictionary = subtopicQuestionCount.value(forKey: subtopicId)!
                    print(subtopicQuestionCount.value(forKey: subtopicId)!)
                    
                    
                    (standardSubtopicArrayForHierarchy[i] as! NSMutableDictionary).setValue(String(describing: questionCountFromDictionary), forKey: "numberOfQuestions")
                    print(standardSubtopicArrayForHierarchy[i] as! NSMutableDictionary)
            }
            
            }
            
        }
        
    }
    
    consoleLog(msg: "Checkpoint VC.100005", level: 5)
    for i in 0...standardTopicArrayForHierarchy.count-1{
        if let item = standardTopicArrayForHierarchy[i] as? [String: Any]{
            var subtopicCounter = 0
            if let topicId = item["id"] as? String {
                
                for j in 0...standardSubtopicArrayForHierarchy.count-1{
                    if let subtopic = standardSubtopicArrayForHierarchy[j] as? [String: Any]{
                        if let correspondingStandardTopic = subtopic["correspondingStandardTopic"] as? String {
                            if (topicId == correspondingStandardTopic){
                                subtopicCounter += 1
                            }
                        }
                        
                    }
                }
                (standardTopicArrayForHierarchy[i] as! NSMutableDictionary).setValue(String(subtopicCounter), forKey: "numberOfSubtopics")
                print(standardTopicArrayForHierarchy[i] as! NSMutableDictionary)
            }
        }
        
    }
 
}

func refreshQuestionSubtopicCount_COPYofOriginalFromLogin(subtopicQuestionCount:inout NSMutableDictionary){
    let temp = NSMutableDictionary()
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
        temp.setValue(secondSplit[1], forKey: secondSplit[0])
    }
    
    
    //This prints the dictionary
    
    
    //This continues with the routine to check if a user is already logged in
    
    }
    subtopicQuestionCount = temp
}
