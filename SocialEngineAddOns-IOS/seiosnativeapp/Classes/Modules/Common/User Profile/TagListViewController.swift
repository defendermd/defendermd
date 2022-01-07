//
//  TagListViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 26/04/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit

class TagListViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{

     var blogResponse = [AnyObject]()
     var blogTableView:UITableView!
     let mainView = UIView()
   //  var imageCache = [String:UIImage]()
    var contentType : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = "Tagged User"
        if contentType == "feedTitle"{
            self.blogResponse.remove(at: 0)
        }
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TagListViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        blogTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight ), style: .grouped)
        blogTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 75
        blogTableView.rowHeight = UITableView.automaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            blogTableView.estimatedSectionHeaderHeight = 0
            
        }
        view.addSubview(blogTableView)
        
    
        explore()
        
        // Do any additional setup after loading the view.
    }
    
    func explore(){
       blogTableView.reloadData()
    }
    @objc func goBack(){
       _ = self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return blogResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        cell.backgroundColor = tableViewBgColor
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imgUser.contentMode = .scaleAspectFill
        cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 25,width: (UIScreen.main.bounds.width - 75) , height: 100)
        if self.contentType == "feedTitle"{
        cell.labTitle.text = (blogInfo["tag_obj"] as! NSDictionary)["displayname"] as? String
        }
        else{
        cell.labTitle.text = blogInfo["text"] as? String
        }
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZEMedium)
        cell.labTitle.sizeToFit()
        
        // Set Blog Owner Image
        
        if self.contentType == "feedTitle"{
            if let url = URL(string: ((blogInfo["tag_obj"] as! NSDictionary)["image_icon"] as? String)!){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            
             cell.accessoryView = nil

        }
        else{
            cell.optionRemoveMenu.tag = (indexPath as NSIndexPath).row
            cell.optionRemoveMenu.addTarget(self, action:#selector(TagListViewController.removeTag(_:)) , for: .touchUpInside)
            

        if let url = URL(string: blogInfo["image"] as! String){
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
           }
            
            if blogInfo["isRemove"] as? Int == 1{
                cell.optionRemoveMenu.isHidden = false
            }
            else{
                cell.optionRemoveMenu.isHidden = true
            }

        }
        
       
        
        return cell
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var blogInfo:NSDictionary
        blogInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        let presentedVC = ContentActivityFeedViewController()
        
        if (blogInfo["tag_id"] is String){
            let tempValue = blogInfo["tag_id"] as! String
            presentedVC.subjectId = "\(tempValue)"
        }else{
            presentedVC.subjectId = "\(blogInfo["tag_id"]!)"
        }
        
        presentedVC.subjectType = "user"
        navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    @objc func removeTag(_ sender:UIButton){
        var memberInfo:NSDictionary
        memberInfo = blogResponse[sender.tag] as! NSDictionary
        
        let menuItem = memberInfo["menus"] as! NSDictionary
        let nameString1 = menuItem["name"] as! String
        switch(nameString1){
            
        case "delete_tag":
            
            displayAlertWithOtherButton(NSLocalizedString("Remove Tag", comment: ""),message: NSLocalizedString("Are you sure you want to remove the tag?",comment: "") , otherButton: NSLocalizedString("Confirm", comment: "")) { () -> () in
                self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo["tag_id"] as! Int , rowId : sender.tag)
            }
            
            self.present(alert, animated: true, completion: nil)
            
        default:
            
            print("error")
            
        }
        
        
    }
    
    func updateMembers(_ parameter: NSDictionary , url : String , user_id : Int , rowId : Int){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            self.blogResponse.remove(at: rowId)
            self.blogTableView.reloadData()
            
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        showToast(message: "Tag removed successfully", controller: self)
                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                            if self.blogResponse.count == 0{
                                _ = self.navigationController?.popViewController(animated: false)
                            }
                        })
                        
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
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
