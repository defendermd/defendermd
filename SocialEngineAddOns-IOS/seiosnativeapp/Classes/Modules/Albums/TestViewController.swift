//
//  TestViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 07/08/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIScrollViewDelegate {
    
    var titleView = UIScrollView()
    var titleLabel:UILabel!
    var contentView : UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        
        
        self.title = "My Title"
        titleView = UIScrollView(frame: CGRectMake(0.0, 0.0, 100.0, 44.0))
        titleView.contentSize = CGSizeMake(0.0, 88.0)
        self.view.addSubview(titleView)
        
       titleLabel = UILabel(frame: CGRectMake(0.0, 44.0, CGRectGetWidth(titleView.frame), 44.0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 17)
        titleLabel.text = self.title
        titleView.addSubview(titleLabel)
        
        self.navigationItem.titleView = titleView
        
        contentView = UIScrollView(frame: self.view.bounds)
        contentView.contentSize = CGSizeMake(0.0, 4000.0)
        contentView.delegate = self
        self.view.addSubview(contentView)
        
        let contentLabel:UILabel = UILabel(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 44.0))
        contentLabel.textAlignment = NSTextAlignment.Center
        contentLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 17)
        contentLabel.text = self.title
        contentView.addSubview(contentLabel)

        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        let contentnOffset:CGPoint = CGPointMake(0.0, min(scrollView.contentOffset.y + 64.0, 44.0))
        titleView.setContentOffset(contentnOffset, animated: true)
    }

}
