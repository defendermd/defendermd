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


//
//  BlogDetailViewController.swift
//  seiosnativeapp
//


import UIKit
import WebKit

class DescriptionViewController: UIViewController, WKNavigationDelegate , TTTAttributedLabelDelegate{
    // Variable for Blog Detail Form
    var subjectId : String!
    var mytitle : String!
    var detailWebView = WKWebView()
    var headertitle : String!
    var url : String!
    var smallDescription : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("\(headertitle!): \(mytitle!)", comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(DescriptionViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: 0, y: 10, width: view.bounds.width, height: view.bounds.height)
        self.detailWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0);
        //self.detailWebView.scrollView.delegate = self
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.navigationDelegate = self
        detailWebView.scrollView.bounces = false
        detailWebView.isUserInteractionEnabled = true
        //detailWebView.scalesPageToFit = true
        detailWebView.scrollView.isScrollEnabled = true
        view.addSubview(detailWebView)
        
        if url == ""
        {
            let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
            let htmlEnd = "</BODY></HTML>"
            let htmlString = "\(htmlStart)\(smallDescription)\(htmlEnd)"
            
            self.detailWebView.loadHTMLString("\(htmlString)", baseURL: nil)
        }
        else
        {
            exploreInfo()
        }

        
        
    }
    
    
    
    
    // MARK: - Server Connection For Blog Updation
    
    // Explore  Detail
    func exploreInfo(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Contents
            post(["subject_id": String(subjectId), "feed_filter": "1", "maxid": "0", "post_menus": "1"], url:url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        if self.headertitle == "Info"
                        {
                            if let blog = succeeded["body"] as? NSDictionary
                            {
                                let description = blog["infoString"] as! String
                                self.detailWebView.loadHTMLString(description, baseURL: nil)
                            }
                        }
                        else
                        {
                            if let _ = succeeded["body"] as? String
                            {
                                //self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
                                let topicDescription = (succeeded["body"] as! String)
//                                let truncatedDescription = topicDescription.html2String
//                                let temp = "<body style=\"background-color: transparent;\"><div style= \"font-size:20px;\">"
//                                let topicDescription1 = "\(temp) \(truncatedDescription) </body>"
                                
                                let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                                let htmlEnd = "</BODY></HTML>"
                                let htmlString = "\(htmlStart)\(topicDescription)\(htmlEnd)"
                                
                                self.detailWebView.loadHTMLString("\(htmlString)", baseURL: nil)
                                
                               // self.detailWebView.loadHTMLString(topicDescription, baseURL: nil)
                                

                            }
                        }
                        
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        self.detailWebView.isHidden = false
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            webView.frame.size.height = height as! CGFloat
            self.detailWebView.frame.size.width = self.view.frame.size.width
            
        })
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url{
                
                let presentedVC = ExternalWebViewController()
                presentedVC.url = url.absoluteString
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
                decisionHandler(.cancel)
                return
            }
            
        default:
            break
        }
        
        
        decisionHandler(.allow)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    
}
