/*
 * QRCodeReader.swift
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import AVFoundation
import UIKit
import QRCodeReader


class QRCode: UIViewController, QRCodeReaderViewControllerDelegate {
    
    var mainView = UIView()
    //Table
    var AdsTableView = UITableView()
    var pageNumber:Int = 1
    var limit: Int = 20
    var updateScrollFlag = true
    var isPageRefresing = false
    var showSpinner = true
    var header = UIView()
    
    var AdsDataArray = [AnyObject]()
    var totalItemCount : Int = 0
    var ads_key : String = "0"
    var ads_code : String = "0"
    var qr_key : String = ""
    var navtitle = UILabel()
    var pageTitle : String = ""
    var stopScanning : Bool = true
    var codeDesc : String = ""
    
    var contentIcon = UILabel()
    var info = UILabel()

    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsReportView : AdsReportViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "clickOnCancel")
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        mainView.isHidden = true
        view.addSubview(mainView)
        
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        removeNavigationViews(controller: self)
        
        //TableView
        AdsTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - (TOPPADING + tabBarHeight) ), style: .grouped)
        AdsTableView.register(CommunityAdsTableViewCell.self, forCellReuseIdentifier: "Cell")
        AdsTableView.dataSource = self
        AdsTableView.delegate = self
        AdsTableView.isOpaque = false
        AdsTableView.backgroundColor = UIColor.darkGray
        AdsTableView.separatorColor = UIColor.darkGray
        AdsTableView.tag = 101
        AdsTableView.isHidden = true
        self.view.addSubview(AdsTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.contentIcon.isHidden = true
        self.info.isHidden = true
        self.AdsTableView.removeFromSuperview()
        if isPaidMember == 0 {
            self.showAlert()
        }
        let defaults = UserDefaults.standard
        let clickOnCancel = defaults.bool(forKey: "clickOnCancel")
        if clickOnCancel == true
        {
            defaults.set(false, forKey: "clickOnCancel")
            if tabBarController != nil{
                baseController.selectedIndex = 0
            }
        }
        else if self.stopScanning == true
        {
            
            self.scanInModalAction()
        }
    }
    func showAlert() {
        // Declare Alert
        let dialogMessage = UIAlertController(title: NSLocalizedString("You are currently a free member",  comment: ""), message: NSLocalizedString("Do you want to update your membership?",  comment: ""), preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: NSLocalizedString("Update Membership",  comment: ""), style: .default, handler: { (action) -> Void in
            let presentedVC = SignupUserSubscriptionViewController()
            presentedVC.user_id = currentUserId
            presentedVC.isFromSettings = true
            self.navigationController?.pushViewController(presentedVC, animated: true)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel) { (action) -> Void in
            if self.tabBarController != nil{
                baseController.selectedIndex = 0
            }
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.stopScanning = true
        self.view.removeFromSuperview()
    }
    
//    @IBOutlet weak var previewView: QRCodeReaderView! {
//        didSet {
//            previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
//        }
//    }
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Actions
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        //            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        //              UIApplication.shared.openURL(settingsURL)
                        //            }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
   func scanInModalAction() {
        guard checkScanPermissions() else { return }
        
        readerVC = {
            let builder = QRCodeReaderViewControllerBuilder {
                $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
                $0.showTorchButton         = true
                $0.preferredStatusBarStyle = .lightContent
                
                $0.reader.stopScanningWhenCodeIsFound = false
            }
            
            return QRCodeReaderViewController(builder: builder)
        }()
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let result = result {
                print("Completion with result: \(result.value) of type \(result.metadataType)")
                self.qr_key = "\(result.value)"
                let string = "\(result.value)"
                if let range = string.range(of: "_")
                {
                    let firstPart = string[(range.upperBound)..<string.endIndex]
                    print(firstPart)
                    self.ads_key = String(firstPart)
                }
                
                if let range = string.range(of: "_")
                {
                    let firstPart = string[(string.startIndex)..<range.lowerBound]
                    print(firstPart)
                    self.ads_code = String(firstPart)
                }
                
                self.browseEntries()
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
    
//    @IBAction func scanInPreviewAction(_ sender: Any) {
//        guard checkScanPermissions(), !reader.isRunning else { return }
//
//        reader.didFindCode = { result in
//            print("Completion with result: \(result.value) of type \(result.metadataType)")
//        }
//
//        reader.startScanning()
//    }
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
         reader.stopScanning()
        self.stopScanning = false
        
        self.view.backgroundColor = bgColor
        self.view.removeFromSuperview()
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }

    //Get Contests response from Api
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            if (showSpinner){
                //   spinner.center = self.view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = self.view.center
                    updateScrollFlag = false
                }
                
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            let path = "communityads/page-ads"
            var parameters = [String:String]()
            
            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","qr_key":qr_key]
    
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if let body = succeeded["body"] as? NSDictionary{
                            if let subjectType = body["subjectType"] as? String, subjectType == "sitegroup_group"
                            {
                                if let subjectId = body["subjectId"] as? Int
                                {
                                    self.ads_key = "\(subjectId)"
                                }
                                if let title = body["title"] as? String
                                {
                                    self.pageTitle =  title
                                    self.navigationItem.title = NSLocalizedString("Thanks For Visiting", comment: "")+" ( "+"\(title)"+" )"
                                }
                                if let title = body["title"] as? String
                                {
                                    self.pageTitle =  title
                                }
                                self.dismiss(animated: true) { [weak self] in
                                    
                                    let alertController = UIAlertController(title: NSLocalizedString("Check-In on ", comment: "")+(self?.pageTitle)!, message: "", preferredStyle: .alert)
                                    
                                    let withdrawAction = UIAlertAction(title: "Done", style: .default) { (aciton) in
                                        
                                        let text = alertController.textFields!.first!.text!
                                        print(text)
                                        self?.codeDesc = text
                                        self?.doneGroup()
                                        
                                    }
                                    
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                        
                                        let presentedVC = AdvancedGroupDetailViewController()
                                        presentedVC.subjectId = "\(Int((self?.ads_key)!))" ?? "0"
                                        presentedVC.subjectType = "sitegroup_group"
                                        self?.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    
                                    alertController.addTextField { (textField) in
                                        textField.text = self?.ads_code
                                    }
                                    
                                    alertController.addAction(withdrawAction)
                                    alertController.addAction(cancelAction)
                                    
                                    self?.present(alertController, animated: true, completion: nil)
                                }
                            }
                            else {
                                if self.pageNumber == 1{
                                    //                                self.AdsTableView.removeFromSuperview()
                                    self.AdsDataArray.removeAll(keepingCapacity: false)
                                }
                                
                                if let response = body["advertisments"] as? NSArray
                                {
                                    self.AdsDataArray = self.AdsDataArray + (response as [AnyObject])
                                }
                                
                                if let getTotalItemCount = body["totalItemCount"] as? Int
                                {
                                    self.totalItemCount = getTotalItemCount
                                    //                                self.mainView.alpha = 0
                                    self.mainView.isHidden = true
                                    print(self.totalItemCount)
                                    
                                }
                                
                                if let page_name = body["page_name"] as? String
                                {
                                    self.pageTitle = page_name
                                    self.navigationItem.title = NSLocalizedString("Thanks For Visiting", comment: "")+" ( "+"\(page_name)"+" )"
                                    //                                self.navigationItem.title = "\(page_name)"
                                    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: fontBold, size: 14)!]
                                }
                                
                                self.isPageRefresing = false
                                self.showSpinner = false
                                self.updateScrollFlag = true
                                
                                var enter : Bool = false
                                
                                self.dismiss(animated: true) { [weak self] in
                                    
                                    enter = true
                                    if (self?.totalItemCount)! > 0
                                    {
                                        self?.AdsTableView.isHidden = false
                                        self?.view.addSubview((self?.AdsTableView)!)
                                    }
                                    self?.noMoreContent()
                                    let alertController = UIAlertController(title: NSLocalizedString("Check-In on ", comment: "")+(self?.pageTitle)!, message: "", preferredStyle: .alert)
                                    
                                    let withdrawAction = UIAlertAction(title: "Done", style: .default) { (aciton) in
                                        
                                        let text = alertController.textFields!.first!.text!
                                        print(text)
                                        self?.codeDesc = text
                                        self?.done()
                                        
                                    }
                                    
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                    }
                                    
                                    alertController.addTextField { (textField) in
                                        textField.text = self?.ads_code
                                    }
                                    
                                    alertController.addAction(withdrawAction)
                                    alertController.addAction(cancelAction)
                                    
                                    self?.present(alertController, animated: true, completion: nil)
                                }
                                
                                if enter == false
                                {
                                    self.noMoreContent()
                                }
                                
                                self.AdsTableView.tableFooterView?.isHidden = true
                                self.AdsTableView.reloadData()
                            }
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    func noMoreContent()
    {
        if self.totalItemCount == 0
        {
            self.AdsTableView.removeFromSuperview()
            self.view.backgroundColor = bgColor
            self.view.addSubview(self.mainView)
            self.mainView.isHidden = false
            self.mainView.backgroundColor = bgColor
            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\u{f06b}",  comment: "") , alignment: .center, textColor: navColor)
            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
            self.mainView.addSubview(self.contentIcon)
            
            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("Currently No Offer Available",  comment: "") , alignment: .center, textColor: navColor)
            self.info.sizeToFit()
            self.info.tag = 1000
            self.info.numberOfLines = 0
            self.info.center = self.view.center
            self.info.backgroundColor = bgColor
            self.mainView.addSubview(self.info)
            
            self.contentIcon.isHidden = false
            self.info.isHidden = false
        }
    }

    // MARK:  UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        header.isHidden = false
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                
                if (!isPageRefresing  && limit*pageNumber < totalItemCount){
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        AdsTableView.tableFooterView?.isHidden = false
                        browseEntries()
                    }
                }
                else
                {
                    AdsTableView.tableFooterView?.isHidden = true
                }
            }
        }
    }

    @objc func tappedOnAds(_ sender: UIButton){
        let dic = AdsDataArray[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_advancedvideo)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_advancedvideo)"
        let dic = AdsDataArray[sender.tag] as? NSDictionary
        if dic!["userad_id"] != nil{
            dictionary["adsId"] =  String(dic!["userad_id"] as! Int)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            if reachability.connection != .none {
                // Send Server Request for Comments
                post(dictionary, url: "communityads/index/remove-ad", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg
                        {
                            if succeeded["body"] != nil{
                                if let body = succeeded["body"] as? NSDictionary{
                                    if let form = body["form"] as? NSArray
                                    {
                                        let  key = form as! [NSDictionary]
                                        
                                        for dic in key
                                        {
                                            for(k,v) in dic{
                                                if k as! String == "multiOptions"{
                                                    self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
                                                    self.blackScreenForAdd.backgroundColor = UIColor.black
                                                    self.blackScreenForAdd.alpha = 0.0
                                                    self.parent?.view.addSubview(self.blackScreenForAdd)
                                                    self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
                                                    self.adsReportView.showMenu(dic: v as! NSDictionary,parameters : dictionary,view : self)
                                                    reportDic = v as! NSDictionary
                                                    self.parent?.view.addSubview(self.adsReportView)
                                                    
                                                    
                                                    UIView.animate(withDuration: 0.2) { () -> Void in
                                                        self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                                                        self.blackScreenForAdd.alpha = 0.5
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
                
            }
            else{
                // No Internet Connection Message
                self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            }
        }
        else {
            self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
            self.blackScreenForAdd.backgroundColor = UIColor.black
            self.blackScreenForAdd.alpha = 0.0
            self.parent?.view.addSubview(self.blackScreenForAdd)
            self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
            self.adsReportView.showMenu(dic: reportDic as NSDictionary,parameters : dictionary,view : self)
            self.parent?.view.addSubview(self.adsReportView)
            
            
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                self.blackScreenForAdd.alpha = 0.5
            }
        }
    }

    @objc func doneAfterReportSelect(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                ob.resignFirstResponder()
            }
            
        }
        UIView.animate(withDuration:0.5) { () -> Void in
            self.blackScreenForAdd.isHidden = true
            self.adsReportView.isHidden = true
            self.blackScreenForAdd.alpha = 0.0
        }
        
    }
    
    @objc func pressedAd(_ sender: UIButton){
        
        // parametersNeedToAdd = [:]
        
        for ob in adsReportView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag == 0 || ob.tag == 1 || ob.tag == 2 || ob.tag == 3 || ob.tag == 4{
                    (ob as! UIButton).setTitle("\u{f10c}", for: UIControl.State.normal)
                }
                if ob.tag == 1005
                {
                    (ob as! UIButton).alpha = 1.0
                    ob.isUserInteractionEnabled = true
                }
            }
        }
        
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"]!
        sender.setTitle("\u{f111}", for: UIControl.State.normal)
        if parametersNeedToAdd["adCancelReason"] != "Other"{
            
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = true
                }
                if ob.tag == 1000{
                    ob.isHidden = true
                }
                if ob.tag == 1005{
                    ob.isHidden = false
                }
            }
            // removeAd()
        }
        else{
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = false
                }
                if ob.tag == 1000{
                    ob.isHidden = false
                }
                if ob.tag == 1005{
                    ob.isHidden = true
                }
            }
        }
    }
    
    @objc func submitReasonPressed()
    {
        removeAd()
    }
    
    @objc func removeAd(){
        self.doneAfterReportSelect()
        self.view.makeToast(NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), duration: 5, position: "bottom")
        activityIndicatorView.startAnimating()
        if reachability.connection != .none {
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if (succeeded["body"] as? NSDictionary) != nil{
                                self.AdsDataArray.removeAll(keepingCapacity: false)
                                self.browseEntries()
                            }
                        }
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    @objc func removeOtherReason(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                let view = ob as? UITextField
                parametersNeedToAdd["adDescription"] = view?.text
            }
        }
        removeAd()
    }
    
    //Get Contests response from Api
    @objc func doneGroup(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            activityIndicatorView.center = self.view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            print("date = \(year):\(month):\(day)")
            
            let path = "sitetagcheckin/content-checkin"
            var parameters = [String:String]()
            
            parameters = ["subject_type":"sitegroup_group","subject_id":self.ads_key
                ,"qr_key":qr_key,"year":"\(year)","month":"\(month)","day":"\(day)","body":"\(String(describing: self.codeDesc))","rewrite":"1"]
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        print("true")
                        let presentedVC = AdvancedGroupDetailViewController()
                        presentedVC.subjectId = "\(Int(self.ads_key))" ?? "0"
                        presentedVC.subjectType = "sitegroup_group"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else
                    {
                        print("false")
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }

    
    //Get Contests response from Api
    @objc func done(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            
            activityIndicatorView.center = self.view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            print("date = \(year):\(month):\(day)")

            let path = "sitetagcheckin/content-checkin"
            var parameters = [String:String]()
            
            parameters = ["subject_type":"sitepage_page","subject_id":self.ads_key
                ,"qr_key":qr_key,"year":"\(year)","month":"\(month)","day":"\(day)","body":"\(String(describing: self.codeDesc))","rewrite":"1"]
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        print("true")
                    }
                    else
                    {
                        print("false")
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }

}

// TableView Delegates
extension QRCode: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard (UIDevice.current.userInterfaceIdiom != .pad) else {
            return 430
        }
        return 260
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let Header = UIView()
        var lblMessage = UILabel() // Table footer label
        
        lblMessage = createLabel(CGRect(x: 50, y: 5, width: view.bounds.width-100,height: 30), text: "Today we have the following news ", alignment: .center, textColor: textColorDark)
        Header.addSubview(lblMessage)
        
        Header.backgroundColor = .white
        return Header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
        var lblMessage = UILabel() // Table footer label

        lblMessage = createLabel(CGRect(x: 50, y: 5, width: view.bounds.width-100,height: 30), text: "No More Offers To View", alignment: .center, textColor: textColorDark)
        header.addSubview(lblMessage)

        header.backgroundColor = .white
        header.isHidden = true
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001 //40
    }
}

extension QRCode: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.AdsDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = AdsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommunityAdsTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        
        var adsData:NSDictionary!
        
        adsData = self.AdsDataArray[indexPath.row] as! NSDictionary
        
        if let title = adsData["cads_title"] as? String {
            cell.adTitleLabel.text = title
            cell.adTitleLabel.sizeToFit()
        }
        
        if adsData["image"] != nil{
            let icon = adsData["image"]
            let url = URL(string:icon as! String)
            cell.adImageView1.kf.indicatorType = .activity
            (cell.adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
            cell.adImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        cell.imageButton.tag = indexPath.row
        cell.imageButton.addTarget(self, action: #selector(QRCode.tappedOnAds(_:)), for: .touchUpInside)
        
        cell.adCallToActionButton.tag = indexPath.row
        cell.adCallToActionButton.addTarget(self, action: #selector(QRCode.actionAfterClick(_:)), for: .touchUpInside)
        
        var description = String(describing: adsData["cads_body"]!)
        description = description.html2String
        cell.adBodyLabel.text = description
        cell.adBodyLabel.sizeToFit()
        
        return cell
    }
}

