//
//  StoryNotUploaded.swift
//  seiosnativeapp
//
//  Created by BigStep on 02/09/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class StoryNotUploaded: UIView {

  
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgCamera: UIImageView!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var viewNoStory: UIView!
    @IBOutlet weak var imgProfile2: UIImageView!
    
    @IBOutlet weak var viewUnMuteStoryHieght: NSLayoutConstraint!
    @IBOutlet weak var viewNoStoryHeight: NSLayoutConstraint!
    @IBOutlet weak var lblLongPressUser: UILabel!
    @IBOutlet weak var imgCamera2: UIImageView!
    @IBOutlet weak var imgMuteIcon: UIImageView!
    @IBOutlet weak var viewMuteUnMuteStory: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMuteUnmute: UILabel!
    
    var dataStory : StoriesBrowseData!
    var objAAF : AdvanceActivityFeedViewController?
    var muteURl = ""
    var isMute = false
    
    init(frame: CGRect, vc: UIViewController) {  //To use it in code
        super.init(frame: frame)
        if let viewController = vc as? AdvanceActivityFeedViewController {
            self.objAAF = viewController
        }
        commonInit()
    }
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    @IBAction func btnClickAction(_ sender: Any)
    {
        setViewHideShow(view: self, hidden: true)
    }
    required init?(coder aDecoder: NSCoder) { // To use it in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("StoryNotUploaded", owner: self, options: nil)
        addSubview(viewContainer)
        viewContainer.frame = self.bounds
        viewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewContainer.layer.shadowColor = shadowColor.cgColor
        viewContainer.layer.shadowOffset = shadowOffset
        viewContainer.layer.shadowRadius = shadowRadius
        viewContainer.layer.shadowOpacity = shadowOpacity
        
        imgProfile.image = UIImage(named: "Storyicon_ViewProfile")!.maskWithColor(color: navColor)
        imgCamera.image = UIImage(named: "editPhoto")!.maskWithColor(color: navColor)
        imgProfile2.image = UIImage(named: "Storyicon_ViewProfile")!.maskWithColor(color: navColor)
        imgCamera2.image = UIImage(named: "editPhoto")!.maskWithColor(color: navColor)
        
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            viewUnMuteStoryHieght.constant = 220
            viewNoStoryHeight.constant = 200
            
        default:
            viewUnMuteStoryHieght.constant = 180
            viewNoStoryHeight.constant = 160
            
        }
    }
    
    func updateData(data : StoriesBrowseData)
    {
        dataStory = data
        lblTitle.textColor = textColorMedium
        lblTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        lblTitle.text = "\(data.owner_title) \(NSLocalizedString("hasn't added to his story recently.", comment: ""))"
    }
    
    @IBAction func btnViewProfileAction(_ sender: UIButton)
    {
        setViewHideShow(view: self, hidden: true)
        openProfile()
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton)
    {
        setViewHideShow(view: self, hidden: true)
        sendMessage()
    }
    @IBAction func btnMuteUnMuteAction(_ sender: UIButton) {
        
        if isMute
        {
            let alert = UIAlertController(title: NSLocalizedString("Mute Story", comment: ""), message: NSLocalizedString("You'll stop seeing their Stories, but can still see their status update in feeds.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Mute", comment: ""), style: .default, handler: { action in
                self.API_getMuteUnMute(url: self.muteURl, isMute: self.isMute)
            }))
            objAAF?.present(alert, animated: true, completion: nil)
        }
        else
        {
              let alert = UIAlertController(title: NSLocalizedString("Unmute Story", comment: ""), message: NSLocalizedString("Are you sure that you want to unmute this person?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Unmute", comment: ""), style: .default, handler: { action in
                self.API_getMuteUnMute(url: self.muteURl, isMute: self.isMute)
            }))
            objAAF?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func sendMessage()
    {
        let presentedVC = MessageCreateController()
        //greetingsCheck = true
        presentedVC.checkfrom = "Greetings"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        presentedVC.userID = "\(dataStory.owner_id)"
        presentedVC.fromProfile = true
        presentedVC.profileName =  dataStory.owner_title
        objAAF?.navigationController?.pushViewController(presentedVC, animated: true)
    }
    func openProfile(){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.strProfileImageUrl = dataStory.owner_image_icon
        presentedVC.strUserName = dataStory.owner_title
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(dataStory.owner_id)"
        objAAF?.navigationController?.pushViewController(presentedVC, animated: true)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func API_getMuteUnMute(url : String, isMute : Bool)
    {
        if Reachabable.isConnectedToNetwork()
        {
            objAAF?.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = (objAAF?.view.center)!
            activityIndicatorView.startAnimating()
            
            var parameters = [String:String]()
            if isMute
            {
                parameters = ["is_mute" : "1"]
            }
            else
            {
                parameters = ["is_mute" : "0"]
            }
            post(parameters, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                   // activityIndicatorView.stopAnimating()
                    if msg {
                        if succeeded["message"] != nil{
                            self.objAAF?.API_getBrowseStories()
                            if self.isMute
                            {
                                UIApplication.shared.keyWindow?.makeToast("\(self.dataStory.owner_title.capitalized) \(NSLocalizedString("has been Muted. You will no longer see story from this person.", comment: ""))", duration: 2, position: "bottom")
                            }
                            else
                            {
                                UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("This user has been unmuted successfully.",comment: ""), duration: 2, position: "bottom")
                            }
                            self.setViewHideShow(view: self, hidden: true)
                            
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            UIApplication.shared.keyWindow?.makeToast(succeeded["message"] as! String, duration: 2, position: "bottom")
                            self.setViewHideShow(view: self, hidden: true)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 2, position: "bottom")
            self.setViewHideShow(view: self, hidden: true)
        }
    }
}
