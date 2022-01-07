//
//  StoreInitialConfiguration.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 20/02/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class StoreInitialConfiguration: UIViewController, UITableViewDataSource,UITableViewDelegate
{

    
    var contentType : String!
    var url : String!
    var PackageTableview : UITableView!
    var dynamicHeight : CGFloat = 60
    var leftBarButtonItem : UIBarButtonItem!
    var storeid : Int!
    var storeID : String!
    var urlParams:NSDictionary!
    var storeCell = ["Add Payment Method", "Add Shipping Method","Add New Product"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        
        PackageTableview = UITableView(frame: CGRect(x: 0,y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        PackageTableview.register(PackageTableViewCell.self, forCellReuseIdentifier: "Cell")
        PackageTableview.estimatedRowHeight = 60.0
        PackageTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        PackageTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        PackageTableview.backgroundColor = tableViewBgColor
        self.PackageTableview.isOpaque = false
        self.PackageTableview.dataSource = self
        self.PackageTableview.delegate = self
        self.view.addSubview(PackageTableview)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        setNavigationImage(controller: self)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.title = NSLocalizedString("Configure Store", comment: "")
        let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(StoreInitialConfiguration.cancel))
        self.navigationItem.rightBarButtonItem = skipButton
        
    } 
    
    @objc func cancel()
    {
        conditionalProfileForm = "BrowseMyStore"
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       let condition = (indexPath as NSIndexPath).row
       switch(condition)
       {
       case 0 :
            let alert = UIAlertController(title: "Password", message: "Please Enter your login Password", preferredStyle: .alert)
            alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Login Password"
            }
            let action1 = UIAlertAction(title: "OK", style:UIAlertAction.Style.default, handler: { (action) -> Void in
            
            let firstTextField = alert.textFields![0] as UITextField
            let firstValue = firstTextField.text
            let presentedVC = AddPaymentMethodViewController()
            presentedVC.password = firstValue!
            presentedVC.storeId = String(self.storeID!)
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated: false, completion: nil)
            
        })
        let action2 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: false, completion: nil)
       case 1 :
        
            let presentedVC = AddShippingMethodViewController()
            presentedVC.contentType = "addNewShippingMethod"
            presentedVC.storeId = storeID
            tempCategArray.removeAll(keepingCapacity: false)
            tempFormArray.removeAll(keepingCapacity: false)
            tempTempCategArray.removeAll(keepingCapacity: false)
            let nativationController = UINavigationController(rootViewController : presentedVC)
            self.present(nativationController, animated : false, completion : nil)
        
       case 2 :
        
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Select Product Type ", comment: "")
            presentedVC.contentType = "productType"
            isCreateOrEdit = true
            presentedVC.url = "sitestore/product/create"
            presentedVC.storeId = storeID
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated: false, completion: nil)
//            let alert = UIAlertController(title: "Message", message: "Sorry this feature has not been setup for Now", preferredStyle: .alert)
//            let productAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//            alert.addAction(productAction)
//            self.present(alert, animated: false, completion: nil)
       default :
            break
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PackageTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        cell.lbltitle.text = storeCell[(indexPath as NSIndexPath).row]
        cell.btnmenu.tag = (indexPath as NSIndexPath).row
        cell.lineView.frame = CGRect(x: 0, y: cell.lbltitle.frame.origin.y + cell.lbltitle.bounds.height+20, width: cell.cellView.frame.size.width, height: 1)
        
        dynamicHeight = 60
        
        if dynamicHeight < (cell.lineView.frame.origin.y + cell.lineView.bounds.height)
        {
            dynamicHeight = (cell.lineView.frame.origin.y + cell.lineView.bounds.height+1)
            cell.cellView.frame.size.height = dynamicHeight
        }
        cell.btnmenu.isHidden = true
        //cell.btnmenu.frame = CGRect(x: cell.cellView.frame.size.width-50, y: cell.cellView.frame.size.height/2-12, width: 25, height: 25)
        return cell
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
