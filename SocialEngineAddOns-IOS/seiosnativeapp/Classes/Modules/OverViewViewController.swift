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
//  OverViewViewController.swift
//  seiosnativeapp
//


import UIKit
import WebKit

class OverViewViewController: UIViewController, TTTAttributedLabelDelegate, UITextViewDelegate,WKNavigationDelegate{
    // Variable for Blog Detail Form
    var subjectId : Int!
    var mytitle : String!
    var detailWebView = WKWebView()
    var label1 : String! = ""
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        //self.title = NSLocalizedString("Overview", comment: "")
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(OverViewViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        

        // WebView for Blog Detail
        detailWebView.frame = CGRect(x: 0, y: 5, width: view.bounds.width, height: view.bounds.height - 5)
        detailWebView.backgroundColor = bgColor
        detailWebView.isOpaque = false
        detailWebView.navigationDelegate = self
        //detailWebView.scalesPageToFit = true
        
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        let htmlString = "\(htmlStart)\(label1!)\(htmlEnd)"

        self.detailWebView.loadHTMLString("\(htmlString)", baseURL: nil)
        
        view.addSubview(detailWebView)
        
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
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
    


    override func viewDidAppear(_ animated: Bool) {
        
        self.title = NSLocalizedString("Overview", comment: "")
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
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
