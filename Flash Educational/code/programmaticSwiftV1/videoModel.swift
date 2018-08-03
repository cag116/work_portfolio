//
//  videoModel.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/30/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import UIKit
import Alamofire

let APIKey = "AIzaSyAsNLZsO8T11fmPsMMhGBidZq-tB7Z0nmE"

class videoModel: NSObject {
    
    func getFeedVideo2(playlistId:String) -> NSDictionary{
        
        var responseDictionary:NSDictionary = [:]
        let parameters: Parameters = ["part": "snippet", "playlistId":playlistId,"key":APIKey]
        print(parameters)
        
        Alamofire.request("https://www.googleapis.com/youtube/v3/playlistItems", parameters: parameters).responseJSON { response in
            debugPrint(response)
            
            if let json = response.result.value {
                print("JSON: \(json)")
                
            }
            responseDictionary = response.result.value as! NSDictionary
        }
        return responseDictionary
        
        
    }
    func getFeedVideo(playlistId:String) -> NSDictionary{
        print("111")
        
        
        var currentFetch:NSDictionary = [:]
        
        //This marker works in conjunction with the timer; it changes value when the post is done. This was needed to get the "inout" array to work
        var marker = "incomplete"
        var responseString = ""
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistId)&key=\(APIKey)")! as URL)
        request.httpMethod = "GET"
        let postString = ""
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
//            responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
            
            
            
                currentFetch = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                consoleLog(msg: responseString, level: 3)
            marker = "complete"
            
            
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
        //print("here")
        //print(currentFetch)
        return currentFetch
        
    }
    }
