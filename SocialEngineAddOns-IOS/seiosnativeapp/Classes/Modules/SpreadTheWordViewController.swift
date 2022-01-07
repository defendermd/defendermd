//
//  SpreadTheWordViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 3/11/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class SpreadTheWordViewController: UIViewController {
    
    let mainView = UIView()
    var pageTitle:UILabel!
    var appTitle:UILabel!
    var shareBackgroundImage:UIImageView!
    var backgroundIcon : UILabel!
    var viewTitle : String! = ""
    var leftBarButtonItem : UIBarButtonItem!
    var showActivity : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        showActivity = true
        if viewTitle != ""
        {
            self.title = NSLocalizedString(String(viewTitle),  comment: "")
        }
        else
        {
            self.title = NSLocalizedString("Spread the word",  comment: "")
        }
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        self.navigationItem.hidesBackButton = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        pageTitle = createLabel(CGRect(x: 10, y: TOPPADING , width: (self.view.bounds.width) - 20, height: 40), text: String(format: NSLocalizedString("Like %@?", comment: ""),app_title), alignment: .center, textColor: textColorDark)
        pageTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
        pageTitle.numberOfLines = 1
        //pageTitle.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(pageTitle)
        
        appTitle = createLabel(CGRect(x: 10, y: TOPPADING + pageTitle.bounds.height  , width: (self.view.bounds.width) - 20, height: 40), text: NSLocalizedString("Recommend it now to your friends and contacts!",  comment: ""), alignment: .center, textColor: textColorDark)
        appTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        appTitle.numberOfLines = 0
        view.addSubview(appTitle)
        
        backgroundIcon = createLabel(CGRect(x: 20, y: appTitle.frame.origin.y + appTitle.bounds.height + contentPADING, width: view.bounds.width - 40, height: 75), text: "\(spreadTheWordIcon)", alignment: NSTextAlignment.center, textColor: navColor)
        backgroundIcon.font = UIFont(name: "FontAwesome", size: 75 )
        view.addSubview(backgroundIcon)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
        // WORK FOR SPREAD THE WORD
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if showActivity == true
        {
            showActivity = false
            var sharingItems = [AnyObject]()
            var trackName = UserDefaults.standard.object(forKey: "trackName")
            let trackViewUrl = shareAppUrl //UserDefaults.standard.object(forKey: "trackViewUrl")
            var trackSubject = ""
             DispatchQueue.main.async {
            if trackName == nil || trackViewUrl == "" {
                
                let bundleID = Bundle.main.bundleIdentifier
                
                let bundleResponse = URL(string:"https://itunes.apple.com/lookup?bundleId=\(bundleID!)")
                
                // FETCHING DATA REGARDING APP LIKE APP NAME AND ACCESS URL
                let task = URLSession.shared.dataTask(with: bundleResponse!, completionHandler: { (data, response, error) -> Void in
                    
                    if let urlContent = data
                    {
                        do
                        {
                            let jsonResult =  try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            if let jsonResults = jsonResult as? NSDictionary
                            {
                                //print(jsonResults)
                                if jsonResults["resultCount"] as! Int != 0 {
                                    if jsonResults["results"] != nil{
                                        
                                        if let results = jsonResults["results"] as? NSArray{
                                            if let result = results[0] as? NSDictionary  {
                                                
                                                trackName = result["trackName"]
//                                                trackViewUrl = result["trackViewUrl"] as! String
                                                if trackName != nil{
                                                    trackSubject = String(format: NSLocalizedString("Hey, you're invited to join  %@", comment: ""), "\(trackName!)")
                                                }
                                                
                                                // SAVING IN NSUSERDEFAULTS TO AVOID THE REPEATION OF REQUEST FOR SAME DATA
                                                UserDefaults.standard.set(trackName, forKey: "trackName")
                                                UserDefaults.standard.set(trackViewUrl, forKey: "trackViewUrl")
                                                
                                                let subjectDetail = NSLocalizedString("Hello,\n Let's Connect To The World. Discover new friends across the world and share the fun!\n", comment: "")
                                                
                                                if trackName != nil {
                                                    sharingItems.append(subjectDetail as AnyObject)
                                                }
                                                
                                                if let tempAppUrl = URL(string: trackViewUrl) {
                                                    //sharingItems.append(subjectDetail)
                                                    
                                                    sharingItems.append(tempAppUrl as AnyObject)
                                                }
                                                 DispatchQueue.main.async {
                                                self.backgroundIcon.frame.origin.y = self.appTitle.frame.origin.y + self.appTitle.bounds.height + contentPADING
                                                
                                                //SHOWING POPUP OF SHARING OPTIONS
                                                if sharingItems.count != 0{
                                                    
                                                    
                                                    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                                                    
                                                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                                                    activityViewController.setValue(trackSubject, forKey: "subject")
                                                    
                                                    if  (UIDevice.current.userInterfaceIdiom == .phone){
                                                        
                                                        if(activityViewController.popoverPresentationController != nil) {
                                                            activityViewController.popoverPresentationController?.sourceView = self.view;
                                                            let frame = UIScreen.main.bounds
                                                            activityViewController.popoverPresentationController?.sourceRect = frame;
                                                        }
                                                        
                                                    }
                                                    else
                                                    {
                                                        
                                                        let presentationController = activityViewController.popoverPresentationController
                                                        presentationController?.sourceView = self.view
                                                        presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                                                        presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                                                        
                                                    }
                                                    
                                                    self.present(activityViewController, animated: true, completion: { () -> Void in
                                                        
                                                    })
                                                    
                                                    activityViewController.completionWithItemsHandler = { activity, success, items, error in
                                                        _ = self.navigationController?.popToRootViewController(animated: false)
                                                        
                                                    }
                                                }
                                            }
                                            }
                                        }
                                    }
                                }else{
                                    
                                    //Initializes toaststyle as it is required in call of maketoast with closure
                                    let temptoaststyle = CSToastStyle(defaultStyle: ())
                                    
                                    self.view.makeToast("Your app is not yet registered in itunes!!", duration: 5, position: CSToastPositionCenter, title: "", image: nil, style: temptoaststyle, completion: { (Bool) -> Void in
                                        
                                        _ = self.navigationController?.popToRootViewController(animated: false)
                                        
                                    })
                                    
                                }
                                
                            }
                            
                        }catch{
                            //print("JSON serialization failed")
                        }
                        
                    }
                })
                
                task.resume()
                
            }
            
            if trackName != nil && trackViewUrl != "" {
                
                let subjectDetail = NSLocalizedString("Hello,\n Let's Connect To The World. Discover new friends across the world and share the fun!\n", comment: "")
                
                if trackName != nil {
                    sharingItems.append(subjectDetail as AnyObject)
                }
                
                if let tempAppUrl = URL(string: trackViewUrl) {
                    sharingItems.append(tempAppUrl as AnyObject)
                }
                
                if  trackName != nil {
                    trackSubject = String(format: NSLocalizedString("Hey, you're invited to join  %@", comment: ""), "\(trackName!)")
                }
                //trackSubject = NSLocalizedString("Hey, you're invited to join", comment: "")
                if sharingItems.count != 0{
                    
                    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    activityViewController.setValue(trackSubject, forKey: "subject")
                    if  (UIDevice.current.userInterfaceIdiom == .phone)
                    {
                        if(activityViewController.popoverPresentationController != nil)
                        {
                            activityViewController.popoverPresentationController?.sourceView = self.view;
                            let frame = UIScreen.main.bounds
                            activityViewController.popoverPresentationController?.sourceRect = frame;
                        }
                    }
                    else
                    {
                        let presentationController = activityViewController.popoverPresentationController
                        presentationController?.sourceView = self.view
                        presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                        presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                    }
                    
                    self.present(activityViewController, animated: true, completion: { () -> Void in
                        
                    })
                    
                    activityViewController.completionWithItemsHandler = { activity, success, items, error in
                        
                        _ = self.navigationController?.popToRootViewController(animated: false)
                        
                    }
                }
            }
        }
        }
        else
        {
          _ = self.navigationController?.popToRootViewController(animated: false)
        }
    }
   
    
    func goBack(){
        _ = self.navigationController?.popViewController(animated: false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
