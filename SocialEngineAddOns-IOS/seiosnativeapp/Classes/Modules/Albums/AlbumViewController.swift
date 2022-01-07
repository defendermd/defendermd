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

//  AlbumViewController.swift

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions
import Kingfisher

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
    
}

var albumUpdate :Bool!
var albumCreated : Bool!
var catKey = ""
var sortKey = ""
// Flag to refresh Album

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var albumCollectionView : UICollectionView!   // collection view to show album content
    var username : String = ""
    var editAlbumID:Int = 0                          // Edit AlbumID
    let mainView = UIView()
    var browseOrMyAlbum = true                   // true for Browse Album & false for My Album
    var showSpinner = true                      // not show spinner at pull to refresh
    var albumResponse = [AnyObject]()
    // For response come from Server
    var categoryResponse = [AnyObject]()
    var categoryArray = [AnyObject]()
    var isPageRefresing = false                 // For Pagination
    var albumTableView:UITableView!              // TAbleView to show the Album Contents
    var popoverTableView:UITableView!      // TableView to show that either you want to create album or want to add photos
    var browseAlbum = UIButton()                   // Album Types
    var myAlbum = UIButton()
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var fromActivityFeed = false
    var objectId:Int!
    var catViewCreated : Bool = false
    var showOnlyMyContent:Bool!
    var photoAlbum = UIButton()
    var contentIcon : UILabel!
    var noContentView: NoContentView!
    var user_id : String!
    var fromTab : Bool! = false
    var fromPhotoBrowseView : Bool!
    var countListTitle : String!
    
    var catButtonTag = 10000
    // var imageCache = [String:UIImage]()
    var formResponse = [AnyObject]()
    var path = ""
    var contentType = ""
    var sortButton : UIButton!
    var leftBarButtonItem : UIBarButtonItem!
    let albumFooter = "footerId"
    var albumFooterView = UICollectionReusableView()
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var canCreateAlbum : Bool = false
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var nativeAdArray = [AnyObject]()
    // Native FacebookAd Variable
    var nativeAd:FBNativeAd!
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var admanager:FBNativeAdsManager!
    var Adiconview:UIImageView!
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var Adiconimageview : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    var adsCellheight:CGFloat = 0.0
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var categoryView = UIScrollView()
    var cellWidth = 0
    var cellHeight = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fromTab == false{
            setDynamicTabValue()
        }
        
        removeMarqueFroMNavigaTion(controller: self)
        cellWidth = Int(self.view.frame.size.width/2-35)
        cellHeight = cellWidth + 50
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        
        // Define Navigation Controller
        setNavigationImage(controller: self)
        
        globFilterValue = ""
        updateAfterAlert = true
        albumUpdate = true
        albumCreated = false
        
        mainView.frame = view.frame
        mainView.backgroundColor = .white
        view.addSubview(mainView)
        if showOnlyMyContent == false {
            if self.contentType == "sitepage_photo" || self.contentType == "sitegroup_photo"{
                self.title = String(format: NSLocalizedString(" %@ ", comment: ""),countListTitle)
            }
            else{
                self.title = NSLocalizedString("Albums", comment: "")
            }
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""),countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AlbumViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        if self.contentType == "" {
            browseAlbum = createNavigationButton(CGRect(x: 0, y:TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("Albums",  comment: ""), border: true, selected: true)
            browseAlbum.tag = 11
            browseAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            browseAlbum.addTarget(self, action: #selector(AlbumViewController.prebrowseEntries(_:)), for: .touchUpInside)
            self.catViewCreated = false
            mainView.addSubview(browseAlbum)
            
            photoAlbum = createNavigationButton(CGRect(x: view.bounds.width/3.0, y: TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("Photos",  comment: ""), border: true, selected: false)
            photoAlbum.tag = 15
            photoAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            photoAlbum.addTarget(self, action: #selector(AlbumViewController.openPhotoController(_:)), for: .touchUpInside)
            
            mainView.addSubview(photoAlbum)
            
            myAlbum = createNavigationButton(CGRect( x: 2*(view.bounds.width)/3.0, y: TOPPADING ,width: view.bounds.width/3.0  , height: ButtonHeight) , title: NSLocalizedString("My Albums",  comment: ""), border: true, selected: false)
            myAlbum.tag = 22
            myAlbum.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            myAlbum.addTarget(self, action: #selector(AlbumViewController.prebrowseEntries(_:)), for: .touchUpInside)
            
            mainView.addSubview(myAlbum)
        }
        else {
            browseAlbum.isHidden = true
            photoAlbum.isHidden  = true
            myAlbum.isHidden  = true
        }
        
        if fromPhotoBrowseView != nil {
            if fromPhotoBrowseView == true {
                photoAlbum.setUnSelectedButton()
                browseAlbum.setSelectedButton()
                myAlbum.setUnSelectedButton()
                browseOrMyAlbum = true
                browseAlbum.backgroundColor = .white
                photoAlbum.backgroundColor = .white
                myAlbum.backgroundColor = .white
            }else{
                browseOrMyAlbum = false
                browseAlbum.setUnSelectedButton()
                photoAlbum.setUnSelectedButton()
                myAlbum.setSelectedButton()
                browseAlbum.backgroundColor = .white
                photoAlbum.backgroundColor = .white
                myAlbum.backgroundColor = .white
                
            }
        }
        albumFooterView.isHidden = true
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: Selector(("filterSerach")), for: .touchUpInside)
        
        mainView.addSubview(filter)
        filter.isHidden = true
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        // Initialize Album Table
        if tabBarHeight > 0{
            albumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
            if browseOrMyAlbum && self.contentType != "" {
                let frame = CGRect(x: 0, y:  9, width: view.bounds.width, height: view.frame.size.height  - tabBarHeight - 10 - 5)
                albumCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
            }
            else if browseOrMyAlbum && self.contentType == "" {
                let frame = CGRect(x: 0, y: getBottomEdgeY(inputView: myAlbum) + 65, width: view.bounds.width, height: view.frame.size.height - getBottomEdgeY(inputView: myAlbum) - tabBarHeight - 10 - 5)
                albumCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
            }
            else {
                let frame = CGRect(x: 0, y: getBottomEdgeY(inputView: myAlbum) + 9, width: view.bounds.width, height: view.frame.size.height - getBottomEdgeY(inputView: myAlbum) - tabBarHeight - 10 - 5)
                albumCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
            }
            
        }else{
            albumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
            let frame = CGRect(x: 0, y: TOPPADING + ButtonHeight + 56 + 10, width: view.bounds.width, height: view.frame.size.height-(tabBarHeight + ButtonHeight + TOPPADING) - 10)
            albumCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        }
        albumTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "Cell")
        albumTableView.dataSource = self
        albumTableView.delegate = self
        albumTableView.estimatedRowHeight = 253
        albumTableView.rowHeight = UITableView.automaticDimension
        albumTableView.backgroundColor = tableViewBgColor
        albumTableView.separatorColor = TVSeparatorColorClear
        
        
        
        
        albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        albumCollectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: albumFooter)
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        albumCollectionView.alwaysBounceVertical = true
        albumCollectionView.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            albumTableView.estimatedSectionHeaderHeight = 0
        }
        // mainView.addSubview(albumTableView)
        mainView.addSubview(albumCollectionView)
        albumCollectionView.backgroundColor = .white
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(AlbumViewController.refresh), for: UIControl.Event.valueChanged)
        //  albumTableView.addSubview(refresher)
        albumCollectionView.addSubview(refresher)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumTableView.tableFooterView = footerView
        albumTableView.tableFooterView?.isHidden = true
        
        
        if logoutUser == true || showOnlyMyContent == true{
            browseAlbum.isHidden = true
            myAlbum.isHidden = true
            filter.frame.origin.y = TOPPADING
            albumTableView.frame.origin.y = TOPPADING
            albumTableView.frame.size.height = view.bounds.height - (TOPPADING) - tabBarHeight
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(AlbumViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
        }
        
        if adsType_album != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(AlbumViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        //        self.catKey = ""
        //        self.sortKey = ""
        
    }
    
    func createCategoryView() {
        var padding = 5
        let btnSpace = 18
        let vPadding = 8
        let buttonWidth = (mainView.frame.size.width/3) - CGFloat((padding + btnSpace + padding + btnSpace)/3)
        let buttonHeight = 40
        let scrollViewHeight = buttonHeight + (2*vPadding)
        categoryView.frame = CGRect(x: CGFloat(0), y: TOPPADING + ButtonHeight + 5, width: mainView.bounds.width, height: CGFloat(scrollViewHeight))
        mainView.addSubview(categoryView)
        categoryView.showsHorizontalScrollIndicator = false
        for dic in self.categoryResponse {
            if let dictionary = dic as? NSDictionary {
                if let name = dictionary["name"] as? String {
                    if name == "category_id" {
                        if let options = dictionary["multiOptions"] as? NSDictionary {
                            sortButton = createButton(CGRect(x: padding, y: vPadding, width: Int(buttonWidth), height: buttonHeight), title: NSLocalizedString("Sort", comment: ""), border: false, bgColor: false, textColor: UIColor.black)
                            padding = padding + Int(buttonWidth) + btnSpace
                            categoryView.addSubview(sortButton)
                            sortButton.layer.cornerRadius = 12
                            sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                            sortButton.isUserInteractionEnabled = true
                            sortButton.addTarget(self, action: #selector(AlbumViewController.sortAlbum(_:)), for: .touchUpInside)
                            sortButton.tag = 1000
                            sortButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                            sortButton.setTitleColor(.black, for: .normal)
                            //catButton.tag = Int("\(key)") ?? 0
                            // allButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                            for (key , value) in options {
                                let catButton = createButton(CGRect(x: padding, y: vPadding, width: Int(buttonWidth), height: buttonHeight), title: value as! String, border: false, bgColor: false, textColor: UIColor.black)
                                padding = padding + Int(buttonWidth) + btnSpace
                                categoryView.addSubview(catButton)
                                catButton.layer.cornerRadius = 12
                                catButton.titleLabel?.numberOfLines = 1
                                catButton.titleLabel?.lineBreakMode = .byTruncatingTail
                                catButton.titleLabel?.adjustsFontSizeToFitWidth = false
                                catButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                                catButton.titleEdgeInsets.left = 5
                                catButton.titleEdgeInsets.right = 5
                                catButton.addTarget(self, action: #selector(AlbumViewController.filterAlbum(_:)), for: .touchUpInside)
                                catButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                                catButton.setTitleColor(.black, for: .normal)
                                catButton.tag = Int("\(key)") ?? 0
                            }
                        }
                    }
                    else if (name == "sort" || name == "Sort") && self.categoryResponse.count == 1 {
                        sortButton = createButton(CGRect(x: padding, y: vPadding, width: Int(buttonWidth), height: buttonHeight), title: NSLocalizedString("Sort", comment: ""), border: false, bgColor: false, textColor: UIColor.black)
                        padding = padding + Int(buttonWidth) + btnSpace
                        categoryView.addSubview(sortButton)
                        sortButton.layer.cornerRadius = 12
                        sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                        sortButton.isUserInteractionEnabled = true
                        sortButton.addTarget(self, action: #selector(AlbumViewController.sortAlbum(_:)), for: .touchUpInside)
                        sortButton.tag = 1000
                        sortButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                        sortButton.setTitleColor(.black, for: .normal)
                    }
                }
            }
        }
        categoryView.contentSize.width = CGFloat(padding)
        self.catViewCreated = true
    }
    
    @objc func filterAlbum(_ sender:UIButton) {
        sortKey = ""
        self.catButtonTag = sender.tag
        sortButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        sortButton.setTitleColor(.black, for: .normal)
        sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        if sender.backgroundColor == navColor {
            catKey = ""
            sender.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            sender.setTitleColor(.black, for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                $0.setTitleColor(.black, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
        }
        else {
            
            let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                if $0.tag != self.catButtonTag  && $0.titleLabel?.text != NSLocalizedString("Sort", comment: ""){
                    $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                    $0.setTitleColor(.black, for: .normal)
                    $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                }
            }
            
            sender.backgroundColor = navColor
            sender.setTitleColor(.white, for: .normal)
            catKey = "\(sender.tag)"
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        }
        albumResponse.removeAll()
        pageNumber = 1
        showSpinner = true
        browseEntries()
    }
    
    @objc func sortAlbum(_ sender: UIButton) {
        catKey = ""
        self.catButtonTag = 1000
        if sortButton.backgroundColor == navColor {
            sortButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            sortButton.setTitleColor(.black, for: .normal)
            sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                if $0.titleLabel?.text != NSLocalizedString("Sort", comment: ""){
                    $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                    $0.setTitleColor(.black, for: .normal)
                    $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                }
            }
            sortKey = ""
            self.pageNumber = 1
            self.showSpinner = true
            self.browseEntries()
            
        }
        else{
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for dic in self.categoryResponse {
                if let dictionary = dic as? NSDictionary {
                    if let name = dictionary["name"] as? String {
                        if name == "sort" {
                            if let options = dictionary["multiOptions"] as? NSDictionary {
                                for (key , value) in options {
                                    
                                    alertController.addAction(UIAlertAction(title: "\(value)", style: .default) { action -> Void in
                                        sortKey = String("\(key)")
                                        
                                        let _ = self.categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                                            if $0.tag != 1000{
                                                $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                                                $0.setTitleColor(.black, for: .normal)
                                                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                                            }
                                            else {
                                                $0.backgroundColor = navColor
                                                $0.setTitleColor(.white, for: .normal)
                                                $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                                            }
                                        }
                                        self.pageNumber = 1
                                        self.showSpinner = true
                                        self.browseEntries()
                                        
                                    })
                                }
                            }
                        }
                    }
                }
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            self.present(alertController, animated:true, completion: nil)
        }
        
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAlbumContent")
        {
            if  UserDefaults.standard.object(forKey: "showAlbumContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showAlbumContent")
        }
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        switch(index) {
            
        case 0:
            
            var  coachMark1 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 75.0
            let radious : Int = 40
            
            coachMark1 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                return circlePath
                
            }
            
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            return coachMark1
            
            
        case 1:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        
        coachMarksController.stop(immediately: true)
        return false
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 1:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(albumTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    
    func showAppTour(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAlbumAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showAlbumAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showAlbumAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.contentType == "sitepage_photo" || self.contentType == "sitegroup_photo"{
        }
        else{
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }

        removeNavigationViews(controller: self)
        IsRedirctToProfile()
        browseAlbum.isUserInteractionEnabled = true
        myAlbum.isUserInteractionEnabled = true
    }
    
    func IsRedirctToProfile(){
        if conditionalProfileForm == "BrowsePage"
        {
            
            albumCreated = true
            conditionalProfileForm = ""
            browseEntries()
            let presentedVC = AlbumProfileViewController()
            allPhotos.removeAll()
            presentedVC.albumId = "\(createResponse["album_id"]!)"
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    // Check for Album Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        if albumUpdate == true{
            showSpinner = true
            albumUpdate = false
            updateAfterAlert = false
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
        if updateFromAlbum == true {
            showSpinner = true
            
            updateAfterAlert = false
            updateFromAlbum = false
            pageNumber = 1
            browseEntries()
        }
        if albumCreated {
            browseEntries()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        albumTableView.tableFooterView?.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    @objc func checkforAds(){
        
        // nativeAdArray.removeAll()
        if adsType_album == 1
        {
            if kFrequencyAdsInCells_album > 4 && placementID != ""
            {
                if arrGlobalFacebookAds.count == 0
                {
                    self.showFacebookAd()
                }
                else
                {
                    for nativeAd in arrGlobalFacebookAds {
                        self.fetchAds(nativeAd)
                    }
                    if nativeAdArray.count == 10
                    {
                        albumTableView.reloadData()
                        albumCollectionView.reloadData()
                    }
                }
                
            }
            
        }
        else if adsType_album == 0
        {
            if kFrequencyAdsInCells_album > 4 && adUnitID != ""
            {
                
                //showNativeAd()
            }
        }
        else  if adsType_album == 2{
            checkCommunityAds()
        }
        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_album)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_album)"
            post(dic, url: "communityads/index/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray
                                    self.uiOfCommunityAds(count: advertismentsArray.count){
                                        (status : Bool) in
                                        if status == true{
                                            self.albumCollectionView.reloadData()
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
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    func uiOfCommunityAds(count : Int,completion: @escaping (_ status: Bool) -> Void){
        var status  = false
        for i in 0  ..< communityAdsValues.count{
            
            if  let dic = communityAdsValues[i]  as? NSDictionary {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width:cellWidth, height: cellHeight))
                }
                else
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: cellWidth,height: cellHeight))
                }
                self.fbView.backgroundColor = UIColor.clear
                self.fbView.tag = 1001001
                
                adsImage = createImageView(CGRect(x: 0, y: 0, width: 18, height: 15), border: true)
                adsImage.image = UIImage(named: "ad_badge.png")
                self.fbView.addSubview(adsImage)
                
                adTitleLabel = UILabel(frame: CGRect(x:  0,y: Int(getBottomEdgeY(inputView: adsImage)), width:cellWidth, height: 30))
                adTitleLabel.numberOfLines = 0
                adTitleLabel.textAlignment = .center
                adTitleLabel.textColor = textColorDark
                adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                let title = String(describing: dic["cads_title"]!)
                adTitleLabel.text = title
                adTitleLabel.sizeToFit()
                self.fbView.addSubview(adTitleLabel)
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(30), y: 5,width: 20,height: 20))
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControl.State())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
                //                adCallToActionButton.clipsToBounds = true
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(AlbumViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    imageButton = createButton(CGRect(x: 5,y: getBottomEdgeY(inputView: adTitleLabel),width: self.fbView.bounds.width-10,height: self.fbView.bounds.height-getBottomEdgeY(inputView: adTitleLabel)-40),title: "", border: false, bgColor: false, textColor: textColorLight)
                }
                else
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 300),title: "", border: false, bgColor: false, textColor: textColorLight)
                }
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 150), border: false)
                }
                else
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 300), border: false)
                }
                adImageView1.contentMode = UIView.ContentMode.scaleAspectFit
                adImageView1.clipsToBounds = true
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                    adImageView1.kf.indicatorType = .activity
                    (adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    adImageView1.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(AlbumViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
                self.fbView.addSubview(imageButton)
                imageButton.addSubview(adImageView1)
                
                
                adBodyLabel = UILabel(frame: CGRect(x: 10,y: getBottomEdgeY(inputView: imageButton),width: self.fbView.bounds.width-20,height: 40))
                adBodyLabel.numberOfLines = 0
                adBodyLabel.textColor = textColorDark
                adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                self.fbView.addSubview(adBodyLabel)
                var description = String(describing: dic["cads_body"]!)
                description = description.html2String
                adBodyLabel.text = description
                adBodyLabel.sizeToFit()
                self.fbView.frame.size.height = getBottomEdgeY(inputView: adBodyLabel) + 10
                nativeAdArray.append(self.fbView)
                nativeAdArray.append(self.fbView)
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
            }
        }
        
    }
    @objc func tappedOnAds(_ sender: UIButton){
        let dic = communityAdsValues[sender.tag] as? NSDictionary
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
        dictionary["type"] =  "\(adsType_album)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_album)"
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic!["userad_id"] != nil{
            dictionary["adsId"] =  String(dic!["userad_id"] as! Int)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            if Reachabable.isConnectedToNetwork() {
                self.parent?.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
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
                showToast(message: network_status_msg, controller: self)
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
        
        //  parametersNeedToAdd = [:]
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
    func removeAd(){
        self.doneAfterReportSelect()
        showToast(message: NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), controller: self)
        
        activityIndicatorView.startAnimating()
        if Reachabable.isConnectedToNetwork() {
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        if succeeded["body"] != nil{
                            if (succeeded["body"] as? NSDictionary) != nil{
                                self.nativeAdArray.removeAll(keepingCapacity: false)
                                self.checkCommunityAds()
                            }
                        }
                    }
                })
            }
            
        }
        else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
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
    
    
    
    
    // MARK: - FacebookAd
    func showFacebookAd()
    {
        //        FBAdSettings.addTestDevices(fbTestDevice)
        //FBAdSettings.addTestDevice(fbTestDevice)
        //        nativeAd = FBNativeAd(placementID: placementID)
        //        nativeAd.mediaCachePolicy = FBNativeAdsCachePolicy.None
        //        nativeAd.delegate = self
        //        nativeAd.loadAd()
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager.delegate = self
        admanager.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager.loadAds()
        
        
        
    }
    
    func nativeAdsLoaded()
    {
        //        for _ in 0 ..< 10
        //
        //        {
        //
        //            self.nativeAd = admanager.nextNativeAd
        //             self.fetchAds(self.nativeAd)
        //
        //        }
        arrGlobalFacebookAds.removeAll()
        for _ in 0 ..< 10
        {
            if let fb = admanager.nextNativeAd
            {
                fb.unregisterView()
                arrGlobalFacebookAds.append(fb)
            }
        }
        for nativeAd in arrGlobalFacebookAds {
            self.fetchAds(nativeAd)
        }
        
        if nativeAdArray.count == 10
        {
            albumTableView.reloadData()
            albumCollectionView.reloadData()
        }
        
    }
    
    func fetchAds(_ nativeAd: FBNativeAd)
    {
        
        //        if ((self.nativeAd) != nil) {
        //            self.nativeAd.unregisterView()
        //        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/3, height: 250))
            
        }
        else
        {
            self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250))
            
        }
        self.fbView.backgroundColor = UIColor.white
        self.fbView.tag = 1001001
        
        Adiconview = createImageView(CGRect(x: self.fbView.frame.size.width-19, y: 0, width: 19, height: 15), border: true)
        Adiconview.image = UIImage(named: "ad_badge.png")
        self.fbView.addSubview(Adiconview)
        
        self.adIconImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
