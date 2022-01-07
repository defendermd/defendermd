//
//  JoinEventViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 30/05/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class JoinEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var privacyTableView:UITableView!              // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 40              // Dynamic Height fort for Cell
    var showOnlyMyContent = false
    var delete:Bool! = false
    var count1 : Int!
    var settingArray : NSArray!
    var keysResponse = [AnyObject]()
    var valuesResponse = [AnyObject]()
    var joinEventOptions = [Any]()
    var url : String!
    var leftBarButtonItem : UIBarButtonItem!
    // Flag to refresh Blog
    // Initialization of class Object
    override func viewDidLoad() {
    
    super.viewDidLoad()
    searchDic.removeAll(keepingCapacity: false)
    view.backgroundColor = bgColor
    navigationController?.navigationBar.isHidden = false
    openMenu = false
    updateAfterAlert = true
    
    let subViews = mainView.subviews
    for subview in subViews{
    subview.removeFromSuperview()
    }
    
    let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(JoinEventViewController.cancel))
    self.navigationItem.leftBarButtonItem = cancel
    navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControl.State())
        cancel.tintColor = textColorPrime
    
    mainView.frame = view.frame
    mainView.backgroundColor = bgColor
    view.addSubview(mainView)
    mainView.removeGestureRecognizer(tapGesture)
    
    // makeSettingsArray()
    self.title = NSLocalizedString("Join Event",  comment: "")
        
    joinEventOptions = [["Attending":2], ["Maybe Attending":1], ["Not Attending":0]]
    
    // Initialize Blog Table
    privacyTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - TOPPADING), style: .grouped)
    privacyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    privacyTableView.dataSource = self
    privacyTableView.delegate = self
    privacyTableView.estimatedRowHeight = 40.0
    privacyTableView.rowHeight = UITableView.automaticDimension
    privacyTableView.backgroundColor = tableViewBgColor
    privacyTableView.separatorColor = TVSeparatorColor
    mainView.addSubview(privacyTableView)
 
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    if openMenu{
    openMenu = false
    openMenuSlideOnView(mainView)
    }
    
    }
 
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
    openMenu = false
    openMenuSlideOnView(mainView)
    mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
    self.view .addSubview(validationMsg)
    showCustomAlert(centerPoint, msg: msg)
    if timer {
    // Initialization of Timer
   self.createTimer(self)
    }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
    stop()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Settings Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if (limit*pageNumber < totalItems){
    return 80
    
    }else{
    return 0.00001
    }
    }
    
    // Set Settings Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if  (UIDevice.current.userInterfaceIdiom == .phone){
    dynamicHeight = 50.0
    }else{
    dynamicHeight = 70.0
    }
    return dynamicHeight
    }
    
    // Set Settings Section
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return self.joinEventOptions.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    {
    let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle , reuseIdentifier: "Cell")
        
    let joinEventInfo:NSDictionary
    joinEventInfo = joinEventOptions[(indexPath as NSIndexPath).row] as! NSDictionary
    cell.accessoryView = nil
    
    let FontIconLabelString = "\u{f10c}"
        for (key,_) in joinEventInfo {
            let labelString =  key as! String
            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(FontIconLabelString)  ")
            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: 15.0)!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedString.Key.foregroundColor , value: navColor, range: NSMakeRange(0, attrString.length))
            
            let descString: NSMutableAttributedString = NSMutableAttributedString(string: labelString)
            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: 16.0)!, range: NSMakeRange(0, descString.length))
            
            attrString.append(descString);
            cell.textLabel?.attributedText = attrString
        }
    return cell
    
    }
    // Handle Settings Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let joinEventInfo:NSDictionary
        joinEventInfo = joinEventOptions[(indexPath as NSIndexPath).row] as! NSDictionary
        for (_,value) in joinEventInfo {

            self.updateContentAction(value as! Int)
        }
    }
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    @objc func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func updateContentAction(_ id:Int){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var dic = Dictionary<String, String>()
            dic["rsvp"] = "\(id)"
            
            let method = "POST"
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url!)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        self.cancel()
                        contentFeedUpdate = true
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
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
