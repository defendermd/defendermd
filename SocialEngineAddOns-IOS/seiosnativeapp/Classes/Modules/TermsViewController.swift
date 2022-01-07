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

//  TermsViewController.swift

import UIKit
import WebKit

class TermsViewController: UIViewController, WKNavigationDelegate  {
   
    var detailWebView = WKWebView()
    var popAfterDelay:Bool!
    var fromLoginPage = false
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        popAfterDelay = false
       
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TermsViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        self.title = NSLocalizedString("Terms", comment: "")
        navigationController?.navigationBar.isHidden = false
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        setNavigationImage(controller: self)
        if (baseController != nil)
        {
            if baseController.selectedIndex == 1 || baseController.selectedIndex == 2 || baseController.selectedIndex == 3{
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
            
        }

        // WebView for Terms
        detailWebView.frame = CGRect(x: PADING, y: 0, width: view.bounds.width, height: view.bounds.height)
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.navigationDelegate = self
        detailWebView.scrollView.bounces = false
        view.addSubview(detailWebView)
        // Get Terms From Server
     
    }
    override func viewDidAppear(_ animated: Bool) {
        getTerms()
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
        setNavigationImage(controller: self)
    }

     // MARK: - Get Terms and Conditions Data From Server
    
    func getTerms(){
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["":""], url: "help/terms", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                         //self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
                        let label1 = succeeded["body"] as! String
                        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                        let htmlEnd = "</BODY></HTML>"
                        let htmlString = "\(htmlStart)\(label1)\(htmlEnd)"
                        self.detailWebView.loadHTMLString(htmlString, baseURL: nil)
                    }else{
                        // Handle Server Error
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
       
    @objc func goBack(){
        if fromLoginPage == true {
            if showAppSlideShow == 1 {
                let presentedVC  = SlideShowLoginScreenViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else{
            let presentedVC = LoginViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
            }
        }else{
            let presentedVC = AdvanceActivityFeedViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    
    
}
