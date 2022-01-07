//
//  stickerView.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 21/11/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
protocol StickerFetchImage {
    func getStickerImage(strImage : String)
    func pushAddRemoveStickersViewController()
}
extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

class StickerView: UIView , UIScrollViewDelegate,UISearchBarDelegate{
    
    var delegateSticker: StickerFetchImage?
    var isComingFromMovingView = false
    let stickerScrollView = UIScrollView() // bottom view where all stickers shows with plus icon
    var addSticker = UIButton()         // plus icon button at bottom view
    var indexOfSelectedSticker : Int! // index of selected sticker
    let particularStickersView =  UIScrollView() //  view where we set all particular sticker
    let searchBar = UISearchBar() // search bar where you can search sticker
    var allStickersOfParticularSticker : NSArray = [] // all stickers corresponding to particular
    var allStickersOfParticularStickernNew  = [NSArray]()
    var particularStickersViewHeight : CGFloat! = 210  // Only particular Sticker height
    var totalStickerViewHeight : CGFloat! = 250 // Total view height
    var statusofResponse : Bool = false
    let searchedStickersView = UIScrollView() // show view after searching stickers
    var searchDictionary = Dictionary<String, String>() // search stickers parameter
    var searchedStickers : NSArray = [] // Array where all searched stickers stored
    var currentPage : Int = 1  // current page of a view
    var stickerParameters = Dictionary<String, String>() //   we clicked on particular stickers then parameter od that sticker stored here
    var dictionaryForStickerImageStringToPost = Dictionary<String, String>()
    var stickerImageStringToPost : String = "" // sticker image url
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StickerView.dismissKeyboard))
        self.addGestureRecognizer(tap)
        getIntialSticker()
        getAllStickers()
        particularStickersViewHeight = self.bounds.height - 40 - iphonXBottomsafeArea
        totalStickerViewHeight = self.bounds.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.endEditing(true)
    }
    
    func updateUIAccordinglyStorie()
    {
        
    }
    
    //MARK:  UI of  all initial stickers that is present in our app (ie bottom view where all stickers shown)
    func getIntialSticker(){
        stickerScrollView.frame = CGRect(x: 0, y: self.bounds.height - 40 - iphonXBottomsafeArea, width: self.bounds.width - 60 , height: 40)
        stickerScrollView.delegate = self
        stickerScrollView.tag = 2;
        stickerScrollView.isHidden = false
        var menuWidth = CGFloat()
        var origin_x:CGFloat = PADING
        menuWidth = 40
        for ob in self.stickerScrollView.subviews{
            ob.removeFromSuperview()
        }
        let viewBorder = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        viewBorder.backgroundColor = UIColor.lightGray
        stickerScrollView.addSubview(viewBorder)
        // if searchStickersArray contain element then
        if searchStickersArray.count > 0{
            let  singleSticker =    createButton(CGRect(x: origin_x,y: PADING ,width: 35,height: 35), title: "\u{f002}", border: false,bgColor: false, textColor: UIColor.lightGray)
            singleSticker.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            singleSticker.tag = 0
            singleSticker.backgroundColor = aafBgColor
            singleSticker.addTarget(self, action: #selector(StickerView.viewParticularSticker(_:)), for: UIControl.Event.touchUpInside)
            stickerScrollView.addSubview(singleSticker)
            origin_x += menuWidth
        }
        var i = 0
        for(_,v) in allStickersDic.sorted(by: { $0.0 < $1.0 }){
            let  singleSticker =    createButton(CGRect(x: origin_x,y: PADING,width: 35,height: 35), title: "", border: false,bgColor: false, textColor: textColorMedium)
            let singleStickerDictionary = v as! NSDictionary
            if singleStickerDictionary["image_icon"] != nil{
                let icon = singleStickerDictionary["image_icon"]
                let url = URL(string:icon as! String)
                if searchStickersArray.count > 0{
                    singleSticker.tag = i + 1
                }
                else{
                    singleSticker.tag = i
                }
                singleSticker.addTarget(self, action: #selector(StickerView.viewParticularSticker(_:)), for: UIControl.Event.touchUpInside)
                singleSticker.backgroundColor = UIColor.clear
                singleSticker.kf.setImage(with: url as URL?, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
            i = i + 1
            stickerScrollView.addSubview(singleSticker)
            origin_x += menuWidth
        }
        stickerScrollView.contentSize = CGSize(width: origin_x,height: 40)
        stickerScrollView.bounces = false
        stickerScrollView.isUserInteractionEnabled = true
        stickerScrollView.showsVerticalScrollIndicator = false
        stickerScrollView.showsHorizontalScrollIndicator = false
        self.stickerScrollView.alwaysBounceHorizontal = true
        self.stickerScrollView.alwaysBounceVertical = false
        stickerScrollView.isDirectionalLockEnabled = true
        self.addSubview(stickerScrollView)
        addSticker =    createButton(CGRect(x: self.bounds.width - 60,y: self.bounds.height - 40 - iphonXBottomsafeArea ,width: 60,height: 40), title: "\u{f067}", border: false,bgColor: false, textColor: UIColor.lightGray)
        addSticker.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        addSticker.tag = 10000
        addSticker.isHidden = false
        addSticker.titleLabel?.textAlignment = .center
        for ob in self.subviews{
            if ob.tag == 10000{
                ob.removeFromSuperview()
                break
            }
        }
        addSticker.addTarget(self, action: #selector(StickerView.addRemoveStickers), for: UIControl.Event.touchUpInside)
        self.addSubview(addSticker)
        
        
        let viewBorder1 = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        viewBorder1.backgroundColor = UIColor.lightGray
        addSticker.addSubview(viewBorder1)
        
    }
    
    @objc func addRemoveStickers(){
//        let presentedVC = AddRemoveStickersViewController()
//        if presentedVC.isModal {
//            self.parentViewController()?.present(presentedVC, animated: true, completion: nil)
//        }
//        else
//        {
//            self.parentViewController()?.navigationController?.pushViewController(presentedVC, animated: true)
//        }
        
        delegateSticker?.pushAddRemoveStickersViewController()
        
    }
    
    //MARK:  View Particular Stickers after Click On Particular Sticker
    @objc func viewParticularSticker(_ sender: UIButton)
    {
        indexOfSelectedSticker = sender.tag
        let width = (sender.tag) * Int(self.bounds.width)
        particularStickersView.setContentOffset(CGPoint(x : width, y :0), animated: true)
    }
    
    //MARK: Call function get All Stickers of Particular Sticker
    func getAllStickers(){
        allStickersValueDic.removeAll(keepingCapacity : false)
        if sticterArray.count != 0
        {
            for i in 1...sticterArray.count {
                self.getAllStickersOfParticularSticker(sender: i)
            }
        }
    }
    
    //MARK: get All Stickers of Particular Sticker
    func  getAllStickersOfParticularSticker(sender : Int){
        var collectionId : Int!
        var order : Int = 0
        if let dic = sticterArray[sender - 1] as? NSDictionary{
            if let collectionid = dic["collection_id"] as? Int{
                collectionId = collectionid
            }
        }
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            dic["collection_id"] = String(collectionId)
//            spinner.center = (UIApplication.shared.keyWindow?.center)!
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            UIApplication.shared.keyWindow?.addSubview(spinner)
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
            activityIndicatorView.center = (UIApplication.shared.keyWindow?.center)!
            activityIndicatorView.startAnimating()
            
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let stickerArray = body["collection"] as? NSDictionary{
                                    if let orderOfSticker = stickerArray["order"] as? Int{
                                        order = orderOfSticker
                                    }
                                }
                                // Check for Stickers Array
                                if let stickerArrayy = body["stickers"] as? NSArray
                                {
                                    self.allStickersOfParticularSticker = stickerArrayy
                                    let value = stickerArrayy
                                    allStickersValueDic["\(order)"] = value
                                    if allStickersValueDic.keys.count == sticterArray.count{
                                        //   statusofResponse is the Varible that shows all response regarding all sticker whether come or not
                                        self.statusofResponse = true
                                        self.stickersUI()
                                    }
                                }
                            }
                        }
                    }
                    else{
                        self.statusofResponse = false
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            self.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
        
    }
    
    //MARK:  After fetch all stickers then Set UI
    func stickersUI(){
        for ob in self.particularStickersView.subviews{
            ob.removeFromSuperview()
        }
        particularStickersView.frame = CGRect(x: 0, y: self.bounds.height - self.totalStickerViewHeight, width: self.bounds.width , height: self.particularStickersViewHeight)
        particularStickersView.delegate = self
        particularStickersView.tag = 3;
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0
        let origin_y:CGFloat = 0
        var j = 0
        if searchStickersArray.count > 0{
            menuWidth = self.bounds.width
            j = 1
            let scrollViewParticularSticker = UIScrollView()
            scrollViewParticularSticker.frame = CGRect(x: origin_x, y: origin_y, width: self.bounds.width , height: self.particularStickersViewHeight)
            scrollViewParticularSticker.delegate = self
            if isComingFromMovingView
            {
                scrollViewParticularSticker.backgroundColor = .clear
            }
            else
            {
                scrollViewParticularSticker.backgroundColor = tableViewBgColor
            }
            
            // SearchView that shows searchBar
            let searchView  =  UIView(frame:CGRect(x: 0, y: 0, width: scrollViewParticularSticker.bounds.width, height: 50))
            scrollViewParticularSticker.addSubview(searchView)
            // Set Color for Search Bar and For Search Icon
            let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = UIColor.red
            let placeholderAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray, NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: UIFont.systemFontSize)]
            let attributedPlaceholder: NSAttributedString = NSAttributedString(string: NSLocalizedString("Search Stickers",  comment: ""), attributes: placeholderAttributes)
            textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
            let imageV = textFieldInsideSearchBar?.leftView as! UIImageView
            imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imageV.tintColor = UIColor.lightGray
            
            searchBar.searchBarStyle = UISearchBar.Style.minimal
            searchBar.layer.borderWidth = 0;
            searchBar.layer.shadowOpacity = 0;
            searchBar.setTextColor(UIColor.lightGray)
            searchBar.sizeToFit()
            searchBar.delegate = self
            searchView.addSubview(searchBar)
            // Predefine Search Stickers
            let scrollViewForSearchSticker = UIScrollView()
            scrollViewForSearchSticker.frame = CGRect(x: 0, y: 50, width: self.bounds.width , height: self.particularStickersViewHeight - 50)
            scrollViewForSearchSticker.delegate = self
            scrollViewForSearchSticker.tag = 0
            if isComingFromMovingView
            {
                scrollViewForSearchSticker.backgroundColor = .clear
            }
            else
            {
                scrollViewForSearchSticker.backgroundColor =  tableViewBgColor
            }
            
            scrollViewParticularSticker.addSubview(scrollViewForSearchSticker)
            var loop : Int = 0
            var origin_labelheight_y2 : CGFloat = 5
            var origin_labelheight_y : CGFloat = 5
            // For Predefine Search Stickers
            for i in 1...searchStickersArray.count {
                if let dic = searchStickersArray[i-1] as? NSDictionary{
                    if loop % 2 == 0{
                        let  singleSticker =    createButton(CGRect(x: 5,y: origin_labelheight_y ,width: self.bounds.width/2 - 10 ,height: 40), title: "", border: false,bgColor: false, textColor: textColorLight)
                        singleSticker.layer.cornerRadius = 10.0
                        singleSticker.tag = i - 1
                        singleSticker.addTarget(self, action: #selector(StickerView.searchParticularSticker(_:)), for: UIControl.Event.touchUpInside)
                        stickerScrollView.addSubview(singleSticker)
                        if dic["background_color"] != nil{
                            let color = dic["background_color"]
                            let realColor = hexStringToUIColor(hex: color as! String)
                            singleSticker.backgroundColor = realColor
                        }
                        let searchStickerView = createImageView(CGRect(x: 10, y: 10, width: 20, height: 20), border: false)
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            searchStickerView.kf.indicatorType = .activity
                            (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        singleSticker.addSubview(searchStickerView)
                        let stickerSearchLabel = createLabel(CGRect(x: searchStickerView.frame.size.width + searchStickerView.frame.origin.x + 5,y: 0,width: singleSticker.frame.size.width - (searchStickerView.frame.size.width + searchStickerView.frame.origin.x + 5) , height: 40), text: "", alignment: .center, textColor: textColorLight)
                        stickerSearchLabel.font = UIFont(name: fontBold, size: FONTSIZELarge)
                        stickerSearchLabel.textAlignment = NSTextAlignment.left
                        if dic["title"] != nil{
                            var title =  String(describing: dic["title"]!)
                            title = title.capitalized
                            stickerSearchLabel.text = title
                        }
                        singleSticker.addSubview(stickerSearchLabel)
                        origin_labelheight_y  = origin_labelheight_y + singleSticker.bounds.height + 10
                        loop = loop + 1
                        scrollViewForSearchSticker.addSubview(singleSticker)
                    }
                    else{
                        let  singleSticker1 =    createButton(CGRect(x: self.bounds.width/2 + 5,y: origin_labelheight_y2 ,width: self.bounds.width/2 - 10 ,height: 40), title: "", border: false,bgColor: false, textColor: textColorMedium)
                        singleSticker1.tag = i - 1
                        singleSticker1.layer.cornerRadius = 10.0
                        singleSticker1.addTarget(self, action: #selector(StickerView.searchParticularSticker), for: UIControl.Event.touchUpInside)
                        if dic["background_color"] != nil{
                            let color = dic["background_color"]
                            let realColor = hexStringToUIColor(hex: color as! String)
                            singleSticker1.backgroundColor = realColor
                        }
                        stickerScrollView.addSubview(singleSticker1)
                        var searchStickerView1 = createImageView(CGRect(x: 10, y: 10, width: 20, height: 20), border: false)
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            searchStickerView1.kf.indicatorType = .activity
                            (searchStickerView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            searchStickerView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        singleSticker1.addSubview(searchStickerView1)
                        let stickerSearchLabel1 = createLabel(CGRect(x: searchStickerView1.frame.size.width + searchStickerView1.frame.origin.x + 5,y: 0,width: singleSticker1.frame.size.width - (searchStickerView1.frame.size.width + searchStickerView1.frame.origin.x + 5) , height: 40), text: "", alignment: .center, textColor: textColorLight)
                        if dic["title"] != nil{
                            var title =  String(describing: dic["title"]!)
                            title = title.capitalized
                            stickerSearchLabel1.text = title
                        }
                        stickerSearchLabel1.textAlignment = NSTextAlignment.left
                        stickerSearchLabel1.font = UIFont(name: fontBold, size: FONTSIZELarge)
                        singleSticker1.addSubview(stickerSearchLabel1)
                        origin_labelheight_y2  = origin_labelheight_y2 + singleSticker1.bounds.height + 10
                        loop = loop + 1
                        scrollViewForSearchSticker.addSubview(singleSticker1)
                    }
                }
            }
            scrollViewForSearchSticker.contentSize = CGSize(width: self.bounds.width,height: origin_labelheight_y)
            particularStickersView.addSubview(scrollViewParticularSticker)
            origin_x = origin_x + scrollViewParticularSticker.bounds.width
        }
        // statusofResponse is the Varible that shows all response regarding all sticker whether come or not
        if statusofResponse == true{
            
            for(_,v) in allStickersValueDic.sorted(by: { $0.0 < $1.0 }){
                let scrollViewParticularSticker = UIScrollView()
                self.allStickersOfParticularSticker =  v as! NSArray
                let origin_x2:CGFloat = (self.bounds.width *  CGFloat(j))
                let origin_y2:CGFloat = 0
                // code for all stickers
                if self.allStickersOfParticularSticker.count > 0{
                    var menuWidth1 = CGFloat()
                    var menuHeight1 = CGFloat()
                    var origin_x1:CGFloat = PADING
                    var origin_y1:CGFloat = PADING
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        menuWidth1 = (self.bounds.width/8) - 10
                        menuHeight1 = (self.bounds.width/8) - 10
                    }
                    else{
                        menuWidth1 = (self.bounds.width/4) - 10
                        menuHeight1 = (self.bounds.width/4) - 10
                    }
                    scrollViewParticularSticker.frame = CGRect(x: origin_x2, y: origin_y2, width: self.bounds.width , height: self.particularStickersViewHeight)
                    scrollViewParticularSticker.delegate = self
                    scrollViewParticularSticker.tag = j
                    if isComingFromMovingView
                    {
                        scrollViewParticularSticker.backgroundColor = .clear
                    }
                    else
                    {
                        scrollViewParticularSticker.backgroundColor = tableViewBgColor
                    }
                    
                    for  i in 1...self.allStickersOfParticularSticker.count {
                        let  imageViewClick : UIButton!
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.bounds.width/8) - 10, height: (self.bounds.width/8) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                        }
                        else{
                            imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.bounds.width/4) - 10, height: (self.bounds.width/4) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                        }
                        let searchStickerView = createImageView(CGRect(x: 0, y: 0, width: imageViewClick.bounds.width, height: imageViewClick.bounds.height), border: true)
                        if let dic = allStickersOfParticularSticker[i - 1] as? NSDictionary{
                            if dic["image"] != nil{
                                let icon = dic["image"]
                                let url = URL(string:icon as! String)
                                if url != nil
                                {
                                    searchStickerView.kf.indicatorType = .activity
                                    (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                                
                            }
                            if dic["collection_id"] != nil{
                                let stickerId = dic["collection_id"] as? Int
                                imageViewClick.tag = stickerId!
                            }
                            if dic["sticker_id"] != nil{
                                let stickerId = dic["sticker_id"] as? Int
                                imageViewClick.tag = stickerId!
                                imageViewClick.addTarget(self, action: #selector(StickerView.postStickers(_:)), for: UIControl.Event.touchUpInside)
                            }
                        }
                        scrollViewParticularSticker.addSubview(imageViewClick)
                        imageViewClick.addSubview(searchStickerView)
                        origin_x1 = menuWidth1 + origin_x1 + 10
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            if i%8 == 0{
                                origin_x1 = PADING
                                origin_y1 = menuHeight1 + origin_y1 +  10 // + PADING
                            }
                        }
                        else{
                            if i%4 == 0{
                                origin_x1 = PADING
                                origin_y1 = menuHeight1 + origin_y1 +  10 // + PADING
                            }
                        }
                    }
                    if self.allStickersOfParticularSticker.count  % 4 != 0{
                        origin_y1 = menuHeight1 + origin_y1 + 10   // + PADING
                    }
                    particularStickersView.addSubview(scrollViewParticularSticker)
                    scrollViewParticularSticker.alwaysBounceHorizontal = false
                    scrollViewParticularSticker.alwaysBounceVertical = true
                    scrollViewParticularSticker.contentSize = CGSize(width: self.bounds.width,height: origin_y1)
                }
                j = j + 1
                origin_x = origin_x + menuWidth
            }
        }
        else{
            for  _ in 0..<sticterArray.count {
                origin_x = origin_x + menuWidth
            }
        }
        particularStickersView.contentSize = CGSize(width: origin_x,height: self.particularStickersViewHeight)
        particularStickersView.delegate = self
        particularStickersView.isPagingEnabled = true
        particularStickersView.bounces = false
        particularStickersView.isUserInteractionEnabled = true
        particularStickersView.isScrollEnabled = true
        particularStickersView.isHidden = false
        self.particularStickersView.alwaysBounceHorizontal = true
        self.particularStickersView.alwaysBounceVertical = false
        particularStickersView.isDirectionalLockEnabled = false
        self.addSubview(particularStickersView)
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 3
        {
            
            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            currentPage = Int(page)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        let totalWidthWithOriginY = ob.frame.origin.x + ob.frame.size.width
                        let widthOfParticularSticker = stickerScrollView.frame.size.width
                        if totalWidthWithOriginY > stickerScrollView.frame.size.width{
                            let difference = totalWidthWithOriginY - widthOfParticularSticker
                            stickerScrollView.setContentOffset(CGPoint(x : difference, y :0), animated: true)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: When ScrollView Stop Scrolling
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.tag == 3
        {
            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        ob.backgroundColor = aafBgColor
                    }
                    else{
                        ob.backgroundColor = UIColor.clear
                    }
                }
            }
        }
    }
    
    // The scroll view calls this method when the scrolling movement comes to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView.tag == 3
        {
            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        ob.backgroundColor = aafBgColor
                    }
                    else{
                        ob.backgroundColor = UIColor.clear
                    }
                }
            }
        }
    }
    
    
    //MARK: Search Stickers
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchDictionary.removeAll(keepingCapacity: false)
        searchDictionary["search"] = searchBar.text
        searchBar.resignFirstResponder()
        getSearchedStickers()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: When we click on predefine search stickers
    @objc func searchParticularSticker(_ sender: UIButton){
        if let dic = searchStickersArray[sender.tag] as? NSDictionary{
            let keyword = dic["keyword"] as! String
            searchBar.text = keyword
            searchDictionary.removeAll(keepingCapacity: false)
            searchDictionary["search"] = keyword
            searchBar.resignFirstResponder()
            getSearchedStickers()
        }
    }
    
    //MARK: After Search for showing results
    func afterSearchStickers(){
        searchedStickersView.isHidden = false
        searchedStickersView.frame = CGRect(x: 0, y: 50, width: self.bounds.width , height: self.particularStickersViewHeight - 50)
        searchedStickersView.delegate = self
        searchedStickersView.tag = 0
        if isComingFromMovingView
        {
             searchedStickersView.backgroundColor = .black
        }
        else
        {
             searchedStickersView.backgroundColor =  tableViewBgColor
        }
        particularStickersView.addSubview(searchedStickersView)
        if searchDictionary.count > 0 {
            searchBar.text = searchDictionary["search"]
            var origin_x1:CGFloat = PADING
            var origin_y1:CGFloat = PADING
            var menuWidth1 = CGFloat()
            var menuHeight1 = CGFloat()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                menuWidth1 = (self.bounds.width/8) - 10
                menuHeight1 = (self.bounds.width/8) - 10
            }
            else{
                menuWidth1 = (self.bounds.width/4) - 10
                menuHeight1 = (self.bounds.width/4) - 10
            }
            
            for ob in self.searchedStickersView.subviews{
                ob.removeFromSuperview()
            }
            if searchedStickers.count > 0{
                for  i in 1...self.searchedStickers.count {
                    let  imageViewClick : UIButton!
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.bounds.width/8) - 10, height: (self.bounds.width/8) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                    }
                    else{
                        imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.bounds.width/4) - 10, height: (self.bounds.width/4) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                    }
                    let searchStickerView = createImageView(CGRect(x: 0, y: 0, width: imageViewClick.bounds.width, height: imageViewClick.bounds.height), border: true)
                    if let dic = searchedStickers[i - 1] as? NSDictionary{
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            if url != nil
                            {
                                searchStickerView.kf.indicatorType = .activity
                                (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                searchStickerView.layer.borderWidth = 0.0
                            }
                        }
                        if dic["sticker_id"] != nil{
                            let stickerId = dic["sticker_id"] as? Int
                            imageViewClick.tag = stickerId!
                            imageViewClick.addTarget(self, action: #selector(StickerView.postStickersUsingSearchedStickers(_:)), for: UIControl.Event.touchUpInside)
                        }
                    }
                    searchedStickersView.addSubview(imageViewClick)
                    imageViewClick.addSubview(searchStickerView)
                    origin_x1 = menuWidth1 + origin_x1 + 10
                    if i%4 == 0{
                        origin_x1 = PADING
                        origin_y1 = menuHeight1 + origin_y1 + 10
                    }
                }
                if self.searchedStickers.count  % 4 != 0{
                    origin_y1 = menuHeight1 + origin_y1 + 10
                }
            }
            else{
                let noStickers = createLabel(CGRect(x: origin_x1,y: origin_y1,width: searchedStickersView.frame.size.width , height: 30), text: "", alignment: .center, textColor: UIColor.lightGray)
                noStickers.text = NSLocalizedString("No Stickers to Show",  comment: "")
                noStickers.font = UIFont(name: fontBold, size: FONTSIZELarge)
                searchedStickersView.addSubview(noStickers)
                origin_y1 =  origin_y1 + 30
            }
            searchedStickersView.alwaysBounceHorizontal = false
            searchedStickersView.alwaysBounceVertical = true
            searchedStickersView.contentSize = CGSize(width: self.bounds.width,height: origin_y1)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            searchedStickersView.isHidden = true
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        return true
    }
    
    
    //MARK: Get Searched Stickers
    func  getSearchedStickers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
                let keyword : String = searchDictionary["search"]!
                dic["sticker_search"] = keyword
                //print((UIApplication.shared.keyWindow?.center)!)
