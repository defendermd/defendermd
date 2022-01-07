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

//  RawFile.swift

import Foundation
import UIKit
import Photos
import CoreData
import QuartzCore
import AVFoundation
import FBAudienceNetwork
//import GoogleMobileAds
import Contacts

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


//MARK: - Global Variables
var audioPlayer = AVAudioPlayer()
var updateAfterAlert:Bool!
var openMenu = false
var openSideMenu = false
var alert = UIAlertController()
let limit:Int = 20
var menuRefreshConter = 0
var menuItems: NSDictionary = [:]
var formValue: NSDictionary = [:]
var MultiCheckFormValue: NSDictionary = [:]
var formValuearr: NSArray = []
var tabMenu: NSArray = []
var gutterMenu: NSArray = []
var tapGesture = UITapGestureRecognizer()
var tempformValue = NSMutableDictionary()
let keyBoardHeight = findKeyBoardHeight()
var leftSwipe:UISwipeGestureRecognizer!
var rightSwipe:UISwipeGestureRecognizer!
var multiplePhotoSelection : Bool!
var mediaType =  ""
//var userImageCaches = [String:UIImage]()
var listingGlobalTypeId : Int!
var FormforRepeat = [AnyObject]()
var window: UIWindow?
var baseController : CustomTabBarController!
var cartCount: Int! = 0
var iscomingfrom:String = ""
var listingNameToShow : String = ""
var frndTag = [Int:String]()
var locationTag = [String:NSDictionary]()
var frndTagValue = [String:String]()

//MARK: - dynamicTabBar
var tabControllersecond = UIViewController()
var tabControllerthird = UIViewController()
var tabControllerfourth = UIViewController()
var notificationIndex : Int = 0
var messageIndex : Int = 0
var friendReqIndex : Int = 0
var cartIndex : Int = 0
var isShowAppName : Int = 0




//MARK: - Font Icons
var valuesOfAddToCart  =  [AnyObject]()
var clipBoardIcon = "\u{f0ea}"
var plusIcon = "\u{f067}"
var likeIcon = "\u{f087}"
var commentIcon = "\u{f0e5}"
var shareIcon = "\u{f064}"
var messageIcon = "\u{f003}"
var subscribeIcon = "\u{f1d9}"
var friendReuestIcon  = "\u{f234}"
var notificationDefaultIcon = "\u{f0ac}"
var inviteIcon = "\u{f122}"
var fiterIcon = "\u{f0b0}"
var dashboardIcon = "\u{f0c9}"
var optionIcon = "\u{f141}"
var removeIcon = "\u{f00d}"
var viewIcon = "\u{f06e}"
var unfriendIcon = "\u{f235}"
var cancelFriendIcon = "\u{f00d}"
var unlikeIcon = "\u{f165}"
var navigationShareIcon = "\u{f045}"
var navigationBackIcon = "\u{f053}"
var starIcon = "\u{f005}"
var blogIcon = "\u{f040}"
var albumIcon = "\u{f03e}"
var classifiedIcon = "\u{f1ea}"
var groupIcon = "\u{f0c0}"
var eventIcon = "\u{f073}"
var videoIcon = "\u{f03d}"
var musicIcon = "\u{f001}"
var moreIcon = "\u{f142}"
var filledCircleIcon = "\u{f111}"
var unfilledCircleIcon = "\u{f1db}"
var cameraIcon = "\u{f030}"
var previewCameraIcon = "\u{f1c8}"
var forwordIcon = "\u{f04e}"
var loadingIcon = "\u{f110}"
var androidShareIcon = "\u{f064}"
var barIcon = "\u{F080}"
var pollIcon = "\u{f080}"
var closedIcon = "\u{f023}"
var checkedIcon = "\u{f00c}"
var nextIcon = "\u{f054}"
var envelopeIcon = "\u{f0e0}"
var spreadTheWordIcon = "\u{f0a1}"
var priceTagIcon = "\u{f0d9}"
var locationIcon = "\u{f041}"
var searchFilterIcon = "\u{f107}"
var statusIcon = "\u{f044}"
var sendReviewIcon = "\u{f1d8}"
var reviewIcon = "\u{f006}"
var listingDefaultIcon = "\u{f03a}"
var wishlistIcon = "\u{f046}"
var pageIcon = "\u{f15c}"
var cakeIcon = "\u{f1fd}"
var onlineIcon = "\u{f007}"
var crossIcon = "\u{f00d}"
var creditCardIcon = "\u{f09d}"
var storeCartIcon = "\u{f07a}"
var myorderIcon = "\u{f187}"
var productIcon =  "\u{f187}"//"\u{f291}"   //"\u{f07a}"
var sortIcon = "\u{f0dc}"
var filterIcon = "\u{f0b0}"
var addToCartIcon = "\u{f217}"
var buyNowIcon = "\u{f0e7}"
var cartIcon = "\u{f07a}"
var taggedIcon = "\u{f02b}"
var sellIcon = "\u{f02c}"
var editSellIcon = "\u{f044}"
var solidCross = "\u{f00d}"
var signOutIcon = "\u{f08b}"
var diaryIcon = "\u{f02d}"
var watchIcon = "\u{f017}"
var favrateIcon = "\u{f08a}"
var playIcon = "\u{f04b}"
var playlistIcon = "\u{f16a}"
var ratingIcon = "\u{f005}"
var channelIcon = "\u{f233}"
var moreShowIcon = "\u{f141}"
var userEditInfo = "\u{f044}"
var userEditPhoto = "\u{f141}"
var friendsIcon = "\u{f007}"
var cancelFriendsIcon = "\u{f235}"
// Feed Menu Icons
var saveFeedIcon = "\u{f0c7}"
var editFeedIcon = "\u{f044}"
var hideIcon = "\u{f00d}"
var reportFeedIcon = "\u{f12a}"
var deleteFeedIcon = "\u{f014}"
var disableCommentIcon = "\u{f0e5}"
var lockFeedIcon = "\u{f023}"
var leftArrow = "\u{f32a}"
var whiteBox = "\u{f0c8}"
var searchIcon = "\u{f002}"
var contactIcon = "\u{f2ba}"
var outgoingIcon = "\u{f0aa}"
var friendIcon = "\u{f2c0}"
var sugetionIcon = "\u{f29a}"

var dollarIcon = "\u{f155}"
var pinicon = "\u{f08d}"
var clockIcon = "\u{f017}"

var gridIcon = "\u{f009}"
var arrowIcon = "\u{f144}"
var tickIcon = "\u{f058}"
var verticalMenu = "\u{f142}"

var friendRequestIcon = "\u{f234}"
var taggingIcon = "\u{f02c}"
var joinGroupEventIcon = "\u{f20e}"
var postedIcon = "\u{f040}"
var messagebda = "\u{f0e0}"
var eyeIcon = "\u{f06e}"
var muteVideoIcon = "\u{f026}"
var unMuteIconIcon = "\u{f028}"
var userJustLogin : Bool = false

let searchTourText = NSLocalizedString("Want to browse anything in particular ? Search from here.", comment: "")
let createTourText = NSLocalizedString("Want to create new content ? Click here.", comment: "")
let cartTourText = NSLocalizedString("Check Cart and Added Products here.", comment: "")
let messageTourText = NSLocalizedString("Create New Message.", comment: "")
let albumTourText = NSLocalizedString("Add new Albums and Photos quickly", comment: "")



//Facebook And GoogleAd variable
var nativeAd1 = FBNativeAd()
//var adLoader1: GADAdLoader!
var isnativeAd1:Bool = true
var fbAdFrame: CGRect = {
    var frame = CGRect.zero
    if(UIDevice.current.userInterfaceIdiom == .pad)
    {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 360)
    }
    else
    {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 360)
    }
    return frame
}()

var ShareOption = [String(format: NSLocalizedString("%@    Share Outside", comment: ""), navigationShareIcon), String(format: NSLocalizedString("%@    Share on %@", comment: ""), shareIcon,app_title),String(format: NSLocalizedString("%@    Copy Link", comment: ""), clipBoardIcon)]
var albumOption = [String(format: NSLocalizedString("Create a New Album", comment: "")), String(format: NSLocalizedString("Upload a new photo", comment: ""))]


//MARK: - Verfiy Url Exists or not to open a new app
func verifyUrl (_ urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = URL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
    }
    return false
}

//MARK: - Custom Toast Message View
func showToast(message : String, controller : UIViewController, onView: Bool = true, time : TimeInterval = 4.0) {
    let toastLabel = TTTAttributedLabel(frame: CGRect(x: controller.view.frame.size.width/2, y: controller.view.frame.size.height - tabBarHeight - 60, width: controller.view.frame.size.width/2, height: 0))
    toastLabel.numberOfLines = 0
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1.0)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = UIFont.systemFont(ofSize: 16)
    toastLabel.text = message
    toastLabel.sizeToFit()
    toastLabel.frame.size.width = toastLabel.frame.size.width + 30
    toastLabel.frame.size.height = toastLabel.frame.size.height + 10
    toastLabel.frame.origin.y = controller.view.frame.size.height - tabBarHeight - (toastLabel.frame.size.height + 10)
    toastLabel.center.x = controller.view.center.x
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = toastLabel.frame.size.height/4
    toastLabel.clipsToBounds  =  true
    if !onView  {
        UIApplication.shared.keyWindow?.addSubview(toastLabel)
    }
    else {
        controller.view.addSubview(toastLabel)
    }
    UIView.animate(withDuration: time, delay: 0.4, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}

// action sheet on ipad
func showIpadActionSheet(sourceView:UIView,popoverController:UIPopoverPresentationController) {
    popoverController.sourceView = sourceView
    popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
    popoverController.permittedArrowDirections = []
    
}

