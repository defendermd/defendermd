//
//  PhotoViewerCell.swift
//  seiosnativeapp
//
//  Created by BigStep on 29/03/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

class PhotoViewerCell: UICollectionViewCell,UIScrollViewDelegate {
    
    var innerscrollview = UIScrollView()
    var imageView = UIImageView()
    
    override func awakeFromNib() {
  
        innerscrollview.frame = CGRect(x: 0, y: PADING, width: self.bounds.size.width, height: self.bounds.size.height - 2*PADING)
        innerscrollview.minimumZoomScale = 1;
        innerscrollview.maximumZoomScale = 3;
        innerscrollview.zoomScale = 1;
     //   innerscrollview.contentSize = self.photoViewerScrollView.bounds.size
        innerscrollview.delegate = self;
        innerscrollview.showsHorizontalScrollIndicator = false;
        innerscrollview.showsVerticalScrollIndicator = false;
        innerscrollview.isUserInteractionEnabled = true
        contentView.addSubview(innerscrollview)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerCell.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2;
        innerscrollview.addGestureRecognizer(doubleTap);
        
        imageView.frame = CGRect(x: 0, y: 0, width: innerscrollview.bounds.width, height: innerscrollview.bounds.height)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "album-default.png")
        innerscrollview.addSubview(imageView)
     
    }
    @objc func doubleTapped(_ sender:UITapGestureRecognizer)
    {
        let scroll = sender.view as! UIScrollView
        if scroll.zoomScale > 1.0
        {
            scroll.setZoomScale(1.0, animated:true);
        }
        else
        {
            let point = sender.location(in: scroll);
            scroll.zoom(to: CGRect(x: point.x-50, y: point.y-50, width: 100, height: 100), animated:true)
        }
        
        
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
