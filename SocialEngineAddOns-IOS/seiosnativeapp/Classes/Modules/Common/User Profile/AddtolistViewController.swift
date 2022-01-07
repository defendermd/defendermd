//
//  AddtolistViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 2/27/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class AddtolistViewController: UIViewController, UITextViewDelegate,UIGestureRecognizerDelegate {
    
    var Listtableview : UITableView!
    var navtitle : UILabel!
    var keyBoardHeight :  CGFloat = 0
    var textfiled1 = UITextView()
    var form = [AnyObject]()
    var friend_id : Int = 0
    var valuedic = [Int:Int]()
    var valuenamedic = [String:String]()
    var height1 : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Customnavigation()
        view.backgroundColor = textColorLight
        
        Listtableview = UITableView(frame: CGRect(x: 0, y:0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight), style: .plain)
        Listtableview.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        Listtableview.rowHeight = 40
        Listtableview.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
        Listtableview.dataSource = self
        Listtableview.delegate = self
        Listtableview.bounces = false
        Listtableview.backgroundColor = tableViewBgColor
        Listtableview.separatorColor = TVSeparatorColor
        Listtableview.isHidden = true
        view.addSubview(Listtableview)
        // Do any additional setup after loading the view.
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddtolistViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        //Notification for showing/Hiding keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddtolistViewController.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddtolistViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        


        browse()
    }
    
    func browse()
    {
        // Set Spinner
//        spinner.center = self.view.center
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
//        view.addSubview(spinner)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        var parameters = [String:String]()
        parameters = ["friend_id": "\(friend_id)"]
        
        // Send Server Request for Activity Feed
        post(parameters, url: "user/list-add", method: "GET") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                
                // On Success Update Feeds
                if msg{
                    
                    activityIndicatorView.stopAnimating()
                    self.form.removeAll(keepingCapacity: false)
                    // Check response of Activity Feeds
                    if let body = succeeded["body"] as? NSDictionary{
                        if let members = body["form"] as? NSArray{
                            self.form =  members as [AnyObject]
                        }
                    }
                    self.Listtableview.isHidden = false
                    self.Listtableview.reloadData()
                }else{
                    // Show Message on Failour
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                        
                    }
                    
                }
                
            })
        }
        
    }
    
    @objc func goBack()
    {
        navtitle.text = ""
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func Customnavigation()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2, y:0, width: navigationBar.frame.width/3, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            navtitle.text = NSLocalizedString("Add To List", comment: "")
            //navtitle.sizeToFit()
            navtitle.tag = 400
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            navigationBar.addSubview(navtitle)
            
            let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
            button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
            button.backgroundColor = UIColor.clear
            button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
            
            button.addTarget(self, action: #selector(AddtolistViewController.send), for: UIControl.Event.touchUpInside)

        
            let filter = UIBarButtonItem()
            filter.customView = button
            self.navigationItem.setRightBarButtonItems([filter], animated: true)
        }
    }
    
    @objc func send()
    {
        //print("okay")
        if textfiled1.text == NSLocalizedString("Create New List",  comment: "")
        {
            textfiled1.text = ""
        }
        var parameters = [String:String]()
        parameters = ["friend_id": "\(friend_id)","title":"\(textfiled1.text!)"]
        parameters.update(valuenamedic)
        // Send Server Request for Activity Feed
        post(parameters, url: "user/list-add", method: "POST") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                
                // On Success Update Feeds
                if msg{
                    if self.textfiled1.text != ""{
                        self.view.makeToast(NSLocalizedString("\(self.textfiled1.text!) list has been created successfully.",  comment: "") , duration: 5, position: CSToastPositionCenter)
                    }
                    else
                    {
                        self.view.makeToast(NSLocalizedString("Your action has been performed successfully.",  comment: "") , duration: 5, position: CSToastPositionCenter)
                    }
                    self.createTimer(self)
                }else{
                    // Show Message on Failour
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                        
                    }
                    
                }
                
            })
        }

    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        self.textfiled1.text = ""
        self.browse()