//MARK: - Sort the Array Alphabetically
func sortArrayFunc(inputArray:Array<String>) -> Array<String>{
    let newArray  = inputArray.sorted(by: { (key1, key2) -> Bool in
        (key1 ) < (key2 )
    })
    return newArray
}
//Gernral video view page redirection function
var listingTypeId_global : Int = 0
func IsRedirctToVideoProfile(videoTypeCheck : String,navigationController:UINavigationController, vc: UIViewController)
{
    if videoredirection == false{
        conditionalProfileForm = ""
        videoredirection = true
    }
    
    if conditionalProfileForm == "BrowsePage"
    {
        conditionalProfileForm = ""
        if  videoTypeCheck == "listings" && manage_advvideoshow == false{
            let presentedVC = AdvanceVideoProfileViewController()
            presentedVC.listingTypeId = listingTypeId_global
            presentedVC.videoProfileTypeCheck = "listings"
            presentedVC.videoId = createResponse["video_id"] as! Int
            presentedVC.videoType = createResponse["type"] as? Int
            presentedVC.videoUrl = createResponse["video_url"] as! String
            if sitevideoPluginEnabled_mlt == 1
            {
                presentedVC.listingId = createResponse["parent_id"] as! Int
            }
            else
            {
                presentedVC.listingId = createResponse["listing_id"] as! Int
            }
            let navigationController = UINavigationController(rootViewController: presentedVC)
            vc.present(navigationController, animated:true, completion: nil)
            
        }
        else
        {
            
            let presentedVC = AdvanceVideoProfileViewController()
            if  videoTypeCheck == "AdvEventVideo"{
                presentedVC.videoProfileTypeCheck = "AdvEventProfile"
            }
            else if  videoTypeCheck == "sitegroupvideo"
            {
                if sitevideoPluginEnabled_group == 1
                {
                    presentedVC.group_id = createResponse["parent_id"] as! Int
                }
                else
                {
                    presentedVC.group_id = createResponse["group_id"] as! Int
                }
            }
            else if videoTypeCheck == "Pages"
            {
                if sitevideoPluginEnabled_page == 1
                {
                    presentedVC.page_id = createResponse["parent_id"] as! Int
                }
                else
                {
                    presentedVC.page_id = createResponse["page_id"] as! Int
                }
            }
            else if videoTypeCheck == "stores"
            {
                if sitevideoPluginEnabled_store == 1
                {
                    presentedVC.store_id = createResponse["parent_id"] as! Int
                }
                else
                {
                    presentedVC.store_id = createResponse["store_id"] as! Int
                }
            }
            else
            {
                presentedVC.videoProfileTypeCheck = ""
            }
            presentedVC.videoId = createResponse["video_id"] as! Int
            presentedVC.videoType = createResponse["type"] as? Int
            presentedVC.videoUrl = createResponse["video_url"] as! String
            if  videoTypeCheck == "AdvEventVideo"{
                if sitevideoPluginEnabled_event == 1
                {
                    presentedVC.event_id = createResponse["parent_id"] as! Int
                }
                else
                {
                    presentedVC.event_id = createResponse["event_id"] as! Int
                }
            }
             let navigationController = UINavigationController(rootViewController: presentedVC)
             vc.present(navigationController, animated:true, completion: nil)
            
        }
        
    }
    
}
extension  UILabel{
    func longPressLabel()
    {
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(UILabel.handleLongPressLabel(_:))))
    }
    
    @objc func handleLongPressLabel(_ gestureReconizer: UILongPressGestureRecognizer) {
        if let recognizerView = gestureReconizer.view
        {
            let recognizerSuperView = recognizerView.superview
            let menuController = UIMenuController.shared
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView!)
            menuController.setMenuVisible(true, animated:true)
            recognizerView.becomeFirstResponder()
        }
    }
}

//MARK: - Download Image From Url String
extension UIImageView {
    func downloadedFrom(link:String, contentMode mode: UIView.ContentMode) {
        guard
            let url = URL(string: link)
            else {return}
        contentMode = mode
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        }).resume()
    }
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.height / 2)
        self.layer.masksToBounds = true
    }
}


// Distinguish among iphone model

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0 || ScreenSize.SCREEN_MAX_LENGTH == 896.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

func fontSizeScale() -> CGFloat{
    
    if ((UIDevice.current.modelName) == "iPhone 6" || (UIDevice.current.modelName) == "iPhone 6s" || (UIDevice.current.modelName) == "iPhone 7"){
        return 0.93
    }else if (((UIDevice.current.modelName) == "iPhone 6 Plus") || ((UIDevice.current.modelName) == "iPhone 7 Plus") || ((UIDevice.current.modelName) == "iPhone 6s Plus")) {
        return 1
    }else{
        return 1
    }
}
// Padding in App
//Mark:- iPone X Setup
let iphonXTopsafeArea = getTOPsafeArea()
let iphonXBottomsafeArea = getTOPsafeArea()
func getTOPsafeArea() -> (CGFloat){
    var size:CGFloat = 0.0
        if DeviceType.IS_IPHONE_X
        {
            size = 20.0
        }
        else{
            size = 0.0
        }
    return size
}

//MARK: - To Change the color of Image.
extension UIImage {
    
    var uncompressedPNGData: Data      { return self.pngData()!        }
    var highestQualityJPEGNSData: Data { return self.jpegData(compressionQuality:1.0)!  }
    var highQualityJPEGNSData: Data    { return self.jpegData(compressionQuality:0.75)! }
    var mediumQualityJPEGNSData: Data  { return self.jpegData(compressionQuality:0.50)!  }
    var lowQualityJPEGNSData: Data     { return self.jpegData(compressionQuality:0.25)!}
    var lowestQualityJPEGNSData:Data   { return self.jpegData(compressionQuality:0.0)!  }
    

    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    func resizedTo1KB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.001),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    func compressImage() -> UIImage? {
        // Reducing file size to a 10th
        var actualHeight: CGFloat = self.size.height
        var actualWidth: CGFloat = self.size.width
        let maxHeight: CGFloat = 1136.0
        let maxWidth: CGFloat = 640.0
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        var compressionQuality: CGFloat = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality:compressionQuality) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func fixOrientation(img: UIImage) -> UIImage {        
        if (img.imageOrientation == .up) {
            return img
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }

    
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func maskWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: CGPoint.zero, size: size)
        color.setFill()
        self.draw(in: rect)
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x:posX, y:posY, width:cropWidth, height:cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, true, self.scale)
        cropped.draw(in: CGRect(x:0, y:0, width:to.width, height:to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized!
    }
}

//MARK: - Menu Refresh Timer

var menuRefreshConterLimit : String {

    get {
        var returnValue = UserDefaults.standard.object(forKey: "menuRefreshLimit") as? String
        if returnValue == nil //Check for first run of app
        {
            returnValue = "25" //Default value
            UserDefaults.standard.set(returnValue, forKey: "menuRefreshLimit")
        }
        return returnValue!

    }

    set (newValue) {
        UserDefaults.standard.set(newValue, forKey: "menuRefreshLimit")
        UserDefaults.standard.synchronize()
    }

}

func isIpad() -> Bool {
    if (UIDevice.current.userInterfaceIdiom == .pad){
        return true
    }else{
        return false
    }
}

// Email Validation Check
func checkValidEmail(_ testStr:String) -> Bool {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

//MARK: - Get Length Of String
extension String {
    var length: Int {
        return self.count
    }
    
    func trimString(_ text : String) -> String{
        let trimmedString = text.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        return trimmedString
    }
    
    func encodeURL(_ urlString: String) -> String {

        let str = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            (urlString as CFString),nil,"&=" as CFString?,CFStringBuiltInEncodings.UTF8.rawValue)
        return str! as String

    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false

    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).deletingLastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).deletingPathExtension
        }
    }
    
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathExtension(ext)
    }
    
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch _ as NSError {
            //print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
        
    }
    
    func removeAll(_ characters: [Character]) -> String {
        return String(self.filter({ !characters.contains($0) }))
    }
    
    func removeAll(_ subStrings: [String]) -> String {
        var resultString = self
        _ = subStrings.map { resultString = resultString.replacingOccurrences(of: $0, with: "") }
        
        return resultString
    }
    
    func heightLabel(constraintedWidth width: CGFloat, font: UIFont) -> CGSize {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.size
    }
}

//MARK: - Successful Login Action
func performLoginActionSuccessfully(_ body: NSDictionary) -> Bool {
    feedPostMenu = true
    browseCurrency()
    if body.count > 0{

        
        let request: NSFetchRequest<UserInfo>
        if #available(iOS 10.0, *)
        {
            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>

        }
        else
        {
            request = NSFetchRequest(entityName: "UserInfo")
        }
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0){
            // If exist Token than Update
            for result: AnyObject in results! {
                if let _ = result.value(forKey: "oauth_token") as? String{
                    AppLauch = true
                    setLocation = true
                    let bodyDictionary = body 
                    
                    let token = bodyDictionary["oauth_token"] as! String
                    result.setValue(token, forKey: "oauth_token")
                    oauth_token = token
                    let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                    userDefaults!.set(oauth_token, forKey: "oauth_token")
                    oauth_secret = bodyDictionary["oauth_secret"] as? String
                    result.setValue(oauth_secret , forKey: "oauth_secret")
                    userDefaults!.set(oauth_secret, forKey: "oauth_secret")
                    userDefaults!.synchronize()
                    if let userDetails = bodyDictionary["user"] as? NSDictionary{
                        let displayNameUser = userDetails["displayname"] as! String
                        result.setValue(displayNameUser, forKey: "display_name")
                        displayName = displayNameUser
                        let displayCoverUser = userDetails["image"] as! String
                        result.setValue(displayCoverUser, forKey: "cover_image")
                        coverImage = displayCoverUser
                        let tempUserId = userDetails["user_id"] as! Int
                        result.setValue(tempUserId, forKey: "user_id")
                        currentUserId = tempUserId

                    }
                        
                    
                }
                
            }
            do {
                try context.save()
            } catch _ {
            }
        }
        else
        {
            // Add Token to Database
            let bodyDictionary = body
            if let token = bodyDictionary["oauth_token"] as? String{

                    AppLauch = true
                    setLocation = true
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "UserInfo", into: context) as NSManagedObject
                    newUser.setValue(token , forKey: "oauth_token")
                    let oauth_secret1 = bodyDictionary["oauth_secret"] as? String
                    newUser.setValue(oauth_secret , forKey: "oauth_secret")
                    var displayNameUser = ""
                    var displayCoverUser = ""
                    var useremail = ""
                    if let userDetails = bodyDictionary["user"] as? NSDictionary{
                        
                        //print(userDetails)
                        displayNameUser = userDetails["displayname"] as! String
                        newUser.setValue(displayNameUser, forKey: "display_name")
                        useremail = userDetails["email"] as! String
                        let defaults = UserDefaults.standard
                        defaults.set("\(useremail)", forKey: "userEmail")
                        if let facebookSdk = Bundle.main.infoDictionary?["FacebookAppID"] as? String {
                            if facebookSdk != "" && (logoutUser == true) {
                                 defaults.set("\(facebookSdk)", forKey: "userPassword")
                            }
                        }
                        displayName = displayNameUser
                        displayCoverUser = userDetails["image"] as! String
                        newUser.setValue(displayCoverUser, forKey: "cover_image")
                        coverImage = displayCoverUser
                        
                        let tempUserId = userDetails["user_id"]! as! Int
                        newUser.setValue(tempUserId, forKey: "user_id")
                        currentUserId = tempUserId as Int
                        
                    }
                    do {
                        try context.save()
                    } catch _ {
                    }
                    deleteAAFEntries()
                    oauth_token = token
                    let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                    userDefaults!.set(oauth_token, forKey: "oauth_token")
                    displayName = displayNameUser
                    coverImage = displayCoverUser
                    oauth_secret = oauth_secret1
                    userDefaults!.set(oauth_secret, forKey: "oauth_secret")
                    userDefaults!.synchronize()
                    print(userDefaults as Any)
                    userJustLogin = true
                }
            
        }
        
        if coverImage != nil{
            if URL(string: coverImage as String) != nil{
                let ownerImageUrl = URL(string: coverImage as String)
                let imgView = UIImageView()
                imgView.kf.setImage(with: ownerImageUrl!, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    if let imgT = image
                    {
                        coverPhotoImage = imgT
                    }
                })
            }
        }
        print(body)
