//
//  LoginSlideShowViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 16/08/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class LoginSlideShowViewController: UIViewController ,UIScrollViewDelegate{
    
    var contentView = UIView()
    var contentImage : [UIImageView]!
    var scrollView = UIScrollView()
    var contentViews = [UIView]()
    var imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3"]
    var colors = [ UIColor(red: 26/255 , green: 188/255 , blue: 156/255, alpha: 1.0) ,  UIColor(red: 219/255 , green: 158/255 , blue: 54/255, alpha: 1.0), UIColor(red: 148/255 , green: 106/255 , blue: 170/255, alpha: 1.0)]
    
    var titleArray = ["Browse & Collaborate","Connect & Share","Discover the perfect places to enjoy"]
    var subTitleArray = ["Explore content, find friends and stay conected with the happenings around!","Join our Group & Events, and Connect with enthusiasts","Browse lists of places and organize the ones you like into wishlists"]
    
    var contentTitle = UILabel()
    var contentSubTitle = UILabel()
    let screenSize = UIScreen.main.bounds
   var arrowButton = createButton(CGRect(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 45, width: 50, height: 20), title: "", border: false, bgColor: false, textColor: slideShowButtonColor)
     var arrowButton2 = createButton(CGRect(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 50, width: 50, height: 30), title: "", border: false, bgColor: false, textColor: slideShowButtonColor)
    var pageControl = UIPageControl(frame: CGRect(x: UIScreen.main.bounds.width/2 - 100, y: UIScreen.main.bounds.height - 50, width: 200, height: 30))
    var arrowButton1 = createButton(CGRect(x:  10, y: UIScreen.main.bounds.height - 50, width: 50, height: 30), title: NSLocalizedString("Skip", comment: ""), border: false, bgColor: false, textColor: slideShowButtonColor)
    
    var yPosition:CGFloat = 0
    var scrollViewContentSize:CGFloat=0;
    var slideTextColor1 = [UIColor]()
    var lastVelocityXSign = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        contentImage = [UIImageView](repeating: UIImageView(), count: totalIntroSlideShowImages)
        switch(totalIntroSlideShowImages){
        case 1:
            
            titleArray = ["\(slide_title_1)"]
            subTitleArray = ["\(slide_subtitle_1)"]
            imagelist = ["slide_screen_1"]
            colors = [bg_slider_screen1]
            slideTextColor1 = [slide_text_color_1]
            
        case 2:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)"]
           imagelist = ["slide_screen_1","slide_screen_2"]
            colors = [bg_slider_screen1,bg_slider_screen2]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2]
            
        case 3:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)"]
             imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3"]
            colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3]
            
        case 4:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)","\(slide_title_4)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)","\(slide_subtitle_4)"]
             imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3","slide_screen_4"]
            colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3,bg_slider_screen4]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3,slide_text_color_4]
            
        case 5:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)","\(slide_title_4)","\(slide_title_5)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)","\(slide_subtitle_4)","\(slide_subtitle_5)"]
             imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3","slide_screen_4","slide_screen_5"]
            colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3,bg_slider_screen4,bg_slider_screen5]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3,slide_text_color_4,slide_text_color_5]
            
        case 6:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)","\(slide_title_4)","\(slide_title_5)","\(slide_title_6)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)","\(slide_subtitle_4)","\(slide_subtitle_5)","\(slide_subtitle_6)"]
             imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3","slide_screen_4","slide_screen_5","slide_screen_6"]
            colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3,bg_slider_screen4,bg_slider_screen5,bg_slider_screen6]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3,slide_text_color_4,slide_text_color_5,slide_text_color_6]
            
        case 7:
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)","\(slide_title_4)","\(slide_title_5)","\(slide_title_6)","\(slide_title_7)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)","\(slide_subtitle_4)","\(slide_subtitle_5)","\(slide_subtitle_6)","\(slide_subtitle_7)"]
            imagelist = ["slide_screen_1","slide_screen_2","slide_screen_3","slide_screen_4","slide_screen_5","slide_screen_6","slide_screen_7"]
           colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3,bg_slider_screen4,bg_slider_screen5,bg_slider_screen6,bg_slider_screen7]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3,slide_text_color_4,slide_text_color_5,slide_text_color_6,slide_text_color_7]

       
        default:
            totalIntroSlideShowImages = 3
            
            titleArray = ["\(slide_title_1)","\(slide_title_2)","\(slide_title_3)"]
            subTitleArray = ["\(slide_subtitle_1)","\(slide_subtitle_2)","\(slide_subtitle_3)"]
            imagelist = ["slide_screen_icon_1","slide_screen_icon_2","slide_screen_icon_3"]
            colors = [bg_slider_screen1,bg_slider_screen2,bg_slider_screen3]
            slideTextColor1 = [slide_text_color_1,slide_text_color_2,slide_text_color_3]
        }
    
        
        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = true
        }
        
        if (auth_user == true  && oauth_token != nil)
        {
            
            auth_user = false
            logoutUser = false
            refreshMenu = true
            let imageViewTemp = createImageView(CGRect(x: 0, y: 0, width: view.bounds.width , height: view.bounds.height), border: false)
            imageViewTemp.backgroundColor = navColor
            imageViewTemp.image = UIImage(named: "Splash")
            view.addSubview(imageViewTemp)
            showHomePage()
            return
        }
        
        loginVieww =  true
        isPresented = false

        scrollView.frame = view.frame
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        scrollView.delegate = self
        self.view.addSubview(scrollView)
       
        self.loadScrollView()
        
 
    }
    func showHomePage () {
        menuRefreshConter = 0
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        else
        {
            baseController.tabBar.items![1].isEnabled = true
            baseController.tabBar.items![2].isEnabled = true
            baseController.tabBar.items![3].isEnabled = true
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }
    func getAppId()
    {
        let bundleID = Bundle.main.bundleIdentifier
        let bundleResponse = URL(string:"https://itunes.apple.com/lookup?bundleId=\(bundleID!)")
        let task = URLSession.shared.dataTask(with: bundleResponse!, completionHandler: { (data, response, error) -> Void in
            
            if let urlContent = data
            {
                do
                {
                    let jsonResult =  try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let jsonResults = jsonResult as? NSDictionary
                    {
                        //print(jsonResults)
                        if jsonResults["resultCount"] as! Int != 0 {
                            if jsonResults["results"] != nil{
                                
                                if let results = jsonResults["results"] as? NSArray
                                {
                                    if let result = results[0] as? NSDictionary
                                    {
                                        let appId = result["trackId"]
                                        UserDefaults.standard.set(appId, forKey: "appItunesId")
                                        
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    //print("JSON serialization failed")
                }
            }
        })
        task.resume()
    }
    
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = imagelist.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        self.pageControl.currentPageIndicatorTintColor = slideShowButtonColor
        self.pageControl.tag = 101
        
        UIApplication.shared.keyWindow?.addSubview(pageControl)
       

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.keyWindow?.addSubview(arrowButton)
        UIApplication.shared.keyWindow?.addSubview(arrowButton1)
        UIApplication.shared.keyWindow?.addSubview(arrowButton2)
        configurePageControl()
        
    }
  
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage()
    {
        var page1 = pageControl.currentPage
        if pageControl.currentPage <= totalIntroSlideShowImages - 1 {
        if pageControl.currentPage == totalIntroSlideShowImages - 1 {
            page1 = pageControl.currentPage
        }
        else{
           page1 = page1 + 1
        }
        let x = CGFloat(page1) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: false)
            let fx = self.contentImage[page1].frame.origin.x
            self.contentImage[page1].frame = CGRect(x: fx+scrollView.frame.size.width, y:self.view.bounds.height/2 - 180 , width:160, height:160)
            UIView.animate(withDuration: 0.3, animations: {
                self.contentImage[page1].frame.origin.x = fx
            })
        }

    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollView.contentOffset.y = 0.0

        let pageNumber = round((scrollView.contentOffset.x) / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        let currentVelocityX =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).x
        let currentVelocityXSign = Int(currentVelocityX).signum()
        if currentVelocityXSign != lastVelocityXSign &&
            currentVelocityXSign != 0 {
            lastVelocityXSign = currentVelocityXSign
        }
        if scrollView.panGestureRecognizer.state == .began{
            if lastVelocityXSign < 0 {
                // To scroll right
                if Int(pageNumber) != totalIntroSlideShowImages - 1 {
                    let fx = self.contentImage[Int(pageNumber) + 1].frame.origin.x
                    self.contentImage[Int(pageNumber) + 1].frame = CGRect(x: fx + scrollView.frame.size.width, y:self.view.bounds.height/2 - 180 , width:160, height:160)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.contentImage[Int(pageNumber) + 1].frame.origin.x = fx
                    })
                }
            }
                // To scroll left
//            else if lastVelocityXSign > 0 {
//                if pageNumber != 0 {
//                    let x = pageNumber * scrollView.frame.size.width
//                    let fx = self.contentImage[Int(pageNumber) - 1].frame.origin.x
//                    self.contentImage[Int(pageNumber) - 1].frame = CGRect(x: x + scrollView.frame.size.width, y:self.view.bounds.height/2 - 180 , width:160, height:160)
//                    UIView.animate(withDuration: 0.5, animations: {
//                        self.contentImage[Int(pageNumber) - 1].frame.origin.x = fx
//                    })
//                }
//            }
        }
        if pageControl.currentPage == totalIntroSlideShowImages - 1 {
            arrowButton.setImage(UIImage(named: "")?.maskWithColor(color: slideShowButtonColor), for: UIControl.State.normal)
            arrowButton.setTitle("", for: .normal)
            arrowButton1.setTitle("", for: .normal)
            arrowButton2.setTitle(NSLocalizedString("Login", comment: "") , for: .normal)
            arrowButton.isHidden = true
            arrowButton2.isHidden = false
        }
        else{
            arrowButton.setTitle("", for: .normal)
            arrowButton.setImage(UIImage(named: "forward")?.maskWithColor(color: slideShowButtonColor), for: UIControl.State.normal)
            arrowButton1.setTitle(NSLocalizedString("Skip", comment: ""), for: .normal)
            arrowButton2.setTitle("", for: .normal)
            arrowButton.isHidden = false
            arrowButton2.isHidden = true
        }
    }
 
    func loadScrollView(){
        var i = 0
        for _ in imagelist{
            var widthSell : CGFloat = 0.0
            let xpoint = (CGFloat(i) * view.bounds.width)
           
            widthSell = view.bounds.width
            scrollView.isPagingEnabled = true
            contentView = createView(CGRect(x:xpoint, y:0, width:widthSell, height:view.bounds.height), borderColor: UIColor.clear, shadow: false)
            contentView.backgroundColor = colors[i]
            view.addSubview(contentView)
            
            contentImage[i] = createImageView(CGRect(x:view.bounds.width/2 - 80, y:view.bounds.height/2 - 180 , width:160, height:160), border: false)
            contentImage[i].layer.cornerRadius = 0.0
            contentImage[i].layer.shadowColor = shadowColor.cgColor
            contentImage[i].layer.shadowOpacity = shadowOpacity
            contentImage[i].layer.shadowRadius = shadowRadius
            contentImage[i].layer.shadowOffset = shadowOffset
            contentTitle = createLabel(CGRect(x:5, y:getBottomEdgeY(inputView: contentImage[i])+15, width:view.bounds.width - 10, height:30), text: " ", alignment: .center, textColor: slideTextColor1[i])
            contentTitle.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
            contentTitle.text = "\(titleArray[i])"
            contentTitle.lineBreakMode = .byTruncatingTail
            contentTitle.numberOfLines = 0
            contentTitle.sizeToFit()
            contentTitle.frame.size.width = view.bounds.width - 10
            contentTitle.textAlignment = .center
            contentView.addSubview(contentTitle)
            
            contentSubTitle = createLabel(CGRect(x:20, y:getBottomEdgeY(inputView: contentTitle)+8, width:view.bounds.width - 40, height:30), text: " ", alignment: .center, textColor: slideTextColor1[i])
            contentSubTitle.font = UIFont(name: fontNormal, size: FONTSIZELarge)
            contentSubTitle.text = "\(subTitleArray[i])"
            contentSubTitle.lineBreakMode = .byTruncatingTail
            contentSubTitle.numberOfLines = 0
            contentSubTitle.sizeToFit()
            contentSubTitle.frame.size.width = view.bounds.width - 40
            contentSubTitle.textAlignment = .center
            contentView.addSubview(contentSubTitle)
            contentImage[i].image = nil
            contentImage[i].image = imageWithImage( UIImage(named: "\(imagelist[i])")!, scaletoWidth: contentImage[i].bounds.width)
            contentView.addSubview(contentImage[i])
            arrowButton.addTarget(self, action: #selector(LoginSlideShowViewController.changePage), for: .touchUpInside)
            arrowButton.tag = 101
            arrowButton1.addTarget(self, action: #selector(LoginSlideShowViewController.showLoginPage), for: .touchUpInside)
            arrowButton1.tag = 101
            arrowButton2.addTarget(self, action: #selector(LoginSlideShowViewController.showLoginPage), for: .touchUpInside)
            arrowButton2.tag = 101
            scrollView.addSubview(contentView)
            contentImage[i].isHidden = true
            contentTitle.isHidden = true
            contentSubTitle.isHidden = true
            contentImage[i].isHidden = false
            contentTitle.isHidden = false
            contentSubTitle.isHidden = false
            if i == 0 {
                let x =  scrollView.frame.size.width
                let fx = self.contentImage[i].frame.origin.x
                self.contentImage[i].frame = CGRect(x: x, y:self.view.bounds.height/2 - 180 , width:160, height:160)
                UIView.animate(withDuration: 0.7, animations: {
                    self.contentImage[i].frame.origin.x = fx
                })
            }
            contentImage[i].isHidden = false
            contentTitle.isHidden = false
            contentSubTitle.isHidden = false
            i += 1
        }
        scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(imagelist.count), height: 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for view in (UIApplication.shared.keyWindow?.subviews)!{
        if (view.tag == 101)
        {
            view.removeFromSuperview()
        }
        }
    }
    
    
    @objc func showLoginPage () {
        
        let pv = SlideShowLoginScreenViewController()
        self.navigationController?.pushViewController(pv, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
