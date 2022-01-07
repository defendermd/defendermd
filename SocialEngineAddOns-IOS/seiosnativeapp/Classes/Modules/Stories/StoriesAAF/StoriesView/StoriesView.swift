//
//  StoriesView.swift
//  seiosnativeapp
//
//  Created by BigStep on 06/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

protocol StoryNotUploadedCell {
    func methodStoryNotUploadedCell(data : StoriesBrowseData)
}

class StoriesView: UIView,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UIGestureRecognizerDelegate {

    //MARK: Outlets and Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    // @IBOutlet weak var imgT: UIImageView!
    @IBOutlet weak var collectionViewStories: UICollectionView?
   // @IBOutlet weak var btnMuteStories: UIButton!
    var arrStoriesData = [StoriesBrowseData]()
    var isCameraSelected = false
    var objAAF : AdvanceActivityFeedViewController?
    var delegateStoryNotUploaded : StoryNotUploadedCell?
    
    init(frame: CGRect, vc: UIViewController) {  //To use it in code
        super.init(frame: frame)
        if let viewController = vc as? AdvanceActivityFeedViewController {
            self.objAAF = viewController
        }
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // To use it in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("StoriesView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.layer.shadowColor = shadowColor.cgColor
        contentView.layer.shadowOffset = shadowOffset
        contentView.layer.shadowRadius = shadowRadius
        contentView.layer.shadowOpacity = shadowOpacity
        collectionViewStories?.register(UINib(nibName: "StoriesCell", bundle: nil), forCellWithReuseIdentifier: "StoriesCell")
        collectionViewStories?.register(UINib(nibName: "MyStoryCell", bundle: nil), forCellWithReuseIdentifier: "MyStoryCell")
//        imgT.image = imgT.image?.maskWithColor(color: textColorMedium)
//        btnMuteStories.setTitleColor(textColorMedium, for: .normal)
//        btnMuteStories.isEnabled = false
        updateStoriesData(isDataUpdate: false)
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        collectionViewStories?.addGestureRecognizer(lpgr)
        collectionViewStories?.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       

    }
    
    func updateStoriesData(isDataUpdate : Bool)
    {
        if let storiesBrowseData = UserDefaults.standard.object(forKey: "storiesBrowseData") as? Data
        {
            if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [StoriesBrowseData] {
                
                self.arrStoriesData = arrStoriesDataTemp
                if isDataUpdate
                {
                    let data = self.arrStoriesData[0]
                    data.isViewLoading = 1
                    self.arrStoriesData[0] = data
                }
                self.collectionViewStories?.reloadData()
                self.collectionViewStories?.scrollToItem(at: IndexPath(row: 0, section: 0),at: .left,animated: true)
                

              //  flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
            }
            
        }
        else
        {
            let data = StoriesBrowseData()
            self.arrStoriesData.append(data)
            
        }
    }
    
//    @IBAction func btnMuteAction(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc  = storyboard.instantiateViewController(withIdentifier: "StoryPreviewController") as! StoryPreviewController
//        vc.isMuteStory = true
//        objAAF.navigationController?.pushViewController(vc, animated: false)
//    }

