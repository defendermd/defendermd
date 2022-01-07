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


//  ExternalWebViewController.swift
//  seiosnativeapp

import UIKit
import WebKit
class ExternalWebViewController: UIViewController , WKNavigationDelegate , UITabBarControllerDelegate, WKUIDelegate{
    
    @objc var externalWebView = WKWebView()
    var url:String! = ""
    var siteTitle = ""
    var fromDashboard = false
    var flagInteger = 0
    var rightBarButton : UIBarButtonItem!
    var hidingNavBarManager: HidingNavigationBarManager?
    var currentUrl : String!
    var marqueeHeader : MarqueeLabel!
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventUpdate = false
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        self.tabBarController?.delegate = self
        popAfterDelay = false
        if baseController != nil{
            switch baseController.selectedIndex {
            case 1:
                if url1 != ""{
                    url = url1
                }
                break
            case 2:
                if url2 != ""{
                    url = url2
                }
                break
            case 3:
                
                if url3 != ""{
                    url = url3
                    
                }
                break
            default:
                break
                
            }
            
        }
        
        self.navigationController?.navigationBar.tintColor = textColorPrime
        if fromDashboard == false {
            if url1 == "" && url2 == "" && url3 == ""
            {
            
            let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(ExternalWebViewController.cancel))
            self.navigationItem.leftBarButtonItem = cancel
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControl.State())
            cancel.tintColor = textColorPrime
            }
            else
            {
                let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                leftNavView.backgroundColor = UIColor.clear
                let tapView = UITapGestureRecognizer(target: self, action: #selector(ExternalWebViewController.goBack))
                leftNavView.addGestureRecognizer(tapView)
                let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
                backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
                leftNavView.addSubview(backIconImageView)
                
                let barButtonItem = UIBarButtonItem(customView: leftNavView)
                self.navigationItem.leftBarButtonItem = barButtonItem
                
            }
        }
        else
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(ExternalWebViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        rightBarButton = UIBarButtonItem(image: UIImage(named: "upload")!.maskWithColor(color: textColorPrime) , style: UIBarButtonItem.Style.plain , target: self, action: #selector(ExternalWebViewController.openBrowserSetting))
        rightBarButton.isEnabled = true
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        // hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: externalWebView.scrollView)
        
        
        // WebView for Blog Detail
        externalWebView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - tabBarHeight)
        externalWebView.backgroundColor = bgColor
        externalWebView.navigationDelegate = self
        externalWebView.uiDelegate = self
        externalWebView.contentMode = .scaleAspectFit
        
        view.addSubview(externalWebView)
        
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        // Add Observer for title
        externalWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
  
    }
    
    //MARK: - Get WKWebView Title with the help of Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
           
            if self.marqueeHeader != nil {
                self.siteTitle = "\(externalWebView.title!)"
                self.marqueeHeader.text = "\(externalWebView.title!)"
            }
        }
    }
    
    func menuAction(_ sender:UIButton){
        switch(sender.tag){
        case 0:
            externalWebView.goBack()
        case 1:
            externalWebView.goForward()
        case 2:
            externalWebView.reload()
        case 3:
            externalWebView.stopLoading()
        default:
            externalWebView.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        removeNavigationViews(controller: self)
        var tempUrl :  String = ""
        print(oauth_token)
        if url.contains("?"){
            tempUrl = url+"&disableHeaderAndFooter=1&token=" + oauth_token
        }
        else{
            if oauth_token != nil {
                tempUrl = url+"?disableHeaderAndFooter=1&token=" + oauth_token
            }
            else {
                tempUrl = url+"?disableHeaderAndFooter=1"
            }
        }
        self.currentUrl = tempUrl

        let prefs = UserDefaults.standard
        if let city = prefs.string(forKey: "Location"){

            tempUrl = tempUrl+"&restapilocation=\(city)"
        }
        let urlNew:String = tempUrl.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        //print(urlNew)
        externalWebView.load(URLRequest(url: URL(string: urlNew)! ))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //print("viewdidappear")
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 70, y: 0, width: navigationBar.frame.width - 120, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
            marqueeHeader.textColor = textColorPrime
            marqueeHeader.text = ""
        }

        if baseController != nil
        {
            if baseController.selectedIndex == 1 {
                //print("url1 value")
                if url1 != ""{
                    url = url1
                    marqueeHeader.text = siteTitle
                    
                }
                if baseController.selectedIndex == 2{
                    //print("url2 value")
                    if url2 != ""{
                        url = url2
                    }
                }
                if baseController.selectedIndex == 3{
                    //print("url3 value")
                    if url3 != ""{
                        url = url3
                        marqueeHeader.text = siteTitle//fourthControllerName
                    }
                }
            }
        }
        
    }
    
    @objc func cancel(){
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - User Interactive delegate of WKWebView
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        print("UIDelegetae callng====")
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        // for _blank target or non-mainFrame target
        webView.load(navigationAction.request)
        return nil
    }
    //MARK: -  WKWebView DidStart Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }
    
    //MARK: - UIWebView Delegates
    

    
    //MARK: - WKWebView Should Start Load Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        var action: WKNavigationActionPolicy?

        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        print(url)
        
        if navigationAction.navigationType == .linkActivated, url.absoluteString.contains(".app") {
            action = .cancel                  // Stop in WebView
            UIApplication.shared.open(url, options: [:], completionHandler: nil) // Open in Safari
        }
    }