//        if let user = body["user"] as? NSDictionary {
//            if let userEmail = user["email"] as? String {
//                let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
//                if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
//                    channelizeClass.performChannelizeLogin(email: userEmail, password: "123456", completion: {(user,errorString) in
//                        if errorString != nil {
//                            print("Failed to login to Channelize")
//                        } else {
//                            print("Login to Channelize Successful")
//                        }
//                    })
//                }
//            }
//        }
        
        
        if let pmAccessToken = body["chAccessTokenv2"] as? String{
            UserDefaults.standard.set(pmAccessToken, forKey: "pmAccessToken")
            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                channelizeClass.updateChannelizeToken(token: pmAccessToken)
                if let userObject = body["user"] as? NSDictionary{
                    if let userId = userObject["user_id"] as? Int{
                        let stringId = String(describing: userId)
                        channelizeClass.getUserObjectWithId(userId: stringId, completion: {(user,error) in
                            if let error = error{
                                print("Fail to get User Object")
                            } else if let user = user{
                                channelizeClass.initializeRealmObjects()
                                channelizeClass.updateUserObject(userObject: user, token: pmAccessToken)
                                channelizeClass.updateFcmToken(token: device_token_id)
                                channelizeClass.updateVoipToken(token: device_voip_token)
                            }

                        })
                    }
                }
            }
        }
        auth_user = false
        logoutUser = false
        refreshMenu = true
        dashboardRefreshInteger = 0
        return true
    } else {
        return false
    }
    
}

func browseCurrency(){
    
    if Reachabable.isConnectedToNetwork() {
        removeAlert()
        
        
        // Send Server Request to Explore Blog Contents with Blog_ID
        post([:], url: "currencies/currency", method: "GET") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                
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
                        
                        if response["defaultCurrencyDetail"] != nil
                        {
                            if let page = response["defaultCurrencyDetail"] as? NSDictionary
                            {
                                
                                currencyDefaultResponse =  page
                                
                                let defaults = UserDefaults.standard
                                let cur = currencyDefaultResponse["code"] as! String
                                if  UserDefaults.standard.object(forKey: "Currency") == nil || UserDefaults.standard.object(forKey: "PriceRate") == nil {
                                    defaults.set(cur, forKey: "Currency")
                                    
                                    defaults.set(Float(truncating: (currencyDefaultResponse["globalRate"] as AnyObject) as! NSNumber), forKey: "PriceRate")
                                }
                                
                                
                            }
                        }
                        if response["response"] != nil
                        {
                            if let page = response["response"] as? NSArray
                            {
                                
                                currencyResponse =  (page as [AnyObject])
                                
                            }
                        }
                        
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

//Redirect to location permission setting
func currentLocation(controller: UIViewController)
{
    let alertController = UIAlertController(title: "Allow Location Permission", message:
        "\nIt is required to display near-by members, places, Events and listings in the app.", preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel,handler: nil))
    alertController.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default,handler: { action in
        locationSetting()
    }))
    controller.present(alertController, animated: true, completion: nil)
}

//Redirect to location permission setting
func gpsLocation(controller: UIViewController)
{
    let alertController = UIAlertController(title: "Enable GPS for this device", message:
        "\nIt is required to display Near-by Members, Places, Events and Listings in the App.\n 1. Go to Settings \n 2. Click on Privacy \n 3. Turn ON Location Services", preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "Got It", style: UIAlertAction.Style.cancel,handler: nil))
    controller.present(alertController, animated: true, completion: nil)
}

func locationSetting()
{
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { _ in })
    } else {
        // Fallback on earlier versions
    }
}

func photoPermissionSetting()
{
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { _ in })
    } else {
        // Fallback on earlier versions
    }
}

func photoPermission(controller: UIViewController)
{
    let alertController = UIAlertController(title: "Allow Photos Permission", message:
        "\nIt is required to choose pictures from the Photo Library to upload them as Profile Picture (during Sign up) and other photos acorss the app.", preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel,handler: nil))
    alertController.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default,handler: { action in
        photoPermissionSetting()
    }))
    controller.present(alertController, animated: true, completion: nil)
}

func deleteAAFEntries() {
    let appDel = UIApplication.shared.delegate as! AppDelegate
    let context = appDel.managedObjectContext!
    let coord = appDel.persistentStoreCoordinator
    
    let fetchRequest: NSFetchRequest<ActivityFeedData>
    
    if #available(iOS 10.0, *){
        fetchRequest = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
    }else{
        fetchRequest = NSFetchRequest(entityName: "ActivityFeedData")
    }
    
    
    if #available(iOS 9.0, *) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try coord!.execute(deleteRequest, with: context)
            feedArray.removeAll()
        } catch _ as NSError {
           // debug print(error)
        }
    } else {
        // Fallback on earlier versions
    }
    
    
}

//MARK: - Custom Square Image Resize

func CustomSquareImage(_ image: UIImage, size: CGSize) -> UIImage {
    return RBResizeImage(RBSquareImage(image), targetSize: size)
}

func RBSquareImage(_ image: UIImage) -> UIImage {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var edge: CGFloat = 0.0
    
    if (originalWidth > originalHeight) {
        // landscape
        edge = originalHeight
        x = (originalWidth - edge) / 2.0
        y = 0.0
        
    } else if (originalHeight > originalWidth) {
        // portrait
        edge = originalWidth
        x = 0.0
        y = (originalHeight - originalWidth) / 2.0
    } else {
        // square
        edge = originalWidth
    }
    
    let cropSquare = CGRect(x: x, y: y, width: edge, height: edge)
    let imageRef = (image.cgImage)?.cropping(to: cropSquare);
    
    return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
}

//MARK: - Resize image proportinally
func imageWithImage(_ sourceImage:UIImage, scaletoWidth: CGFloat) -> UIImage{
    
    let oldWidth = sourceImage.size.width
    let scaleFactor = scaletoWidth/oldWidth
    
    let newHeight = ceil(sourceImage.size.height * scaleFactor)
    let newwidth = ceil(oldWidth * scaleFactor)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newwidth, height: newHeight), false, 0)
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newwidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
    
}
// scale image
func imageWithImage1(_ sourceImage:UIImage, newHeight:CGFloat,newwidth:CGFloat) -> UIImage{
    

    UIGraphicsBeginImageContextWithOptions(CGSize(width: newwidth, height: newHeight), false, 0)
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newwidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
    
}
// Resize imageview
func imagesize(height:CGFloat,width:CGFloat, scaletoWidth: CGFloat) -> CGSize{
    
    let oldWidth = width
    let scaleFactor = scaletoWidth/oldWidth
    let newHeight = ceil(height * scaleFactor)
    let newwidth = ceil(oldWidth * scaleFactor)
    let size = CGSize(width: newwidth, height: newHeight)
    return size
    
}
func cropToBounds(_ image: UIImage, width: Double, height: Double) -> UIImage {
    
    let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
    let contextSize: CGSize = contextImage.size
    
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = 0
        posY = 0
        cgwidth = contextSize.width
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ceil((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    // Create bitmap image from context using the rect
    let imageRef: CGImage = (contextImage.cgImage)!.cropping(to: rect)!
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}
//MARK: - Image Orientation
func fixOrientation(img:UIImage) -> UIImage {
    
    if (img.imageOrientation == UIImage.Orientation.up) {
        return img;
    }
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext();
    return normalizedImage;
    
}


func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func cropToSquare(image originalImage: UIImage) -> UIImage {
    // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
    let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)
    
    // Get the size of the contextImage
    let contextSize: CGSize = contextImage.size
    
    let posX: CGFloat
    let posY: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        width = contextSize.height
        height = contextSize.height
    }
    else
    {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        width = contextSize.width
        height = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = (contextImage.cgImage)!.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    
    return image
}

//MARK: - Convert String into Unicode used as FontAwesome
extension UInt32 {
    init?(hexString: String) {
        let scanner = Scanner(string: hexString)
        var hexInt = UInt32.min
        let success = scanner.scanHexInt32(&hexInt)
        if success {
            self = hexInt
        } else {
            return nil
        }
    }
}

//MARK: - PreLoad Filter Search in whole app

func loadFilter(_ url : String)
{
    
    if Reachabable.isConnectedToNetwork() {
        removeAlert()
        filterSearchFormArray.removeAll(keepingCapacity: false)
        subCategoryDicFilter.removeAllObjects()
        categoryDicFilter.removeAllObjects()
        Form.removeAll(keepingCapacity: false)
        
        var parameters = [String:String]()
        if forumSearchCheck == "ForumSearch"
        {
            parameters = ["forumSearch" : "1"]
        }
        else if listingGlobalTypeId != nil
        {
            parameters = ["listingtype_id" : String(listingGlobalTypeId)]

        }
        
        filterSearchFlag = true
        // Create Server Request for Filter Search Form
        post(parameters, url: "\(url)", method: "GET") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                
                if msg{

                    // On Success Add Values to Form Array
                    filterSearchFormArray.removeAll(keepingCapacity: false)
                    if let form = succeeded["body"] as? NSArray{
                        filterSearchFormArray = form as [AnyObject]
                        filterView = form as [AnyObject]
                        // Crete Filter Search Form
                    }
                    if let dic = succeeded["body"] as? NSDictionary{
                        if let formArray = dic["form"] as? NSArray{
                            Form = formArray as [AnyObject]
                            filterSearchFormArray = formArray as [AnyObject]
                            

                            for key in Form{
                                // Create element Dictionary for every FXForm Element
                                
                                if let dic = (key as? NSDictionary)
                                {
                                    if dic["name"] as? String == "category_id"
                                    {
                                        categoryDicFilter = dic as! NSMutableDictionary
                                    }
                                    if dic["name"] as? String == "category"
                                    {
                                        categoryDicFilter = dic as! NSMutableDictionary
                                    }

                                    
                                    
                                }
                            }
                        }

                        
                        if let formValues = dic["formValues"] as? NSDictionary
                        {
                            formValue = formValues
                        }
                        
                    }
                    

                    if let dic = succeeded["body"] as? NSDictionary
                    {


                        if url == "listings/search-form" ||  url == "sitestore/product/product-search-form"
                        {
                            if let formArray = dic["form"] as? NSArray
                            {
                                    tempFormArray = formArray as [AnyObject]
                                    Form = formArray as [AnyObject]

                            }

                            if let catdic = dic["categoriesForm"] as? NSDictionary
                            {

                                subCategoryDicFilter = catdic as! NSMutableDictionary
                            }
                            
                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic

                            }
                            
                            if let formValues = dic["formValues"] as? NSDictionary
                            {
                                formValue = formValues
                            }
                            

                        }
                        else
                        {
                            if let formArray = dic["form"] as? NSArray
                            {
                                tempFormArray = formArray as [AnyObject]
                                Form = formArray as [AnyObject]
                            }

                            if let catdic = dic["categoriesForm"] as? NSDictionary
                            {
                                subCategoryDicFilter = catdic as! NSMutableDictionary
                            }
                            

                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic
                            }
                            
                            if let formValues = dic["formValues"] as? NSDictionary
                            {
                                tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                formValue = formValues
                            }
                            
                        }
                    }

                }
            })
        }
    }
}

//MARK: - Fade In Fade out Animation For View
extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController?
            }
        }
        return nil
    }
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = 1
    }
    func dropShadowCheckUnCheck() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 4
        // self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        // self.layer.shouldRasterize = true
        // self.layer.rasterizationScale = UIScreen.main.scale
    }
    func dropShadowLight() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        // self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        // self.layer.shouldRasterize = true
        // self.layer.rasterizationScale = UIScreen.main.scale
    }
}

