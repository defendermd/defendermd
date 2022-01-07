//
//  TestBlogViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 04/08/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

class TestBlogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   let dogs = ["English Bulldog", "Labrador Retriever", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"]
        let cats = ["Persian", "Siamese", "LOL", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"]
        let rabbits = ["Lionhead", "Rex"]
    
    
    var catsTableView:UITableView!
    var dogsTableView:UITableView!
    var customSegmentControl : UISegmentedControl!
    
//        @IBOutlet weak var segmentedControl: UISegmentedControsl!
//        @IBOutlet weak var dogsTableView: UITableView!
//        @IBOutlet weak var catsTableView: UITableView!
//        @IBOutlet weak var rabbitsTableView: UITableView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let cancel = UIBarButtonItem( title: "Cancel", style: UIBarButtonItemStyle.Plain , target:self , action: "cancel")
            
            self.navigationItem.leftBarButtonItem = cancel
            
            view.backgroundColor = bgColor
            navigationController?.navigationBar.hidden = false
            let items = ["Cat", "Dog"]
            customSegmentControl = UISegmentedControl(items: items)
            customSegmentControl.addTarget(self, action: "indexChanged:", forControlEvents: UIControlEvents.ValueChanged)
            let frame = UIScreen.mainScreen().bounds
            customSegmentControl.frame = CGRectMake(0,TOPPADING, CGRectGetWidth(view.bounds), ButtonHeight)
            customSegmentControl.selectedSegmentIndex = 0
            
            view.addSubview(customSegmentControl)
            
            catsTableView = UITableView(frame: CGRectMake(0, TOPPADING+ButtonHeight , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - ButtonHeight), style: .Grouped)
            dogsTableView = UITableView(frame: CGRectMake(0, TOPPADING+ButtonHeight , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - ButtonHeight), style: .Grouped)
//            
//             self.shyNavBarManager.scrollView = self.catsTableView;
//            self.shyNavBarManager.scrollView = self.dogsTableView;
//
//            
            
//            catsTableView.frame = CGRectMake(0, 150, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-150)
//            dogsTableView.frame = CGRectMake(0, 150, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-150)
            // Do any additional setup after loading the view.
            self.dogsTableView.hidden = false
            self.catsTableView.hidden = true
            
            
            dogsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            dogsTableView.dataSource = self
            dogsTableView.delegate = self
            
            catsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            catsTableView.dataSource = self
            catsTableView.delegate = self
            
            
            view.addSubview(catsTableView)
            view.addSubview(dogsTableView)

//            self.rabbitsTableView.hidden = true
        }
        
         func indexChanged(sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                self.dogsTableView.hidden = false
                self.catsTableView.hidden = true
                
                println("india")
                
//                self.rabbitsTableView.hidden = true
            case 1:
                self.dogsTableView.hidden = true
                self.catsTableView.hidden = false
                
                 println("pakistan")
                
//                self.rabbitsTableView.hidden = true
            case 2:
                self.dogsTableView.hidden = true
                self.catsTableView.hidden = true
//                self.rabbitsTableView.hidden = false
            default:
                break;
            }
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var count: Int = 0
            
            println(tableView)
            
            if (tableView == self.dogsTableView) {
                println("dogs count")
                count = self.dogs.count
            }
            else if (tableView == self.catsTableView) {
                println("cats count")
                count = self.cats.count
            }
//            else if (tableView == self.rabbitsTableView) {
//                println("rabbits count")
//                count = self.rabbits.count
//            }
            
            return count
        }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = "Srijan"
        
        return cell
        
    }
    
    
//        
//        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//            var cell: UITableViewCell!
//            
//            if (tableView == self.dogsTableView) {
//                println("dogs count")
//                
//                var cell = self.dogsTableView.dequeueReusableCellWithIdentifier("cell") as? DogTableViewCell
//                
//                if (cell == nil) {
//                    let nib = NSBundle.mainBundle().loadNibNamed("DogTableViewCell", owner: DogTableViewCell.self, options: nil) as NSArray
//                    cell = nib.objectAtIndex(0) as? DogTableViewCell
//                }
//                
//                cell?.loadDog(breed: self.dogs[indexPath.row])
//                
//                return cell!
//            }
//            else if (tableView == self.catsTableView) {
//                println("cats count")
//                
//                var cell = self.catsTableView.dequeueReusableCellWithIdentifier("cell") as? CatTableViewCell
//                
//                if (cell == nil) {
//                    let nib = NSBundle.mainBundle().loadNibNamed("CatTableViewCell", owner: CatTableViewCell.self, options: nil) as NSArray
//                    cell = nib.objectAtIndex(0) as? CatTableViewCell
//                }
//                
//                cell?.loadCat(breed: self.cats[indexPath.row])
//                
//                return cell!
//            }
//            else if (tableView == self.rabbitsTableView) {
//                println("rabbits count")
//                
//                var cell = self.rabbitsTableView.dequeueReusableCellWithIdentifier("cell") as? RabbitTableViewCell
//                
//                if (cell == nil) {
//                    let nib = NSBundle.mainBundle().loadNibNamed("RabbitTableViewCell", owner: RabbitTableViewCell.self, options: nil) as NSArray
//                    cell = nib.objectAtIndex(0) as? RabbitTableViewCell
//                }
//                
//                cell?.loadRabbit(breed: self.rabbits[indexPath.row])
//                
//                return cell!
//            }
//            else {
//                return cell!
//            }
//        }
//    }
    
    // Dog, Cat, and Rabbit Table View Cell files (essentially the same, see Dog is shown below)
    class DogTableViewCell: UITableViewCell {
        
        @IBOutlet weak var titleLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        
        func loadDog(#breed: String) {
            self.titleLabel.text = breed
        }
        
    }
    
    func cancel(){
        var presentedVC = AdvanceActivityFeedViewController()
        
        self.navigationController?.pushViewController(presentedVC, animated: true)
        

    }
}