//    private func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
//    {
//        if request.url?.host?.contains(".app") == true
//        {
//            webView.stopLoading()
//            UIApplication.shared.openURL((request.url)!)
//            navigationController?.popViewController(animated: true)
//            return false
//        }
//        else
//        {
//            return true
//        }
////        if (request.url?.scheme == "https" || request.url?.scheme == "http") {
////            webView.stopLoading()
////            UIApplication.shared.openURL((request.url)!)
////            navigationController?.popViewController(animated: true)
////            return false
////        }
////        else {
////            return true
////        }
//    }
    
    //MARK: - WKWebView Did Finish Delegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        
        activityIndicatorView.stopAnimating()
        
        flagInteger += 1
   
        guard let currentUrlString = webView.url?.absoluteString else
        {
            //urlStr is what you want
            return
        }
        
        print("currentUrlString === \(currentUrlString)")
        

        self.currentUrl = currentUrlString
        
        if (currentUrlString.range(of: "success/payment/finish/state/active") != nil) || (currentUrlString.range(of:  "/success") != nil) //stores/products/success
        {
            
            showToast(message: NSLocalizedString("Payment Successful", comment: ""), controller: self)
            
            eventUpdate = true
            contentFeedUpdate = true
            
            self.popAfterDelay = true
            self.createTimer(self)
        }
        else if ((currentUrlString.range(of:"success/payment/finish/state/failure") != nil) || (currentUrlString.range(of:"/failure") != nil)) //stores/products/failure
        {
            showToast(message: NSLocalizedString("Payment Fail", comment: ""), controller: self)
            self.popAfterDelay = true
            self.createTimer(self)
            
            placeandorder = 0
        }
    }

    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
        if self.popAfterDelay == true
        {
            externalWebView.navigationDelegate = self
            externalWebView.stopLoading()
            dismiss(animated: false, completion: nil)
            
        }
    }
    
    //MARK: -  WKWebView Error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nserror = error as NSError
        if nserror.code != NSURLErrorCancelled {
             activityIndicatorView.stopAnimating()
        }
    }

    

    
    @objc func openBrowserSetting(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment: ""), style: .default, handler: { (UIAlertAction) -> Void in
            self.openInSafari()
        }))
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    func openInSafari(){
        
//        guard let url = URL(string: self.currentUrl) else {
//            return
//        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: self.currentUrl)!, options: [:],completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: self.currentUrl)!)
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchItem(){
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            searchDic.removeAll(keepingCapacity: false)
            pv.fromInapp = true
            self.navigationController?.pushViewController(pv, animated: false)
            
        }
       
    }
    
    @objc func goBack()
    {
        activityIndicatorView.stopAnimating()
        if externalWebView.canGoBack == false {
            if((self.fromDashboard == true))
            {
          
                if logoutUser == true
                {
                    feedArray.removeAll()
                }
              let presentedVC = AdvanceActivityFeedViewController()
              self.navigationController?.pushViewController(presentedVC, animated: true)
                dismiss(animated: true, completion: nil)
                
            }
            else
            {
                _ = self.navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
                
            }
        }
        else
        {
            externalWebView.goBack()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if externalWebView.isLoading
        {
            externalWebView.stopLoading()
        }
        
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
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