//MARK: - Update User Information in Core Data Table

func updateUserData(){
    
    if Reachabable.isConnectedToNetwork() {
        // Set Parameters & Path for Activity Feed Request
        var parameters = [String:String]()
        parameters = ["userIds": String(currentUserId)]
        // Send Server Request for Activity Feed
        post(parameters, url: "members/index/get-lists", method: "GET") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                // Reset Object after Response from server
                
                // On Success Update Feeds
                if msg{
                    
                    // Check response of Activity Feeds
                    if let response1 = succeeded["body"] as? NSArray{
                        if succeeded["body"] != nil{
                            if let _ = response1[0] as? NSDictionary{
                                
                                let request: NSFetchRequest<UserInfo>
                                
                                if #available(iOS 10.0, *){
                                    request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
                                }else{
                                    request = NSFetchRequest(entityName: "UserInfo")
                                }
                                request.returnsObjectsAsFaults = false
                                let results = try? context.fetch(request)
                                if(results?.count>0){
                                    // If exist Token than Update
                                    for result: AnyObject in results! {
                                        
                                        if let _ = result.value(forKey: "oauth_token") as? String{
                                            
                                            if let userDetails = response1[0] as? NSDictionary{
                                                let displayNameUser = userDetails["displayname"] as! String
                                                result.setValue(displayNameUser, forKey: "display_name")
                                                displayName = displayNameUser
                                                let displayCoverUser = userDetails["image"] as! String
                                                result.setValue(displayCoverUser, forKey: "cover_image")
                                                coverImage = displayCoverUser
                                             
                                                //cover image in dashboard
                                                if let urlCover = userDetails["cover"] as? String, urlCover.length != 0
                                                {
                                                    coverImageBackgorund = urlCover
                                                        let coverImageUrl = NSURL(string: urlCover)
                                                        if coverImageUrl != nil {
                                                            let tempImage = UIImageView()
                                                            
                                                            tempImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                                if let img = image
                                                                {
                                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoverImageUpdated"), object: nil, userInfo: ["imageCover":img])
                                                                }
                                                            })
                                                            
                                                        }
                                                }
                                                else
                                                {
                                                    imageDashboardCover = nil
                                                    coverImageBackgorund = nil
                                                    
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoverImageUpdated"), object: nil, userInfo:nil)
                                                    
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    do {
                                        try context.save()
                                    } catch _ {
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
            })
        }
    }
}

//MARK: - Image Gradients

class ImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor,UIColor.gray.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class ImageViewWithGradientDetailView: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor,UIColor.lightGray.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.3, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class DashboardImageViewWithGradientDetailView: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor,UIColor.lightGray.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.7, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class ContentImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.6,1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class ContentImageViewWithGradientadvanced: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3,1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class categoryImageViewWithGradientadvanced: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0,1.0,1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class LoginPageImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor, UIColor.clear.cgColor,UIColor.black.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.2, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class CenterTextGradient : UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor, UIColor.lightGray.cgColor, UIColor.clear.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.4,1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class LoginImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.black.cgColor, UIColor.clear.cgColor,UIColor.black.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.2, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class ClassifiedCoverImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.black.cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3,0.5, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}
class ProductCoverImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3,0.8, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class CoverImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3,0.7, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}
class LiveImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,UIColor.clear.cgColor]
        
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.2,0.4,0.8, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}
class DiaryImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.0,1.0, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}
class DiaryButtonViewWithGradient: UIButton
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 1)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 0.8)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.0,0.8, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class Content1ImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.7, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class AAFMultipleImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,UIColor.clear.cgColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3, 1.0]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

//MARK: - Date Time Conversion Functions

func formatTimeInSec(_ totalSeconds: Int) -> String {
    let seconds = totalSeconds % 60
    let minutes = (totalSeconds / 60) % 60
    let hours = totalSeconds / 3600
    let strHours = hours > 9 ? String(hours) : "0" + String(hours)
    let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
    let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
    if hours > 0
    {
        return "\(strHours):\(strMinutes):\(strSeconds)"
    }
    else
    {
        return "\(strMinutes):\(strSeconds)"
    }
}

//MARK: - Convert Image From Color

func imagefromColor(_ color:UIColor) -> UIImage{
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
    //UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    let context = UIGraphicsGetCurrentContext();
    context?.setFillColor(color.cgColor);
    context?.fill(rect);
    
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image!;
}

//MARK: - Get Height Of Keyboard in iPhone and iPad

func findKeyBoardHeight() -> (CGFloat){
    var keyBoardHeight:CGFloat = 0.0
    if(UIDevice.current.userInterfaceIdiom == .pad){
        keyBoardHeight = 264.0
    }else{
        keyBoardHeight = 216.0
    }
    return keyBoardHeight
}

//MARK: - Tap Gesture For Side Menu

func tapGestureCreation(_ target: AnyObject )-> UITapGestureRecognizer{
    let recognizer = UITapGestureRecognizer(target: target, action:Selector(("handleTap:")))
    return recognizer
}
//MARK: - Extension on Dictionary for Merge (Key, Values)

extension Dictionary {
    mutating func merge<K, V>(_ dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}


//MARK: - Condition For Autorotate

extension UINavigationController {
    
    open override var shouldAutorotate : Bool {
        
        if visibleViewController is AdvancePhotoViewController || visibleViewController is LoginViewController{
            return false
        }
        return false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if visibleViewController is AdvancePhotoViewController {
            if isPresented {
                return UIInterfaceOrientationMask.allButUpsideDown
            }else{
                return UIInterfaceOrientationMask.portrait
            }
        }
        return UIInterfaceOrientationMask.portrait
    }
}

func findWidthByText(_ text:String)->CGFloat{
    let label = createLabel(CGRect(x: 0, y: 0,width: 500, height: 30), text: text, alignment: .left, textColor: textColorDark)
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.sizeToFit()
    return label.frame.width
}
func findWidthByText2(_ text:String)->CGFloat{
    let label = createLabel(CGRect(x: 0, y: 0,width: 500, height: 30), text: text, alignment: .left, textColor: textColorDark)
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = UIFont(name: fontName, size: FONTSIZESmall)
    label.sizeToFit()
    return label.frame.width
}
func findWidthByTextLive(_ text:String)->CGFloat{
    let label = createLabel(CGRect(x: 0, y: 0,width: 500, height: 30), text: text, alignment: .left, textColor: textColorDark)
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = UIFont(name: fontName, size: 17.0)
    label.sizeToFit()
    return label.frame.width
}
func findWidthByTextFont(_ text:String , _ fontText:String , _ fontSize:CGFloat)->CGFloat{
    let label = createLabel(CGRect(x: 0, y: 0,width: 500, height: 30), text: text, alignment: .left, textColor: textColorDark)
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = UIFont(name: fontText, size: fontSize)
    label.sizeToFit()
    return label.frame.width
}
// Calculate number of Lines
func findHeightByText(_ text:String)->Int{
    let label = createLabel(CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: 500), text: text, alignment: .left, textColor: textColorDark)
    label.font = UIFont(name: fontName, size: 15.0)
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.sizeToFit()
    var lineCount = 0;
    let textSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity));
    let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
    let charSize = lroundf(Float(label.font!.lineHeight));
    lineCount = rHeight/charSize
    return lineCount
}
// Calucate Height from text
func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

// Animation for Side Menu
func openMenuSlideOnView(_ mainView: UIView) {
    // Set Position For Side Menu
    if(openSideMenu)
    {
        mainView.addGestureRecognizer(tapGesture)
    }
    else{
        mainView.removeGestureRecognizer(tapGesture)
    }
}

// Animation for Side Menu
func animateCenterPanelXPosition(targetPosition: CGFloat, mainView:UIView ,completion: ((Bool) -> Void)! = nil) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
        mainView.frame.origin.x = targetPosition
        }, completion: completion)
}

//MARK: - Common Alert For App

// Create Native Alert
func displayAlert(_ title: String, error: String )->(){
    displayAlertWithOtherButton(title, message: error, otherButton: "") { () -> () in
        
    }
}

// Create Native Alert
func displayAlertWithOtherButton(_ title: String, message: String ,otherButton:String , otherButtonAction:@escaping () -> ()){
    alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    if otherButton != "" {
        
        if otherButton.range(of: "Delete") != nil{
            alert.addAction(UIAlertAction(title: otherButton, style: .destructive , handler:{
                (UIAlertAction) -> Void in
                otherButtonAction()
            }))
            
        }else{
            alert.addAction(UIAlertAction(title: otherButton, style: .default, handler:{
                (UIAlertAction) -> Void in
                otherButtonAction()
            }))
        }
        
        
    }
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .default, handler:nil ))
}



//MARK: - Date Difference

// Find Difference in Date from Current Date

func dateDifference(_ orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = TimeZone(identifier: "GMT") // NSTimeZone.systemTimeZone()//NSTimeZone(name: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
    let convertedDate = dateFormatter.date(from: orignalDate)
    let date = Date()
    var timeInterval = convertedDate?.timeIntervalSince(date)
    timeInterval = timeInterval! * -1
    
    // Calculate Time Difference from Current Date Time

    if timeInterval < 1 {
        return NSLocalizedString("Just now", comment: "")
    }
    else if timeInterval < 60
    {
        return NSLocalizedString("a minute ago", comment: "")
    }
    else if (timeInterval < 3600)
    {
        let diff = Int(round(timeInterval! / 60))
        
        if (diff == 1){
            return NSLocalizedString("a minute ago", comment: "")
        }else{
            return String(format: NSLocalizedString("%d minutes ago", comment: ""),diff)
        }
    }
    else if (timeInterval < 86400)
    {
        let diff = Int(round(timeInterval! / 60 / 60))
        
        if (diff == 1){
            return String(format: NSLocalizedString("%d hour ago", comment: ""),diff)
        }else{
            return String(format: NSLocalizedString("%d hours ago", comment: ""),diff)
        }
        
        
    }
    else
    { //if (timeInterval < 2629743) {
        let diff = Int(round(timeInterval! / 60 / 60 / 24))
        if (diff == 1)
        {
            return NSLocalizedString("a day ago", comment: "")
        }
        else if diff>3
        {
            dateFormatter.dateFormat = "MMM dd, YYYY"
            let date = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
            return  dateFormatter.string(from: date)  //[dat stringFromDate:date1];

        }
        else
        {
            return String(format: NSLocalizedString("%d days ago", comment: ""),diff)
        }
        
    }
}

func singlePluralCheck(_ single:String,plural:String,count:Int)->String{
    if count == 1{
        return String(format: "%d\(single)", count)
    }else{
        return String(format: "%d\(plural)", count)
    }
}

func dateDifferenceWithTime(_ orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = TimeZone.current//NSTimeZone(name: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
    
    let convertedDate = dateFormatter.date(from: orignalDate)
    
    let date = Date()
    var timeInterval = convertedDate?.timeIntervalSince(date)
    timeInterval = timeInterval! * -1
    if timeInterval < 1{
        timeInterval = date.timeIntervalSince(convertedDate!)
    }
    dateFormatter.dateFormat = "MMM, dd, HH:mm"
    let date1 = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
    return  dateFormatter.string(from: date1)  //[dat stringFromDate:date1];
}