//        self.goBack()
    }
    
    func deletelist(tag : Int)
    {
        var name : Int = 0
        let formdata = form[tag]
        if formdata["type"] as? String == "Checkbox"
        {
            name = (formdata["name"] as? Int)!
        }
        let parameters = ["friend_id": "\(friend_id)","list_id":"\(name)"]
        
        // Send Server Request for Activity Feed
        post(parameters , url: "user/list-delete", method: "DELETE") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                
                // On Success Update Feeds
                if msg{
                    self.browse()
                }else{
                    // Show Message on Failour
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
                
            })
        }
    }
    
    @objc func removelist(_ sender : UIButton)
    {
        displayAlertWithOtherButton(NSLocalizedString("Delete List", comment: ""),message: NSLocalizedString("Are you sure you want to delete this list?",comment: "") , otherButton: NSLocalizedString("Confirm", comment: "")) { () -> () in
            //print("ok")
            self.deletelist(tag: sender.tag)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func resignKeyboard(){
        textfiled1.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == textColorMedium {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.isEmpty{
            self.textfiled1.text = NSLocalizedString("Create New List",  comment: "")
            self.textfiled1.textColor = textColorMedium
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.contains("\n") {
            textView.text = textView.text?.replacingOccurrences(of: "\n", with: "")
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyBoardHeight = keyboardFrame.size.height
        
        height1 = Listtableview.bounds.height - (view.bounds.height - keyBoardHeight)
        
        if height1 > 0
        {
            Listtableview.frame.size.height -= height1
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification)
    {
        if height1 > 0
        {
            Listtableview.frame.size.height += height1
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddtolistViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let formdata = form[indexPath.row]
        let namekey = formdata["name"] as? Int
        if valuedic[indexPath.row] == 0
        {
            valuenamedic["\(namekey!)"] = "1"
            valuedic[indexPath.row] = 1
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        }
        else
        {
            valuenamedic["\(namekey!)"] = "0"
            valuedic[indexPath.row] = 0
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.form.count != 0
        {
            return 50
        }
        else
        {
            return 0.00001
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width-20, height: 20))
        label.font = UIFont(name: fontName, size: FONTSIZEMedium)
        label.numberOfLines = 0
        label.text = NSLocalizedString("Please select the list in which you want to add your friend.", comment: "")
        label.sizeToFit()
        header.addSubview(label)
        header.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = UIView()
        
        let label1 = UILabel(frame: CGRect(x: 15, y: 10, width: UIScreen.main.bounds.width-30, height: 20))
        label1.font = UIFont(name: fontName, size: FONTSIZEMedium)
        label1.text = NSLocalizedString("Add Friend In a New List.", comment: "")
        header.addSubview(label1)
        
        textfiled1 = UITextView(frame: CGRect(x: 15, y: getBottomEdgeY(inputView: label1)+5, width: UIScreen.main.bounds.width-30, height: 40))
        textfiled1.textColor = textColorMedium
        textfiled1.delegate = self
        textfiled1.text = NSLocalizedString("Create New List",  comment: "")
        header.addSubview(textfiled1)
        
        header.backgroundColor = .white
        return header
    }
}

extension AddtolistViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.form.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let formdata = form[indexPath.row]
//        label.isHidden = false
        cell.imgUser.isHidden = true
        cell.addtolist.isHidden = true
        cell.endDateLabel.isHidden = true
        cell.cross.isHidden = false
        cell.cross.tag = indexPath.row
        cell.cross.addTarget(self, action: #selector(removelist(_:)), for: .touchUpInside)
    
        cell.memberAge.isHidden = false
        cell.memberAge.frame = CGRect(x: 15, y: 10, width: 180, height: 30)
        if formdata["type"] as? String == "Checkbox"
        {
            let name = formdata["label"]
            cell.memberAge.text = "\((name!)!)"
            
            let value = formdata["value"] as? Int
            let namekey = formdata["name"] as? Int
            if value == 1
            {
                cell.accessoryType = .checkmark
                valuedic[indexPath.row] = 1
                valuenamedic["\(namekey!)"] = "1"
            }
            else
            {
                valuenamedic["\(namekey!)"] = "0"
                valuedic[indexPath.row] = 0
                cell.accessoryType = .none
            }
        }
        
        
        cell.memberAge.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        return cell
    }
}
