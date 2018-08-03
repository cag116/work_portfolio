//
//  resourcesVC.swift
//  programmaticSwiftV1
//
//  Created by Christopher Guirguis on 12/30/16.
//  Copyright © 2016 Christopher Guirguis. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ResourcesVC:UIViewController {
    
    var fetchedStandardTests:NSArray = []
    var fetchedStandardTopics:NSArray = []
    var fetchedStandardSubtopics:NSArray = []
    
    var selectedTopic = "";
    var selectedTest = "";
    var selectedTopicPlaylistId = ""
    @IBOutlet weak var mainSV: UIScrollView!
    //let mainSV = UIScrollView()
    let recommendedViewSV = UIScrollView()
    let localResourceContainer = UIView()
    
    let localResourceContainerSectionTitle = UILabel()
    let recommendedStudyMaterialsSectionTitle = UILabel()
    
    //This is between the various container types
    let mainSpacer:CGFloat = 15
    
    let indents:CGFloat = 10
    
    //These are used to dictate scrollview content size
    var currentMainSVContentHeight:CGFloat = 0
    
    var recommendedVideos:[Any] = Array()
    
    //This var gets changed when you select a button. it gets carried into the resourceWebView
    var urlForWebView:String = ""
    
    @IBOutlet var videoView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let window = UIApplication.shared.delegate?.window!
        window?.viewWithTag(6666)?.removeFromSuperview()
        
        if (selectedTopicPlaylistId != ""){
            recommendedVideos = loadRecommendedVideos(playListId: selectedTopicPlaylistId)
        }
        videoView.allowsInlineMediaPlayback = true
        loadPageElements()
        
        videoView.loadHTMLString("<style>body,html,iframe{margin:0;}</style><iframe width=\"\(videoView.frame.width)\" height=\"\(videoView.frame.height) frameborder=0 vspace=0 hspace=0 marginwidth=0 marginheight=0\" src=\"https://www.youtube.com/embed/0gdUvWumfpk?&playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
    }
    
    func loadRecommendedVideos(playListId:String) -> Array<Any>{
        
        let test:NSDictionary = videoModel().getFeedVideo(playlistId: playListId)
        
        var arrayOfVideos:[[Any]] = []
        var listOfKeyPaths = ["items.snippet.title","items.snippet.resourceId.videoId","items.snippet.description","items.snippet.channelId","items.snippet.thumbnails.maxres.url"]
        
        for i in 0...listOfKeyPaths.count-1{
            var tempArray = test.value(forKeyPath: listOfKeyPaths[i]) as! NSArray
            arrayOfVideos.append([])
            for j in 0...tempArray.count-1{
                arrayOfVideos[i].append(tempArray[j])
            }
        }
        return arrayOfVideos
    }
    
    func loadPageElements(){
        loadGenericElements()
        
        loadVideoElements()
        
        loadResourcesOnLocalServer()
    }
    
    func loadGenericElements(){
        
        
        
        let widthPostIndent:CGFloat = UIScreen.main.bounds.width - 2*indents
        //Load Main ScrollView
        
        mainSV.backgroundColor = UIColor.black
        //mainSV.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)! + 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //self.view.addSubview(mainSV)
        
        //Load Recommended View ScrollView
        
        
        recommendedViewSV.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.2)
        recommendedViewSV.frame = CGRect(x: 0, y: currentMainSVContentHeight, width: UIScreen.main.bounds.width, height: 240)
        
        
        localResourceContainerSectionTitle.text = "Recommended Videos"
        localResourceContainerSectionTitle.textColor = UIColor.white
        localResourceContainerSectionTitle.backgroundColor = UIColor.clear
        localResourceContainerSectionTitle.frame = CGRect(x: indents, y: indents, width: widthPostIndent, height: 30)
        
        mainSV.addSubview(recommendedViewSV)
        mainSV.addSubview(localResourceContainerSectionTitle)
        
        currentMainSVContentHeight += recommendedViewSV.frame.height
        //currentMainSVContentHeight += mainSpacer
        
        localResourceContainer.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        localResourceContainer.frame = CGRect(x: 0, y: currentMainSVContentHeight, width: UIScreen.main.bounds.width, height: 500)
        
        
        recommendedStudyMaterialsSectionTitle.text = "Studying Materials"
        recommendedStudyMaterialsSectionTitle.textColor = UIColor.white
        recommendedStudyMaterialsSectionTitle.backgroundColor = UIColor.clear
        recommendedStudyMaterialsSectionTitle.frame = CGRect(x: indents, y: currentMainSVContentHeight + indents, width: widthPostIndent, height: 30)
        
        mainSV.addSubview(localResourceContainer)
        mainSV.addSubview(recommendedStudyMaterialsSectionTitle)
        
        recommendedViewSV.layer.shadowOffset = CGSize(width: 0, height: 2)
        recommendedViewSV.layer.shadowOpacity = 0.4
        recommendedViewSV.layer.shadowRadius = 3
        
    }
    
    func loadVideoElements(){
        
        if (recommendedVideos.count == 0){
            let noVideoLabel = UILabel()
            noVideoLabel.text = "No videos are present for this topic"
            noVideoLabel.textAlignment = .center
            noVideoLabel.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            noVideoLabel.numberOfLines = 0
            noVideoLabel.frame = CGRect(x: 0, y: 170, width: recommendedViewSV.frame.width, height: 30)
            
            let noVideoIcon = UIImageView()
            noVideoIcon.backgroundColor = UIColor.clear
            noVideoIcon.frame = CGRect(x: (recommendedViewSV.frame.width/2)-50, y: 60, width: 100, height: 100)
            noVideoIcon.image = UIImage(named: "playlist_g")
            
            recommendedViewSV.addSubview(noVideoIcon)
            recommendedViewSV.addSubview(noVideoLabel)
            
        } else {
        
            var currentRecommendedViewSVWidth:CGFloat = 0
            
            for i in 0...((recommendedVideos[0]) as AnyObject).count-1{
                print("Title: " + (recommendedVideos[0] as! Array)[i])
                print("Video ID: " + (recommendedVideos[1] as! Array)[i])
                print("Description: " + (recommendedVideos[2] as! Array)[i])
                print("Channel ID: " + (recommendedVideos[3] as! Array)[i])
                print("Thumbnail URL: " + String(describing: (recommendedVideos[4] as! NSArray)[i]))
                
                
                //BEGIN MAKING ELEMENTS
                let videoElement = UIImageView()
                videoElement.frame = CGRect(x: currentRecommendedViewSVWidth + 10, y: 50, width: 225, height: 150)
                videoElement.backgroundColor = UIColor.clear
                recommendedViewSV.addSubview(videoElement)
                
                let videoButton = parameterizedButton()
                videoButton.frame = CGRect(x: currentRecommendedViewSVWidth + 10, y: 50, width: 225, height: 150)
                videoButton.backgroundColor = UIColor.clear
                recommendedViewSV.addSubview(videoButton)
                videoButton.tagForPass = "http://youtube.com/watch?v=" + (recommendedVideos[1] as! Array)[i] + "&list=" + selectedTopicPlaylistId
                videoButton.addTarget(self, action: #selector(ResourcesVC.goToLocalResource(_:)), for: .touchDown)
                
                let videoInfoView = UIView()
                videoInfoView.frame = CGRect(x: currentRecommendedViewSVWidth + 10, y: 150, width: 225, height: 50)
                videoInfoView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.8)
                recommendedViewSV.addSubview(videoInfoView)
                
                let titleMargins:CGFloat = 5
                let videoTitle = UILabel()
                videoTitle.frame = CGRect(x: currentRecommendedViewSVWidth + 10 + titleMargins, y: 150 + titleMargins, width: 225 - (2*titleMargins), height: 44)
                videoTitle.numberOfLines = 0
                videoTitle.text = ((recommendedVideos[0] as AnyObject) as! Array)[i]
                
                videoTitle.font = UIFont.systemFont(ofSize: 15)
                recommendedViewSV.addSubview(videoTitle)
                
                var thumbnailURL:String = String(describing: (recommendedVideos[4]  as! NSArray)[i])
                //Some videos dont have a link to a maxres image so it comes up as <null>
                //This next line will fix that problem by constructing the URL to a thumbnail of lower quality using the video's ID
                if (thumbnailURL == "<null>"){
                    thumbnailURL = "https://i.ytimg.com/vi/\(String(describing: (recommendedVideos[1]  as! NSArray)[i]))/sddefault.jpg"
                }
                consoleLog(msg: "debug: sdfg7ghh - " + thumbnailURL, level: 5)
                
                videoElement.sd_setImage(with: URL(string: thumbnailURL))
                
                currentRecommendedViewSVWidth += videoElement.frame.width + 10
                
               
            }
            
            
            
            //Create one more for the "view more" button
            let moreVideosElement = UIImageView()
            moreVideosElement.frame = CGRect(x: currentRecommendedViewSVWidth + 10, y: 50, width: 225, height: 150)
            moreVideosElement.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.15)
            recommendedViewSV.addSubview(moreVideosElement)
            moreVideosElement.image = UIImage(named: "more_g")
            moreVideosElement.contentMode = .center
            
            let moreVideosButton = parameterizedButton()
            moreVideosButton.frame = CGRect(x: currentRecommendedViewSVWidth + 10, y: 50, width: 225, height: 150)
            moreVideosButton.backgroundColor = UIColor.clear
            recommendedViewSV.addSubview(moreVideosButton)
            moreVideosButton.tagForPass = "http://youtube.com/playlist?list=" + selectedTopicPlaylistId
            moreVideosButton.addTarget(self, action: #selector(ResourcesVC.goToLocalResource(_:)), for: .touchDown)
            
            currentRecommendedViewSVWidth += moreVideosElement.frame.width + 10
            recommendedViewSV.contentSize.width = currentRecommendedViewSVWidth + 10
            
            print(String(recommendedVideos.count) + " videos loaded")
        }
    }
    
    func loadResourcesOnLocalServer(){
        let spacing:CGFloat = 5
        let localResourceVSpacer:CGFloat = 15
        var localResourceContainerCurrentContentHeight = 2*indents + localResourceContainerSectionTitle.frame.height
        
        var localServerResources = fetchResourcesLocalServer(argument: "path=../supplements/topics/" + selectedTopic + "/notes")
        print(localServerResources)
        if (localServerResources.count != 0){
            for i in 0...localServerResources.count-1{
                print("000")
                let fileType = ((localServerResources)[i] as! String).components(separatedBy: "~!~")[1]
                let fileName = ((localServerResources)[i] as! String).components(separatedBy: "~!~")[0]
                if fileType != "Unknown"{
                    let localResourceView = UIView()
                    localResourceView.frame = CGRect(x: indents, y: localResourceContainerCurrentContentHeight, width: localResourceContainer.frame.width - (2*indents), height: 50)
                    localResourceView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.1)
                    
                    let localResourceButton = parameterizedButton()
                    localResourceButton.frame = CGRect(x: indents, y: localResourceContainerCurrentContentHeight, width: localResourceContainer.frame.width - (2*indents), height: 50)
                    localResourceButton.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.1)
                    localResourceButton.tagForPass = "http://flasheducational.com/supplements/topics/" + selectedTopic + "/notes/" + fileName
                    localResourceButton.addTarget(self, action: #selector(ResourcesVC.goToLocalResource(_:)), for: .touchDown)
                    
                    localResourceContainer.addSubview(localResourceView)
                    localResourceContainer.addSubview(localResourceButton)
                    
                    
                    
                    
                    let localResourceLabel = UILabel()
                    //The 40 + 3*spacing takes into account 40 for the icon, and 3 spacings for the following setups |-sp-icon-sp-label-sp-|
                    localResourceLabel.frame = CGRect(x: 40 + 2*spacing, y: spacing, width: localResourceView.frame.width-(40 + 3*spacing), height: localResourceView.frame.height-10)
                    localResourceLabel.backgroundColor = UIColor.clear
                    localResourceLabel.text = fileName
                    localResourceLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
                    
                    let localResourceIcon = UIImageView()
                    localResourceIcon.backgroundColor = UIColor.clear
                    localResourceIcon.frame = CGRect(x: spacing, y: spacing, width: 40, height: 40)
                    
                    let ext = fileName.components(separatedBy: ".")[1]
                    if (ext == "pdf" || ext == "dox" || ext == "docx"){
                        localResourceIcon.image = UIImage(named: "document_blue")
                    } else if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "gif"){
                        localResourceIcon.image = UIImage(named: "document_blue")
                    }
                    localResourceView.addSubview(localResourceIcon)
                    localResourceView.addSubview(localResourceLabel)
                    
                    localResourceContainerCurrentContentHeight += localResourceView.frame.height + localResourceVSpacer
                }
            }
            localResourceContainer.frame = CGRect(x: localResourceContainer.frame.origin.x, y: localResourceContainer.frame.origin.y, width: localResourceContainer.frame.width, height: localResourceContainerCurrentContentHeight)
            
            currentMainSVContentHeight += localResourceContainer.frame.height
            currentMainSVContentHeight += mainSpacer
        } else {
            localResourceContainer.frame = CGRect(x: localResourceContainer.frame.origin.x, y: localResourceContainer.frame.origin.y, width: localResourceContainer.frame.width, height: UIScreen.main.bounds.height-(recommendedViewSV.frame.height + 44 + 20))
            
            let noLocalResourcesLabel = UILabel()
            noLocalResourcesLabel.text = "No resources are present for this topic"
            noLocalResourcesLabel.textAlignment = .center
            noLocalResourcesLabel.textColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            noLocalResourcesLabel.numberOfLines = 0
            noLocalResourcesLabel.frame = CGRect(x: 0, y: 170, width: recommendedViewSV.frame.width, height: 30)
            
            let noLocalResourcesIcon = UIImageView()
            noLocalResourcesIcon.backgroundColor = UIColor.clear
            noLocalResourcesIcon.frame = CGRect(x: (recommendedViewSV.frame.width/2)-50, y: 60, width: 100, height: 100)
            noLocalResourcesIcon.image = UIImage(named: "multipleDocuments_g")
            
            localResourceContainer.addSubview(noLocalResourcesIcon)
            localResourceContainer.addSubview(noLocalResourcesLabel)
            
            currentMainSVContentHeight += localResourceContainer.frame.height
            currentMainSVContentHeight += mainSpacer
        }
        
        mainSV.contentSize.height = currentMainSVContentHeight
    }
    
    func goToLocalResource(_ button: parameterizedButton){
        print("222")
        urlForWebView = button.tagForPass.cleanStringToURL()
        print(urlForWebView)
        self.performSegue(withIdentifier: "resourcesToResourcesWebViewSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "resourcesToResourcesWebViewSegue"){
            print("Moving to Expanded Image")
            
            //This passes important variables to the next screen
            
            let destinationVC = segue.destination as! resourceWebViewVC
            print(urlForWebView)
            destinationVC.URLforWebView = urlForWebView
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