//        nativeAd.icon?.loadAsync(block: { (iconImage) -> Void in
//            if let image = iconImage {
//                self.adIconImageView.image = image
//            }
//
//        })
        self.fbView.addSubview(self.adIconImageView)
        
        
        adTitleLabel = UILabel(frame: CGRect(x: self.adIconImageView.bounds.width + 10 , y: 5, width: self.fbView.bounds.width-(self.adIconImageView.bounds.width + 55), height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontName, size: 16)
       // adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            adImageView = FBMediaView(frame: CGRect(x: 0 , y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y, width: self.fbView.bounds.width, height: 150))
        }
        else
        {
            adImageView = FBMediaView(frame: CGRect(x: 0 , y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y, width: self.fbView.bounds.width, height: 150))
        }
        
        
        //self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        self.fbView.addSubview(adImageView)
        
        
        adBodyLabel = UILabel(frame: CGRect(x: 10 , y: adImageView.bounds.height + 5 + adImageView.frame.origin.y, width: self.fbView.bounds.width-100, height: 40))
//        if let _ = nativeAd.body {
//            adBodyLabel.text = nativeAd.body
//        }
        
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorMedium
        adBodyLabel.font = UIFont(name: "FontAwesome", size: 14)
        
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        self.fbView.addSubview(adBodyLabel)
        
        
        
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80,y: self.adImageView.bounds.height + 10 + self.adImageView.frame.origin.y, width: 70, height: 30))
        
        adCallToActionButton.setTitle(
            nativeAd.callToAction, for: UIControl.State())
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        //nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
        
    }
    
    public func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error.localizedDescription)
    }
    
    
    
    // MARK: - GADAdLoaderDelegate