func dateDifferenceWithEventTime(_ orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = TimeZone.current//NSTimeZone(name: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
    
    let convertedDate = dateFormatter.date(from: orignalDate)
    
    let date = Date()
    var timeInterval = convertedDate?.timeIntervalSince(date)
    timeInterval = timeInterval! * -1
    if timeInterval < 1{
        timeInterval = date.timeIntervalSince(convertedDate!)
    }
    dateFormatter.dateFormat = "MMM, dd, yyyy, HH:mm"
    let date1 = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
    return  dateFormatter.string(from: date1)  //[dat stringFromDate:date1];
}

func dateDifferenceWithEventTimeCalender(_ orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = TimeZone.current//NSTimeZone(name: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d"
    let convertedDate = dateFormatter.date(from: orignalDate)
    dateFormatter.dateFormat = "MMM, dd, yyyy"
    let date1 = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
    return  dateFormatter.string(from: date1)  //[dat stringFromDate:date1];
}

func dateDifferenceWithTimeStyleFull(_ orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = TimeZone(identifier: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
    
    let convertedDate = dateFormatter.date(from: orignalDate)
    let date = Date()
    var timeInterval = convertedDate?.timeIntervalSince(date)
    timeInterval = timeInterval! * -1
    if timeInterval < 1{
        timeInterval = date.timeIntervalSince(convertedDate!)
    }
    dateFormatter.dateFormat = "dd MMM, h:mm a"
    let date1 = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
    return  dateFormatter.string(from: date1)  //[dat stringFromDate:date1];
    
}

func timeFormatted(_ totalSeconds: Int)->String{
    
    let seconds = (totalSeconds % 60) as Int
    let minutes = ((totalSeconds/60) % 60) as Int
    let hours = (totalSeconds / 3600) as Int
    
    var time = ""
    if hours > 0{
        if hours < 10{
            time = "0\(hours):"
        }else{
            time = "\(hours):"
        }
        
        if minutes < 10 {
            time += "0\(minutes):"
        }else{
            time += "\(minutes):"
        }
        
        if seconds < 10 {
            time += "0\(seconds)"
        }else{
            time += "\(seconds)"
        }
    }else{
        if minutes < 10 {
            time += "0\(minutes):"
        }else{
            time += "\(minutes):"
        }
        
        if seconds < 10 {
            time += "0\(seconds)"
        }else{
            time += "\(seconds)"
        }
    }
    
    return time
}

func saveFileInDocumentDirectory(_ images :[AnyObject]) ->([String]){
    var getImagePath = [String]()
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    var i = 0
    for image in images{
        i += 1
        var filename = ""
        if mediaType == "video"
        {
            if let str = (image as? URL)?.lastPathComponent
            {
              filename = "\(str)" // "\((image as! URL).lastPathComponent)"
            }
            else if image is UIImage
            {
                let tempImageString = randomStringWithLength(8)
                filename = "\(tempImageString)\(i).png"
            }
        }
        else
        {
            let tempImageString = randomStringWithLength(8)
            filename = "\(tempImageString)\(i).png"
        }
        let filePathToWrite = "\(paths)/\(filename)"
        //print(filePathToWrite)
        if fileManager.fileExists(atPath: filePathToWrite)
        {
            removeFileFromDocumentDirectoryAtPath(filePathToWrite)
        }
        
        var imageData: Data!
        if mediaType == "video"
        {
            //print("video case")
            if let imageT = image as? URL
            {
                 imageData = try? Data(contentsOf: imageT)
            }
            else if let imageT = image as? UIImage
            {
                 imageData = imageT.wxCompress().jpegData(compressionQuality: 1.0)//imageT.jpegData(compressionQuality:0.7)
            }
           
        }
        else
        {
          //  imageData =  (image as! UIImage).jpegData(compressionQuality:0.7)
          
            imageData = (image as! UIImage).wxCompress().jpegData(compressionQuality: 1.0)
            
           
            
        }
        fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
        getImagePath.append(paths.stringByAppendingPathComponent("\(filename)"))
        
    }
    
    return getImagePath;
}

func saveFileInCacheDirectory(_ images :[String:UIImage]){
    
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory , .userDomainMask, true)[0] as String
    var i = 0
    for (key, value) in images{
        i += 1
        let filename = "\(key)"
        let filePathToWrite = "\(paths)/\(filename)"
        if !(fileManager.fileExists(atPath: filePathToWrite)){
            //let imageData: NSData = UIImagePNGRepresentation(value as UIImage)!
            let imageData: Data = NSData(data: (value as UIImage).jpegData(compressionQuality:0.7) as! Data) as Data
            //print("length1 \(imageData.count)")
            fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
        }else{
            //print("file exist")
        }
    }
}

func getImageFromCache(_ getImagePath:String) -> Data{
    var imageData = Data()
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory , .userDomainMask, true)[0] as String
    let filePath = "\(paths)/\(getImagePath)"
    if (fileManager.fileExists(atPath: filePath))
    {
        //Pick Image and Use accordingly
        let imageis: UIImage = UIImage(contentsOfFile: filePath)!
        imageData = imageis.pngData()!
    }
    else
    {
        //print("FILE NOT AVAILABLE, write new");
        
    }
    return imageData
}



func removeFileFromDocumentDirectoryAtPath(_ getImagePath:String){
    
    let fileManager = FileManager.default
    if (fileManager.fileExists(atPath: getImagePath))
    {
        do {
            try fileManager.removeItem(atPath: getImagePath)
        } catch _ {
        }
    }
    else
    {
        //print("FILE NOT AVAILABLE, write new");
    }
    
}

class Singleton {
    
    private static var __once: () = {

        _ = Singleton()
    }()
    
    var imageCache:NSCache<AnyObject, AnyObject>{
        let cache = NSCache<AnyObject, AnyObject>()

        cache.totalCostLimit = 1024 * 1024 * 10 //10 MB
        return cache
    }
    
    class var sharedInstance: Singleton {
        
        struct Static {
            static var instance: Singleton?
            static var token: Int = 0
        }
        _ = Singleton.__once
        
        return Static.instance!
    }
    
    func cacheImage(_ imageData:Data, key :String){
        imageCache.setObject(imageData as AnyObject, forKey: key as AnyObject)
    }
    
    func getcacheImage(_ key :String)->(Data){
        let imageData = Data()
        if imageCache.object(forKey: key as AnyObject) != nil{
            return imageCache.object(forKey: key as AnyObject) as! Data
        }
        return imageData
    }
    
}

//class Singleton {
//    
//    var imageCache:NSCache{
//        let cache =  NSCache()
//        cache.totalCostLimit = 1024 * 1024 * 10 //10 MB
//        return cache
//    }
//    
//    class var sharedInstance: Singleton {
//        
//        struct Static {
//            static var instance: Singleton?
//            static var token: dispatch_once_t = 0
//        }
//        dispatch_once(&Static.token) {
//            Static.instance = Singleton()
//        }
//        
//        return Static.instance!
//    }
//    
//    func cacheImage(imageData:NSData, key :String){
//        imageCache.setObject(imageData, forKey: key)
//    }
//    
//    func getcacheImage(key :String)->(NSData){
//        let imageData = NSData()
//        if imageCache.objectForKey(key) != nil{
//            return imageCache.objectForKey(key) as! NSData
//        }
//        return imageData
//    }
//    
//}


class WishlistImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 1)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,UIColor.clear.cgColor,UIColor.clear.cgColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor]
        
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.0,0.8, 1.0]
        myGradientLayer.isHidden = true
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

class UIVerticalAlignLabel: UILabel {
    
    enum VerticalAlignment : Int {
        case verticalAlignmentTop = 0
        case verticalAlignmentMiddle = 1
        case verticalAlignmentBottom = 2
    }
    
    var verticalAlignment : VerticalAlignment = .verticalAlignmentTop {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {

        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)
        
        switch(verticalAlignment) {
        case .verticalAlignmentTop:
            return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
        case .verticalAlignmentMiddle:
            return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
        case .verticalAlignmentBottom:
            return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)

        }
    }
    
    override func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}

func setupImageTextInsideButton(_ button: UIButton) {
    let spacing: CGFloat = 6.0
    let imageSize: CGSize = (button.imageView?.frame.size)!
    button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0);
    let labelString = NSString(string: button.titleLabel!.text!)
    let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: button.titleLabel!.font])
    button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width);
}
//MARK: - Table View Cell Animator

class CellAnimator {
    class func animate(_ cell:UITableViewCell) {
        let view = cell.contentView
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(Double.pi)/180.0)
        let offset = CGPoint(x: -20, y: -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity,
                                             rotationRadians, 0.0, 0.0, 1.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0) // 4
        // 5
        view.layer.transform = startTransform
        view.layer.opacity = 0.8
        
        // 6
        UIView.animate(withDuration: 0.4, animations: {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        })
    }
}

func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        completion(data, response, error as NSError?)
        return()
    }.resume()

}

// For fix width and variable height
extension UITextView {
    func sizeFitOnFixWidth(textView:UITextView)-> CGRect {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        return newFrame
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
extension UIButton {
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //UIGraphicsBeginImageContext(rect.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @objc func setBackgroundColor(_ color: UIColor, forUIControlState state: UIControl.State) {
        self.setBackgroundImage(imageWithColor(color), for: state)
    }
    
    func setSelectedButton(){
        self.setTitleColor(buttonColor, for: UIControl.State())
        self.backgroundColor = tableViewBgColor
        for ob in self.subviews{
            if ob.tag == 1001{
                ob.removeFromSuperview()
            }
        }
        
        
        let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 2.0, width: self.frame.size.width , height: 2))
        bottomBorder.backgroundColor = buttonColor
        bottomBorder.tag = 1000
        self.addSubview(bottomBorder)
    }
    
    func setUnSelectedButton(){
        self.setTitleColor(textColorMedium, for: UIControl.State())
        self.backgroundColor = tableViewBgColor
        for ob in self.subviews{
            if ob.tag == 1000{
                ob.removeFromSuperview()
            }
        }
        let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 0.7, width: self.frame.size.width , height: 0.7))
        bottomBorder.tag = 1001
        bottomBorder.backgroundColor = textColorMedium
        self.addSubview(bottomBorder)
    }
}

//Fetch record from core data
func GetallRecord()->NSArray
{
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CartData")
    request.returnsObjectsAsFaults = false
    let results = try? context.fetch(request)
    return results! as NSArray
}


// Convert Dictionry and array into json object
func GetjsonObject(data:AnyObject)->String
{
    do
    {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options:  [])
        let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        var tempDic = [String:AnyObject]()
        tempDic.updateValue(finalString as AnyObject, forKey: "fields")
        let tempfieldsString =  finalString
        _ = "\(tempfieldsString)\(finalString)}" as String
        return tempfieldsString

    }
    catch _ as NSError
    {
        // failure
        //print("Fetch failed: \(error.localizedDescription)")
    }
    return ""
}


//Returns currency symbol of the given currency code
func getCurrencySymbol(_ currencyCode:String)->String{
    let locale = NSLocale(localeIdentifier: currencyCode)
    let symbol = locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currencyCode)
    return symbol!
}

