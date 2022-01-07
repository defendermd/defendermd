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


import GoogleMaps
import UIKit
import NVActivityIndicatorView
//import MapKit

class MemberSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , GMUClusterManagerDelegate, GMSMapViewDelegate, MapMarkerDelegate, GMUClusterRendererDelegate ,UISearchBarDelegate{
    
    var searchBar = UISearchBar()
    // Variables for Likes
    var allMembers:[Members] = []
    var allMapMembers:[Members] = []
    var membersTableView:UITableView!
    var matrixMemberTable: UICollectionView!
    var pageNumber:Int = 1
    var mapPageNumber:Int = 1
    var totalItems:Int = 0
    
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 100              // Dynamic Height fort for Cell
    var contentType:String! = ""
    var contentId:Int!
    var memberCount : Int!
    var updateScrollFlag = true
    var indexChange : Int!
    var showSpinner = true
    var navLeftIcon = false
    var leftBarButtonItem : UIBarButtonItem!
    var fromTab : Bool! = false
    var matrixfooterView = UICollectionReusableView()
    var buttonView : UIView!
    var listbutton : UIButton!
    var mapButton : UIButton!
    var showType = "list"
    var mapView = GMSMapView()
    var clusterManager: GMUClusterManager!
    var userdata :[AnyObject] = []
    var phones = [String]()
    var imageConvert = [UIImage]()
    var nextButton = UIButton()
    var checkNext : Bool = true
    var totalMemberCount : Int = 0
    var mapTotalMemberCount : Int = 0
    var titleLabelField = UILabel()
    var mapormember : Int = 1 // 1 for listView
    var j = 0
    let matrixFooterId = "footerId"
    var deleteButton1 : UIButton!
    var customLimit : Int = 20
    var urlString: String!
    var param: NSDictionary!
    var kCameraLatitude : Double = 0.0
    var kCameraLongitude : Double = 0.0
    let defaults = UserDefaults.standard
    var viewType : String = "0"
    var firstTime : Bool = true
    
    var profileOfUserId : Int = 0
    
    private var infoWindow = MapMarkerWindowView()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    //Search page
    
    var isComingFromMemberController = false
    var tblAutoSearchSuggestions : UITableView!
    
