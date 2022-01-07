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
//  PhotosTableViewCell.swift
//  seiosnativeapp
//

import UIKit

// This Class is used by PhotoListViewController & UploadPhotosEventViewController

class PhotosTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var image1:UIButton!
    var uploadedby1:UILabel!
    var uploadedate1:UILabel!
    
    var image2:UIButton!
    var uploadedby2:UILabel!
    var uploadedate2:UILabel!
    
    var image3:UIButton!
    var uploadedby3:UILabel!
    var uploadedate3:UILabel!
    
    var image4:UIButton!
    var uploadedby4:UILabel!
    var uploadedate4:UILabel!
    
    
    
    // Initialize Variable for Comments Table Cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Configure the view for the selected state
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width)/4
        }else{
            size = (UIScreen.main.bounds.width)/2
        }
        //1
        
        image1 = createButton(CGRect(x: 2*PADING, y: 0,width: size - 2*PADING , height: 160 - 5), title: "", border: false,bgColor: false, textColor: textColorLight)
        image1.isHidden = true
        image1.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        image1.setImage(UIImage(named: "sampleImage.png"), for: UIControl.State())
        self.addSubview(image1)
        
        
        
        uploadedby1 = createLabel(CGRect(x: 5, y: 15+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
        uploadedby1.font =   UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(uploadedby1)
        
        uploadedate1 = createLabel(CGRect(x: 5, y: 27+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
        uploadedate1.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(uploadedate1)
        
        //2
        image2 = createButton(CGRect(x: (2 * PADING) + size, y: 0,width: size - 2*PADING , height: 160-5), title: "", border: false,bgColor: false, textColor: textColorLight)
        image2.isHidden = true
        image2.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        image2.setImage(UIImage(named: "sampleImage.png"), for: UIControl.State())
        self.addSubview(image2)
        
        
        
        
        
        uploadedby2 = createLabel(CGRect(x: 10+size, y: 15+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
        uploadedby2.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(uploadedby2)
        
        uploadedate2 = createLabel(CGRect(x: 10+size, y: 27+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
        uploadedate2.font = UIFont(name: fontName, size: FONTSIZESmall)
        self.addSubview(uploadedate2)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            //3
            image3 = createButton(CGRect(x: (2*size), y: 0,width: size , height: size), title: "", border: false,bgColor: false, textColor: textColorLight)
            image3.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            image3.isHidden = true
            image3.setImage(UIImage(named: "sampleImage.png"), for: UIControl.State())
            self.addSubview(image3)
            
            uploadedby3 = createLabel(CGRect(x: 15+(2*size), y: 15+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
            uploadedby3.font = UIFont(name: fontName, size: FONTSIZESmall)
            self.addSubview(uploadedby3)
            
            uploadedate3 = createLabel(CGRect(x: 15+(2*size), y: 27+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
            uploadedate3.font = UIFont(name: fontName, size: FONTSIZESmall)
            self.addSubview(uploadedate3)
            
            
            //4
            image4 = createButton(CGRect(x: (3*size), y: 0,width: size , height: size), title: "", border: false,bgColor: false, textColor: textColorLight)
            image4.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            image4.isHidden = true
            image4.setImage(UIImage(named: "sampleImage.png"), for: UIControl.State())
            self.addSubview(image4)
            
            uploadedby4 = createLabel(CGRect(x: 20+(3*size), y: 15+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
            uploadedby4.font = UIFont(name: fontName, size: FONTSIZESmall)
            self.addSubview(uploadedby4)
            
            uploadedate4 = createLabel(CGRect(x: 20+(3*size), y: 27+size,width: size , height: 12), text: "", alignment: .left, textColor: textColorMedium)
            uploadedate4.font = UIFont(name: fontName, size: FONTSIZESmall)
            self.addSubview(uploadedate4)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