func getCurrencyConvertedPrice(_ fixPrice:Float)->Float{
    return 1.0
}

func gettwoFractionDigits(FractionDigit:String)->String{
        let styler = NumberFormatter()
        styler.minimumFractionDigits = 2
        styler.maximumFractionDigits = 2
        let converter = NumberFormatter()
        converter.decimalSeparator = "."
        if let result = converter.number(from: FractionDigit) {
            var value = styler.string(from: result)!
            if value == ".00"
            {
               value = "0.00"
            }
            return value
        }
    return ""
    
}

// MARK: - TAB BAR METHOD
func getTabController(name : String) -> UIViewController {
    
    switch(name){
        
    case "core_main_blog":
        UserDefaults.standard.set(false, forKey: "showBlogContent")
        return BlogViewController()
    case "core_main_group":
        UserDefaults.standard.set(false, forKey: "showGroupContent")
        return GroupViewController()
    case "core_main_event":
        UserDefaults.standard.set(false, forKey: "showEventContent")
        return EventViewController()
    case "core_main_classified":
        UserDefaults.standard.set(false, forKey: "showClassifiedContent")
        return ClassifiedViewController()
    case "core_main_forum":
        return ForumHomePageController()
    case "core_main_video":
        UserDefaults.standard.set(false, forKey: "showVideoContent")
        return VideoBrowseViewController()
    case "core_main_sitevideo":
        UserDefaults.standard.set(false, forKey: "showAdvVideoContent")
        return AdvanceVideoViewController()
    case "core_main_poll":
        UserDefaults.standard.set(false, forKey: "showPollContent")
        return PollViewController()
    case "core_main_sitepage":
        UserDefaults.standard.set(false, forKey: "showPageContent")
        return PageViewController()
    case "core_main_music":
        UserDefaults.standard.set(false, forKey: "showMusicContent")
        return MusicViewController()
    case "core_main_user":
        UserDefaults.standard.set("members", forKey: "showMemberContent")
        return MemberViewController()
    case "core_main_album":
       UserDefaults.standard.set(false, forKey: "showAlbumContent")
        return AlbumViewController()
    case "core_main_sitegroup":
        UserDefaults.standard.set(false, forKey: "showAdvGroupContent")
        return AdvancedGroupViewController()
    case "core_main_siteevent":
        UserDefaults.standard.set(false, forKey: "showAdvEventContent")
        return AdvancedEventViewController()
    case "core_main_sitestoreproduct_cart":
        if thirdController == name{
            cartIndex = 2
        }
        else if secondController == name {
            cartIndex = 1
        }
        else{
            cartIndex = 3
        }
        return ManageCartViewController()

    case "core_mini_messages":
        
        if thirdController == name{
            messageIndex = 2
        }
        else if secondController == name {
            messageIndex = 1
        }
        else{
            messageIndex = 3
        }
        
        return MessageViewController()
    case "core_mini_friend_request":
        
        UserDefaults.standard.set("friendmembers", forKey: "showFriendContent")
        if thirdController == name{
            friendReqIndex = 2
            
        }
        else if secondController == name {
            friendReqIndex = 1
            
        }
        else{
            friendReqIndex = 3
            
        }
        return FriendRequestViewController()
        
    case "core_mini_notification":
        
        if secondController == name{
            notificationIndex = 1
            
        }
        else if thirdController == name {
            notificationIndex = 2
            
        }
        else{
            notificationIndex = 3
            
        }
        
        
        return NotificationViewController()
        
    case "user_settings":
           return SettingsViewController()
      
    case "contact_us":
           return ContactViewController()
      
    case "user_settings_network":
            return EditProfileViewController()
      
    case "user_settings_password":
            return EditProfilePhotoViewController()
      
    case "terms_of_service":
           return TermsViewController()
     
    case "privacy_policy":
           return PrivacyViewController()
      
    case "core_main_global_search":
            return CoreAdvancedSearchViewController()
    case "spread_the_word":
            
        return SpreadTheWordViewController()
        
    case "core_main_sitestoreproduct_orders":
        return MyStoreViewController()
        
    case "core_main_sitestoreoffer":
        UserDefaults.standard.set(false, forKey: "showOfferContent")
        return CouponsBrowseViewController()
        
    case "core_main_sitestoreproduct":
            UserDefaults.standard.set(false, forKey: "showProductContent")
            return ProductsViewPage()
        case "core_main_sitestore":
            UserDefaults.standard.set(false, forKey: "showStoreContent")
            return StoresBrowseViewController()
        
    case "sitereview_listing":
        
        
        if globalBrowseType > 0{
            let browseType = globalBrowseType
            switch(browseType){
            case 1:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent")
                UserDefaults.standard.set(globalListingName, forKey: "showlistingName")
                UserDefaults.standard.set(globalListingTypeId, forKey: "showlistingId")
                UserDefaults.standard.set(globalViewType, forKey: "showlistingviewType")
                UserDefaults.standard.set(globalBrowseType, forKey: "showlistingBrowseType")
                globalBrowseType = 0
                return MLTBrowseListViewController()
                
            case 2:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent")
                UserDefaults.standard.set(globalListingName, forKey: "showlistingName")
                UserDefaults.standard.set(globalListingTypeId, forKey: "showlistingId")
                UserDefaults.standard.set(globalViewType, forKey: "showlistingviewType")
                UserDefaults.standard.set(globalBrowseType, forKey: "showlistingBrowseType")
                globalBrowseType = 0
                return MLTBrowseGridViewController()
            case 3:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent")
                UserDefaults.standard.set(globalListingName, forKey: "showlistingName")
                UserDefaults.standard.set(globalListingTypeId, forKey: "showlistingId")
                UserDefaults.standard.set(globalViewType, forKey: "showlistingviewType")
                UserDefaults.standard.set(globalBrowseType, forKey: "showlistingBrowseType")
                globalBrowseType = 0
                return MLTBrowseMatrixViewController()
            default:
                print("error")
            }
            
        }
        if globalBrowseType1 > 0{
            let browseType = globalBrowseType1
            switch(browseType){
            case 1:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent1")
                UserDefaults.standard.set(globalListingName1, forKey: "showlistingName1")
                UserDefaults.standard.set(globalListingTypeId1, forKey: "showlistingId1")
                UserDefaults.standard.set(globalViewType1, forKey: "showlistingviewType1")
                UserDefaults.standard.set(globalBrowseType1, forKey: "showlistingBrowseType1")
                globalBrowseType1 = 0
                return MLTBrowseListViewController()
                
            case 2:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent1")
                UserDefaults.standard.set(globalListingName1, forKey: "showlistingName1")
                UserDefaults.standard.set(globalListingTypeId1, forKey: "showlistingId1")
                UserDefaults.standard.set(globalViewType1, forKey: "showlistingviewType1")
                UserDefaults.standard.set(globalBrowseType1, forKey: "showlistingBrowseType1")
                globalBrowseType1 = 0
                return MLTBrowseGridViewController()
            case 3:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent1")
                UserDefaults.standard.set(globalListingName1, forKey: "showlistingName1")
                UserDefaults.standard.set(globalListingTypeId1, forKey: "showlistingId1")
                UserDefaults.standard.set(globalViewType1, forKey: "showlistingviewType1")
                UserDefaults.standard.set(globalBrowseType1, forKey: "showlistingBrowseType1")
                globalBrowseType1 = 0
                return MLTBrowseMatrixViewController()
            default:
                print("error1")
            }
            
        }
        
        if globalBrowseType2 > 0{
            let browseType = globalBrowseType2
            switch(browseType){
            case 1:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent2")
                UserDefaults.standard.set(globalListingName2, forKey: "showlistingName2")
                UserDefaults.standard.set(globalListingTypeId2, forKey: "showlistingId2")
                UserDefaults.standard.set(globalViewType2, forKey: "showlistingviewType2")
                UserDefaults.standard.set(globalBrowseType2, forKey: "showlistingBrowseType2")
                globalBrowseType2 = 0
                return MLTBrowseListViewController()
                
            case 2:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent2")
                UserDefaults.standard.set(globalListingName2, forKey: "showlistingName2")
                UserDefaults.standard.set(globalListingTypeId2, forKey: "showlistingId2")
                UserDefaults.standard.set(globalViewType2, forKey: "showlistingviewType2")
                UserDefaults.standard.set(globalBrowseType2, forKey: "showlistingBrowseType2")
                globalBrowseType2 = 0
                return MLTBrowseGridViewController()
            case 3:
                
                UserDefaults.standard.set(false, forKey: "showMyListingContent2")
                UserDefaults.standard.set(globalListingName2, forKey: "showlistingName2")
                UserDefaults.standard.set(globalListingTypeId2, forKey: "showlistingId2")
                UserDefaults.standard.set(globalViewType2, forKey: "showlistingviewType2")
                UserDefaults.standard.set(globalBrowseType2, forKey: "showlistingBrowseType2")
                globalBrowseType2 = 0
                return MLTBrowseMatrixViewController()
            default:
                
                print("error1")
            }
            
        }
        
    default:
        //print("error no such class")
        return ExternalWebViewController()
        
    }
    
    return AdvanceActivityFeedViewController()
    
}

// MARK: - Create Tabs
 func createTabs() {
    var tabControllers : [UIViewController] = []
    let tabController1 = AdvanceActivityFeedViewController()
    let subController1 = UINavigationController(rootViewController: tabController1)
    subController1.tabBarItem.title = ""
    subController1.tabBarItem.image = UIImage(named: "home")
    tabControllers.append(subController1)
    
    tabControllersecond = QRCode()//getTabController(name: secondController)
    let subController2 = UINavigationController(rootViewController: tabControllersecond)
    if isChannelizeAvailable{
        if secondController == "core_mini_messages"{
            subController2.tabBarItem.image = UIImage(named: "channelize_icon")
        } else{
            subController2.tabBarItem.image = UIImage(named: "secondController")
        }
    }
    else{
        subController2.tabBarItem.image = UIImage(named: "secondController")
    }
    subController2.tabBarItem.badgeValue = nil
    subController2.tabBarItem.title = ""
    tabControllers.append(subController2)
    
    
    tabControllerthird = getTabController(name: thirdController)
    let subController3 = UINavigationController(rootViewController: tabControllerthird )
    if isChannelizeAvailable{
        if thirdController == "core_mini_messages"{
            subController3.tabBarItem.image = UIImage(named: "channelize_icon")
        } else{
            subController3.tabBarItem.image = UIImage(named: "thirdController")
        }
    }
    else{
        subController3.tabBarItem.image = UIImage(named: "thirdController")
    }
    subController3.tabBarItem.badgeValue = nil
    subController3.tabBarItem.title = ""
    tabControllers.append(subController3)
    
    tabControllerfourth = getTabController(name: fourthController)
    let subController4 = UINavigationController(rootViewController: tabControllerfourth)
    
    if isChannelizeAvailable{
        if fourthController == "core_mini_messages"{
            subController4.tabBarItem.image = UIImage(named: "channelize_icon")
        } else{
            subController4.tabBarItem.image = UIImage(named: "fourthController")
        }
    }
    else{
        subController4.tabBarItem.image = UIImage(named: "fourthController")
    }
    subController4.tabBarItem.badgeValue = nil
    subController4.tabBarItem.title = ""
    tabControllers.append(subController4)
    
    let tabController5 = DashboardViewController()
    tabController5.getDynamicDashboard()
    let subController5 = UINavigationController(rootViewController: tabController5)
    subController5.tabBarItem.image = UIImage(named: "toolbar_menu")
    subController5.tabBarItem.title = ""
    tabControllers.append(subController5)
    
    baseController = CustomTabBarController()
    baseController.viewControllers = tabControllers
   
   
    
}
public extension UISearchBar {
    
