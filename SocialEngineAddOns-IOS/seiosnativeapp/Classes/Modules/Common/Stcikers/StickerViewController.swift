//
//  StickerViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 17/11/17.
//  Copyright © 2017 bigstep. All rights reserved.
//


import UIKit
var searchStickersArray : NSArray = [] // Search list Array
class StickerViewController: UIViewController{
    
    let mainView = UIView()
    var pageOption:UIButton!
    let scrollView = UIScrollView()
    var searchDictionary = Dictionary<String, String>()
    var stikerView = UIView()
    var updateStickerView = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateStickerView = true
        view.backgroundColor = textColorLight
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(StickerViewController.cancel))
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel
        
        allStickersDic.removeAll(keepingCapacity : false)
        searchStickersArray = [ ]
        createScrollPageMenu()
 
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if StickerPlugin == true{
                searchDictionary.removeAll(keepingCapacity: false)
                self.getStickers()
        }
    }
    
    func createScrollPageMenu()
    {
        scrollView.frame = CGRect(x:0, y: TOPPADING, width:  view.bounds.width, height:  ButtonHeight+10)
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0.0
        var eventMenu = ["Sticker","Feeling"]
        for i in 100 ..< 102
        {
            menuWidth = CGFloat((view.bounds.width)/2)
            if i == 100
            {   pageOption =  createNavigationButton(CGRect(x:origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
            }else{
                pageOption =  createNavigationButton(CGRect(x:origin_x, y: -ScrollframeY, width: menuWidth , height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
            }
            pageOption.tag = i
            pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            pageOption.addTarget(self, action:#selector(StickerViewController.pageSelectOptions(_:)), for: .touchUpInside)
            pageOption.backgroundColor =  UIColor.clear
            pageOption.alpha = 1.0
            if i==102
            {
                pageOption.alpha = 0.4
            }
            scrollView.addSubview(pageOption)
            origin_x += menuWidth
        }
        scrollView.contentSize = CGSize( width: origin_x + 10, height: ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        mainView.addSubview(scrollView)
    }
    
    
    
    @objc func pageSelectOptions( _ sender: UIButton)
    {
        let productBrowseType = sender.tag - 100
        for ob in scrollView.subviews{
            if ob .isKind(of:UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                    }
                }
            }
        }
        if productBrowseType == 0
        {
            stikerView.isHidden = false
        }
        else if productBrowseType == 1
        {
            stikerView.isHidden = true
        }
    }
    
    
    
    //MARK: Get All Initial Stickers
    func  getStickers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            activityIndicatorView.startAnimating()
            
            if searchDictionary.count > 0{
                let keyword : String = searchDictionary["search"]!
                dic["sticker_search"] = keyword
            }
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                // Check for Stickers Array that
                                if let stickerArray = body["collectionList"] as? NSArray
                                {
                                    sticterArray = stickerArray as! NSMutableArray
                                    allStickersDic.removeAll(keepingCapacity : false)
                                    for i in 0..<sticterArray.count {
                                        let singleStickerDictionary = sticterArray[i] as! NSDictionary
                                        let order = singleStickerDictionary["order"] as? Int
                                        allStickersDic["\(order!)"] = singleStickerDictionary
                                    }
                                    if let searchStickersArray1 = body["searchList"] as? NSArray
                                    {
                                        searchStickersArray = searchStickersArray1
                                    }
                                    if self.searchDictionary.count == 0{
                                        self.stikerView = StickerView(frame: CGRect(x:0, y: TOPPADING + ButtonHeight + 10, width: self.view.bounds.width, height: self.view.bounds.height - (TOPPADING + ButtonHeight + 10)))
                                        self.stikerView.backgroundColor = bgColor
                                        self.mainView.addSubview(self.stikerView)
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
    
    @objc func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
}
