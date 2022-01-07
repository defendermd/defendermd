//
//  GroupSearchViewController.swift
//  seiosnativeapp
/*
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/ios-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 */


import UIKit
import NVActivityIndicatorView

class GroupSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate, TTTAttributedLabelDelegate {
    
    var searchBar = UISearchBar()
    var groupTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var groupResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
    //var imageCache = [String:UIImage]()
    var categ_id : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Groups",  comment: ""))
//        searchBar.delegate = self
//        searchBar.setTextColor(textColorPrime)

        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Groups",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(GroupSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(GroupSearchViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        groupTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        groupTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "Cell")
        groupTableView.rowHeight = 250.0
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.isOpaque = false
        groupTableView.backgroundColor = tableViewBgColor
        groupTableView.separatorColor = TVSeparatorColorClear
        view.addSubview(groupTableView)

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        groupTableView.tableFooterView = footerView
        groupTableView.tableFooterView?.isHidden = true
        
         tblAutoSearchSuggestions = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 420), style: UITableView.Style.plain)
        tblAutoSearchSuggestions.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tblAutoSearchSuggestions.dataSource = self
        tblAutoSearchSuggestions.delegate = self
        tblAutoSearchSuggestions.rowHeight = 50
        tblAutoSearchSuggestions.backgroundColor = tableViewBgColor
        tblAutoSearchSuggestions.separatorColor = TVSeparatorColor
        tblAutoSearchSuggestions.tag = 122
        tblAutoSearchSuggestions.isHidden = true
        view.addSubview(tblAutoSearchSuggestions)
        tblAutoSearchSuggestions.keyboardDismissMode = .onDrag
        
        if let arr = UserDefaults.standard.array(forKey: "arrRecentSearchOptions") as? [String]{
            arrRecentSearchOptions = arr
        }
        if arrRecentSearchOptions.count != 0
        {
            tblAutoSearchSuggestions.reloadData()
            tblAutoSearchSuggestions.isHidden = false
        }
        else
        {
            tblAutoSearchSuggestions.isHidden = true
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
      //  self.navigationItem.titleView = searchBar
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
        }
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    @objc func showGroup(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(view)
            return
        }
        var groupInfo:NSDictionary!
        groupInfo = groupResponse[sender.tag] as! NSDictionary
        
        if(groupInfo["allow_to_view"] as! Int == 1){
            if let name = groupInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
            let presentedVC = ContentFeedViewController()//GroupDetailViewController()
            presentedVC.subjectId = "\(groupInfo["group_id"]!)"
            presentedVC.subjectType = "group"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
            
            
        }
    }
    
    // Update Blog
    func browseEntries(){
        
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // info.removeFromSuperview()
            
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.groupResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true {
                    removeAlert()
                    self.groupTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
              //  spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                 //   activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyBlog
            path = "groups"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.groupTableView.isHidden = false
                    }
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        self.isPageRefresing = false
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSDictionary{
                                if let group = response["response"] as? NSArray {
                                    self.groupResponse = self.groupResponse + (group as [AnyObject])
                                }
                                if response["totalItemCount"] != nil{
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                            }
                        }
                        
                        //Reload Blog Tabel
                        self.groupTableView.reloadData()
                        
                        if self.groupResponse.count == 0{
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any group entries. Get started by writing a new entry.", comment: ""), alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message: "You do not have any group entries. Get started by writing a new entry.", controller: self)
                            self.searchBar.resignFirstResponder()
                            
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            self.searchBar.resignFirstResponder()
        }
        
    }
    
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if tableView.tag == 122{
            let labTitle = createLabel(CGRect( x: 14, y: 0,width: view.bounds.width, height: 40), text: NSLocalizedString("RECENT SEARCHES", comment: ""), alignment: .left, textColor: textColorDark)
            labTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            vw.addSubview(labTitle)
            return vw
        }
        else
        {
            return vw
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag == 122{
            return 40
        }
        else
        {
            return 0.00001
        }
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return 250.0
        }
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(groupResponse.count)/2))
        }else{
            return groupResponse.count
        }
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 122{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            let blogInfo = arrRecentSearchOptions[(indexPath as NSIndexPath).row]
            cell.imgSearch.isHidden = false
            cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
            // cell.labTitle.center.y = cell.bounds.midY + 5
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.text = blogInfo
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.numberOfLines = 2       
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = bgColor
        //cell.videoPlayLabel.isHidden = true
        var groupInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(groupResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                groupInfo = groupResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.menu.tag = ((indexPath as NSIndexPath).row)*2
            }
        }else{
            groupInfo = groupResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
            cell.menu.tag = (indexPath as NSIndexPath).row
        }
        
        //Select Group Action
        cell.contentSelection.addTarget(self, action: #selector(GroupSearchViewController.showGroup(_:)), for: .touchUpInside)
        // Set MenuAction
        cell.menu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        cell.menu.addTarget(self, action:Selector(("groupMenu:")) , for: .touchUpInside)

        
        
        // Set Group Image
        
        if let photoId = groupInfo["photo_id"] as? Int{
            
            if photoId != 0{
                cell.contentImage.image = nil
                cell.contentImage.backgroundColor = placeholderColor
                if let url = URL(string: groupInfo["image"] as! NSString as String){
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })

                }
                

            }
            else{
                cell.contentImage.image = nil
                cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                
            }
        }
        
        // Set Group Name
        let name = groupInfo["title"] as? String
        
        let tempString = name! as NSString
        
        var value : String
        
        if tempString.length > 30{
            
            value = tempString.substring(to: 27)
            value += NSLocalizedString("...",  comment: "")
        }else{
            value = "\(tempString)"
        }
        
        
        
        
        let owner = groupInfo["owner_title"] as? String
        let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
        
        let members = groupInfo["member_count"] as? Int
        let fontIcon1 = "\u{f007}"
        
        let a = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!) as String
        cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 75, width: (cell.contentImage.bounds.width-20), height: 20)
        cell.contentName.text = " \(value)"
        cell.contentName.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        
        cell.totalMembers.frame = CGRect(x: 10, y: cell.contentImage.bounds.height - 40, width: (cell.contentImage.bounds.width-100), height: 20)
        cell.totalMembers.text = "\(fontIcon1)  \(text)"
        cell.totalMembers.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.totalMembers.layer.shadowOpacity = 0.0
        
        // cell.eventTime.frame.origin.x = findWidthByText("\(cell.totalMembers.text!)") + 5
        
        
        cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 100, y: cell.contentImage.bounds.height - 40, width: 100, height: 20)
        cell.eventTime.text = "\(fontIcon1)  \(a)"
        cell.eventTime.textAlignment = NSTextAlignment.left
        cell.eventTime.textColor = textColorLight
        cell.eventTime.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        
        
        
        // Set Menu
        cell.menu.isHidden = true
        cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)

        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            var groupInfo2:NSDictionary!
            if(groupResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                groupInfo2 = groupResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                cell.menu2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                return cell
            }
            
            // Select Group Action
            cell.contentSelection2.addTarget(self, action: #selector(GroupSearchViewController.showGroup(_:)), for: .touchUpInside)
            // Set MenuAction

            cell.menu2.addTarget(self, action:Selector(("groupMenu:")) , for: .touchUpInside)
            // cell.videoPlayLabel2.isHidden = true

            // Set Group Image
            
            
            if let photoId = groupInfo2["photo_id"] as? Int{
                
                if photoId != 0{
                    cell.contentImage2.image = nil

                    cell.contentImage2.backgroundColor = placeholderColor
                    
                    if let url = URL(string: groupInfo["image"] as! NSString as String){
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    
                }else{
                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    
                }
            }
            
            // Set Group Name
            let name = groupInfo2["title"] as? String
            
            cell.contentName2.frame = CGRect(x: 10, y: 110, width: (cell.contentImage2.bounds.width-20), height: 100)
            cell.contentName2.text = "\(name!)"
            cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.contentName2.sizeToFit()
            cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
            
            // Set Total Group Members
            let members = groupInfo2["member_count"] as? Int
            cell.totalMembers2.text = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
            
            
            // Set Group Owner
            cell.createdBy2.frame.origin.x = findWidthByText("\(cell.totalMembers2.text!)") + 30
            let owner = groupInfo2["owner_title"] as? String
            let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
            cell.createdBy2.delegate = self

            cell.createdBy2.setText(text, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                
                let range = (text as NSString).range(of: owner!)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)

                
                return mutableAttributedString
            })
            let range = (text as NSString).range(of: owner!)
            cell.createdBy2.addLink(toTransitInformation: ["type" : "user"], with:range)
            
            // Set Menu

            cell.menu2.isHidden = true
            cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 10)

        }
        return cell
        }
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 122{
            searchBar.text = arrRecentSearchOptions[(indexPath as NSIndexPath).row]
            arrRecentSearchOptions.remove(at: (indexPath as NSIndexPath).row)
            arrRecentSearchOptions.insert(searchBar.text!, at: 0)
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
            if searchBar.text?.range(of: "#") != nil
            {
                let hashTagString = searchBar.text!
                let singleString : String!
                
                searchDic.removeAll(keepingCapacity: false)
                
                if hashTagString.range(of: "#") != nil{
                    let original = hashTagString
                    singleString = String(original.dropFirst())
                    
                }
                else{
                    singleString = hashTagString
                }
                updateAutoSearchArray(str: hashTagString)
                searchBar.resignFirstResponder()
                searchDic.removeAll(keepingCapacity: false)
                self.groupTableView.isHidden = true
                //self.converstationTableView.isHidden = true
                
                let presentedVC = HashTagFeedViewController()
                presentedVC.completionHandler = { 
                    
                    self.searchBar.text = nil
                    self.searchBar.becomeFirstResponder()
                    self.tblAutoSearchSuggestions.reloadData()
                    
                }
                presentedVC.hashtagString = singleString
                navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            else{
                tblAutoSearchSuggestions.isHidden = true
                searchBar.resignFirstResponder()
                searchQueryInAutoSearch()
            }
            
        }
        else
        {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    // MARK:  UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if tblAutoSearchSuggestions.isHidden == true
        {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        groupTableView.tableFooterView?.isHidden = false
                        // if searchDic.count == 0{
                     
                        browseEntries()
                        //}
                    }
                }
                else
                {
                    groupTableView.tableFooterView?.isHidden = true
                }
            }
            }
        }
        
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)

    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        //print(components)
