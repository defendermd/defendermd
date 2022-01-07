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

import UIKit


let objectType = ["group", "blog", "classified", "event", "user", "music","music_playlist","video", "album", "poll", "core", "activity", "advancedactivity","album_photo","siteevent_event","sitepage_page","sitereview_listing", "sitereview_wishlist","siteevent_review","sitestoreproduct_product","sitestoreproduct_wishlist","sitestore_store","sitestoreproduct_order","sitereview_review","sitestoreproduct_review","sitegroup_group","sitevideo","sitevideo_channel","sitevideo_playlist"]
let apiServerKey = "AIzaSyB7oOFvRUnqAmYj-Pe9B8KUNFZ7ffmIkX4"
let app_title = "SocialEngine"
let Welcome_SlideShow1_title = " SocialEngine "
let Welcome_SlideShow1_description = "Social Media can provide a conversational extension to a B2B company’s nurturing programs. Social Media gives us the opportunity to humanize our communications and make our companies more approachable"
let Welcome_SlideShow2_title = " SocialEngine "
let Welcome_SlideShow2_description = "Social network represents the digital reflection of what humans do: we connect and share"
let Welcome_SlideShow3_title = " SocialEngine "
let Welcome_SlideShow3_description = "Social tools are not just about giving people a voice, but giving them a way to collaborate,contribute and connect."
let slideShowCount = 3


let baseUrl = "https://www.iterra.md/api/rest/"
let oauth_consumer_secret = "0dv24k7hkof1ldddohfy118bvzq4krry"
let oauth_consumer_key = "47irj1am2etxe5oyugmtg9cvnoeupmk4"

var baseServerUrl = ""

let load_slides = ""
let enable_background_service = false
let verySmallFontSize:CGFloat = 12.0
let smallFontSize:CGFloat = 13.0
let normalFontSize:CGFloat = 14.0
let mediumFontSize:CGFloat = 14.0
let largeFontSize:CGFloat = 16.0
let extraLargeFontSize:CGFloat = 18.0
let veryLargeFontSize:CGFloat = 35.0
let isFooterDashboardMenu = 1
let textColorPrime = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
//let buttonColor =  UIColor(red: 41/255 , green: 121/255 , blue: 255/255, alpha: 1.0) // Blue Color
let buttonColor = UIColor(red: 228/255 , green: 0/255 , blue: 70/255, alpha: 1.0) // Pink Color
let cometChatPackageName = "com.secometchat.app"

let secondController = "core_mini_friend_request"
let secondControllerImage = UIImage(named: "secondController")
let secondControllerName = "Requests"

let thirdController = "core_mini_messages"
let thirdControllerImage = UIImage(named: "thirdController")
let thirdControllerName = "Messages"


let fourthController = "core_mini_notification"
let fourthControllerImage = UIImage(named: "fourthController")
let fourthControllerName = "Notifications"

var globalBrowseType = 0
let globalViewType = 0
let globalListingName = ""
let globalListingTypeId = 0

var globalBrowseType1 = 0
let globalViewType1 = 0
let globalListingName1 = ""
let globalListingTypeId1 = 0

var globalBrowseType2 = 0
let globalViewType2 = 0
let globalListingName2 = ""
let globalListingTypeId2 = 0

let url1 = ""
let url3 = ""
let url2 = ""

let isFacebookAd = 1

var placementID = "509261915900016_968597059966497"//"509261915900016_563958577097016"

let fbTestDevice = ["c243091e68f5a2caf91cb3ad3551940cf94b670e" ,"bb10a500739c125613ebb1b0b3065e40a55ba00c",  "2092021bcabc9747084f2479f9c8245a33359a25", "c0233def07a3ce78f798d649e87008a09d119696",  "ad29061bdeb4f94d0f69bd01001e20ba477e3dc6", "c243091e68f5a2caf91cb3ad3551940cf94b670e","c7afda6798581045bfc060c8154dc56a1f63ff8b", "d0ed8117a075ce9b88aea2ae95cd30a52cac0ded"]

