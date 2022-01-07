////
////  CreateNewBlog.swift
////  seiosnativeapp
////
////  Created by bigstep on 24/12/14.
////  Copyright (c) 2014 bigstep. All rights reserved.
////
//
//import UIKit
//
//
//
//class CreateNewBlog: FXFormViewController {
//    var popAfterDelay:Bool!
//    var id:Int!
//    // Initialization of class Object
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        view.backgroundColor = bgColor
//        blogUpdate = false
//        popAfterDelay = false
//        if isCreateOrEdit {
//            self.title = NSLocalizedString("Write New Entry", comment: "")
//        }else{
//            self.title = NSLocalizedString("Edit Entry", comment: "")
//        }
//        
//    }
//    
//    
//    // Generate Form On View Appear
//    override func viewDidAppear(animated: Bool) {
//        generateBlogForm()
//    }
//    
//    
//    // Generate Custom Alert Messages
//    func showAlertMessage( centerPoint: CGPoint, msg: String){
//        self.view .addSubview(validationMsg)
//        showCustomAlert(centerPoint, msg)
//        // Initialization of Timer
//        createTimer(self)
//    }
//    
//    // Stop Timer
//    func stopTimer() {
//        stop()
//        
//        if popAfterDelay == true{
//             navigationController?.popViewControllerAnimated(true)
//        }
//    }
//    
//    
//    // MARK: - Server Connection For Blog Form Creation & Submission
//    
//    // FXFormForm Submission for Create or Edit Blog
//    func submitForm(cell: FXFormFieldCellProtocol) {
//        
//        //we can lookup the form from the cell if we want, like this:
//        
//        let form = cell.field.form as CreateNewForm
//        var error = ""
//        
//        // Form Validation Check
//            if (form.valuesByKey["title"] as String) == ""{
//                error = NSLocalizedString("Please Enter an Title.", comment: "")
//            } else if (form.valuesByKey["body"] as String) == "" && error == ""{
//                error = NSLocalizedString("Please Enter body.", comment: "")
//            }
//        
//        
//               
//        if error != ""{
//            showAlertMessage(view.center , msg: error)
//            return
//        }
//            
//            
//            
//            
//            // Check Internet Connection
//            if reachability.isReachable() {
//                
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//                view.addSubview(spinner)
//                spinner.startAnimating()
//                
//                
//                var dic = Dictionary<String, String>()
//                for (key, value) in form.valuesByKey{
//                   
//                    if (key as NSString == "draft") || (key as NSString == "category_id") || (key as NSString == "auth_view") || (key as NSString == "auth_comment"){
//                      dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as String)
//                    }else{
//                        
//                        if let receiver = value as? NSString {
//                            dic["\(key)"] = receiver
//                        }
//                        if let receiver = value as? Int {
//                            dic["\(key)"] = String(receiver)
//                        }
//                    }
//                    
//                }
//                
//                
//                println(dic)
//                
//                var err: NSError?
//                // Conversion of Form Data in Json
//                
//                var data = NSJSONSerialization.dataWithJSONObject(dic, options: nil, error: &err)
//                var jsonString = ""
//                if((data) != nil)
//                {
//                    jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
//                }
//                
//                //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
//                var parameter = [String:String]()
//                var path = ""
//                if isCreateOrEdit{
//                    parameter = ["token":"\(auth_token)", "values":"\(jsonString)"]
//                    path = "blogs/create"
//                }else{
//                    parameter = ["token":"\(auth_token)", "values":"\(jsonString)", "blog_id":"\(id)"]
//                    path = "blogs/edit"
//                }
//                
//                // Send Server Request to Create/Edit Blog Entries
//                post(parameter,path , "POST") { (succeeded, msg) -> () in
//                   
//                    dispatch_async(dispatch_get_main_queue(),{
//                         spinner.stopAnimating()
//                    if msg{
//                        // On Sucess Update Blog
//                        
//                        
//                            if succeeded["message"] != nil{
//                                self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                            self.popAfterDelay = true
//                            }
//                            
//                        blogUpdate = true
//                        blogDetailUpdate = true
//                           // isFilterSerch = false
//                        
//                        
//                    }else{
//                        if succeeded["message"] != nil{
//                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                            
//                        }
//                        }
//                        })
//                }
//            }else{
//                // No Internet Connection Message
//                showAlertMessage(view.center , msg: network_status_msg)
//            }
//            
//       
//    }
//    
//    
//    // Create Request for Generation of Create/Edit Blog Form
//    func generateBlogForm(){
//        // Check Internet Connection
//        if reachability.isReachable() {
//            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//            view.addSubview(spinner)
//            spinner.startAnimating()
//            
//            //Set Parameters & path for Create/Edit Blog Form
//            var parameter = [String:String]()
//            var path = ""
//            if isCreateOrEdit{
//                parameter = ["token":"\(auth_token)"]
//                path = "blogs/create"
//            }else{
//                parameter = ["token":"\(auth_token)","blog_id":"\(id)"]
//                path = "blogs/edit"
//            }
//            
//            // Send Server Request for Create/Edit Blog Form
//            post(parameter, path, "GET") { (succeeded, msg) -> () in
//                dispatch_async(dispatch_get_main_queue(),{
//                    spinner.stopAnimating()
//                
//                
//                if msg{
//                    // On Success Add Value to Form Array & Values to formValue Array
//                    Form.removeAll(keepCapacity: false)
//                    if succeeded["message"] != nil{
//                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                        
//                    }
//                    if isCreateOrEdit{
//                        if let dic = succeeded["body"] as? NSDictionary{
//                            if let formArray = dic["response"] as? NSArray{
//                                Form = formArray
//                            }
//                        }
//                    }else{
//                        if let dic = succeeded["body"] as? NSDictionary{
//                           // if let response = dic["response"] as? NSDictionary{
//                            if let formArray = dic["form"] as? NSArray{
//                                Form = formArray
//                            }
//                            if let formValues = dic["formValue"] as? NSDictionary{
//                                formValue = formValues
//                            }
//                           // }
//                        }
//                    }
//                    
//                  //  dispatch_async(dispatch_get_main_queue(),{
//                    
//                        // Create FXForm Form
//                        self.formController.form = CreateNewForm()
//                        self.formController.tableView.reloadData()
//                   // })
//                    
//                    
//                }else{
//                    if succeeded["message"] != nil{
//                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                        
//                    }
//                    }
//                    })
//            }
//        }else{
//            // No Internet Connection Message
//            showAlertMessage(view.center , msg: network_status_msg)
//        }
//        
//    }
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    /*
//    // MARK: - Navigation
//    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    // Get the new view controller using segue.destinationViewController.
//    // Pass the selected object to the new view controller.
//    }
//    */
//    
//}
