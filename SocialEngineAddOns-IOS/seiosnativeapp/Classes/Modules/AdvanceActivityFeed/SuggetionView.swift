//
//  SuggetionView.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 17/12/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class SuggetionView: UIView,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var suggetionCollectionView : UICollectionView!
    var viewTitle : UILabel!
    var seeAll: UIButton!
    let collectionIdentifier = "collectionCell"
    override init(frame: CGRect) {
        super.init(frame : frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  Create UI elements
    func createSuggetionView(comingFrom : String){
        
        self.backgroundColor = UIColor.white
        
        // Showing collection view header label
        viewTitle = createLabel(CGRect(x: PADING + 8, y: PADING, width: self.bounds.width - PADING, height: self.bounds.height * 0.1), text: NSLocalizedString("People you may know",  comment: ""), alignment: .left, textColor: textColorDark)
        viewTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.addSubview(viewTitle)
        
        // CollectionView Flow Layout Configuration
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.itemSize = CGSize(width: self.bounds.width * 0.5, height: self.bounds.height * 0.8)
        
        // CollectionView Initialization
        suggetionCollectionView = UICollectionView(frame:CGRect(x: 0.0, y: getBottomEdgeY(inputView: viewTitle), width: UIScreen.main.bounds.width, height: self.bounds.height * 0.8) , collectionViewLayout: flowLayout)
        suggetionCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: collectionIdentifier)
        suggetionCollectionView.backgroundColor = textColorLight
        suggetionCollectionView.dataSource = self
        suggetionCollectionView.delegate = self
        suggetionCollectionView.alwaysBounceHorizontal = true
        self.addSubview(suggetionCollectionView)
        
        
        // Showing collection view Footer
        seeAll = createButton(CGRect(x: PADING, y: getBottomEdgeY(inputView: suggetionCollectionView)-1, width: self.bounds.width - PADING, height: self.bounds.height * 0.1), title: NSLocalizedString("See All",  comment: ""), border: false, bgColor: false, textColor: textColorMedium)
        seeAll.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        seeAll.addTarget(self, action: #selector(SuggetionView.seeAllSuggestions(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(seeAll)

    }
    
    // MARK: - CollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userSuggestions.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionIdentifier, for: indexPath) as! CollectionViewCell
        cell.awakeFromNib()
        
        // User Suggetions
        if indexPath.row < userSuggestions.count
        {
            let suggetion = userSuggestions[indexPath.row] as! NSDictionary
            
            // User Image
            let url1 = NSURL(string: suggetion["image"] as! String)

            cell.suggestionImageView.kf.indicatorType = .activity
            (cell.suggestionImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.suggestionImageView.kf.setImage(with: url1! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                DispatchQueue.main.async(execute:
                    {
                        let image = cell.suggestionImageView.image
                        let tempCoverWidth = Double(cell.suggestionImageView.bounds.width)
                        let tempCoverHeight = Double(cell.suggestionImageView.bounds.height)
                        if let img = image{
                            cell.suggestionImageView.image = cropToBounds(img, width: tempCoverWidth, height: tempCoverHeight)
                        }
                        
                })
            })
            
            // Content title
            cell.contentTitle.text = suggetion["displayname"] as? String
            
            // Mutual friend count
            if suggetion["mutualfriendCount"] as? Int != nil && suggetion["mutualfriendCount"] as? Int != 0{
                
                let mutualFriendCount = String(suggetion["mutualfriendCount"] as! Int)
                if (suggetion["mutualfriendCount"] as! Int) > 1
                {
                    cell.contentDetail.text =  mutualFriendCount + NSLocalizedString(" mutual friends",  comment: "")
                }
                else
                {
                    cell.contentDetail.text =  mutualFriendCount + NSLocalizedString(" mutual friend",  comment: "")
                }
                
            }else if suggetion["location"] as? String != nil && suggetion["location"] as? String != ""{
                
                let location = suggetion["location"] as! String
                
                cell.contentDetail.text = "\(locationIcon) " + location
                
            }
            
            // Friend request title
            if suggetion["friendship_type"] as? String == "cancel_request"{
                
                cell.addFriend.setTitle(NSLocalizedString("Undo request",  comment: ""), for: UIControl.State.normal)
                // suggestionsScrollView.contentOffset = CGPoint(x: getRightEdgeX(inputView: suggestionView)/2, y: 0)
                
            }
            
            // Action method for Add friend request
            cell.addFriend.addTarget(self, action: #selector(SuggetionView.addFriendSuggestion(_:)), for: .touchUpInside)
            cell.addFriend.tag = indexPath.row
            
            // Action method for remove suggetion
            cell.removeSuggestion.addTarget(self, action: #selector(SuggetionView.removeSuggestionItem(_:)), for: .touchUpInside)
            cell.removeSuggestion.tag = indexPath.row
            
            // Action method for redirecting to User Profile from userimage
            cell.contentRedirectionView.addTarget(self, action: #selector(SuggetionView.suggestionProfile(_:)), for: .touchUpInside)
            cell.contentRedirectionView.tag = suggetion["user_id"] as! Int
        }
        else   // More Suggetions
        {
            
            cell.contentTitle.isHidden = true
            cell.contentDetail.isHidden = true
            cell.addFriend.isHidden = true
            cell.removeSuggestion.isHidden = true
            cell.findMoreSuggestions.isHidden = false
            cell.suggestionImageView.image = UIImage(named: "noContactsIcon.png")
            cell.findMoreSuggestions.addTarget(self, action: #selector(SuggetionView.seeAllSuggestions(_:)), for: UIControl.Event.touchUpInside)
            
        }
        return cell
    }
    

    // MARK: - Action Methods
    
    // See all suggetion
    @objc func seeAllSuggestions(_ sender: UIButton){
        let vc = SuggestionsBrowseViewController()
        vc.activeTableView = 1
     self.parentViewController()!.navigationController?.pushViewController(vc, animated: false)
    }
    
    // Add friends
    @objc func addFriendSuggestion(_ sender: UIButton) {
        let suggestionIndex = sender.tag
        let updateRow = IndexPath(row: suggestionIndex, section: 0)
        let selectedSuggestion = userSuggestions[suggestionIndex] as! NSDictionary
        let suggestedUserId = selectedSuggestion["user_id"]
        
        let userAction = selectedSuggestion["friendship_type"] as! String
        if userAction == "cancel_request"{
            selectedSuggestion.setValue("add_friend", forKey: "friendship_type")
        }else{
            selectedSuggestion.setValue("cancel_request", forKey: "friendship_type")
        }
        userSuggestions[suggestionIndex] = selectedSuggestion
        self.suggetionCollectionView.reloadItems(at: [updateRow])
  
        enableSuggestion = true
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["user_id": "\(suggestedUserId!)"]
            var url = "user/add"
            if userAction == "cancel_request"{
                url = "user/cancel"
            }
            activityIndicatorView.startAnimating()
            post(parameters , url: url, method: "POST", postCompleted: { (succeeded, msg) in
                DispatchQueue.main.async(execute: {
                    if msg{
                        activityIndicatorView.stopAnimating()
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            UIApplication.shared.keyWindow?.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            let  frndship_type = selectedSuggestion.value(forKey: "friendship_type") as! String
                            if frndship_type == "cancel_request"{
                                selectedSuggestion.setValue("add_friend", forKey: "friendship_type")
                            }else{
                                selectedSuggestion.setValue("cancel_request", forKey: "friendship_type")
                            }
                            userSuggestions[suggestionIndex] = selectedSuggestion
                            self.suggetionCollectionView.reloadItems(at: [updateRow])
                            
                        }
                    }
                })
                
            })
        }
        
    }
    
    // Remove Friends
    @objc func removeSuggestionItem(_ sender: UIButton) {
        let suggestionIndex = sender.tag
        let selectedSuggestion = userSuggestions[suggestionIndex] as! NSDictionary
        let suggestedUserId = selectedSuggestion["user_id"]
        userSuggestions.remove(at: suggestionIndex)
        self.suggetionCollectionView.reloadData()
        if suggestionIndex == userSuggestions.count{
            self.suggetionCollectionView.reloadData()
        }
        //if userSuggestions.count == 0{
             enableSuggestion = true
       // }
        
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"2", "restapilocation": "", "user_id": "\(suggestedUserId!)"]
            let url = "suggestions/remove"
            activityIndicatorView.startAnimating()
            post(parameters , url: url, method: "POST", postCompleted: { (succeeded, msg) in
                DispatchQueue.main.async(execute: {
                    if msg{
                        activityIndicatorView.stopAnimating()

                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            UIApplication.shared.keyWindow?.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
                
            })
        }
    }
    
    // Redirect to user profile
    @objc func suggestionProfile(_ sender: UIButton){
        let userId = sender.tag
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(userId)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.parentViewController()!.navigationController?.pushViewController(presentedVC, animated: false)
    }
}