let ContentAD = 1
var adUnitID = "ca-app-pub-9077803346330204/5289937176" //ios id ca-app-pub-9077803346330204/5289937176
let kFrequencyAdsInCells_feeds = 5
let kFrequencyAdsInCells_blogs = 5
let kFrequencyAdsInCells_advancedevent = 5
let kFrequencyAdsInCells_event = 5
let kFrequencyAdsInCells_group = 5
let kFrequencyAdsInCells_advgroup = 5
let kFrequencyAdsInCells_music = 5
let kFrequencyAdsInCells_classified = 5
let kFrequencyAdsInCells_poll = 5
let kFrequencyAdsInCells_video = 5
let kFrequencyAdsInCells_album = 5
let kFrequencyAdsInCells_page = 5
let kFrequencyAdsInCells_mltgrid = 5
let kFrequencyAdsInCells_mltmatrix = 5
let kFrequencyAdsInCells_mltlist = 5
let kFrequencyAdsInCells_stores = 5
let kFrequencyAdsInCells_product = 5
let kFrequencyAdsInCells_forum = 5
let kFrequencyAdsInCells_advancedvideo = 5
let kFrequencyAdsInCells_channel = 5
let kFrequencyAdsInCells_playlist = 5


let isSoundEffects = 0
let shareGroupname = "group.com.seao.seiosnativeapp.share"

// 0 for google ads
// 1 for facebook
// 2 for community ads
// 4 for sponsored ads


let adsType_feeds = 1
let adsType_blogs = 1
let adsType_advancedevent = 1
let adsType_event = 1
let adsType_group = 1
let adsType_music = 1
let adsType_classified = 1
let adsType_poll = 1
let adsType_video = 1
let adsType_album = 0
let adsType_page = 2
let adsType_mltgrid = 1
let adsType_mltmatrix = 1
let adsType_mltlist = 2
let adsType_stores = 1
let adsType_product = 1
let adsType_forum = 1
let adsType_advancedvideo = 2
let adsType_channel = 1
let adsType_playlist = 1
let adsType_advGroup = 1

let suggestionSlideshowPosition = 9
let showSuggestions = 1
let suggestionsLimit = 10

let shareAppUrl = "http://mobiledemo.socialengineaddons.com/siteapi/index/app-page"
let isshow_app_name = 0
let splashAnimationTime = 2.0
let showSplashType = 1
let isEnableRate = 1

//Story show
let show_story = 1

//showPIP
let show_PIP = 1

// 0 for gif
// 1 for png
let welcome_image_type = 0

// Intro SlideShow

let slide_title_1 = "Browse & Collaborate"
let slide_subtitle_1 = "Explore content, find friends and stay conected with the happenings around!"

let slide_title_2 = "Connect & Share"
let slide_subtitle_2 = "Join our Group & Events, and Connect with enthusiasts."

let slide_title_3 = "Discover the perfect places to enjoy"
let slide_subtitle_3 = "Browse lists of places and organize the ones you like into wishlists."

let slide_title_4 = "Browse & Collaborate"
let slide_subtitle_4 = "Explore content, find friends and stay conected with the happenings around!"

let slide_title_5 = "Connect & Share"
let slide_subtitle_5 = "Join our Group & Events, and Connect with enthusiasts."

let slide_title_6 = "Discover the perfect places to enjoy"
let slide_subtitle_6 = "Browse lists of places and organize the ones you like into wishlists."

let slide_title_7 = "Browse & Collaborate"
let slide_subtitle_7 = "Explore content, find friends and stay conected with the happenings around!"

let bg_slider_screen1 = UIColor(red: 26/255 , green: 188/255 , blue: 156/255, alpha: 1.0)
let bg_slider_screen2 = UIColor(red: 219/255 , green: 158/255 , blue: 54/255, alpha: 1.0)
let bg_slider_screen3 =  UIColor(red: 148/255 , green: 106/255 , blue: 170/255, alpha: 1.0)
let bg_slider_screen4 = UIColor(red: 26/255 , green: 188/255 , blue: 156/255, alpha: 1.0)
let bg_slider_screen5 = UIColor(red: 219/255 , green: 158/255 , blue: 54/255, alpha: 1.0)
let bg_slider_screen6 =  UIColor(red: 148/255 , green: 106/255 , blue: 170/255, alpha: 1.0)
let bg_slider_screen7 = UIColor(red: 26/255 , green: 188/255 , blue: 156/255, alpha: 1.0)

let slide_text_color_1 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_2 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_3 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_4 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_5 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_6 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let slide_text_color_7 = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)

let isWhiteBackground = 0 // 1 if app theme is white else 0
var totalIntroSlideShowImages = 3
var showAppSlideShow = 0 // For dafult login page without slide show screens
var slideShowButtonColor = UIColor(red: 255/255 , green: 255/255 , blue: 255/255, alpha: 1.0)
let AgoraId = "25d85ed806e6450e99490f887dbf64b1"//"2eae278a63a04da0b1feb1f602fdc1a2"// "afb3123201fc4780bd29609b25fef1bb" // "39d199c2db8841059410ef92731925bb"//