    override func viewDidLoad() {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Members",  comment: ""))
        searchBar.delegate = self
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MemberSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MemberSearchViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        self.infoWindow = loadNiB()
        
        // Initialize Member Table
        membersTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING ,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        membersTableView.register(MemberListViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.dataSource = self
        membersTableView.delegate = self
        membersTableView.estimatedRowHeight = 90.0
        membersTableView.rowHeight = UITableView.automaticDimension
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        let frame = CGRect(x: 2.5, y: TOPPADING , width: view.bounds.width-5, height: view.bounds.height-(TOPPADING)  - tabBarHeight)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        matrixMemberTable = UICollectionView(frame: frame, collectionViewLayout: layout)
        matrixMemberTable.register(MemberMatrixViewCell.self, forCellWithReuseIdentifier: "cell")
        matrixMemberTable.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: matrixFooterId)
        self.setUpGridView()
        matrixMemberTable.dataSource = self
        matrixMemberTable.delegate = self
        matrixMemberTable.bounces = false
        matrixMemberTable.backgroundColor = UIColor(white: 0.8, alpha: 1)
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.membersTableView.estimatedSectionHeaderHeight = 0
            membersTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        membersTableView.tableFooterView = footerView
        membersTableView.tableFooterView?.isHidden = true
        
        if contentType == "members"{
            membersTableView.frame.origin.y = TOPPADING + 40
            membersTableView.frame.size.height = view.bounds.height-(TOPPADING)  - tabBarHeight - 40
            matrixMemberTable.frame.origin.y = TOPPADING + 40
            matrixMemberTable.frame.size.height = view.bounds.height-(TOPPADING)  - tabBarHeight - 40
            membersTableView.isHidden = true
            matrixMemberTable.isHidden = true
        }
        
        buttonView = UIView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: 40))
        buttonView.backgroundColor = UIColor.clear
        view.addSubview(buttonView)
        
        
        listbutton = createButton(CGRect(x: view.bounds.width - 80, y: 0, width: 40, height: 40), title: listingDefaultIcon, border: false, bgColor: false, textColor: textColorDark)
        listbutton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        listbutton.isHidden = true
        listbutton.addTarget(self, action: #selector(MemberSearchViewController.listView), for: .touchUpInside)
        //        buttonView.addSubview(listbutton)
        
        mapButton = createButton(CGRect(x: view.bounds.width - 40, y: 0, width: 40, height: 40), title: locationIcon, border: false, bgColor: false, textColor: textColorDark)
        mapButton.isHidden = true
        mapButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        mapButton.addTarget(self, action: #selector(MemberSearchViewController.mapViewPage), for: .touchUpInside)
        //        buttonView.addSubview(mapButton)
        
        titleLabelField = createLabel(CGRect(x: 10,y: 10,width: view.bounds.width - 80,height: 20), text: "", alignment: .left, textColor: textColorDark)
        titleLabelField.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
        titleLabelField.isHidden = true
        buttonView.addSubview(titleLabelField)
        
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
        view.addSubview(membersTableView)
        view.addSubview(matrixMemberTable)
        
        if self.contentType == "members"{
            
            if mapormember == 1{
                self.listView()
            }
            else if mapormember == 0{
                self.mapViewPage()
            }
            else {
                self.matrixView()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        membersTableView.tableFooterView?.isHidden = true
        searchDic.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            
            if viewType == "0" || viewType == "2"
            {
                pageNumber = 1
                showSpinner = true
                allMembers.removeAll(keepingCapacity: false)
            }
            else
            {
                self.kCameraLatitude = 0.0
                self.kCameraLongitude = 0.0
                mapPageNumber = 1
                showSpinner = true
                allMapMembers.removeAll(keepingCapacity: false)
            }
            findAllMembers()
            filterSearchFormArray.removeAll(keepingCapacity: false)
        }
    }
    
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "members"
            presentedVC.url = "members/search-form"
            presentedVC.contentType = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "members/search-form"
            presentedVC.serachFor = "members"
            presentedVC.url = "members/search-form"
            presentedVC.contentType = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(view)
        view.removeGestureRecognizer(tapGesture)
    }
    
    @objc func sendMessage(_ sender:AnyObject)
    {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.matrixMemberTable)
        let indexPath = self.matrixMemberTable.indexPathForItem(at: buttonPosition)
        let memberInfo = allMembers[(indexPath?.row)!]
        let presentedVC = MessageCreateController()
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        presentedVC.userID = "\(memberInfo.user_id!)"
        presentedVC.fromProfile = true
        presentedVC.profileName = memberInfo.displayname
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func matrixView() {
        infoWindow.removeFromSuperview()
        self.titleLabelField.text = "\(self.totalMemberCount) members found"
        viewType = "2"
        matrixMemberTable.isHidden = false
        mapView.isHidden = true
        membersTableView.isHidden = true
        nextButton.isHidden = true
    }
    
    // Action , when we ckick on list icon
    @objc func listView(){
        infoWindow.removeFromSuperview()
        self.titleLabelField.text = "\(self.totalMemberCount) members found"
        viewType = "0"
        membersTableView.isHidden = false
        matrixMemberTable.isHidden = true
        mapView.isHidden = true
        nextButton.isHidden = true
        mapButton.setTitleColor(textColorDark, for: .normal)
        listbutton.setTitleColor(navColor, for: .normal)
    }
    // Action , when we ckick on map icon
    @objc func mapViewPage(){
        
        self.titleLabelField.text = "\(self.mapTotalMemberCount) members found"
        viewType = "1"
        if firstTime == true {
            googleMap()
            showSpinner = true
            firstTime = false
        }
        matrixMemberTable.isHidden = true
        membersTableView.isHidden = true
        mapView.isHidden = false
        nextButton.isHidden = false
        mapButton.setTitleColor(navColor, for: .normal)
        listbutton.setTitleColor(textColorDark, for: .normal)
    }
    
    // We frame the map
    func googleMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        //        mapView.mapType =  .terrain
        view.addSubview(mapView)
        mapView.delegate = self
        
        nextButton = createButton(CGRect(x: view.bounds.width/2 - 35, y: view.bounds.height  - tabBarHeight - 40, width: 100, height: 30), title: "View More", border: false, bgColor: true, textColor: UIColor.white)
        nextButton.backgroundColor = textColorDark.withAlphaComponent(0.9)
        nextButton.addTarget(self, action: #selector(MemberSearchViewController.nextMember), for: .touchUpInside)
        nextButton.alpha = 0.7
        nextButton.isHidden = true
        view.addSubview(nextButton)
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    func loadNiB() -> MapMarkerWindowView {
        let infoWindow = MapMarkerWindowView.instanceFromNib() as! MapMarkerWindowView
        var pad = 9
        if DeviceType.IS_IPHONE_X
        {
            pad = 3
        }
        var frame = infoWindow.frame
        frame.size.width = self.view.frame.size.width
        frame.origin.y = self.view.frame.size.height - frame.size.height - tabBarHeight - CGFloat(pad)
        infoWindow.frame = frame
        
        // infoWindow.btnProfileImage.layer.masksToBounds = false
        //infoWindow.btnProfileImage.clipsToBounds = true
        // infoWindow.btnProfileImage.layer.cornerRadius = infoWindow.btnProfileImage.frame.width/2
        
        
        return infoWindow
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    // In this we pass the data for infowindow
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        searchBar.resignFirstResponder()
        if let poiItem = marker.userData as? POIItem {
            var markerData : Members!
            if let data = poiItem.userData{
                markerData = data
            }
            
            locationMarker = marker
            infoWindow.removeFromSuperview()
            infoWindow = loadNiB()
            //            guard let location = locationMarker?.position else {
            //                print("locationMarker is nil")
            //                return false
            //            }
            // Pass the spot data to the info window, and set its delegate to self
            infoWindow.spotData = markerData
            infoWindow.delegate = self
            // Configure UI properties of info window
            //infoWindow.alpha = 0.9
            //infoWindow.layer.cornerRadius = 12
            //infoWindow.layer.borderWidth = 2
            
            var imgFriendType = UIImageView()
            imgFriendType = UIImageView(frame: CGRect(x:infoWindow.lblView.frame.size.width/2-2,y:-5,width:20,height:20))
            imgFriendType.image = UIImage(named: "addFriend")!.maskWithColor(color: textColorPrime)
            infoWindow.lblFollowCount.addSubview(imgFriendType)
            
            if let stringUrl = markerData.image_normal{
                let url = URL(string: stringUrl)
                infoWindow.btnProfileImage.kf.setImage(with: url, for: .normal, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    self.infoWindow.btnProfileImage.clipsToBounds = true
                })
            }
            
            if let dic = markerData.mapData
            {
                infoWindow.lblView.text = dic["rv_text"] as? String
                if let viewCount = dic["rv_count"] as? Int {
                    infoWindow.lblViewCount.text = String(describing: viewCount)
                }
                
                //                infoWindow.lblFollow.text = dic["af_text"] as? String
                //                if let followCount = dic["af_count"] as? Int {
                //                    infoWindow.lblFollowCount.text = String(describing: followCount)
                //                }
                
                infoWindow.lblFriend.text = dic["ff_text"] as? String
                if let friendCount = dic["ff_count"] as? Int {
                    infoWindow.lblFriendCount.text = String(describing: friendCount)
                }
                
            }
            
            if let user_id = markerData.user_id
            {
                self.profileOfUserId = user_id
            }
            
            if let dic = markerData.menus
            {
                
                if let lblFollow = dic["label"] as? String {
                    infoWindow.lblFollow.text = lblFollow
                }
                
                let condition = dic["name"] as! String
                
                if   self.profileOfUserId != currentUserId {
                    
                    if condition == "add_friend" || condition ==  "member_follow"
                    {
                        imgFriendType.image = UIImage(named : "addFriend")!.maskWithColor(color: textColorPrime)
                    }
                    else  if  condition == "cancel_request" ||   condition == "cancel_follow"
                    {
                        imgFriendType.image = UIImage(named : "cancelFriendRequest")!.maskWithColor(color: textColorPrime)
                    }
                    else if  condition == "remove_friend" ||  condition == "member_unfollow"
                    {
                        imgFriendType.image = UIImage(named : "removeFriend")!.maskWithColor(color: textColorPrime)
                    }
                    else if  condition == "accept_request"
                    {
                        imgFriendType.image = UIImage(named : "cancelFriendRequest")!.maskWithColor(color: textColorPrime)
                    }
                    else  if condition == "user_profile_send_message"{
                        
                        if isChannelizeAvailable{
                            imgFriendType.image = UIImage(named:"channelize_icon")?.maskWithColor(color: textColorLight)
                        } else{
                            imgFriendType.image = UIImage(named:"messageIcon")?.maskWithColor(color: textColorLight)
                        }
                    }
                }
            }
            
            let address = markerData.location ?? "Country"
            let title = markerData.displayname ?? "Unknown"
            
            infoWindow.lblAddress.text = address
            infoWindow.lblTitle.text = title
            
            // Offset the info window to be directly above the tapped marker
            //infoWindow.center = mapView.projection.point(for: location)
            //infoWindow.center.y = infoWindow.center.y - 15
            
            self.view.addSubview(infoWindow)
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //        if (locationMarker != nil)
        //        {
        //            guard let location = locationMarker?.position else {
        //                print("locationMarker is nil")
        //                return
        //            }
        //            //infoWindow.center = mapView.projection.point(for: location)
        //            //infoWindow.center.y = infoWindow.center.y - 15
        //        }
    }
    
    // redirection
    func redirection(condition : String, dic : NSDictionary, userId : Int){
        let menuItem = dic
        let nameString1 = condition
        switch(condition){
        case "accept_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "add_friend":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "cancel_request":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "remove_friend" :
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to  remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "follow":
            
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to follow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "following":
            
            var message = ""
            let title = "Unfollow"//dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to unfollow this member?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
        case "member_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to add this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        case "member_unfollow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want  to remove this member as your friend?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                //                self.updateUser(dic["urlParams"] as! NSDictionary,url:dic["url"] as! String)
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        case "cancel_follow":
            var message = ""
            let title = dic["label"] as! String
            message = String(format: NSLocalizedString("Do you want to cancel friend request?", comment: ""), title)
            displayAlertWithOtherButton(title, message: message, otherButton: title) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : userId, menuType : nameString1)
            }
            self.present(alert, animated: true, completion: nil)
            
        default:
            showToast(message: unconditionalMessage, controller: self)
            
            
        }
        
    }
    // Finish :- code of showing add friend, more menus and message
    
    // We remove the infowindow , when user click anywhere on the map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // We modify the google marker from user image
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let poiItem = marker.userData as? POIItem {
            var markerData : Members!
            if let data = poiItem.userData{
                markerData = data
            }
            let imageView = UIImageView()
            imageView.frame.size.width = 40
            imageView.frame.size.height = 40
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            
            if let stringUrl = markerData.image_normal{
                let url = URL(string: stringUrl)
                imageView.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                marker.iconView = imageView
            }
        }
    }
    
    // MARK: - MapView Delegate
    func didTapInfoButton(data: Members) {
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(data.user_id!)"//sender.tag
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // Redirect user location into google map or browser
    func didTapRedirectLocButton(data: Members) {
        let lat = data.latitude
        let lang = data.longitude
        let newString = data.location
        let loc = newString?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        print("https://maps.google.com/maps?f=d&daddr=\(String(describing: loc!))=&sll=\(lat),\(lang)")
        
        if let url = URL(string: "https://maps.google.com/maps?f=d&daddr=\(String(describing: loc!))=&sll=\(lat),\(lang)"){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    // Redirect user location into google map or browser
    func didTapRedirectFriendType(data: Members) {
        print(data)
        if let menu = data.menus
        {
            self.redirection(condition : menu["name"] as? String ?? "", dic : menu,userId :data.user_id)
        }
    }
    
    @objc func nextMember(){
        nextButton.isHidden = false
        if self.allMapMembers.count < self.mapTotalMemberCount {
            mapPageNumber  = mapPageNumber + 1
            self.nextButton.isEnabled = false
            findAllMembers()
        }
        else{
            showToast(message: "No More Members", controller: self)
        }
    }
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(view)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            membersUpdate1 = false
            filterSearchFormArray.removeAll(keepingCapacity: false)
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showMemberContent")
        {
            if  UserDefaults.standard.object(forKey: "showMemberContent") != nil {
                
                contentType = name as! String
                
            }
            UserDefaults.standard.removeObject(forKey: "showMemberContent")
        }
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
    
    // MARK: - Server Connection For All Likes
    @objc func menuAction(_ sender:UIButton){
        // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
        
        if viewType == "0" || viewType == "2"
        {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                sender.transform = .identity
            }, completion: { _ in
                if (sender.tag > -1){
                    let memberInfo = self.allMembers[sender.tag]
                    if let menuItem = memberInfo.menus{
                        let nameString1 = menuItem["name"]as! String
                        self.indexChange = sender.tag
                        self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                        
                    }
                }
            }
                
                
            )
            
        }
        else {
            if (sender.tag > -1){
                let memberInfo = self.allMembers[sender.tag]
                if let menuItem = memberInfo.menus{
                    let nameString1 = menuItem["name"]as! String
                    self.indexChange = sender.tag
                    self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                    
                }
            }
        }
        
        
    }
    
    func updateMembers(_ parameter: NSDictionary , url : String , user_id : Int,menuType : String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var temp = allMembers
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            if self.viewType == "0" || self.viewType == "2"
            {
                
                for (index,value) in self.allMembers.enumerated(){
                    if url == "delete"{
                        feedUpdate = true
                        if value.user_id == user_id{
                            self.allMembers.remove(at: index)
                            self.userdata.remove(at: index)
                            // Set Updated Label Info
                            var finalText = ""
                            finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                            total_Comments = total_Comments - 1
                            finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                            
                        }
                    }else{
                        
                        
                        if value.user_id == user_id{
                            
                            let tempOldMenuDictionary :NSMutableDictionary = [:]
                            //                                    let type = menuType
                            switch(menuType){
                            case "add_friend":
                                
                                if   value.isVerified != nil && value.isVerified == 1{
                                    tempOldMenuDictionary["label"] = "Cancel Request"
                                    tempOldMenuDictionary["url"] = "user/cancel"
                                    tempOldMenuDictionary["name"] = "cancel_request"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                    
                                }
                                else{
                                    tempOldMenuDictionary["label"] = "Remove Friend"
                                    tempOldMenuDictionary["url"] = "user/remove"
                                    tempOldMenuDictionary["name"] = "remove_friend"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                }
                                
                            case "cancel_request":
                                
                                tempOldMenuDictionary["label"] = "Add Friend"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "add_friend"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                            case "remove_friend":
                                
                                tempOldMenuDictionary["label"] = "Add Friend"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "add_friend"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                                
                            case "member_follow":
                                if  value.isVerified != nil && value.isVerified == 1 {
                                    tempOldMenuDictionary["label"] = "Cancel Follow Request"
                                    tempOldMenuDictionary["url"] = "user/cancel"
                                    tempOldMenuDictionary["name"] = "cancel_follow"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                    
                                }
                                else{
                                    tempOldMenuDictionary["label"] = "Unfollow"
                                    tempOldMenuDictionary["url"] = "user/remove"
                                    tempOldMenuDictionary["name"] = "member_unfollow"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                }
                                
                            case "member_unfollow":
                                tempOldMenuDictionary["label"] = "Follow"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "member_follow"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                                
                            case "cancel_follow":
                                tempOldMenuDictionary["label"] = "Follow"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "member_follow"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                            default:
                                print("default")
                            }
                            
                            
                            let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                            newDictionary["image_profile"] = value.image_profile
                            newDictionary["displayname"] = value.displayname
                            newDictionary["user_id"] = value.user_id
                            newDictionary["isVerified"] = value.isVerified
                            newDictionary["location"] = value.location
                            newDictionary["latitude"] = value.latitude
                            newDictionary["longitude"] = value.longitude
                            newDictionary["mutualFriendCount"] = value.mutualFriendCount
                            newDictionary["image_normal"] = value.image_normal
                            newDictionary["mutualFriendCount"] = value.mutualFriendCount
                            newDictionary["menus"] = tempOldMenuDictionary
                            
                            var newData = Members.loadCommentsfromDictionary(newDictionary)
                            
                            self.allMembers[index] = newData[0] as Members
                            self.membersTableView.reloadData()
                            self.matrixMemberTable.reloadData()
                        }
                    }
                }
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if url.range(of: "remove") != nil{
                            showToast(message: NSLocalizedString("This person has been removed from your friends.", comment: ""), controller: self)
                            
                        }else if url.range(of: "add") != nil {
                            showToast(message: NSLocalizedString("Your friend request has been sent", comment: ""), controller: self)
                            
                        }else if url.range(of: "cancel") != nil{
                            showToast(message: NSLocalizedString("Your friend request has been canceled.", comment: ""), controller: self)
                            
                        }else{
                            
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                self.allMembers = temp
                                self.membersTableView.reloadData()
                                self.matrixMemberTable.reloadData()
                            }
                        }
                        
                        if self.viewType == "1"
                        {
                            self.mapView.removeFromSuperview()
                            self.googleMap()
                            for (index,value) in self.allMapMembers.enumerated(){
                                if url == "delete"{
                                    feedUpdate = true
                                    if value.user_id == user_id{
                                        self.allMapMembers.remove(at: index)
                                        self.userdata.remove(at: index)
                                        // Set Updated Label Info
                                        var finalText = ""
                                        finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                                        total_Comments = total_Comments - 1
                                        finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                                        
                                    }
                                }else{
                                    
                                    if value.user_id == user_id{
                                        
                                        let tempOldMenuDictionary :NSMutableDictionary = [:]
                                        //                                    let type = menuType
                                        switch(menuType){
                                        case "add_friend":
                                            
                                            if   value.isVerified != nil && value.isVerified == 1{
                                                tempOldMenuDictionary["label"] = "Cancel Request"
                                                tempOldMenuDictionary["url"] = "user/cancel"
                                                tempOldMenuDictionary["name"] = "cancel_request"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                                
                                            }
                                            else{
                                                tempOldMenuDictionary["label"] = "Remove Friend"
                                                tempOldMenuDictionary["url"] = "user/remove"
                                                tempOldMenuDictionary["name"] = "remove_friend"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            }
                                            
                                        case "cancel_request":
                                            
                                            tempOldMenuDictionary["label"] = "Add Friend"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "add_friend"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                        case "remove_friend":
                                            
                                            tempOldMenuDictionary["label"] = "Add Friend"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "add_friend"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        case "member_follow":
                                            if  value.isVerified != nil && value.isVerified == 1 {
                                                tempOldMenuDictionary["label"] = "Cancel Follow Request"
                                                tempOldMenuDictionary["url"] = "user/cancel"
                                                tempOldMenuDictionary["name"] = "cancel_follow"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                                
                                            }
                                            else{
                                                tempOldMenuDictionary["label"] = "Unfollow"
                                                tempOldMenuDictionary["url"] = "user/remove"
                                                tempOldMenuDictionary["name"] = "member_unfollow"
                                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            }
                                            
                                        case "member_unfollow":
                                            tempOldMenuDictionary["label"] = "Follow"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "member_follow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        case "cancel_follow":
                                            tempOldMenuDictionary["label"] = "Follow"
                                            tempOldMenuDictionary["url"] = "user/add"
                                            tempOldMenuDictionary["name"] = "member_follow"
                                            tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                            
                                            
                                        default:
                                            print("default")
                                        }
                                        
                                        
                                        let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                                        newDictionary["image_profile"] = value.image_profile
                                        newDictionary["displayname"] = value.displayname
                                        newDictionary["user_id"] = value.user_id
                                        newDictionary["isVerified"] = value.isVerified
                                        newDictionary["menus"] = tempOldMenuDictionary
                                        newDictionary["latitude"] = value.latitude
                                        newDictionary["longitude"] = value.longitude
                                        newDictionary["location"] = value.location
                                        newDictionary["image_normal"] = value.image_normal
                                        newDictionary["mapData"] = value.mapData
                                        
                                        var newData = Members.loadCommentsfromDictionary(newDictionary)
                                        self.infoWindow.removeFromSuperview()
                                        self.allMapMembers[index] = newData[0] as Members
                                    }
                                }
                                
                                if let listingMain = self.allMapMembers[index] as? Members{
                                    if var lat = listingMain.latitude as? Double{
                                        if var lang = listingMain.longitude as? Double{
                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                            {
                                                self.kCameraLatitude = lat
                                                self.kCameraLongitude = lang
                                                
                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,longitude: self.kCameraLongitude, zoom: 10)
                                                self.mapView.camera = camera
                                            }
                                            
                                            let extent = 0.2
                                            lat = lat + extent * self.randomScale()
                                            lang = lang + extent * self.randomScale()
                                            let name = "Item "
                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                            
                                            if self.mapView.isHidden == false {
                                                self.clusterManager.add(item)
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            if self.mapView.isHidden == false {
                                self.clusterManager.cluster()
                                self.clusterManager.setDelegate(self, mapDelegate: self)
                            }
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    
    func findAllMembers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if viewType == "0"
            {
                if (self.pageNumber == 1) && allMembers.count > 0{
                    membersTableView.reloadData()
                }
            }
            else if viewType == "2"
            {
                if (self.pageNumber == 1) && allMembers.count > 0{
                    matrixMemberTable.reloadData()
                }
                
            }
            if self.showSpinner{
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
            var parameter = [String:String]()
            let defaults = UserDefaults.standard
            let loc = defaults.string(forKey: "Location") ?? ""
            if viewType == "0" || viewType == "2"
            {
                parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","viewType":"0"]
            }
            else
            {
                parameter = ["limit":"\(customLimit)", "page":"\(mapPageNumber)","viewType":viewType]
            }
            
            var url = ""
            
            switch(contentType){
                
            case "user":
                parameter.merge(["user_id": String(contentId)])
                url = "user/get-friend-list"
            case "userFollow":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/following"
            case "userFollower":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/followers"
            case "members":
                url = "members"
            case "AdvVideo":
                url = urlString
                parameter = param as! [String : String]
                break
                
            default:
                print("error")
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
                searchDic.removeAll()
            }
            
            // Send Server Request to Share Content
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.nextButton.isEnabled = true
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if self.contentType == "members"{
                                    if let members = body["response"] as? NSArray{
                                        if self.viewType == "0" || self.viewType == "2"{
                                            if self.allMembers.count > 0 {
                                                self.allMembers.removeAll(keepingCapacity: false)
                                            }
                                            self.allMembers +=  Members.loadMembers(members)
                                            
                                            for i in 0 ..< (self.allMembers.count) {
                                                if let listingMain = self.allMembers[i] as? Members{
                                                    if var lat = listingMain.latitude as? Double{
                                                        if var lang = listingMain.longitude as? Double{
                                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                            {
                                                                self.kCameraLatitude = lat
                                                                self.kCameraLongitude = lang
                                                                
                                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                                      longitude: self.kCameraLongitude, zoom: 10)
                                                                self.mapView.camera = camera
                                                            }
                                                            
                                                            let extent = 0.2
                                                            lat = lat + extent * self.randomScale()
                                                            lang = lang + extent * self.randomScale()
                                                            let name = "Item \(self.j)"
                                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                                            
                                                            if self.mapView.isHidden == false {
                                                                self.clusterManager.add(item)
                                                            }
                                                            self.j = self.j + 1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        if self.viewType == "1"{
                                            self.kCameraLatitude = 0.0
                                            self.kCameraLongitude = 0.0
                                            self.mapView.removeFromSuperview()
                                            self.allMapMembers.removeAll(keepingCapacity: false)
                                            self.googleMap()
                                            self.allMapMembers += Members.loadMembers(members)
                                            
                                            for i in 0 ..< (self.allMapMembers.count) {
                                                if let listingMain = self.allMapMembers[i] as? Members{
                                                    if var lat = listingMain.latitude as? Double{
                                                        if var lang = listingMain.longitude as? Double{
                                                            if (self.kCameraLatitude == 0.0 && self.kCameraLongitude == 0.0)
                                                            {
                                                                self.kCameraLatitude = lat
                                                                self.kCameraLongitude = lang
                                                                
                                                                let camera = GMSCameraPosition.camera(withLatitude: self.kCameraLatitude,
                                                                                                      longitude: self.kCameraLongitude, zoom: 10)
                                                                self.mapView.camera = camera
                                                            }
                                                            
                                                            let extent = 0.2
                                                            lat = lat + extent * self.randomScale()
                                                            lang = lang + extent * self.randomScale()
                                                            let name = "Item \(self.j)"
                                                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lang), name: name,userData:listingMain)
                                                            
                                                            if self.mapView.isHidden == false {
                                                                self.clusterManager.add(item)
                                                            }
                                                            self.j = self.j + 1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if self.mapView.isHidden == false {
                                            self.clusterManager.cluster()
                                            self.clusterManager.setDelegate(self, mapDelegate: self)
                                        }
                                    }
                                    
                                }
                                if self.contentType == "AdvVideo"{
                                    if let members = body["members"] as? NSArray{
                                        self.allMembers +=  Members.loadMembers(members)
                                    }
                                }
                                
                                if ((self.contentType == "user") ){
                                    if let likes = body["friends"] as? NSArray{
                                        self.userdata += likes as [AnyObject]
                                        
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                if  (self.contentType == "userFollow") || (self.contentType == "userFollower"){
                                    if let likes = body["response"] as? NSArray{
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                
                                if ((self.contentType == "members") ){
                                    
                                    self.listbutton.isHidden = false
                                    self.mapButton.isHidden = false
                                }
                                
                                if let members = body["totalItemCount"] as? Int{
                                    
                                    if self.viewType == "0" || self.viewType == "2"
                                    {
                                        self.totalMemberCount = members
                                    }
                                    else
                                    {
                                        self.mapTotalMemberCount = members
                                    }
                                    self.memberCount = members
                                    if self.contentType == "user"{
                                        self.title =  String(format: NSLocalizedString(" Friends (%d) ", comment: ""),self.memberCount)
                                    }
                                    else if self.contentType == "userFollow"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Following (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followings (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                    else if self.contentType == "userFollower"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Follower (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followers (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                        
                                        
                                    else if self.contentType == "AdvVideo"
                                    {
                                        self.title =  String(format: NSLocalizedString(" Subscribers (%d) ", comment: ""),self.memberCount)
                                    }
                                        
                                    else{
                                        self.title = NSLocalizedString("Members", comment: "")
                                        self.titleLabelField.text = "\(self.memberCount!) members found"
                                        self.titleLabelField.isHidden = false
                                    }
                                    
                                    self.totalItems = members
                                }
                            }
                            
                            self.isPageRefresing = false
                            if self.viewType == "0" {
                                self.membersTableView.reloadData()
                            }
                            else if self.viewType == "2" {
                                self.matrixMemberTable.reloadData()
                            }
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (customLimit*pageNumber < totalItems){
            return 0
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mapormember == 1 {
            return 120
        }
        else {
            return dynamicHeight
        }
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allMembers.count
    }
    
    @objc func redirecttolist(_ sender: UIButton)
    {
        let presentedVC = AddtolistViewController()
        let id = self.allMembers[sender.tag]
        presentedVC.friend_id = id.user_id
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemberListViewCell
        
        guard allMembers.count > 0 else { return cell }
        cell.backgroundColor = UIColor.white
        let memberInfo = allMembers[(indexPath as NSIndexPath).row]
        if memberInfo.is_member_verified == 1 {
            cell.verifyIcon.isHidden = false
        }
        else {
            cell.verifyIcon.isHidden = true
        }
        if let url = URL(string: memberInfo.image_profile!){
            
            cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })
        }
        
        cell.userName.text = memberInfo.displayname
        if memberInfo.location != nil
        {
            cell.locationLabel.text = memberInfo.location
        }
        
        if let mutualFriends = memberInfo.mutualFriendCount {
            if mutualFriends > 0 {
                cell.mutualFriendsLabel.text = NSLocalizedString("\(mutualFriends) mutual friends", comment: "")
            }
            else {
                cell.mutualFriendsLabel.text = ""
            }
        }
        if let menu = memberInfo.menus
        {
            if menu.count > 0
            {
                let nameString = menu["name"]as! String
                if nameString == "add_friend" || nameString == "member_follow"{
                    cell.friendRequestButton.isHidden = false
                    let originalImage = UIImage(named: "FriendOutlinedIcon_Add")
                    let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                    cell.friendRequestButton.setImage(tintedImage, for: .normal)
                    cell.friendRequestButton.tintColor = buttonColor
                    cell.friendRequestButton.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                    cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                    
                }
                    
                else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                    cell.friendRequestButton.isHidden = false
                    let originalImage = UIImage(named: "FriendFilledIcon_Cancel")
                    let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                    cell.friendRequestButton.setImage(tintedImage, for: .normal)
                    cell.friendRequestButton.tintColor = buttonColor
                    cell.friendRequestButton.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                    
                    cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                }
                else if (nameString == "remove_friend") ||  (nameString == "member_unfollow"){
                    cell.friendRequestButton.isHidden = false
                    let originalImage = UIImage(named: "FriendFilledIcon_Tick")
                    let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                    cell.friendRequestButton.setImage(tintedImage, for: .normal)
                    cell.friendRequestButton.tintColor = buttonColor
                    cell.friendRequestButton.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                    cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                    
                }
                
            }
        }
        else {
            cell.friendRequestButton.isHidden = true
        }
       
        
        return cell
    }
    
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard allMembers.count > 0 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        let  memberInfo = allMembers[(indexPath as NSIndexPath).row]
        
        if let menuItem = memberInfo.menus{
            
            if let urlParam = menuItem["urlParams"] as? NSDictionary{
                
                var user_id : Int = 0
                if let id = urlParam["user_id"] as? Int
                {
                    user_id = id
                }
                else if let id = urlParam["resource_id"] as? Int
                {
                    user_id = id
                }
                
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(user_id)"
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            
        } else{
            if let user_id = memberInfo.user_id{
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(user_id)"
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && customLimit*pageNumber < totalItems){
                    
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        membersTableView.tableFooterView?.isHidden = false
                        matrixfooterView.isHidden = false
                        findAllMembers()
                    }
                }
                else
                {
                    membersTableView.tableFooterView?.isHidden = true
                    matrixfooterView.isHidden = false
                }
            }
            
        }
        
    }
    
    @objc func addNewMember(){
        let presentedVC = MemberSearchViewController()
        presentedVC.contentType = "members"
        presentedVC.navLeftIcon = true
        presentedVC.fromTab = true
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancel(){
        go_Back = true
        membersUpdate1 = false
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        if viewType == "0" || viewType == "2"
        {
            allMembers.removeAll(keepingCapacity: false)
        }
        searchBar.resignFirstResponder()
        findAllMembers()
        if self.contentType == "members"{
            if mapormember == 1{
                self.listView()
            }
            else if mapormember == 0{
                self.mapViewPage()
            }
            else {
                self.matrixView()
            }
        }
        
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
                if viewType == "0" {
                    self.membersTableView.isHidden = false
                    self.matrixMemberTable.isHidden = true
                    self.membersTableView.reloadData()
                }
                else if viewType == "2"{
                    self.matrixMemberTable.isHidden = false
                    self.membersTableView.isHidden = true
                    self.matrixMemberTable.reloadData()
                }
                
                //                tblAutoSearchSuggestions.reloadData()
                //                tblAutoSearchSuggestions.isHidden = true
                //                self.membersTableView.isHidden = true
                //                self.matrixMemberTable.isHidden = false
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
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        allMembers.removeAll(keepingCapacity: false)
        
        findAllMembers()
        if self.contentType == "members"{
            if mapormember == 1{
                self.listView()
                // self.listbutton.isHidden = false
                // self.mapButton.isHidden = false
            }
            else if mapormember == 0{
                self.mapViewPage()
                //self.listbutton.isHidden = false
                //self.mapButton.isHidden = false
            }
            else  if mapormember == 2{
                self.matrixView()
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        if searchDic.count > 0 {
            // searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            
            if globFilterValue != ""{
                searchBar.text = globFilterValue
                searchBar.endEditing(true)
                
            }
            if self.contentType == "members"{
                if mapormember == 1{
                    self.listView()
                }
                else if mapormember == 0{
                    self.mapViewPage()
                }
                else {
                    self.matrixView()
                    
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// CollectionView Delegates

extension MemberSearchViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width = self.calculateWidth()
        let width = self.view.frame.size.width/2-10
        return CGSize(width: width, height: width + 40)
    }
    
    func setUpGridView()
    {
        let flow = matrixMemberTable.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension MemberSearchViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        matrixfooterView = matrixMemberTable.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: matrixFooterId, for: indexPath)
        if (!isPageRefresing  && customLimit*pageNumber < totalItems){
            let footerView = UIView(frame: frameActivityIndicator)
            footerView.backgroundColor = UIColor.clear
            let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
            activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:17.0)
            footerView.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            matrixfooterView.addSubview(footerView)
            return matrixfooterView
        }
        else
        {
            return matrixfooterView
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MemberMatrixViewCell
        guard allMembers.count > 0 else { return cell }
        cell.backgroundColor = UIColor.white
        let memberInfo = allMembers[(indexPath as NSIndexPath).row]
        if let displayName = memberInfo.displayname {
            cell.nameLabel.text = displayName
        }
        cell.locationLabel.text = memberInfo.location
        if let mutualFriends = memberInfo.mutualFriendCount {
            if mutualFriends > 0 {
                cell.mutualFriendsLabel.text = NSLocalizedString("\(mutualFriends) mutual friends", comment: "")
            }
            else {
                cell.mutualFriendsLabel.text = "No mutual friends"
            }
        }
        if memberInfo.isVerified == 1 {
            cell.verifyIcon.isHidden = false
        }
        else {
            cell.verifyIcon.isHidden = true
        }
        if let menu = memberInfo.menus
        {
            if menu.count > 0
            {
                let nameString = menu["name"]as! String
                if nameString == "add_friend" || nameString == "member_follow"{
                    cell.friendRequest.isHidden = false
                    cell.friendRequest.setTitle("Add Friend", for: .normal)
                    cell.friendRequest.tag = (indexPath as NSIndexPath).row
                    cell.friendRequest.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                }
                    
                else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                    cell.friendRequest.isHidden = false
                    cell.friendRequest.setTitle("Cancel Request", for: .normal)
                    cell.friendRequest.tag = (indexPath as NSIndexPath).row
                    cell.friendRequest.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                }
                else if (nameString == "remove_friend") ||  (nameString == "member_unfollow"){
                    cell.friendRequest.isHidden = false
                    cell.friendRequest.setTitle("Remove Friend", for: .normal)
                    cell.friendRequest.tag = (indexPath as NSIndexPath).row
                    cell.friendRequest.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                    
                }
                    
                else if nameString == "accept_request" {
                    cell.friendRequest.isHidden = false
                    cell.friendRequest.setTitle("Accept Request", for: .normal)
                    cell.friendRequest.tag = (indexPath as NSIndexPath).row
                    cell.friendRequest.addTarget(self, action: #selector(MemberSearchViewController.menuAction(_:)), for: .touchUpInside)
                }
            }
        }
        else {
            cell.friendRequest.isHidden = true
        }
        
        
        if let imageUrl = memberInfo.image_normal
        {
            if imageUrl != ""
            {
                if let url = URL(string: imageUrl)
                {
                    cell.profileImage.kf.indicatorType = .activity
                    (cell.profileImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard allMembers.count > 0 else { return }
        
        let  memberInfo = allMembers[(indexPath as NSIndexPath).row]
        if let userId = memberInfo.user_id {
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(userId)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
}