//    func showNativeAd()
//    {
//        var adTypes = [GADAdLoaderAdType]()
//        if iscontentAd == true
//        {
//            if isnativeAd
//            {
//                adTypes.append(GADAdLoaderAdType.nativeAppInstall)
//                isnativeAd = false
//            }
//            else
//            {
//                adTypes.append(GADAdLoaderAdType.nativeContent)
//                isnativeAd = true
//            }
//        }
//        else
//        {
//            adTypes.append(GADAdLoaderAdType.nativeAppInstall)
//        }
//        delay(0, closure: {
//            self.adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
//                                        adTypes: adTypes, options: nil)
//            self.adLoader.delegate = self
//            let request = GADRequest()
//            //            request.testDevices = [kGADSimulatorID,"bc29f25fa57e135618e267a757a5fa35"]
//            self.adLoader.load(request)
//        })
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//        print("\(adLoader) failed with error: \(error.localizedDescription)")
//    }
//
//    // Mark: - GADNativeAppInstallAdLoaderDelegate
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd)
//    {
//        let appInstallAdView = Bundle.main.loadNibNamed("NativeAdAdvancedevent", owner: nil,
//                                                        options: nil)?.first as! GADNativeAppInstallAdView
//        if(UIDevice.current.userInterfaceIdiom == .pad)
//        {
//            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height+150)
//        }
//        else
//        {
//            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height)
//        }
//
//        // Associate the app install ad view with the app install ad object. This is required to make
//        // the ad clickable.
//        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
//        appInstallAdView.tag = 1001001
//
//        (appInstallAdView.iconView as! UIImageView).frame = CGRect(x:5,y: 5,width: 40,height: 40)
//        (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
//
//        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: (appInstallAdView.iconView as! UIImageView).bounds.width + 10 ,y: 5,width: appInstallAdView.bounds.width-((appInstallAdView.iconView as! UIImageView).bounds.width + 55),height: 30)
//        (appInstallAdView.headlineView as! UILabel).numberOfLines = 0
//        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
//        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
//
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x:0,y: (appInstallAdView.iconView as! UIImageView).bounds.height + 10 + (appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 150)
//        }
//        else
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (appInstallAdView.iconView as! UIImageView).bounds.height+10+(appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 300)
//        }
//
//        let imgheight = Double(appInstallAdView.frame.size.height)
//        let imgWidth = Double((appInstallAdView.imageView as! UIImageView).frame.size.width)
//        (appInstallAdView.imageView as! UIImageView).image = cropToBounds((nativeAppInstallAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
//        //(appInstallAdView.imageView as! UIImageView).contentMode = .ScaleAspectFit
//
//        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: 10,y: (appInstallAdView.imageView as! UIImageView).bounds.height + 10 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-100,height: 40)
//
//        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
//        (appInstallAdView.bodyView as! UILabel).numberOfLines = 0
//        (appInstallAdView.bodyView as! UILabel).textColor = textColorDark
//        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: appInstallAdView.bounds.width-75, y:(appInstallAdView.imageView as! UIImageView).bounds.height + 15 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
//
//        (appInstallAdView.callToActionView as! UIButton).setTitle(
//            nativeAppInstallAd.callToAction, for: UIControl.State.normal)
//        (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
//        (appInstallAdView.callToActionView as! UIButton).backgroundColor = bgColor
//        (appInstallAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
//        (appInstallAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
//        (appInstallAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
//        (appInstallAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        nativeAdArray.append(appInstallAdView)
//
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.albumTableView.reloadData()
//            self.albumCollectionView.reloadData()
//        }
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
//
//        let contentAdView = Bundle.main.loadNibNamed("ContentAdsFeedview", owner: nil,
//                                                     options: nil)?.first as! GADNativeContentAdView
//
//        if(UIDevice.current.userInterfaceIdiom == .pad)
//        {
//            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height+150)
//        }
//        else
//        {
//            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height)
//        }
//
//        // Associate the app install ad view with the app install ad object. This is required to make
//        // the ad clickable.
//        contentAdView.nativeContentAd = nativeContentAd
//        contentAdView.tag = 1001001
//
//        // Populate the app install ad view with the app install ad assets.
//        // Some assets are guaranteed to be present in every app install ad.
//        (contentAdView.headlineView as! UILabel).frame = CGRect(x: 10 ,y: 5,width: contentAdView.bounds.width-55, height: 30)
//        (contentAdView.headlineView as! UILabel).numberOfLines = 0
//        (contentAdView.headlineView as! UILabel).textColor = textColorDark
//        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
//
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 160)
//        }
//        else
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 300)
//        }
//
//        let imgheight = Double(contentAdView.frame.size.height)
//        let imgWidth = Double((contentAdView.imageView as! UIImageView).frame.size.width)
//        (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
//
//        (contentAdView.bodyView as! UILabel).frame = CGRect(x:10 ,y: (contentAdView.imageView as! UIImageView).bounds.height + 10 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: contentAdView.bounds.width-100,height: 40)
//
//        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
//        (contentAdView.bodyView as! UILabel).numberOfLines = 0
//        (contentAdView.bodyView as! UILabel).textColor = textColorDark
//        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//
//        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: contentAdView.bounds.width-75, y: (contentAdView.imageView as! UIImageView).bounds.height + 15 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
//
//        (contentAdView.callToActionView as! UIButton).setTitle(
//            nativeContentAd.callToAction, for: UIControl.State.normal)
//        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
//        (contentAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
//        (contentAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
//        (contentAdView.callToActionView as! UIButton).backgroundColor = bgColor
//        (contentAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
//        (contentAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
//        (contentAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
//        (contentAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        nativeAdArray.append(contentAdView)
//
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.albumTableView.reloadData()
//            self.albumCollectionView.reloadData()
//        }
//    }
    
    func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyAlbum = true
            self.browseEntries()
        case 1:
            browseOrMyAlbum = false
            self.browseEntries()
        default:
            break;
        }
    }
    
    // Cancle Search Result for Logout User
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(self.contentType)
        super.viewWillDisappear(animated)
        if self.contentType == "sitepage_photo" || self.contentType == "sitegroup_photo"{
            
        }
        else {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        if browseOrMyAlbum {
            if albumCreated {
                let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                    if $0.backgroundColor == navColor {
                        $0.setTitleColor(.white, for: .normal)
                        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                    }
                    else {
                        $0.setTitleColor(.black, for: .normal)
                        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    }
                }
                albumCreated = false
            }
            
        }
        timerFB.invalidate()
        globFilterValue = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    
    // Create popover
    @objc func addNewAlbum(){
        let startPoint = CGPoint(x: self.view.frame.width - 28, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: 80))
        popoverTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "Cell")
        popoverTableView.delegate = self
        popoverTableView.dataSource = self
        popoverTableView.isScrollEnabled = false
        popoverTableView.tag = 11
        popover.show(popoverTableView, point: startPoint)
        popoverTableView.reloadData()
    }
    
    // Handle Browse Album or My Album PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Browse Album & false for My Album
        sortKey = ""
        catKey = ""
        if sender.tag == 22 {
            albumCollectionView.frame.origin.y = getBottomEdgeY(inputView: myAlbum) + 9
            albumCollectionView.frame.size.height = view.frame.size.height - getBottomEdgeY(inputView: myAlbum) - tabBarHeight - 4
            categoryView.isHidden = true
            browseOrMyAlbum = false
            browseAlbum.isUserInteractionEnabled = false
            photoAlbum.isUserInteractionEnabled = false
        }else if sender.tag == 11 {
            browseOrMyAlbum = true
            
            catButtonTag = 6000
            if self.catViewCreated {
                self.sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
            let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                $0.setTitleColor(.black, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
            let frame = CGRect(x: 0, y: getBottomEdgeY(inputView: myAlbum) + 65, width: view.bounds.width, height: view.frame.size.height - getBottomEdgeY(inputView: myAlbum) - tabBarHeight - 10 - 5) 
            albumCollectionView.frame = frame
            categoryView.isHidden = false
            myAlbum.isUserInteractionEnabled = false
            photoAlbum.isUserInteractionEnabled = false
        }
        self.albumResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        pageNumber = 1
        showSpinner = true
        updateScrollFlag = false
        albumTableView.tableFooterView?.isHidden = true
        // Update for Album
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            catButtonTag = -11
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer{
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
    
    
    
    func noRedirection(_ sender: UIButton){
        if browseOrMyAlbum == true {
            showToast(message: "User not allowed to view this page", controller: self)
        }
    }
    
    // MARK: - Server Connection For Album Updation
    
    // For delete  a Album
    func updateAlbumMenuAction(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            self.mainView.addSubview(spinner)
            view.addSubview(activityIndicatorView)
            activityIndicatorView.center = view.center
            activityIndicatorView.startAnimating()
            let dic = Dictionary<String, String>()
            
            // Send Server Request to Explore Album Contents with Album_ID
            
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Album Detail
                        // Update Album Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        updateAfterAlert = false
                        self.browseEntries()
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
    
    // Update Album
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            //            if showOnlyMyContent == true{
            //                browseOrMyAlbum = false
            //            }
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                    
                }
            }
            
            if self.catViewCreated{
                //            for ob in categoryView.subviews {
                //                if ob.tag != self.catButtonTag
                //                {
                //                   ob.isUserInteractionEnabled = false
                //                }
                //            }
                //                let _ = categoryView.subviews.compactMap{ $0 as? UIButton }.map {
                //                    if $0.tag != self.catButtonTag  && $0.titleLabel?.text != "sort"{
                //                    $0.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                //                    $0.isUserInteractionEnabled = false
                //                    $0.setTitleColor(.black, for: .normal)
                //                    $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                //                    }
                //                    else if $0.tag == 1000 {
                //                        $0.backgroundColor = navColor
                //                        $0.isUserInteractionEnabled = false
                //                        $0.setTitleColor(.white, for: .normal)
                //                        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                //                    }
                //                }
            }
            
            if (self.pageNumber == 1){
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.albumResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.albumTableView.reloadData()
                    self.albumCollectionView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                activityIndicatorView.stopAnimating()
                //     spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    albumFooterView.isHidden = true
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                self.mainView.addSubview(spinner)
                view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            var parameters = [String:String]()
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyAlbum = true
            }
            // Set Parameters for Browse/MyAlbum
            
            if browseOrMyAlbum
            {
                if contentType != "sitepage_photo"  && contentType != "sitestore_photo" && contentType != "sitegroup_photo"
                {
                    path = "albums"
                }
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    if pageNumber == 1 {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit-1)","user_id" : String(user_id),"category_id":"\(catKey)", "sort": "\(sortKey)"]
                    }
                    else {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id),"category_id":"\(catKey)", "sort": "\(sortKey)"]
                    }
                }else{
                    if pageNumber == 1 {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit-1)","category_id":"\(catKey)", "sort": "\(sortKey)"]
                    }
                    else {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","category_id":"\(catKey)", "sort": "\(sortKey)"]
                    }
                }
                browseAlbum.setSelectedButton()
                myAlbum.setUnSelectedButton()
                browseAlbum.backgroundColor = .white
                photoAlbum.backgroundColor = .white
                myAlbum.backgroundColor = .white
                
            }else{
                path = "albums/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                browseAlbum.setUnSelectedButton()
                myAlbum.setSelectedButton()
                browseAlbum.backgroundColor = .white
                photoAlbum.backgroundColor = .white
                myAlbum.backgroundColor = .white
            }
            
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            // Send Server Request to Browse Album Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.albumTableView.tableFooterView?.isHidden = true
                    if msg{
                        if self.pageNumber == 1{
                            self.albumResponse.removeAll(keepingCapacity: false)
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if var album = response["response"] as? [AnyObject]{
                                    for (index,dic) in album.enumerated() {
                                        if let dictionary = dic as? NSDictionary {
                                            if let name = dictionary["allow_to_view"] as? Int {
                                                if name == 0 {
                                                    if index < album.count {
                                                        album.remove(at: index)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    self.albumResponse = self.albumResponse + (album as [AnyObject])
                                }
                            }
                            if self.browseOrMyAlbum {
                                if response["filter"] != nil {
                                    if let categories = response["filter"]  as? NSArray{
                                        self.categoryResponse = (categories as [AnyObject])
                                        if self.browseOrMyAlbum {
                                            if self.catViewCreated == false && self.contentType == ""{
                                                self.createCategoryView()
                                            }
                                        }
                                    }
                                }
                                else {
                                    self.albumCollectionView.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.myAlbum) + 9, width: self.view.bounds.width, height: self.view.frame.size.height - getBottomEdgeY(inputView: self.myAlbum) - tabBarHeight - 10 - 5)
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            if self.showOnlyMyContent == false {
                                if (response["canCreate"] as! Bool == true){
                                    self.canCreateAlbum = true
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AlbumViewController.searchItem))
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AlbumViewController.addNewAlbum))
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    self.showAppTour()
                                }else{
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AlbumViewController.searchItem))
                                    
                                    self.navigationItem.rightBarButtonItem = searchItem
                                }
                            }
                            self.title_update()
                        }
                        
                        self.isPageRefresing = false
                        //Reload Album Tabel
                        if self.browseOrMyAlbum {
                            if self.catViewCreated == false && self.contentType == ""{
                                self.createCategoryView()
                            }
                        }
                        self.albumTableView.reloadData()
                        self.albumCollectionView.reloadData()
                        self.browseAlbum.isUserInteractionEnabled = true
                        self.photoAlbum.isUserInteractionEnabled = true
                        self.myAlbum.isUserInteractionEnabled = true
                        if self.albumResponse.count == 0{
                            self.noContentView = NoContentView()
                            self.noContentView.tag = 1000
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            if self.canCreateAlbum {
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.button.setTitleColor(buttonColor, for: .normal)
                                self.noContentView.button.addTarget(self, action: #selector(AlbumViewController.createForm), for: .touchUpInside)
                                self.noContentView.button.isUserInteractionEnabled = true
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                            }
                            else {
                                self.noContentView.button.isHidden = true
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment", comment: "")
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
    
    // Set Album Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Apply condition for tableViews
        if tableView.tag == 11{
            return 0.00001
        }else{
            if (limit*pageNumber < totalItems){
                return 0
                
            }else{
                return 0.00001
            }
        }
    }
    
    // Set Album Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Apply condition for tableViews
        if tableView.tag == 11{
            return 40
        }
        else
        {
            let row = (indexPath as NSIndexPath).row as Int
            if adsType_album == 2
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 430
                }
                else
                {
                    if (kFrequencyAdsInCells_album > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_album) == (kFrequencyAdsInCells_album)-1))
                    {
                        return adsCellheight
                    }
                }
                return 250
            }
            else if adsType_album == 0
            {
                return 265
            }
            return 253.0
        }
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        // Apply condition for tableViews
        if tableView.tag == 11{
            return 2
        }
        else
        {
            if nativeAdArray.count > 0
            {
                // For showing facebook ads count
                var rowcount = Int()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    rowcount = 3*(kFrequencyAdsInCells_album-1)
                }
                else
                {
                    
                    rowcount = (kFrequencyAdsInCells_album-1)
                }
                if albumResponse.count > rowcount
                {
                    
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(albumResponse.count)/3))
                        adsCount = b/(kFrequencyAdsInCells_album-1)
                        if adsCount > 2
                        {
                            adsCount = adsCount/3
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_album-1) == 0 && albumResponse.count % 3 != 0
                        {
                            if adsCount%3 != 0
                            {
                                
                                return Totalrowcount - 1
                            }
                        }
                        else if albumResponse.count % 3 != 0 && adsCount % 3 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        
                        return Totalrowcount
                        
                    }
                    else
                    {
                        let b = albumResponse.count
                        adsCount = b/(kFrequencyAdsInCells_album-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_album == 0
                        {
                            return Totalrowcount-1
                        }
                        else
                        {
                            return Totalrowcount
                        }
                    }
                }
                else
                {
                    
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return Int(ceil(Float(albumResponse.count)/3))
                    }
                    else
                    {
                        return albumResponse.count
                    }
                }
                
            }
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return Int(ceil(Float(albumResponse.count)/3))
            }else{
                return albumResponse.count
            }
        }
    }
    
    // Set Cell of TabelView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // Apply condition for tableViews
        if tableView.tag == 11 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = albumOption[(indexPath as NSIndexPath).row]
            //            cell.backgroundColor = UIColor.red
            cell.textLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            return cell
            
        }
        else
        {
            var row = (indexPath as NSIndexPath).row as Int
            if (kFrequencyAdsInCells_album > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_album) == (kFrequencyAdsInCells_album)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                albumTableView.register(NativeAlbumCell.self, forCellReuseIdentifier: "Cell1")
                let cell = albumTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeAlbumCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_album-1)
                while Adcount > 10 {
                    
                    Adcount = Adcount%10
                }
                
                if Adcount > 0
                {
                    Adcount = Adcount-1
                }
                
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                {
                    for obj in cell.contentView.subviews
                    {
                        if obj.tag == 1001001 //Condition if that view belongs to any specific class
                        {
                            obj.removeFromSuperview()
                            
                        }
                    }
                    let view = nativeAdArray[Adcount]
                    cell.contentView.addSubview(view as! UIView)
                    cell.layoutIfNeeded()
                    print("---*****---")
                    
                }
                
                return cell
                
            }
            else
            {
                
                if kFrequencyAdsInCells_album > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_album)
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AlbumTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                
                if browseOrMyAlbum
                {
                    cell.contentSelection.frame.size.height = 253
                }
                else
                {
                    cell.contentSelection.frame.size.height = 175
                }
                
                var index:Int!
                
                index = row * 1
                cell.contentSelection.tag = index
                
                
                if albumResponse.count > index
                {
                    cell.contentSelection.isHidden = false
                    cell.albumCoverImage.isHidden = false
                    cell.createdBy.isHidden = false
                    cell.albumName.isHidden = false
                    cell.totalPhotos.isHidden = false
                    cell.albumCoverImage.image = UIImage(named : "default.png")
                    if let photoInfo = albumResponse[index] as? NSDictionary
                    {
                        cell.albumCoverImage.backgroundColor = placeholderColor
                        let imageUrl = photoInfo["image"] as! String
                        if (imageUrl.range(of: ".gif") != nil){
                            cell.gifImageView.isHidden = false
                        }else{
                            cell.gifImageView.isHidden = true
                        }
                        let url1 = URL( string:imageUrl)
                        cell.albumCoverImage.kf.indicatorType = .activity
                        (cell.albumCoverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.albumCoverImage.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        // LHS
                        if let photoCount = photoInfo["photo_count"] as? String{
                            if Int(photoCount) > 1 {
                                
                                cell.photoCount.text = String(format: NSLocalizedString("%d photos ", comment: ""),photoCount) //"\(photoCount) photos"
                            }else{
                                cell.photoCount.text = String(format: NSLocalizedString("%d photo ", comment: ""),photoCount) //"\(photoCount) photo"
                            }
                        }else if let photoCount = photoInfo["photo_count"] as? Int{
                            if photoCount > 1 {
                                cell.photoCount.text = String(format: NSLocalizedString("%d photos ", comment: ""),photoCount) //"\(photoCount) photos"
                            }else{
                                cell.photoCount.text = String(format: NSLocalizedString("%d photo ", comment: ""),photoCount) //"\(photoCount) photo"
                            }
                        }
                        
                        
                        
                        // cell.contentSelection.addTarget(self, action: #selector(AlbumViewController.showAlbum(_:)), for: .touchUpInside)
                        
                        // cell.createdBy.text = " by " + String(photoInfo["owner_title"] as! NSString)
                        var value : String
                        var tempString : NSString = ""
                        if let titl = photoInfo["title"] as? NSString {
                            tempString = titl
                        }
                        else if let titl = photoInfo["title"] as? Int {
                            tempString = "\(titl)" as NSString
                        }
                        if tempString.length > 30{
                            value = tempString.substring(to: 25)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(tempString)"
                        }
                        cell.albumName.text = " \(value)"
                        var totalView = ""
                        if let likes = photoInfo["like_count"] as? Int{
                            totalView = "\(likes) \(likeIcon)"
                        }
                        if let comment = photoInfo["comment_count"] as? Int{
                            totalView += " \(comment) \(commentIcon)"
                        }
                        
                        cell.totalMembers.text = "\(totalView)"
                        cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                        cell.totalPhotos.text = String(photoInfo["photo_count"] as! Int)
                        
                        // Set Menu
                        if browseOrMyAlbum {
                            cell.menu.isHidden = true
                            cell.createdBy.frame.size.width = cell.albumCoverImage.bounds.width
                        }else{
                            // Set MenuAction
                            cell.menu.tag = index
                            cell.menu.addTarget(self, action:#selector(AlbumViewController.showMenu(_:)) , for: .touchUpInside)
                            cell.menu.isHidden = false
                            cell.createdBy.frame.size.width = cell.albumCoverImage.bounds.width -  cell.menu.bounds.width
                        }
                    }
                    
                }else{
                    cell.contentSelection.isHidden = true
                    cell.albumCoverImage.isHidden = true
                    cell.createdBy.isHidden = true
                    cell.albumName.isHidden = true
                    cell.totalPhotos.isHidden = true
                    
                    return cell
                }
                
                
                return cell
            }
            
        }
    }
    @objc func createForm() {
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Add New Photos", comment: "")
        presentedVC.contentType = "Album"
        presentedVC.param = [ : ]
        presentedVC.url = "albums/upload"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        // Apply condition for tableViews
        if  tableView.tag == 11{
            formResponse.removeAll(keepingCapacity: false)
            self.popover.dismiss()
            if (indexPath as NSIndexPath).row == 0{
                // Create Album Form
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Add New Photos", comment: "")
                presentedVC.contentType = "Album"
                presentedVC.param = [ : ]
                presentedVC.url = "albums/upload"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:true, completion: nil)
                
            }
            else if (indexPath as NSIndexPath).row == 1{
                // Upload Photos
                // Check Internet Connectivity
                if Reachabable.isConnectedToNetwork() {
                    view.isUserInteractionEnabled = false
                    let parameters = [String:String]()
                    //                    spinner.center = mainView.center
                    //                    spinner.hidesWhenStopped = true
                    //                    spinner.style = UIstyle.gray
                    //                    self.mainView.addSubview(spinner)
                    view.addSubview(activityIndicatorView)
                    activityIndicatorView.center = view.center
                    activityIndicatorView.startAnimating()
                    post(parameters, url: "albums/upload", method: "GET") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            self.view.alpha = 1.0
                            self.view.isUserInteractionEnabled = true
                            if let response = succeeded["body"] as? NSArray{
                                self.formResponse = self.formResponse + (response as [AnyObject])
                                activityIndicatorView.stopAnimating()
                            }
                            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                            // Shows the album Options on which we can add photos
                            var albumDic : NSDictionary!
                            for key in self.formResponse{
                                if let dic = (key as? NSDictionary){
                                    if dic["name"] as! String == "album"{
                                        if let albums = dic["multiOptions"] as? NSDictionary{
                                            albumDic = albums
                                            for(key,value) in (dic["multiOptions"] as? NSDictionary)!{
                                                if key as! String != "0"{
                                                    alertController.addAction(UIAlertAction(title: (value) as? String, style: .default, handler:{ (UIAlertAction) -> Void in
                                                        var urlParams = Dictionary<String, String>()
                                                        urlParams["album_id"] = "\(key)"
                                                        let presentedVC = UploadPhotosViewController()
                                                        presentedVC.directUpload = false
                                                        presentedVC.url = "albums/upload"
                                                        presentedVC.param =  urlParams as NSDictionary?
                                                        
                                                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                                    }))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if  (UIDevice.current.userInterfaceIdiom == .phone){
                                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
                            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                                // Present Alert as! Popover for iPad
                                alertController.popoverPresentationController?.sourceView = self.view
                                alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.height/2, width: 0, height: 0)
                                alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
                            }
                            if albumDic != nil && albumDic.count > 0 {
                            self.present(alertController, animated:true, completion: nil)
                            }
                            else {
                                showToast(message: "No album to show", controller: self)
                            }
                        }
                        )}
                }
                else{
                    showToast(message: network_status_msg, controller: self)
                }
            }
            
        }
    }
    
    
    @objc func showMenu(_ sender:UIButton){
        
        var albumInfo:NSDictionary
        albumInfo = albumResponse[sender.tag] as! NSDictionary
        editAlbumID = albumInfo["album_id"] as! Int
        if(albumInfo["menu"] != nil){
            let menuOption = albumInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    if titleString.range(of: "delete") != nil {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Album entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.updateAlbumMenuAction(menuItem["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    }else{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "edit":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit", comment: "")
                                presentedVC.contentType = "album"
                                //                                               presentedVC.param = menuItem["urlParams"] as! NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                        }))
                        
                    }
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Album
                //                if albumTableView.contentOffset.y >= albumTableView.contentSize.height - albumTableView.bounds.size.height{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        albumTableView.tableFooterView?.isHidden = false
                        albumFooterView.isHidden = false
                        //   if searchDic.count == 0{
                        if adsType_album == 2 || adsType_album == 4{
                            delay(0.1) {
                                self.checkforAds()
                            }
                        }
                        browseEntries()
                        // }
                    }
                }
                else
                {
                    albumTableView.tableFooterView?.isHidden = true
                    albumFooterView.isHidden = true
                }
                //  }
            }
            
        }
        
        
    }
    
    @objc func openPhotoController(_ sender: UIButton){
        sortKey = ""
        catKey = ""
        browseAlbum.isUserInteractionEnabled = false
        myAlbum.isUserInteractionEnabled = false
        let presentedVC = PhotoAlbumViewController()
        presentedVC.canCreate = canCreateAlbum
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func searchItem(){
        let presentedVC = AlbumSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        let url : String = "albums/search-form"
        loadFilter(url)
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We update the title when we delete the data from profile page
    func title_update()
    {
        if showOnlyMyContent == false {
            if self.contentType == "sitepage_photo" || self.contentType == "sitegroup_photo"{
                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), "Albums " + "(" + "\(totalItems)" + ")" + " : " + self.username)
            }
            else{
                self.title = NSLocalizedString("Albums", comment: "")
            }
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), "Albums " + "(" + "\(totalItems)" + ")" + " : " + self.username)
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





