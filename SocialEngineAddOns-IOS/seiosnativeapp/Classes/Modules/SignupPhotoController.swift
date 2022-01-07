//
//  SignupViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 04/06/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

class SignupPhotoController: FXFormViewController {
    var popAfterDelay:Bool!
    var id:Int!
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        //        view.backgroundColor = bgColor
        popAfterDelay = false
        self.title = NSLocalizedString("Sign Up", comment: "")
        conditionalForm = "signupPhotoForm"
        
        mediaType = "image"
       
        multiplePhotoSelection = false
        
        
        
    }
    
    
    // Generate Form On View Appear
    override func viewDidAppear(animated: Bool) {
        generateBlogForm()
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg)
        // Initialization of Timer
        createTimer(self)
    }
    
    // Stop Timer
    func stopTimer() {
        stop()
        
        if popAfterDelay == true{
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as CreateNewForm
        var error = ""
        
        for (key, value) in form.valuesByKey{
            println("\(key) ----->  \(value)")
        }
        // Check Internet Connection
        if reachability.isReachable() {
            
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            
            if (form.valuesByKey["photo"]) != nil{
                println([form.valuesByKey["photo"] as UIImage])
                var imageArray = [form.valuesByKey["photo"] as UIImage]
                filePathArray.removeAll(keepCapacity: false)
                filePathArray = saveFileInDocumentDirectory(imageArray)
            }else{
                filePathArray.removeAll(keepCapacity: false)
            }
        
        
            
            var dic = Dictionary<String, String>()
            for (key, value) in form.valuesByKey{
                
                if (key as NSString == "draft") || (key as NSString == "category_id") || (key as NSString == "auth_view") || (key as NSString == "auth_comment"){
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as String)
                }else{
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver
                    }
                    if let receiver = value as? Int {
                        dic["\(key)"] = String(receiver)
                    }
                    
                    dic["photo"] = "123"
                    dic["fields_validation"] = "0"
                    dic["account_validation"] = "0"
                }
                
            }
            
            dic["fields_validation"] = "1"
            dic["account_validation"] = "1"
            dic["photo"] = "123"
            signupDictionary.update(dic)
            
            println(signupDictionary)
            println("final")
            
            var err: NSError?
            // Conversion of Form Data in Json
            
            
            var data = NSJSONSerialization.dataWithJSONObject(dic, options: nil, error: &err)
            var jsonString = ""
            if((data) != nil)
            {
                jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            }
            
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = signupDictionary
            path = "signup"
            
            // Send Server Request to Create/Edit Blog Entries
//            post(parameter,path , "POST") { (succeeded, msg) -> () in
                 postForm(parameter, path, filePathArray, "photo" , true) { (succeeded, msg) -> () in
                
                dispatch_async(dispatch_get_main_queue(),{
//                    spinner.stopAnimating()
//                    self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                    self.popAfterDelay = true
//                    if msg{
//                        if succeeded["message"] != nil{
//                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                            self.popAfterDelay = true
//                        }
//                    }else{
//                        if succeeded["message"] != nil{
//                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                            
//                        }bch
//                    }
                    
                    self.showAlertMessage(self.view.center,msg: ("Account created...Yipeeee!!!") )
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
        
    }
    
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateBlogForm(){
        // Check Internet Connection
        if reachability.isReachable() {
            
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            path = "signup"
            
            // Send Server Request for Create/Edit Blog Form
            post(parameter, path, "GET") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(),{
                    spinner.stopAnimating()
                    
                    
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepCapacity: false)
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
                            
                        }
                        if let dic = succeeded["body"] as? NSDictionary{
                            if let fieldDictionary = dic["photo"] as? NSArray{
//                                if let accountArray = fieldDictionary["1"] as? NSArray{
                                    Form = fieldDictionary
//                                }
                            }
                            
                        }
                        
                        println(Form)
                        
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        
                        let save = UIBarButtonItem(image: UIImage(named:"icon-new.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "submitForm")
                        self.navigationItem.rightBarButtonItem = save
                        
                        
                        self.formController.tableView.reloadData()
                        // })
                        
                        
                    }else{
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveAndCheckValidations(){
        
        var presentedVC = SignupProfileFieldController()
        //        presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
        //        presentedVC.contentType = "blog"
        //        presentedVC.param = [ : ]
        //        presentedVC.url = "blogs/create"
        
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
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
