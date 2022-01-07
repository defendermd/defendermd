//
//  ShareStoryController.swift
//  seiosnativeapp
//
//  Created by BigStep on 22/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

var strPrivacykey = ""
var strPostkey = ""
var isStoryShare = false
var isStoryPost = false
var isStoryUploadingCompleted = true

class ShareStoryController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate,UITableViewDataSource {
    
    //MARK: Outlets and Property
    let cellIdentifier = "cell"
    let tblYourStoryHightConstraintConstant : CGFloat = 300
    var rightBarButtonItem : UIBarButtonItem!
    var arrGetStoryCreate = [CustomFeedPostMenuData]()
    var arrGetFeedPostMenus = [CustomFeedPostMenuData]()
    @IBOutlet weak var viewYourStory: UIView!
    @IBOutlet weak var tblYourStory: UITableView!
    @IBOutlet weak var tblYourStoryHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgPeofile: DesignableImageView!
    @IBOutlet weak var imgStoryCheck: UIImageView!
    @IBOutlet weak var btnStoryClicked: UIButton!
    @IBOutlet weak var btnStorySetting: UIButton!
    @IBOutlet weak var lblStoryDesc: UILabel!
    @IBOutlet weak var lblYourStory: UILabel!
    
    @IBOutlet weak var imgPostIcon: UIImageView!
    @IBOutlet weak var btnPostAction: UIButton!
    @IBOutlet weak var imgPostCheck: UIImageView!
    @IBOutlet weak var lblPostDesc: UILabel!
    @IBOutlet weak var viewContainerYourStoryTableView: UIView!
    
    @IBOutlet weak var btnPostPrivacy: UIButton!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var viewPost: UIView!
    
    @IBOutlet weak var imgPostSettings: UIImageView!
    @IBOutlet weak var imgStorySetting: UIImageView!
    @IBOutlet weak var tblPost: UITableView!
    @IBOutlet weak var viewPostContainerTableView: UIView!
    var duration = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        isStoryShare = true
        isStoryPost = false
        