// CollectionView Delegates

extension AlbumViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.size.width/2-20
        return CGSize(width: cellWidth + 18, height: cellHeight + 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension AlbumViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.canCreateAlbum {
            return albumResponse.count + 1
        }
        else {
            return albumResponse.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        albumFooterView = albumCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: albumFooter, for: indexPath)
        for ob in albumFooterView.subviews {
            if ob.tag == 2000 {
                ob.removeFromSuperview()
            }
        }
        if (!isPageRefresing  && limit*pageNumber < totalItems){
            if browseOrMyAlbum {
                let footerView = UIView(frame: frameActivityIndicator)
                footerView.backgroundColor = UIColor.clear
                footerView.tag = 2000
                let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
                activityIndicatorView.frame = CGRect(x: 0, y: 0, width:30 , height: 25)
                activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:15)
                footerView.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                albumFooterView.addSubview(footerView)
                // albumFooterView.isHidden = false
                return albumFooterView
            }
        }
        else
        {
            albumFooterView.isHidden = true
            return albumFooterView
        }
        return albumFooterView
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        cell.albumCoverView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        if self.contentType == "" {
            if browseOrMyAlbum {
                cell.menu.isHidden = true
            }
            else {
                if self.canCreateAlbum {
                    if indexPath.row != 0 {
                        cell.menu.tag = indexPath.row - 1
                        cell.menu.addTarget(self, action: #selector(AlbumViewController.showMenu(_:)), for: .touchUpInside)
                        
                        cell.menu.isHidden = false
                    }
                }
                else  {
                    cell.menu.isHidden = false
                    cell.menu.tag = indexPath.row
                    cell.menu.addTarget(self, action: #selector(AlbumViewController.showMenu(_:)), for: .touchUpInside)
                }
            }
            if self.canCreateAlbum {
                if indexPath.row == 0 {
                    cell.gifImageView.isHidden = true
                    cell.menu.isHidden = true
                    if albumResponse.count > 0 {
                        cell.plusIcon.isHidden = false
                        cell.albumCoverView.isHidden = false
                        cell.albumTitleLabel.text = NSLocalizedString("Create new Album", comment: "")
                        cell.albumPhotoCount.isHidden = true
                        cell.albumCoverView.backgroundColor = .white
                        cell.albumTitleLabel.isHidden = false
                        cell.albumCoverView.image = nil
                        cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(1.0).cgColor
                    }
                    else {
                        cell.plusIcon.isHidden = true
                        cell.albumCoverView.isHidden = true
                        cell.albumTitleLabel.isHidden = true
                        cell.albumPhotoCount.isHidden = true
                    }
                    
                    
                }
                else {
                    cell.plusIcon.isHidden = true
                    cell.albumPhotoCount.isHidden = false
                    if let photoInfo = albumResponse[indexPath.row-1] as? NSDictionary
                    {
                        if let imageUrl = photoInfo["image"] as? String
                        {
                            if (imageUrl.range(of: ".gif") != nil){
                                cell.gifImageView.isHidden = false
                            }else{
                                cell.gifImageView.isHidden = true
                            }
                            if (imageUrl.range(of: "mobiledemo.socialengineaddons.com") == nil){
                                cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(0.5).cgColor
                            }
                            else {
                                cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(1.0).cgColor
                            }
                            let url1 = URL( string:imageUrl)
                            //cell.albumCoverView.kf.indicatorType = .activity
                            // (cell.albumCoverView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.albumCoverView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                        // LHS
                        if let photoCount = photoInfo["photo_count"] as? String{
                            if Int(photoCount) > 1 {
                                
                                cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                            }else{
                                cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                            }
                        }else if let photoCount = photoInfo["photo_count"] as? Int{
                            if photoCount > 1 {
                                cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                            }else{
                                cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                            }
                        }
                        else {
                            cell.albumPhotoCount.text = NSLocalizedString("0 photos", comment: "")
                        }
                        var value : String
                        var tempString : NSString = ""
                        if let titl = photoInfo["title"] as? NSString {
                            tempString = titl
                        }
                        else if let titl = photoInfo["title"] as? Int {
                            tempString = "\(titl)" as NSString
                        }
                        if tempString.length > 30{
                            value = tempString.substring(to: 25)
                            value += NSLocalizedString("...",  comment: "")
                        }else{
                            value = "\(tempString)"
                        }
                        cell.albumTitleLabel.text = " \(value)"
                        
                    }
                }
            }
            else {
                
                cell.plusIcon.isHidden = true
                cell.albumPhotoCount.isHidden = false
                if let photoInfo = albumResponse[indexPath.row] as? NSDictionary
                {
                    if let imageUrl = photoInfo["image"] as? String
                    {
                        if (imageUrl.range(of: ".gif") != nil){
                            cell.gifImageView.isHidden = false
                        }else{
                            cell.gifImageView.isHidden = true
                        }
                        if (imageUrl.range(of: "mobiledemo.socialengineaddons.com") == nil){
                            cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(0.5).cgColor
                        }
                        else {
                            cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(1.0).cgColor
                        }
                        let url1 = URL( string:imageUrl)
                        // cell.albumCoverView.kf.indicatorType = .activity
                        //(cell.albumCoverView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.albumCoverView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    else {
                        
                    }
                    // LHS
                    if let photoCount = photoInfo["photo_count"] as? String{
                        if Int(photoCount) > 1 {
                            
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                        }else{
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                        }
                    }else if let photoCount = photoInfo["photo_count"] as? Int{
                        if photoCount > 1 {
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                        }else{
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                        }
                    }
                    var value : String
                    var tempString : NSString = ""
                    if let titl = photoInfo["title"] as? NSString {
                        tempString = titl
                    }
                    else if let titl = photoInfo["title"] as? Int {
                        tempString = "\(titl)" as NSString
                    }
                    if tempString.length > 30{
                        value = tempString.substring(to: 25)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(tempString)"
                    }
                    cell.albumTitleLabel.text = " \(value)"
                    
                }
            }
            
            return cell
        }
        else {
            cell.plusIcon.isHidden = true
            cell.menu.isHidden = true
            if let photoInfo = albumResponse[indexPath.row] as? NSDictionary
            {
                if let imageUrl = photoInfo["image"] as? String
                {
                    if (imageUrl.range(of: ".gif") != nil){
                        cell.gifImageView.isHidden = false
                    }else{
                        cell.gifImageView.isHidden = true
                    }
                    if (imageUrl.range(of: "mobiledemo.socialengineaddons.com") == nil){
                        cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(0.5).cgColor
                    }
                    else {
                        cell.albumCoverView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).withAlphaComponent(1.0).cgColor
                    }
                    let url1 = URL( string:imageUrl)
                    cell.albumCoverView.kf.indicatorType = .activity
                    (cell.albumCoverView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.albumCoverView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                
                // LHS
                if let photoCount = photoInfo["photo_count"] as? String{
                    if Int(photoCount) > 1 {
                        
                        cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                    }else{
                        cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                    }
                }else if let photoCount = photoInfo["photo_count"] as? Int{
                    if photoCount > 1 {
                        cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                    }else{
                        cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                    }
                }
                var value : String
                var tempString : NSString = ""
                if let titl = photoInfo["title"] as? NSString {
                    tempString = titl
                }
                else if let titl = photoInfo["title"] as? Int {
                    tempString = "\(titl)" as NSString
                }
                if tempString.length > 30{
                    value = tempString.substring(to: 25)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                cell.albumTitleLabel.text = " \(value)"
            }
            return cell
        }
    }
    
    func checkAlbumPassword(row: Int) {
        let albumInfo:NSDictionary!
        albumInfo = albumResponse[row] as! NSDictionary
        if let isPassword = albumInfo["isPassword"] as? Bool, isPassword {
            if let password = albumInfo["password"] as? String {
                self.passwordAlert(pass: password, row: row)
            }
        }
        else {
            self.showAlbum(row: row)
        }
    }
    
    func passwordAlert(pass : String, row: Int)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Enter Password",  comment: ""), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Enter Password",  comment: "")
            textField.isSecureTextEntry = true
        })
        
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let enterpass = alertController.textFields?[0].text
            if enterpass == String(pass)
            {
                self.showAlbum(row: row)
            }
            else
            {
                showToast(message: "Password invalid", controller: self)
                self.passwordAlert(pass : pass, row: row)
            }
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: {  })
    }
    
    func showAlbum(row: Int){
        if browseOrMyAlbum == true {
            let albumInfo:NSDictionary!
            albumInfo = albumResponse[row] as! NSDictionary
            if(albumInfo["allow_to_view"] as! Int == 1){
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = "\(albumInfo["album_id"]!)"
                
                switch(self.contentType){
                case "sitepage_photo":
                    presentedVC.photoId = albumInfo["photo_id"] as! Int
                    presentedVC.pageId = albumInfo["page_id"] as! Int
                case "sitestore_photo":
                    presentedVC.photoId = albumInfo["photo_id"] as! Int
                    presentedVC.contentId = albumInfo["store_id"] as! Int
                case "sitegroup_photo":
                    
                    presentedVC.albumId = "\(albumInfo["album_id"]!)"
                    presentedVC.groupId = albumInfo["group_id"] as! Int
                default:
                    break
                    
                }
               
                presentedVC.contentType = contentType
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }else{
                showToast(message: "You do not have permission to view this private page.", controller: self)
            }
            
        }else{
            let albumInfo:NSDictionary!
            albumInfo = albumResponse[row] as! NSDictionary
            let presentedVC = AlbumProfileViewController()
            presentedVC.albumId = "\(albumInfo["album_id"]!)"
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.contentType == "" {
            if self.canCreateAlbum {
                if indexPath.row == 0 {
                    isCreateOrEdit = true
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add New Photos", comment: "")
                    presentedVC.contentType = "Album"
                    presentedVC.param = [ : ]
                    presentedVC.url = "albums/upload"
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:true, completion: nil)
                }
                else {
                    checkAlbumPassword(row: indexPath.row - 1)
                }
            }
            else {
                checkAlbumPassword(row: indexPath.row)
            }
        }
        else {
            checkAlbumPassword(row: indexPath.row)
        }
    }
    
}