//        let type = components["type"] as! String
//        
//        switch(type){
//            
//        case "user":
//            //print("user")
//        default:
//            //print("default")
//        }
        
        
    }
    
    @objc func cancel(){
        groupUpdate = false
        _ = self.navigationController?.popViewController(animated: false)

        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search_text"] = searchBar.text
        if categ_id != nil{
            searchDic["category_id"] = "\(categ_id)"
        }
        showSpinner = true
        pageNumber = 1
        searchBar.resignFirstResponder()
        browseEntries()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
  

        if searchBar.text?.length != 0
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
        }
        else
        {
            activityIndicatorView.stopAnimating()
            if arrRecentSearchOptions.count != 0
            {
                tblAutoSearchSuggestions.reloadData()
                tblAutoSearchSuggestions.isHidden = false
                self.groupTableView.isHidden = true
            }
            else
            {
                tblAutoSearchSuggestions.isHidden = true
            }
        }
        
    }
    @objc func reload(_ searchBar: UISearchBar) {
        if searchBar.text?.length != 0
        {
        tblAutoSearchSuggestions.isHidden = true
        searchQueryInAutoSearch()
        }
    }
    func updateAutoSearchArray(str : String) {
        if !arrRecentSearchOptions.contains(str)
        {
            arrRecentSearchOptions.insert(str, at: 0)
            if arrRecentSearchOptions.count > 6 {
                arrRecentSearchOptions.remove(at: 6)
            }
            tblAutoSearchSuggestions.reloadData()
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
        }
    }
    func searchQueryInAutoSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search_text"] = searchBar.text
        if categ_id != nil{
            searchDic["category_id"] = "\(categ_id)"
        }
        showSpinner = true
        pageNumber = 1
     //   searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func filter(){
        if filterSearchFormArray.count > 0{
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            
            
            // presentedVC.searchUrl = "classifieds/browse-search-form"
            presentedVC.serachFor = "group"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "groups/search-form"
            presentedVC.serachFor = "group"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        if searchDic.count > 0 {
            if globFilterValue != ""{
               // searchBar.text = globFilterValue
                searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        groupTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
        if (self.isMovingFromParent){
            if fromGlobSearch{
                conditionalForm = ""
                loadFilter("search")
                globSearchString = searchBar.text!
                backToGlobalSearch(self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
}
