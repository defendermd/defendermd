//
//  CurrencyViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 05/04/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class CurrencyViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    var currencyTableView = UITableView()
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var flagTickCheck = true
    var indexStore = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("MultiCurrency", comment: "")
        self.view.backgroundColor = UIColor.blue
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CurrencyViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        currencyTableView = UITableView(frame : CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - (tabBarHeight + TOPPADING)), style: .plain)
        currencyTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        currencyTableView.rowHeight = 50.0
        currencyTableView.dataSource = self
        currencyTableView.delegate = self
        currencyTableView.backgroundColor = bgColor
        currencyTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            currencyTableView.estimatedRowHeight = 0
            currencyTableView.estimatedSectionHeaderHeight = 0
            currencyTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(currencyTableView)
        
        browseCurrency()

        // Do any additional setup after loading the view.
    }
    
    func browseCurrency(){
       
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post([:], url: "currencies/currency", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    if msg{
                        
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["isSymbol"] != nil {
                                let symbol = response["isSymbol"] as! String
                                
                                if symbol == NSLocalizedString("countryFlag", comment: "")
                                {
                                    flagCheck = true
                                  }
                                else{
                                   flagCheck = false
                                }
                            }
                            if response["response"] != nil
                            {
                                if let page = response["response"] as? NSArray
                                {
                                    
                                    currencyResponse =  (page as [AnyObject])
                                    
                                }
                            }
                        self.currencyTableView.reloadData()
                    }
                    
                }
            
        })
        }
        }
            else{
            // No Internet Connection Message
          //  showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyResponse.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click \((indexPath as NSIndexPath).row)")
        var currencyInfo:NSDictionary
        currencyInfo = currencyResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        let defaults = UserDefaults.standard
        let currencyName = currencyInfo["currency_name"] as! String
        defaults.set(currencyName, forKey: "CurrencyFlagCheck")
        let cur = currencyInfo["code"] as! String
     //   let curLable = currencyInfo["code"] as! String
        defaults.set(cur, forKey: "Currency")
     //   defaults.set(curLable, forKey: "CurrLabel")
        defaults.set(Float(truncating: (currencyInfo["globalRate"] as AnyObject) as! NSNumber), forKey: "PriceRate")
       //  tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Default Currency has been changed.", comment: ""), duration: 3, position: CSToastPositionCenter)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! CustomTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = bgColor
        var currencyInfo:NSDictionary
        currencyInfo = currencyResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.imgUser.isHidden = true
        
        if flagCheck == true {
        cell.labTitle.frame = CGRect(x: 40, y: 13,width: UIScreen.main.bounds.width - 100, height: 45)
            cell.labTitle.text = currencyInfo["currency_name"] as? String
            cell.imgUser.isHidden = false
            cell.imgUser.frame.origin.y = 25
            cell.imgUser.frame.size.width = 20
            cell.imgUser.frame.size.height = 20
            if let url1 = URL(string: currencyInfo["symbol"] as! NSString as String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
        }
        else{
        
        cell.labTitle.frame = CGRect(x: 10, y: 10,width: UIScreen.main.bounds.width - 20, height: 45)
            cell.labTitle.text = "\(currencyInfo["code"] as! String) \(currencyInfo["currency_name"] as! String)"
        }
        // cell.labTitle.center.y = cell.bounds.midY + 5
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.numberOfLines = 2
        
        
        if flagCheck == true {
            
            if UserDefaults.standard.object(forKey: "CurrencyFlagCheck") != nil {
                let checkString : String = (UserDefaults.standard.object(forKey: "CurrencyFlagCheck") as AnyObject) as! String
                if currencyInfo["currency_name"] as? String == (checkString)
                {
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 5, width: 20, height: 20), title: "" , border: false, bgColor: false, textColor: textColorDark)
                    
                    optionMenu.setBackgroundImage(UIImage(named: "tickicon")?.maskWithColor(color: buttonColor), for: .normal)
                    //optionMenu.addTarget(self, action: #selector(NetworksSettingsController.menuAction(_:)), for: .touchUpInside)
                    
                    
                    
                    
                    cell.accessoryView = optionMenu
                    //cell.backgroundColor = textColorMedium//UIColor(red: 40/255 , green: 40/255 , blue: 40/255, alpha: 1.0)
                }
                else{
                    cell.accessoryView = nil
                }
            }
            else{
                
                if indexStore == (indexPath as NSIndexPath).row{
                    cell.tickCheckButton.isHidden = false
                    cell.tickCheckButton.setBackgroundImage(UIImage(named: "tickicon")?.maskWithColor(color: buttonColor), for: .normal)
                }
                else{
                    cell.tickCheckButton.isHidden = true
                }
                
                
                if flagTickCheck == true{
                if  (currencyInfo["code"] as! String == (UserDefaults.standard.object(forKey: "Currency") as AnyObject) as! String) && flagTickCheck == true
                {
                    flagTickCheck = false
                    indexStore = (indexPath as NSIndexPath).row
                    cell.tickCheckButton.isHidden = false
                    cell.tickCheckButton.setBackgroundImage(UIImage(named: "tickicon")?.maskWithColor(color: buttonColor), for: .normal)
                    print("\((indexPath as NSIndexPath).row)===")
                    
                }
                else{
                    cell.tickCheckButton.isHidden = true
                }
            }
            }
        }
        else{
        
        if UserDefaults.standard.object(forKey: "Currency") != nil {
        let checkString : String = (UserDefaults.standard.object(forKey: "Currency") as AnyObject) as! String
        if currencyInfo["code"] as? String == (checkString)
        {
            let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 5, width: 20, height: 20), title: "" , border: false, bgColor: false, textColor: textColorDark)
            
            optionMenu.setBackgroundImage(UIImage(named: "tickicon")?.maskWithColor(color: buttonColor), for: .normal)
  
            cell.accessoryView = optionMenu
        }
        else{
           cell.accessoryView = nil
        }
        }
        }
        return cell
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