    public func setTextColor(_ color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
    public func setPlaceholderWithColor(_ placeholderText: String) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.attributedPlaceholder = NSAttributedString(string:"\(placeholderText)",
            attributes:[NSAttributedString.Key.foregroundColor: textColorPrime])
        tf.font = UIFont(name: fontBold, size: FONTSIZENormal )
        if let glassIconView = tf.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            glassIconView.tintColor = textColorPrime
        }
    }
    
    func addSearchBarWithText(_ ob : UIViewController,placeholderText: String) {
        self.barTintColor = UIColor.clear
        self.tintColor = textColorPrime
        self.backgroundColor = navColor
        self.searchBarStyle = UISearchBar.Style.minimal
        self.setPlaceholderWithColor(placeholderText)
        self.becomeFirstResponder()
        self.layer.borderWidth = 0;
        self.layer.shadowOpacity = 0;
//        if #available(iOS 11.0, *) {
//            self.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
//        }
        ob.navigationItem.titleView = self
        self.setTextColor(textColorPrime)
        self.sizeToFit()
    }
    
}
//MARK: Convert HexCodeColor into Color
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
extension TTTAttributedLabel {
    var adjustFontToRealIPhoneSize: Bool {
        set {
            if newValue {
                let currentFont = self.font
                var sizeScale: CGFloat = 1
                let model = UIDevice.current.modelName
                if model == "iPhone 6" {
                    sizeScale = 1.1
                }
                else if model == "iPhone 6 Plus" {
                    sizeScale = 1.5
                }
                
                self.font = currentFont?.withSize((currentFont?.pointSize)! * sizeScale)
            }
        }
        
        get {
            return false
        }
    }
}

extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if self.next != nil {
                return (self.next!).getParentViewController()
            }
            else {return nil}
        }
    }
}

extension MarqueeLabel {
    func setDefault(){
        self.scrollDuration = 5.0
        self.animationCurve = .easeInOut
        self.fadeLength = 5.0
        self.leadingBuffer = 0.0
        self.trailingBuffer = 0.0
        self.textColor = textColorLight
        self.textAlignment = .center
        self.type = .continuous
    }
}


func openCometChat(){
    
    let myString: String = "/api/";
    var myStringArr = baseUrl.components(separatedBy: myString)
    
    var cometchatURL = "\(myStringArr[0])/cometchat/"
    var username: String = ""
    var password: String = ""
    
    let defaults = UserDefaults.standard
    if let userEmail = defaults.string(forKey: "userEmail")
    {
        username = "\(userEmail)"
    }
    
    if let userPassword = defaults.string(forKey: "userPassword")
    {
        password = "\(userPassword)"
    }
    if username != "" && password != "" {
        cometchatURL = "\(cometChatPackageName)://?siteurl=\(cometchatURL.encodeURL(cometchatURL))&username=\(cometchatURL.encodeURL(username))&password=\(cometchatURL.encodeURL(password))"
        if UIApplication.shared.canOpenURL(URL(string: cometchatURL)!) {
            UIApplication.shared.openURL(URL(string: cometchatURL)!)
        }
        else {
            redirectToiTunes(cometChatPackageName)
        }
    }else{
        //print("something not working :(")
    }
}

func redirectToiTunes(_ packageName : String){
    getiTunesObject(cometChatPackageName) { (succeeded, msg) -> () in
        if let results = succeeded["results"] as? NSArray{
            if msg{
                if let result = results[0] as? NSDictionary  {
                    if let trackViewUrl = result["trackViewUrl"] as? String {
                        UIApplication.shared.openURL(URL(string: trackViewUrl)!)
                    }
                }
            }
        }
    }
}

func randomStringWithLength (_ len : Int) -> NSString {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    for _ in 0 ..< len {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    return randomString
}

func getiTunesObject(_ packageName : String, returniTunesObject : (_ succeeded:NSDictionary , _ msg: Bool) -> ()){
    
    var response:Dictionary<String, AnyObject> = [:]
    let urlString = "https://itunes.apple.com/lookup?bundleId=\(packageName)"
    let urlNew:String = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let endpoint = URL(string: urlNew)
    let data = try? Data(contentsOf: endpoint!)
    do {
        let anyObj = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
        if anyObj["resultCount"] as! Int != 0 {
            response = anyObj
            returniTunesObject(response as NSDictionary, true)
        }else{
            returniTunesObject(response as NSDictionary, false)
        }
    } catch {
        returniTunesObject(response as NSDictionary, false)
        //print("json error: \(error)")
    }
    
    
}

class Emoticonizer {
    class func emoticonizeString(_ aString: NSString) -> NSString {
        // You can easily add more emoticons by visiting
        // http://www.unicode.org/reports/tr51/full-emoji-list.html#263a
        
        let mappings = [
            ":P": "\u{1F61C}", // 😄
            ";P": "\u{1F61C}",
            ":p": "\u{1F61C}",
            "=p": "\u{1F61C}",
            ";p": "\u{1F61C}",
            ":D": "\u{1F604}", // 😃
            ":d": "\u{1F604}",
            ":)": "\u{1F60A}", // 😃
            ">.<": "\u{1F606}", // 😆
            ">_<": "\u{1F606}", // 😉
            ";)": "\u{1F609}", // 😋
            "=P": "\u{1F60B}", // 😋
            ":J": "\u{1F609}", // 😏
            ":(": "\u{1F61E}", // 😞
            ">:(": "\u{1F621}", // 😡
            ":@": "\u{1F621}",
            ";@": "\u{1F621}",
            ":'(": "\u{1F622}", // 😢
            ":O": "\u{1F631}", // 😱
            "X(": "\u{1F632}", // 😲
            ";*": "\u{1F618}",
            ":X)": "\u{1F638}",
            "(y)": "\u{1F44D}",
            "<3": "\u{1F494}",
            "</3": "\u{1F494}",
            "B)": "\u{1F60E}",
            "B-)": "\u{1F60E}"
        ]
        
        var text: NSString = aString
        for (search,replace) in mappings{
            if NSNotFound != aString.range(of: search, options: NSString.CompareOptions.caseInsensitive).location {
                text = text.replacingOccurrences(of: search as String, with: replace) as NSString
            }
        }
        
        return text
    }
}
func soundEffect(_ sound : String) {
    if soundEffect == true{
        do {
            if let bundle = Bundle.main.path(forResource: sound, ofType: "wav") {
                let alertSound = URL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        } catch {
            //print(error)

        }
        
    }
    
}


func cartButtonView(functionOf:UIViewController) -> UIButton{
    
    let tempbutton = UIButton(type:UIButton.ButtonType.system) as UIButton
    tempbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    tempbutton.backgroundColor = UIColor.clear
    tempbutton.titleLabel?.font = UIFont(name: "fontAwesome", size: 18.0)
    tempbutton.setTitle("\(storeCartIcon)", for: UIControl.State.normal)
    tempbutton.addTarget(functionOf, action: Selector(("showCart")), for: UIControl.Event.touchUpInside)
    
    //Replace random with count of products in cart
    let countLabel = createLabel(CGRect(x: 15, y: -3, width: 15, height: 15), text: "\(cartCount!)", alignment: .center, textColor: textColorLight)
    countLabel.backgroundColor = UIColor.red
    countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
    countLabel.layer.masksToBounds = true
    countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZESmall)
    tempbutton.addSubview(countLabel)
    if cartCount ==  0{
        countLabel.isHidden = true
    }
    return tempbutton
}

func mergeAddToCart (){
    
    let results = GetallRecord()
    if(results.count>0)
    {
        for result in results{
            let data = (result as AnyObject).value(forKey: "added_products")
            let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            if let dict = output as? NSDictionary {
                valuesOfAddToCart.append(dict)
            }
        }
        
        
    }
    merge()
    
}

func merge()
{
    if Reachabable.isConnectedToNetwork()
    {
        removeAlert()
        var parameters = [String:String]()
        if valuesOfAddToCart.count > 0
        {
            
           parameters["products"] =  GetjsonObject(data: valuesOfAddToCart as AnyObject)
            
        }
        // Send Server Request to Explore classified Contents with classified_ID
        post(parameters, url: "/sitestore/cart/merge/", method: "POST") { (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                if msg
                {
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CartData")
                    request.returnsObjectsAsFaults = false
                    let results = try? context.fetch(request)
                    valuesOfAddToCart.removeAll()
                    if(results?.count>0)
                    {
                        for result in results as! [NSManagedObject]
                        {
                            context.delete(result )
                        }
                        do
                        {
                            try context.save()
                        }
                        catch _ {
                        }
                    }

                }
                else
                {
                    // Handle Server Side Error
                }
            })
        }

    }
    else
    {
        // No Internet Connection Message
        //                        showAlertMessage(view.center , msg: network_status_msg , timer: false)
    }
  
}

class ProductsImageViewWithGradient: UIImageView
{
    let myGradientLayer: CAGradientLayer
    override init(frame: CGRect)
    {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder)
    {
        myGradientLayer = CAGradientLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()
    {
        myGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        myGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        let colors: [CGColor] = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,UIColor.clear.cgColor]
        
        //        let colors: [CGColorRef] = [UIColor.clearColor().CGColor,UIColor.clearColor().CGColor,UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).CGColor]
        myGradientLayer.colors = colors
        myGradientLayer.isOpaque = false
        myGradientLayer.locations = [0.0,0.3]
        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = self.layer.bounds
    }
}