        CreateNavigation()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetStoryCreate") as? Data {
            if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                arrGetStoryCreate = arrStoriesDataTemp.sorted(by: { $0.value < $1.value })
            }
        }
        lblYourStory.text = NSLocalizedString("Your Story", comment: "")
        lblPost.text = NSLocalizedString("Post", comment: "")
        var isSelected = false
        print(storyDuration)
        for item in arrGetStoryCreate {
            if item.isSelected == 1
            {
                strPrivacykey = item.key
                lblStoryDesc.text = String(format: NSLocalizedString("Visible to %@ for %@ day", comment: ""),"\(item.value)","\(storyDuration)")
                isSelected = true
                break
            }
        }
        duration = "\(storyDuration)"
        // print(arrGetStoryCreate)
        for (index, item) in arrGetStoryCreate.enumerated()
        {
            if item.key == "everyone"
            {
                if isSelected == false
                {
                    strPrivacykey = item.key
                    item.isSelected = 1
                    lblStoryDesc.text = String(format : NSLocalizedString("Visible to %@ for %@ day", comment: ""),item.value, duration)
                    
                }
                arrGetStoryCreate.remove(at: index)
                //                arrGetStoryCreate.insert(item, at: 0)
                arrGetStoryCreate.insert(item, at: index)
            }
            else if item.key == "networks"
            {
                arrGetStoryCreate.remove(at: index)
                //                arrGetStoryCreate.insert(item, at: 2 < arrGetStoryCreate.count ? 2 : arrGetStoryCreate.count - 1)
                arrGetStoryCreate.insert(item, at: index)
            }
            else if item.key == "friends"
            {
                arrGetStoryCreate.remove(at: index)
                //                arrGetStoryCreate.insert(item, at: 1 < arrGetStoryCreate.count ? 1 : arrGetStoryCreate.count - 1)
                arrGetStoryCreate.insert(item, at: index)
            }
        }
        self.tblYourStory.dataSource = self
        self.tblYourStory.delegate = self
        tblYourStory.tableFooterView = UIView()
        //  viewContainerYourStoryTableView.dropShadow()
        
        if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetFeedPostMenus") as? Data {
            
            if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                arrGetFeedPostMenus = arrStoriesDataTemp.sorted(by: { $0.value < $1.value })
                print(arrGetFeedPostMenus)
            }
            
        }
        
        isSelected = false
        for item in arrGetFeedPostMenus {
            if item.isSelected == 1
            {
                strPostkey = item.key
                // lblPostDesc.text = String(format: NSLocalizedString("Share with %@", comment: ""),item.value)
                lblPostDesc.text = String(format: NSLocalizedString("Share with %@", comment: ""),"\(item.value)")
                isSelected = true
                break
            }
        }
        
        for (index, item) in arrGetFeedPostMenus.enumerated()
        {
            if item.key == "everyone"
            {
                if isSelected == false
                {
                    strPostkey = item.key
                    item.isSelected = 1
                    lblPostDesc.text = String(format: NSLocalizedString("Share with %@", comment: ""),"\(item.value)")
                }
                arrGetFeedPostMenus.rearrange(from: index, to: 0)
            }
            else if item.key == "networks"
            {
                arrGetFeedPostMenus.rearrange(from: index, to: 1 < arrGetFeedPostMenus.count ? 1 : arrGetFeedPostMenus.count - 1)
            }
            else if item.key == "friends"
            {
                arrGetFeedPostMenus.rearrange(from: index, to: 2 < arrGetFeedPostMenus.count ? 2 : arrGetFeedPostMenus.count - 1)
            }
            else if item.key == "onlyme"
            {
                arrGetFeedPostMenus.rearrange(from: index, to: 3 < arrGetFeedPostMenus.count ? 3 : arrGetFeedPostMenus.count - 1)
            }
        }
        if arrGetFeedPostMenus.count >= 5
        {
            arrGetFeedPostMenus.rearrange(from: 2, to: 4)
            arrGetFeedPostMenus.rearrange(from: 2, to: 3)
        }
        
        self.tblPost.dataSource = self
        self.tblPost.delegate = self
        tblPost.tableFooterView = UIView()
        // viewPostContainerTableView.dropShadow()
        
        imgStoryCheck.image = UIImage(named: "StoryIcons_Check")!.maskWithColor(color: .white)
        imgStoryCheck.backgroundColor = navColor
        imgPostCheck.image = UIImage(named: "StoryIcons_uncheck")!.maskWithColor(color: textColorMedium)
        imgPostCheck.backgroundColor = .clear
        imgPostSettings.image = UIImage(named: "StoryIcons_Setting")!.maskWithColor(color: textColorMedium)
        imgStorySetting.image = UIImage(named: "StoryIcons_Setting")!.maskWithColor(color: textColorMedium)
        imgPostIcon.image = UIImage(named: "StoryIcons_Post")!.maskWithColor(color: .white)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetStoryCreate)
        UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetStoryCreate")
        
        let storiesBrowseData2 = NSKeyedArchiver.archivedData(withRootObject: arrGetFeedPostMenus)
        UserDefaults.standard.set(storiesBrowseData2, forKey: "arrGetFeedPostMenus")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Create navigation
    func CreateNavigation()
    {
        self.title = NSLocalizedString("Share Story",comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(backButton))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 44))
        rightNavView.backgroundColor = UIColor.clear
        let tapViewRight = UITapGestureRecognizer(target: self, action: #selector(shareStoryBarButton))
        rightNavView.addGestureRecognizer(tapViewRight)
        let backIconImageViewRight = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageViewRight.image = UIImage(named: "StoryIcons_Right")!.maskWithColor(color: textColorPrime)
        rightNavView.addSubview(backIconImageViewRight)
        
        rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        
        imgPeofile.image = imageProfile
    }
    
    @objc func backButton(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    @objc func shareStoryBarButton(){
        isViewWillAppearCall = 2
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is AdvanceActivityFeedViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    @objc func tapGestureHandler() {
        setViewHideShow(view: viewContainerYourStoryTableView, hidden: true)
        setViewHideShow(view: viewPostContainerTableView, hidden: true)
    }
    //MARK: IBActions and Methods
    @IBAction func btnStoryClickedAction(_ sender: UIButton) {
        if sender.tag == 0 {
            isStoryShare = true
            sender.tag = 100
            lblYourStory.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            imgStoryCheck.image = UIImage(named: "StoryIcons_Check")!.maskWithColor(color: .white)
            imgStoryCheck.backgroundColor = navColor
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        }
        else
        {
            isStoryShare = false
            sender.tag = 0
            lblYourStory.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            imgStoryCheck.image = UIImage(named: "StoryIcons_uncheck")!.maskWithColor(color: textColorMedium)
            imgStoryCheck.backgroundColor = .clear
            if btnPostAction.tag == 0
            {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    @IBAction func btnStorySettingAction(_ sender: UIButton)
    {
        tblYourStory.reloadData()
        setViewHideShow(view: viewContainerYourStoryTableView, hidden: false)
    }
    @IBAction func btnPostClickedAction(_ sender: UIButton)
    {
        if sender.tag == 0 {
            isStoryPost = true
            sender.tag = 101
            lblPost.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            imgPostCheck.image = UIImage(named: "StoryIcons_Check")!.maskWithColor(color: .white)
            imgPostCheck.backgroundColor = navColor
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        }
        else
        {
            isStoryPost = false
            sender.tag = 0
            lblPost.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            imgPostCheck.image = UIImage(named: "StoryIcons_uncheck")!.maskWithColor(color: textColorMedium)
            imgPostCheck.backgroundColor = .clear
            if btnStoryClicked.tag == 0
            {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    @IBAction func btnPostPrivacyAction(_ sender: UIButton)
    {
        tblPost.reloadData()
        setViewHideShow(view: viewPostContainerTableView, hidden: false)
    }
    
    
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    //MARK:- Gesture Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: tblYourStory) == true {
            return false
        }
        if touch.view?.isDescendant(of: tblPost) == true {
            return false
        }
        return true
    }
    
    // MARK: TABLEVIEW DATASOURCE and DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblYourStory
        {
            return arrGetStoryCreate.count
        }
        else
        {
            return arrGetFeedPostMenus.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblYourStory
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
            let customModel = arrGetStoryCreate[indexPath.row]
            cell.lblTitle.text = customModel.value
            cell.lblTitle.textColor = textColorDark
            if customModel.isSelected == 1
            {
                cell.imgCheck.isHidden = false
                cell.imgCheck.image = UIImage(named: "StoryIcons_CheckSquare")
                cell.imgCheck.backgroundColor = navColor
            }
            else
            {
                cell.imgCheck.isHidden = true
            }
            
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StoryTableViewCell
            let customModel = arrGetFeedPostMenus[indexPath.row]
            cell.lblTitle.text = customModel.value
            cell.lblTitle.textColor = textColorDark
            if customModel.isSelected == 1
            {
                cell.imgCheck.isHidden = false
                cell.imgCheck.image = UIImage(named: "StoryIcons_CheckSquare")
                cell.imgCheck.backgroundColor = navColor
            }
            else
            {
                cell.imgCheck.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblYourStory
        {
            for (index,customModel) in arrGetStoryCreate.enumerated() {
                customModel.isSelected = 0
                arrGetStoryCreate.remove(at: index)
                arrGetStoryCreate.insert(customModel, at: index)
            }
            let customModel = arrGetStoryCreate[indexPath.row]
            strPrivacykey = customModel.key
            customModel.isSelected = 1
            //            lblStoryDesc.text = String(format: NSLocalizedString("Visible to %@ for \(storyDuration) day", comment: ""),customModel.value)
            lblStoryDesc.text = String(format: NSLocalizedString("Visible to %@ for %@ day", comment: ""),customModel.value, duration)
            arrGetStoryCreate.remove(at: indexPath.row)
            arrGetStoryCreate.insert(customModel, at: indexPath.row)
            setViewHideShow(view: viewContainerYourStoryTableView, hidden: true)
        }
        else
        {
            for (index,customModel) in arrGetFeedPostMenus.enumerated() {
                customModel.isSelected = 0
                arrGetFeedPostMenus.remove(at: index)
                arrGetFeedPostMenus.insert(customModel, at: index)
            }
            let customModel = arrGetFeedPostMenus[indexPath.row]
            customModel.isSelected = 1
            strPostkey = customModel.key
            lblPostDesc.text = String(format: NSLocalizedString("Share with %@", comment: ""),"\(customModel.value)")
            
            arrGetFeedPostMenus.remove(at: indexPath.row)
            arrGetFeedPostMenus.insert(customModel, at: indexPath.row)
            setViewHideShow(view: viewPostContainerTableView, hidden: true)
        }
        
    }
}