    //MARK: UICollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStoriesData.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dicStories = arrStoriesData[indexPath.row]
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyStoryCell", for: indexPath) as! MyStoryCell
            cell.lblTitle.textColor = textColorDark
            cell.lblTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.viewStory.borderColors = navColor
            cell.btnStoryAction.addTarget(self, action: #selector(btnGalleryClickedAction(button:)), for: .touchUpInside)
            //cell.btnStoryAction.setImage(UIImage(named: "StoryIcons_PlusIcon")!.maskWithColor(color: .white), for: .normal) //addicon
            cell.btnStoryAction.backgroundColor = navColor
            cell.btnStoryAction.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.viewCircular.colors = [navColor]
            if dicStories.isViewLoading == 1
            {
                cell.animateStartCircularView()
            }
            else
            {
                cell.animateStopCircularView()
            }
            if dicStories.story_id == 0
            {
                cell.viewStory.borderColors = .clear
            }
            else
            {
                cell.viewStory.borderColors = navColor
            }
            if !dicStories.owner_title.isEmpty
            {
                cell.lblTitle.text = dicStories.owner_title
            }
            if let url = URL(string: dicStories.image)
            {
                cell.imgStory.kf.indicatorType = .activity
                (cell.imgStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    if image == nil
                    {
                        cell.imgStory.image = imageProfile
                    }
                })
            }
            else
            {
                cell.imgStory.image = imageProfile
            }
            return cell
        }
        else
        {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
            cell.lblTitle.textColor = textColorDark
            cell.lblTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.lblTitle.text = dicStories.owner_title
            if let url = URL(string: dicStories.image)
            {
                if dicStories.isMute == 1
                {
                  cell.viewUserBlur.isHidden = false
                  cell.viewBlur.isHidden = false
                  cell.viewStory.borderColors = navColor.withAlphaComponent(0.3)
                }
                else
                {
                  cell.viewUserBlur.isHidden = true
                  cell.viewBlur.isHidden = true
                  cell.viewStory.borderColors = navColor
                }
                cell.imgUser.isHidden = false
                cell.imgStory.kf.indicatorType = .activity
                (cell.imgStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
                if let url = URL(string: dicStories.owner_image_icon)
                {
                    //cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = .clear
                    cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
            }
            else
            {
                if let url = URL(string: dicStories.owner_image_icon)
                {
                    cell.viewBlur.isHidden = false
                    cell.imgUser.isHidden = true
                    cell.viewUserBlur.isHidden = true
                    cell.viewStory.borderColors = .clear
                    cell.imgStory.kf.indicatorType = .activity
                    (cell.imgStory.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgStory.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
            
        return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellsize = CGSize(width: (collectionViewStories.bounds.size.width/3) - 10, height: 115)
//        return cellsize
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//        let edgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
//        return edgeInsets;
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dic = arrStoriesData[indexPath.row]
        if dic.story_id == 0
        {
            if indexPath.row == 0
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc  = storyboard.instantiateViewController(withIdentifier: "StoryController") as! StoryController
                objAAF?.navigationController?.pushViewController(vc, animated: false)
            }
            else
            {
                delegateStoryNotUploaded?.methodStoryNotUploadedCell(data : dic)
            }
        }
        else
        {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc  = storyboard.instantiateViewController(withIdentifier: "StoryPreviewController") as! StoryPreviewController
            
            if dic.isMute == 1
            {
                vc.arrStoryIds = [dic.story_id]
                vc.isMuteStory = true
            }
            else
            {
                var arrStoryIds = [Int]()
                for index in  indexPath.row ..< arrStoriesData.count
                {
                    if arrStoriesData[index].story_id != 0 && arrStoriesData[index].isMute != 1
                    {
                        arrStoryIds.append(arrStoriesData[index].story_id)
                    }
                }
                vc.arrStoryIds = arrStoryIds
                vc.isMuteStory = false
            }            
            objAAF?.navigationController?.pushViewController(vc, animated: false)
        }
  
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        let p = gesture.location(in: collectionViewStories)
        if let indexPath = collectionViewStories?.indexPathForItem(at: p) {
            if indexPath.row != 0
            {
                let dic = self.arrStoriesData[indexPath.row]
                if dic.story_id != 0
                {
                  delegateStoryNotUploaded?.methodStoryNotUploadedCell(data : dic)
                }
            }
            
        } else {
            print("couldn't find index path")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionViewStories?.contentOffset.y = 0
    }
    
    @objc func btnGalleryClickedAction(button: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "StoryController") as! StoryController
        objAAF?.navigationController?.pushViewController(vc, animated: false)
      
    }
}