func dateDifferenceWithEndTime(orignalDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
    dateFormatter.timeZone = NSTimeZone.system//NSTimeZone(name: "GMT")
    dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
    
    let convertedDate = dateFormatter.date(from: orignalDate)
    
    if convertedDate != nil{
        let date = NSDate()
        var timeIntervale = convertedDate?.timeIntervalSince(date as Date)
        timeIntervale = timeIntervale! * -1
        if timeIntervale < 1{
            timeIntervale = date.timeIntervalSince(convertedDate!)
        }
        dateFormatter.dateFormat = "MMM, dd, yyyy, HH:mm"
        let date1 = NSDate(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
        return  dateFormatter.string(from: date1 as Date)  //[dat stringFromDate:date1];
    }else{
        return "Never Expires"

    }
    
    
}
func getCartCount()
{
    
    if logoutUser == false{
        post([:], url: "sitestore/cart/cartcount/", method: "GET", postCompleted: { (succeeded, msg) -> () in
            
            
            DispatchQueue.main.async(execute: { () -> Void in
                if msg{
                    if let body = succeeded["body"] as? NSDictionary{
                        if let count = body["count"] as? Int
                        {
                         cartCount = count
                        }
                    }
                }
            })
        })
    }
    else
    {
        let tempAllRecords = GetallRecord()
        var cartcount:Int = 0
        var quantity:Int!
        if tempAllRecords.count>0
        {
            for tempAllRecord in tempAllRecords
            {
                let data = (tempAllRecord as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    if dict.count>0
                    {
                        if let quantityobj = dict["quantity"] as? Int
                        {
                             quantity = quantityobj
                        }
                        else
                        {
                            let quantityobj =  dict["quantity"] as! String
                            quantity = Int(quantityobj)
                        }
                       cartcount += quantity
                    }
                    
                }
                
            }
            
        }
        cartCount = cartcount
    }
}

//Function called on back from other modules to global search
func backToGlobalSearch(_ currentView: UIViewController){
    let navArray = currentView.navigationController?.viewControllers
    for tempViewController in navArray!{
        if tempViewController is FilterSearchViewController{
            conditionalForm = "coreSearch"
            //globCoreSearchType = "0"
            fromGlobSearch = false
            (tempViewController as! FilterSearchViewController).searchUrl = "search"
            _ = currentView.navigationController?.popToViewController(tempViewController, animated: true)

        }
    }
}



//MARK: -  For Removing Marque label from Navigation
func removeMarqueFroMNavigaTion(controller: UIViewController)
{
    if controller.navigationController?.navigationBar.subviews != nil {
        for ob in (controller.navigationController?.navigationBar.subviews)!{
            if ob.tag == 101 {
                ob.removeFromSuperview()
            }

        }
    }
}
//MARK: - SetNavIgationImage
func setNavigationImage(controller: UIViewController)
{
    //controller.navigationController?.setNavigationBarHidden(false, animated:false)
    controller.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
    controller.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
    controller.navigationController?.navigationBar.isTranslucent = true
    controller.navigationController?.navigationBar.tintColor = textColorPrime
    controller.navigationController?.navigationBar.alpha = 1
}

//MARK: - RemoveNavIgationImage
func removeNavigationImage(controller: UIViewController)
{
    controller.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    controller.navigationController?.navigationBar.shadowImage = UIImage()
    controller.navigationController?.navigationBar.isTranslucent = true
    controller.navigationController?.view.backgroundColor = UIColor.clear
    controller.navigationController?.navigationBar.alpha = 1
}

//MARK: - RemoveNavIgation element
func removeNavigationViews(controller: UIViewController)
{
    if (controller.navigationController?.navigationBar.subviews) != nil {
        for view in (controller.navigationController?.navigationBar.subviews)!
        {
            if (view.tag == 400)
            {
                view.removeFromSuperview()
            }
        }
    }
}

//MARK: - getRightEdgeX
//For getting the x coordinate of the right edge of the element
func getRightEdgeX(inputView: UIView) -> CGFloat{
    let x = inputView.frame.origin.x + inputView.bounds.width
    return x
}

//MARK: - getBottomEdgeY
//For getting the y coordinate of the bottom edge of the element
func getBottomEdgeY(inputView: UIView) -> CGFloat{
    let y = inputView.frame.origin.y + inputView.bounds.height
    return y
}

//MARK: - Remove view from Window
func viewRemoveFromWindow() {
    var currentWindow : UIWindow!
    currentWindow = UIApplication.shared.keyWindow
    for ob in currentWindow.subviews{
        if ob.tag == 8{
            ob.removeFromSuperview()
            break
        }
    }
}

@objcMembers class FXFormCustomization : NSObject  {
    //override init(){}
     class func fxfontName() -> String { return fontName }
     class func fxfontSizeNormal() -> CGFloat { return FONTSIZELarge }
     class func fxfontSizeSmall() -> CGFloat { return FONTSIZELarge }
     class func fxColorDark() -> UIColor { return textColorDark }
     class func fxColorLight() -> UIColor { return textColorMedium }
     class func fxMediaType() -> String { return mediaType }
     class func fxHideIndex() -> NSArray { return hideIndexFormArray as NSArray }
    class func fxbuttonColor() -> UIColor { return buttonColor }
    class func fxButtonColorCgcolor() -> CGColor {return buttonColor.cgColor}
}
@objc class Toast : CSToastStyle {
    class func toastiphonXTopsafeArea() -> CGFloat { return iphonXTopsafeArea }
    class func toastiphonXBottomsafeArea() -> CGFloat { return iphonXBottomsafeArea }
}
func getPhoneContact() -> NSMutableDictionary {
    let phoneContacts: NSMutableDictionary = [:]
    if #available(iOS 9.0, *) {
        let contactStore = CNContactStore()
        let keys = [CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                let firstName = contact.givenName
                
                if contact.emailAddresses.count > 0{
                    for emailContact in contact.emailAddresses{
                        if firstName != "" && emailContact.value != ""{
                            phoneContacts.setValue(firstName, forKey: emailContact.value as String)
                        }else if emailContact.value != ""{
                            phoneContacts.setValue(emailContact.value, forKey: emailContact.value as String)
                        }
                    }

              }
                //else if contact.phoneNumbers.count > 0{
//                    for phoneNumber in contact.phoneNumbers{
//                        if firstName != "" && phoneNumber.value.stringValue != ""{
//                            phoneContacts.setValue(firstName, forKey: phoneNumber.value.stringValue)
//                        }
//
//                    }
//                }

                
            }
        }
        catch {
            //print("unable to fetch contacts")
        }
        
        return phoneContacts
        
    } else {
        // Fallback on earlier versions
        return phoneContacts
    }
    
}

//Email verification function
func isValidEmail(testStr:String) -> Bool {
    // //print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

//Sort Reaction Dictionary
func sortedReactionDictionary(dic : NSDictionary) -> NSDictionary{
    var reactionDic = Dictionary<String, AnyObject>()
    var reactionDic1 = Dictionary<String, AnyObject>()
    for (_,v) in dic
    {
        let dic1 = v as! NSDictionary
        if let order = dic1["order"] as? Int{
            reactionDic["\(order)"] = v as AnyObject?
        }
    }
    for key in reactionDic.keys.sorted(by: <) {
        reactionDic1["\(key)"] = reactionDic[key]!
    }
    return reactionDic1 as NSDictionary
    
}

// If String Have Accents Symbols then Convert String into Accents Symbols
func cnvertStringToAccents(stringToConvert:String) -> String {
    var stringAfterConvert:String = stringToConvert
     if let tempStringAfterConvert = stringToConvert.data(using: String.Encoding.utf8),
     let attributedString = try? NSAttributedString(data: tempStringAfterConvert, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
          stringAfterConvert = attributedString.string
        }
       return stringAfterConvert
}

//MARK: func to abbreviate number
func suffixNumber(number:Int) -> String {
    
    var num:Double = Double(number)
    let sign = ((num < 0) ? "-" : "" )
    
    num = fabs(num)
    
    if (num < 1000.0){
        return "\(sign)\(Int(num))"
    }
    
    let exp:Int = Int(log10(num) / 3.0 ) //log10(1000));
    
    let units:[String] = ["K","M","G","T","P","E"]
    
    let roundedNum:Double = round(10 * num / pow(1000.0, Double(exp))) / 10
    
    return "\(sign)\(roundedNum)\(units[exp-1])"
}

// Get Thumbnail from video
func getThumbnailFrom(path: URL) -> UIImage? {
    
    do {
        
        let asset = AVURLAsset(url: path , options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        return thumbnail
        
    } catch _ {
                //print("*** Error generating thumbnail: \(error.localizedDescription)")
        return nil
        
    }
    
}
//Get multivalues for submitting multicheckbox value
func getmultioptionvaluse(options : NSDictionary,formdic : CreateNewForm) -> String
{
    var multivalues = "" as String
    var multikey = String()
    //print(formdic.valuesByKey)
    for (key, value) in options
    {
        let keys =  formdic.valuesByKey["\(value)"] as? Int
        if keys != nil
        {
            if keys != 0
            {
                multikey = "\(key)"
                formdic.valuesByKey.removeObject(forKey: value)
                if multivalues != ""
                {
                    multivalues = "\(multivalues),\(multikey)"
                }
                else
                {
                    multivalues = "\(key)"
                }
                
            }
            else
            {
                formdic.valuesByKey.removeObject(forKey: value)
            }
        }
        
    }
    return multivalues
}

// Search bar class
class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        addSubview(searchBar)
    }
    
    init(_ ob : UIViewController, customSearchBar: UISearchBar, isKeyboardAppear: Bool = true)
    {
        searchBar = customSearchBar
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.barTintColor = UIColor.clear
        searchBar.tintColor = textColorLight
        searchBar.backgroundColor = UIColor.clear
        searchBar.layer.borderWidth = 0;
        searchBar.layer.shadowOpacity = 0;
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = textColorPrime
        if let iconView = textField?.leftView as? UIImageView {
            iconView.tintColor = textColorPrime
        }
        super.init(frame: CGRect.zero)
        addSubview(searchBar)
        self.frame = CGRect(x: 0, y: 0, width: ob.view.frame.width, height: 44)
        if isKeyboardAppear
        {
            searchBar.becomeFirstResponder()
        }
        else
        {
            searchBar.resignFirstResponder()
        }
        ob.navigationItem.titleView = self
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}


//TextView Content Center Class
class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}


extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        
        if from == to { return }
        precondition(indices.contains(from) && indices.contains(to), "Invalid Indexes")
        //if abs(to - from) == 1 { return swapAt(from, to) }
        insert(remove(at: from), at: to)
    }
}
extension UIApplication {
    
    static func topViewController() -> UIViewController? {
        guard var top = shared.keyWindow?.rootViewController else {
            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }

  }
func setDeviceLocation(location : String,latitude:Double,longitude:Double,country:String,state:String,zipcode:String,city:String,countryCode:String)
{
    var parameters = [String:AnyObject]()
    var loc = [String:AnyObject]()
     //{loc={
    loc =  ["country":country,"state":state,"zipcode":zipcode,"city":city,"countryCode":countryCode,"address":location,"formatted_address":location,"location":location,"latitude":latitude,"longitude":longitude] as [String : AnyObject]
    
//}}
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: loc, options:  [])
        let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        parameters["location"] = finalString as AnyObject?
        parameters["resource_type"] = "user" as AnyObject
        parameters["user_id"] = "\(currentUserId)" as AnyObject
    }
    catch _ {
        // failure
        //print("Fetch failed: \(error.localizedDescription)")
    }
    
    if Reachabable.isConnectedToNetwork() {
        activityPostTag(parameters, url: "memberlocation/edit-address", method: "POST") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                if msg{
                    print("true")
                }
                else
                {
                    print("false")
                }
            })
        }
    }
    else
    {
        print(network_status_msg)
    }
}

class ActivityShareItemSources : NSObject,UIActivityItemSource
{
    private var text : String!
    private var image : UIImage!
    private var url : URL!
    
    init(text: String, image: UIImage, url: URL)
    {
        self.text = text
        self.image = image
        self.url = url
    }
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        
        
        let jpgImage = image.jpegData(compressionQuality:0.8)
        return jpgImage!
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any?
    {
        let jpgImage = image.jpegData(compressionQuality:0.8)
        return ["text": text, "image": jpgImage!, "url": url]
        //return ["text": text, "url": url]
    }
}