//                spinner.center = (UIApplication.shared.keyWindow?.center)! //self.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                UIApplication.shared.keyWindow?.addSubview(spinner)
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
            activityIndicatorView.center = (UIApplication.shared.keyWindow?.center)!
                activityIndicatorView.startAnimating()
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let searchStickers = body["stickers"] as? NSArray
                                {
                                    self.searchedStickers = searchStickers
                                    self.afterSearchStickers()
                                }
                            }
                        }
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            self.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    
    // MARK: When click on particular sticker in after searching sticker
    @objc func postStickersUsingSearchedStickers(_ sender: UIButton){
        for  i in 1...self.searchedStickers.count {
            if let dic = searchedStickers[i - 1] as? NSDictionary{
                let stickerId = dic["sticker_id"] as? Int
                if stickerId == sender.tag{
                    stickerParameters["attachment_id"] = dic["guid"] as? String
                    stickerParameters["attachment_type"] =  "sticker"
                    self.stickerImageStringToPost = (dic["image_profile"] as? String)!
                    dictionaryForStickerImageStringToPost["image_profile"] = self.stickerImageStringToPost
                    delegateSticker?.getStickerImage(strImage: self.stickerImageStringToPost)
                    break
                }
            }
        }
        //print(stickerParameters)
        //print(self.stickerImageStringToPost)
    }
    
    
    // MARK:  When click on particular sticker
    @objc func postStickers(_ sender: UIButton){
        let currentStickerPage = currentPage - 1
        var index = 0
        for(_,v) in allStickersValueDic.sorted(by: { $0.0 < $1.0 }){
            if index == currentStickerPage{
                let dic = v as? NSArray
                for tempdic in dic!{
                    let actualDictionary = tempdic as! NSDictionary
                    let collectionID = actualDictionary["sticker_id"]! as? Int
                    if collectionID == sender.tag{
                        stickerParameters["attachment_id"] = actualDictionary["guid"] as? String
                        stickerParameters["attachment_type"] =  "sticker"
                        self.stickerImageStringToPost = (actualDictionary["image_profile"] as? String)!
                        dictionaryForStickerImageStringToPost["image_profile"] = self.stickerImageStringToPost
                        delegateSticker?.getStickerImage(strImage: self.stickerImageStringToPost)
                        break
                    }
                }
            }
            index = index + 1
        }
        //print(stickerParameters)
        //print(self.stickerImageStringToPost)
    }
    
    
    
}


