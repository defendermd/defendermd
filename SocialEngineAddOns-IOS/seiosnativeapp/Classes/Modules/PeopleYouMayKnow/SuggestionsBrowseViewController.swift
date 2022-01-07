//
//  SuggestionsBrowseViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 2/8/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import MessageUI

class SuggestionsBrowseViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMessageComposeViewControllerDelegate {
    
    var mainView: UIView!
    var scrollMenu: UIScrollView!
    var itemView: UIButton!
    var itemName: UILabel!
    var sampleView: UIView!
    var suggestionsTableView: UITableView!
    var searchResultsTableView: UITableView!
    var requestsTableView: UITableView!
    var contactsTableView: UITableView!
    var invitationsTableView: UITableView!
    var friendsTableView: UITableView!
    var outgoingTableView: UITableView!
    var memberSearchBar = UISearchBar()
    var friendsSearchBar = UISearchBar()
    
    var noSuggestionsIcon : UILabel!
    var noSearchResultsIcon : UILabel!
    var noRequestsIcon : UILabel!
    //    var noContactsIcon : UILabel!
    var noContactsIcon : UIImageView!
    var noInvitationSuggestionIcon : UILabel!
    var noFriendsIcon : UILabel!
    var noOutgoingRequestsIcon : UILabel!
    
    var noSuggestionsMessage: UILabel!
    var noSearchResultsMessage: UILabel!
    var noRequestsMessage: UILabel!
    var noContactsMessage: UILabel!
    var noInvitationSuggestionMessage: UILabel!
    var noFriendsMessage: UILabel!
    var noOutgoingRequestsMessage: UILabel!
    
    
    var userSuggestions = [AnyObject]()
    var searchResults = [AnyObject]()
    var friendRequests :[FriendRequestModel] = []
    var contactsList = [AnyObject]()
    var invitationsList: NSMutableDictionary = [:]
    var friendsList = [Any]()
    var requestsSentList = [Any]()
    var responseCache = [String:AnyObject]()
    
    var suggestionsPageNumber: Int = 1
    var searchResultsPageNumber: Int = 1
    var requestsPageNumber: Int = 1
    var contactsPageNumber: Int = 1
    var invitationsPageNumber: Int = 1
    var friendsPageNumber: Int = 1
    var outgoingPageNumber: Int = 1
    
    var suggestionsTotalItems:Int = 0
    var searchResultsTotalItems:Int = 0
    var friendRequestsTotalItems:Int = 0
    var contactsTotalItems:Int = 0
    var invitationsTotalItems:Int = 0
    var friendsTotalItems:Int = 0
    var outgoingTotalItems:Int = 0
    
    var isPageRefresing = false
    var activeTableView: Int!
    var inviteSelectedIndex: Int!
    var refresher:UIRefreshControl! // Refresher for Pull to Refresh
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    var friendRequestAcceptView : FriendConfirmationTip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAfterAlert = true
        
        self.title = NSLocalizedString("Find Friends",  comment: "")
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(SuggestionsBrowseViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        mainView = createView((navigationController?.navigationBar.frame)!, borderColor: UIColor.clear, shadow: false)
        view.addSubview(mainView)
        addScrollMenu()
        
        
        suggestionsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu) - tabBarHeight), style: UITableView.Style.plain)
        suggestionsTableView.tag = 001
        suggestionsTableView.backgroundColor = bgColor
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "suggestionsCell")
        suggestionsTableView.separatorStyle = .none
        view.addSubview(suggestionsTableView)
        
        
        noSuggestionsIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-100,width: 60 , height: 50), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noSuggestionsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noSuggestionsIcon.isHidden = true
        suggestionsTableView.addSubview(noSuggestionsIcon)
        
        noSuggestionsMessage = createLabel(CGRect(x: 0, y: noSuggestionsIcon.bounds.height + noSuggestionsIcon.frame.origin.y + (2 * PADING),width: self.view.bounds.width , height: 30), text: NSLocalizedString("There are no suggestions available.",  comment: "") , alignment: .center, textColor: buttonColor)
        noSuggestionsMessage.numberOfLines = 0
        noSuggestionsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noSuggestionsMessage.backgroundColor = bgColor
        noSuggestionsMessage.tag = 1000
        noSuggestionsMessage.isHidden = true
        suggestionsTableView.addSubview(noSuggestionsMessage)
        
        
        
        searchResultsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu) - tabBarHeight), style: UITableView.Style.plain)
        searchResultsTableView.tag = 002
        searchResultsTableView.backgroundColor = bgColor
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.isHidden = true
        searchResultsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "searchResultCell")
        searchResultsTableView.separatorStyle = .none
        view.addSubview(searchResultsTableView)
        
        noSearchResultsIcon = createLabel(CGRect(x: self.searchResultsTableView.bounds.width/2 - 30, y: self.searchResultsTableView.bounds.height/2-100, width: 60, height: 50), text: NSLocalizedString("\(onlineIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noSearchResultsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noSearchResultsIcon.isHidden = true
        searchResultsTableView.addSubview(noSearchResultsIcon)
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        noSearchResultsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noSearchResultsIcon) + (2 * PADING), width: self.searchResultsTableView.bounds.width , height: 30), text: NSLocalizedString("No member to display.",  comment: "") , alignment: .center, textColor: buttonColor)
        noSearchResultsMessage.numberOfLines = 0
        noSearchResultsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noSearchResultsMessage.backgroundColor = bgColor
        noSearchResultsMessage.tag = 1000
        noSearchResultsMessage.isHidden = true
        searchResultsTableView.addSubview(noSearchResultsMessage)
        
        
        
        requestsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu)), style: UITableView.Style.plain)
        requestsTableView.tag = 003
        requestsTableView.backgroundColor = bgColor
        requestsTableView.delegate = self
        requestsTableView.dataSource = self
        requestsTableView.isHidden = true
        requestsTableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "requestsCell")
        requestsTableView.separatorStyle = .none
        view.addSubview(requestsTableView)
        
        noRequestsIcon = createLabel(CGRect(x: self.requestsTableView.bounds.width/2 - 30,y: self.requestsTableView.bounds.height/2-100,width: 60 , height: 50), text: NSLocalizedString("\(unfriendIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noRequestsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noRequestsIcon.isHidden = true
        requestsTableView.addSubview(noRequestsIcon)
        
        noRequestsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noRequestsIcon) + (2 * PADING),width: self.requestsTableView.bounds.width , height: 30), text: NSLocalizedString("No friend request pending",  comment: "") , alignment: .center, textColor: buttonColor)
        noRequestsMessage.numberOfLines = 0
        noRequestsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noRequestsMessage.backgroundColor = bgColor
        noRequestsMessage.tag = 1000
        noRequestsMessage.isHidden = true
        requestsTableView.addSubview(noRequestsMessage)
        
        
        
        contactsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu)), style: UITableView.Style.plain)
        contactsTableView.tag = 004
        contactsTableView.backgroundColor = bgColor
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        contactsTableView.isHidden = true
        contactsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "contactsCell")
        contactsTableView.separatorStyle = .none
        view.addSubview(contactsTableView)
        
        noContactsIcon = createImageView(CGRect(x: self.contactsTableView.bounds.width/2 - 30, y: self.contactsTableView.bounds.height/2-100, width: 50, height: 60), border: false)
        noContactsIcon.image = UIImage(named: "noContactsIcon.png")
        noContactsIcon.isHidden = true
        contactsTableView.addSubview(noContactsIcon)
        
        noContactsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noContactsIcon) + (2 * PADING),width: self.contactsTableView.bounds.width, height: 30), text: NSLocalizedString("No Contacts to display",  comment: "") , alignment: .center, textColor: buttonColor)
        noContactsMessage.numberOfLines = 0
        noContactsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noContactsMessage.backgroundColor = bgColor
        noContactsMessage.tag = 1000
        noContactsMessage.isHidden = true
        contactsTableView.addSubview(noContactsMessage)
        
        invitationsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu)), style: UITableView.Style.plain)
        invitationsTableView.tag = 005
        invitationsTableView.backgroundColor = bgColor
        invitationsTableView.delegate = self
        invitationsTableView.dataSource = self
        invitationsTableView.isHidden = true
        invitationsTableView.register(InviteMemberTableViewCell.self, forCellReuseIdentifier: "inviteCell")
        invitationsTableView.separatorStyle = .none
        view.addSubview(invitationsTableView)
        
        noInvitationSuggestionIcon = createLabel(CGRect(x: self.invitationsTableView.bounds.width/2 - 30,y: self.invitationsTableView.bounds.height/2-100,width: 50 , height: 50), text: NSLocalizedString("\(onlineIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noInvitationSuggestionIcon.font = UIFont(name: "FontAwesome", size: 50)
        noInvitationSuggestionIcon.isHidden = true
        invitationsTableView.addSubview(noInvitationSuggestionIcon)
        
        noInvitationSuggestionMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noInvitationSuggestionIcon) + (2 * PADING),width: self.invitationsTableView.bounds.width , height: 30), text: NSLocalizedString("No contacts to invite",  comment: "") , alignment: .center, textColor: buttonColor)
        noInvitationSuggestionMessage.numberOfLines = 0
        noInvitationSuggestionMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noInvitationSuggestionMessage.backgroundColor = bgColor
        noInvitationSuggestionMessage.tag = 1000
        noInvitationSuggestionMessage.isHidden = true
        invitationsTableView.addSubview(noInvitationSuggestionMessage)
        
        friendsTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu)), style: UITableView.Style.plain)
        friendsTableView.tag = 006
        friendsTableView.backgroundColor = bgColor
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.isHidden = true
        friendsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "friendCell")
        friendsTableView.separatorStyle = .none
        view.addSubview(friendsTableView)
        
        noFriendsIcon = createLabel(CGRect(x: self.friendsTableView.bounds.width/2 - 30,y: self.friendsTableView.bounds.height/2-100,width: 60 , height: 50), text: NSLocalizedString("\(onlineIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noFriendsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noFriendsIcon.isHidden = true
        friendsTableView.addSubview(noFriendsIcon)
        
        noFriendsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noFriendsIcon) + (2 * PADING),width: self.friendsTableView.bounds.width , height: 30), text: NSLocalizedString("No member to display",  comment: "") , alignment: .center, textColor: buttonColor)
        noFriendsMessage.numberOfLines = 0
        noFriendsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noFriendsMessage.backgroundColor = bgColor
        noFriendsMessage.tag = 1000
        noFriendsMessage.isHidden = true
        friendsTableView.addSubview(noFriendsMessage)
        
        outgoingTableView = UITableView(frame: CGRect(x: 0.0, y: getBottomEdgeY(inputView: scrollMenu), width: view.frame.size.width, height: view.frame.size.height - getBottomEdgeY(inputView: scrollMenu)), style: UITableView.Style.plain)
        outgoingTableView.tag = 007
        outgoingTableView.backgroundColor = bgColor
        outgoingTableView.delegate = self
        outgoingTableView.dataSource = self
        outgoingTableView.isHidden = true
        outgoingTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "sentRequestCell")
        outgoingTableView.separatorStyle = .none
        view.addSubview(outgoingTableView)
        
        noOutgoingRequestsIcon = createLabel(CGRect(x: self.outgoingTableView.bounds.width/2 - 30, y: self.outgoingTableView.bounds.height/2-100, width: 70, height: 70), text: NSLocalizedString("\(onlineIcon)",  comment: "") , alignment: .center, textColor: buttonColor)
        noOutgoingRequestsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noOutgoingRequestsIcon.isHidden = true
        outgoingTableView.addSubview(noOutgoingRequestsIcon)
        noOutgoingRequestsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noOutgoingRequestsIcon) + (2 * PADING),width: self.outgoingTableView.bounds.width , height: 30), text: NSLocalizedString("No pending outgoing requests",  comment: "") , alignment: .center, textColor: buttonColor)
        noOutgoingRequestsMessage.numberOfLines = 0
        noOutgoingRequestsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noOutgoingRequestsMessage.backgroundColor = bgColor
        noOutgoingRequestsMessage.tag = 1000
        noOutgoingRequestsMessage.isHidden = true
        outgoingTableView.addSubview(noOutgoingRequestsMessage)
        
        
        
        if activeTableView == 5{
            activeTableView = 6
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = false
            outgoingTableView.isHidden = true
            memberSearchBar.resignFirstResponder()
            if logoutUser == false
            {
                getFriends()
            }
            else
            {
                showToast(message:"You must login to see Friends", controller: self)
            }
        }
        else{
            activeTableView = 1
            if logoutUser == false {
                if enabledModules.contains("suggestion") {
                    getSuggestions()
                }
                else {
                    showToast(message:"Please enable suggestion plugin to see Suggestions", controller: self)
                }
                
            }
            else{
                showToast(message:"You must login to see Suggestions", controller: self)
            }
        }
        
    }
    @objc func cancel(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let view = friendRequestAcceptView {
            view.removeFromSuperview()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            searchResultsTableView.frame.size.height = view.frame.size.height - getBottomEdgeY(inputView: scrollMenu) - keyboardHeight
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addScrollMenu(){
        scrollMenu = UIScrollView(frame: CGRect(x: 0.0, y: TOPPADING, width: self.view.frame.size.width, height: 70))
        scrollMenu.delegate = self
        let menuArray = [String(format:NSLocalizedString("\n%@\n\nSuggestions\n",  comment: ""),sugetionIcon), String(format:NSLocalizedString("\n%@\n\nSearch\n",  comment: ""),searchIcon), String(format:NSLocalizedString("\n%@\n\nRequests\n",  comment: ""),friendReuestIcon), String(format:NSLocalizedString("\n%@\n\nContacts\n",  comment: ""),contactIcon),
                         String(format:NSLocalizedString("\n%@\n\nFriends\n",  comment: ""),friendIcon),
                         String(format:NSLocalizedString("\n%@\n\nInvite\n",  comment: ""),inviteIcon),
                         String(format:NSLocalizedString("\n%@\n\nOutgoing\n",  comment: ""),outgoingIcon)]
        var i = 0
        var tableTag = 0
        for menu in menuArray{
            itemView = createButton(CGRect(x: (i * (83 + 2)) + 4, y: 0, width: 83, height: 70), title: "\(menu)", border: false, bgColor: true, textColor: textColorDark)
            if (activeTableView == 5 && tableTag == 4) || activeTableView == 1 && tableTag == 0{
                itemView.setTitleColor(navColor, for: UIControl.State.normal)
            }
            itemView.tag = 101 + tableTag
            itemView.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
            itemView.titleLabel?.textAlignment = .center
            itemView.addTarget(self, action: #selector(SuggestionsBrowseViewController.switchTableView(_:)), for: UIControl.Event.touchUpInside)
            itemView.backgroundColor = UIColor.white
            itemView.layer.borderColor = textColorMedium.cgColor
            itemView.titleLabel?.lineBreakMode = .byWordWrapping
            if #available(iOS 9.0, *) {
                scrollMenu.addSubview(itemView)
                i+=1
            }else{
                if menu != "Contacts" && menu != "Invite"{
                    scrollMenu.addSubview(itemView)
                    i+=1
                }
            }
            tableTag+=1
        }
        scrollMenu.contentSize = CGSize(width: (i * (83 + 2)) + 4, height: 70)
        if (activeTableView == 5){
            scrollMenu.contentOffset.x = scrollMenu.contentSize.width - scrollMenu.bounds.size.width
        }
        scrollMenu.backgroundColor = UIColor.clear
        scrollMenu.showsHorizontalScrollIndicator = false
        view.addSubview(scrollMenu)
    }
    
    @objc func switchTableView(_ sender: UIButton){
        
        let selectedTag = sender.tag-101
        
        for ob in scrollMenu.subviews{
            if ob.tag == sender.tag && ob is UIButton {
                let button = ob as! UIButton
                if button.isHighlighted{
                    button.setTitleColor(navColor, for: UIControl.State.normal)
                }
            }else if ob is UIButton{
                let button = ob as! UIButton
                button.setTitleColor(textColorDark, for: UIControl.State.normal)
            }
        }
        
        switch selectedTag {
        case 0:
            activeTableView = 1
            suggestionsTableView.isHidden = false
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = true
            if logoutUser == false {
                if enabledModules.contains("suggestion")
                {
                    getSuggestions()
                }
                else
                {
                    showToast(message:"Please enable suggestion plugin to see Suggestions", controller: self)
                }
                
            }
            else{
                showToast(message:"You must login to see Suggestions", controller: self)
            }
            memberSearchBar.resignFirstResponder()
        case 1:
            activeTableView = 2
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = false
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = true
            getSearchResults()
            memberSearchBar.becomeFirstResponder()
        case 2:
            activeTableView = 3
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = false
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = true
            if logoutUser == false {
                getFriendRequests()
            }
            else{
                showToast(message:"You must login to see Requests", controller: self)
            }
            memberSearchBar.resignFirstResponder()
        case 3:
            activeTableView = 4
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = false
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = true
            memberSearchBar.resignFirstResponder()
            getContacts()
        case 4:
            activeTableView = 6
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = false
            outgoingTableView.isHidden = true
            if logoutUser == false {
                if self.friendsList.count == 0
                {
                    getFriends()
                }
            }
            else{
                showToast(message:"You must login to see Friends", controller: self)
            }
            memberSearchBar.resignFirstResponder()
        case 5:
            activeTableView = 5
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = false
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = true
            getInvitationResults()
            
        case 6:
            activeTableView = 7
            suggestionsTableView.isHidden = true
            searchResultsTableView.isHidden = true
            requestsTableView.isHidden = true
            contactsTableView.isHidden = true
            invitationsTableView.isHidden = true
            friendsTableView.isHidden = true
            outgoingTableView.isHidden = false
            getOutgoingRequests()
            memberSearchBar.resignFirstResponder()
        default:
            activeTableView = 1
            memberSearchBar.resignFirstResponder()
            break
            //do nothing
        }
    }
    
    // MARK: Scroll View Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentTableView: UITableView
        switch scrollView.tag {
        case 1:
            contentTableView = suggestionsTableView
            
            // Check for Page Number for suggestions
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*suggestionsPageNumber < suggestionsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        suggestionsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0 {
                            getSuggestions()
                        }
                    }
                }
            }
        case 2:
            contentTableView = searchResultsTableView
            
            // Check for Page Number for search results
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*searchResultsPageNumber < searchResultsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        searchResultsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getSearchResults()
                        }
                    }
                }
            }
        case 3:
            contentTableView = requestsTableView
            
            // Check for Page Number for friend requests
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*requestsPageNumber < friendRequestsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        requestsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getFriendRequests()
                        }
                    }
                }
            }
        case 4:
            contentTableView = contactsTableView
            
            // Check for Page Number for contacts
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*requestsPageNumber < contactsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        contactsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getContacts()
                        }
                    }
                }
            }
        case 5:
            contentTableView = invitationsTableView
            
            // Check for Page Number for invitations
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*invitationsPageNumber < invitationsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        invitationsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getInvitationResults()
                        }
                    }
                }
            }
        case 6:
            contentTableView = friendsTableView
            
            // Check for Page Number for friends
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*friendsPageNumber < friendsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        friendsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getFriends()
                        }
                    }
                }
            }
        case 7:
            contentTableView = outgoingTableView
            // Check for Page Number for sent requests
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*outgoingPageNumber < outgoingTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        outgoingPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            getOutgoingRequests()
                        }
                    }
                }
            }
        case 8:
            contentTableView = suggestionsTableView
            
            // Check for Page Number for suggestions
            if contentTableView.contentOffset.y >= contentTableView.contentSize.height - contentTableView.bounds.size.height{
                if (!isPageRefresing  && limit*suggestionsPageNumber < suggestionsTotalItems){
                    if Reachabable.isConnectedToNetwork() {
                        suggestionsPageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0 {
                            getSuggestions()
                        }
                    }
                }
            }
        default:
            break
        }
        
    }
    
    //MARK: Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchResultsPageNumber = 1
        searchDic["search"] = searchBar.text
        filterSearchString = searchBar.text!
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        getSearchResults()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    //MARK: Table View Delegates
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 001 || tableView.tag == 003{
            return 90
        }
        if tableView.tag == 002{
            return 90
        }
        
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch tableView.tag {
        case 001:
            return ButtonHeight
        case 002:
            return ButtonHeight
        case 003:
            return ButtonHeight
        case 004:
            return ButtonHeight
        case 005:
            return 5.0
        case 006:
            return 5.0
        case 007:
            return ButtonHeight
        default:
            return ButtonHeight
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        
        switch tableView.tag {
        case 001:
            title = NSLocalizedString("PEOPLE YOU MAY KNOW",  comment: "")
        case 002:
            
            memberSearchBar.searchBarStyle = .prominent
            memberSearchBar.placeholder = NSLocalizedString("Name or email..",  comment: "")
            memberSearchBar.setTextColor(textColorDark)
            memberSearchBar.tintColor = textColorDark
            memberSearchBar.sizeToFit()
            memberSearchBar.delegate = self
            return memberSearchBar
            
        case 003:
            title = NSLocalizedString("FRIEND REQUESTS",  comment: "")
        case 004:
            title = NSLocalizedString("CONTACTS",  comment: "")
        case 007:
            title = NSLocalizedString("OUTGOING FRIEND REQUESTS",  comment: "")
        default:
            title = ""
        }
        
        let headerview = createView(CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: ButtonHeight), borderColor: borderColorMedium, shadow: false)
        let sectionHeaderLabel = createLabel(CGRect(x: 10, y: 0.0, width: tableView.frame.size.width-20, height: ButtonHeight), text: title, alignment: NSTextAlignment.left, textColor: textColorMedium)
        sectionHeaderLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        sectionHeaderLabel.backgroundColor = tableViewBgColor
        headerview.backgroundColor = tableViewBgColor
        headerview.addSubview(sectionHeaderLabel)
        
        if title == ""
        {
            return UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        return headerview
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView.tag {
        case 001:
            return self.userSuggestions.count
        case 002:
            return self.searchResults.count
        case 003:
            return self.friendRequests.count
        case 004:
            return self.contactsList.count
        case 005:
            return self.invitationsList.count
        case 006:
            return self.friendsList.count
        case 007:
            return self.requestsSentList.count
        default:
            return self.userSuggestions.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.tag {
        case 001:
            //MARK: Suggestion Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionsCell", for: indexPath) as! FriendRequestTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let memberInfo = self.userSuggestions[indexPath.row] as! [String: AnyObject]
            
            // Set Name People who Likes Content
            cell.title.text = memberInfo["displayname"] as! String?
            cell.title.font = UIFont(name: fontBold, size: FONTSIZENormal)
            cell.title.numberOfLines = 1
            
            // Set Owner Image
            if let photoId = memberInfo["photo_id"] as? Int{
                
                if photoId != 0{
                    let url1 = NSURL(string: memberInfo["image"] as! NSString as String)
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url1! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                else{
                    cell.imgUser.image = nil
                    cell.imgUser.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.imgUser.bounds.width)
                    
                }
            }
            
            cell.acceptButton.setTitle(NSLocalizedString("Add Friend",  comment: ""), for: UIControl.State.normal)
            if memberInfo["friendship_type"] != nil && memberInfo["friendship_type"] as! String == "cancel_request"{
                cell.acceptButton.setTitle(NSLocalizedString("Undo",  comment: ""), for: UIControl.State.normal)
            }
            cell.acceptButton.tag =  120 + (indexPath as NSIndexPath).row
            cell.acceptButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
            
            cell.rejectButton.setTitle(NSLocalizedString("Remove",  comment: ""), for: UIControl.State.normal)
            cell.rejectButton.tag = 130 + (indexPath as NSIndexPath).row
            cell.rejectButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.removeSuggestionFromList(_:)), for: .touchUpInside)
            return cell
        case 002:
            // MARK: Search Results Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.labMessage.isHidden = true
            
            let memberInfo = self.searchResults[indexPath.row] as! NSDictionary
            
            var heightForFields: CGFloat = 15.0
            
            cell.imgUser.frame = CGRect(x: 5, y: 15, width: 60, height: 60)
            
            cell.memberOnlineLabel.isHidden = false
            cell.memberAge.isHidden = false
            cell.memberLocation.isHidden = false
            cell.memberMutualFriends.isHidden = false
            
            
            cell.memberOnlineLabel.frame = CGRect(x: cell.imgUser.bounds.width - 15, y: cell.imgUser.bounds.height - 15, width: 10, height: 10)
            cell.memberOnlineLabel.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
            cell.memberOnlineLabel.text = "\(onlineIcon)"
            
            if memberInfo["memberStatus"] as? Int != nil{
                if memberInfo["memberStatus"] as! Int == 1{
                    cell.memberOnlineLabel.textColor = UIColor.init(red: 101/255, green: 204/255, blue: 0, alpha: 1)
                    cell.memberOnlineLabel.layer.shadowColor = shadowColor.cgColor
                }else{
                    cell.memberOnlineLabel.textColor = UIColor.gray
                }
            }
            
            cell.memberOnlineLabel.sizeToFit()
            if memberInfo["memberStatus"] == nil || memberInfo["memberStatus"] as! Int == 0{
                cell.memberOnlineLabel.isHidden = true
            }
            
            
            //Creating an array of profile fields
            var profileFieldsDictionary = Dictionary<String, String>()
            
            if memberInfo["age"] != nil && memberInfo["age"] as! Int  > 0{
                profileFieldsDictionary["age"] = "\(memberInfo["age"]!)"
            }
            
            if memberInfo["location"] != nil && memberInfo["location"] as! String != ""{
                profileFieldsDictionary["location"] = memberInfo["location"] as? String
            }
            
            if memberInfo["mutualFriendCount"] != nil && memberInfo["mutualFriendCount"] as! Int > 0{
                profileFieldsDictionary["mutualFriends"] = String(describing: memberInfo["mutualFriendCount"])
            }
            
            // Set Name People who Likes Content
            
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 15,width: (UIScreen.main.bounds.width - 75) , height: 30)
            
            if profileFieldsDictionary.count == 0{
                cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 7 + cell.imgUser.bounds.height/2,width: (UIScreen.main.bounds.width - 75) , height: 30)
                cell.memberAge.isHidden = true
                cell.memberLocation.isHidden = true
                cell.memberMutualFriends.isHidden = true
            }
            
            
            cell.labTitle.text = memberInfo["displayname"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.numberOfLines = 1
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.sizeToFit()
            cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - 75)
            
            heightForFields = 20 + cell.labTitle.bounds.height
            
            //For showing 1st profile field if exists
            if profileFieldsDictionary.count > 0{
                
                cell.memberAge.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 125), height: 20)
                cell.memberAge.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberAge.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "age") != nil{
                    if memberInfo["age"] as! Int != 1{
                        cell.memberAge.text = "\(cakeIcon) " + String(describing: memberInfo["age"]!) + " years old"
                    }else{
                        cell.memberAge.text = "\(cakeIcon) " + String(describing: memberInfo["age"]!) + " year old"
                    }
                    profileFieldsDictionary.removeValue(forKey: "age")
                }else if profileFieldsDictionary.index(forKey: "location") != nil{
                    
                    cell.memberAge.text = "\(locationIcon) \(String(describing: memberInfo["location"]!))"
                    profileFieldsDictionary.removeValue(forKey: "location")
                    
                }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberAge.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberAge.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberAge.numberOfLines = 1
                cell.memberAge.lineBreakMode = .byTruncatingTail
                cell.memberAge.sizeToFit()
                cell.memberAge.frame.size.width = (UIScreen.main.bounds.width - 125)
                heightForFields = heightForFields + cell.memberAge.bounds.height + 2
                
                
            }else{
                if cell.memberAge.text == ""{
                    cell.memberAge.isHidden = true
                }
            }
            
            //For showing 2nd profile field if exists
            if profileFieldsDictionary.count > 0{
                
                cell.memberLocation.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 115), height: 20)
                cell.memberLocation.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberLocation.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "location") != nil{
                    cell.memberLocation.text = "\(locationIcon) \(String(describing: memberInfo["location"]!))"
                    profileFieldsDictionary.removeValue(forKey: "location")
                }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberLocation.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberLocation.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberLocation.numberOfLines = 1
                cell.memberLocation.lineBreakMode = .byTruncatingTail
                cell.memberLocation.sizeToFit()
                cell.memberLocation.frame.size.width = (UIScreen.main.bounds.width - 115)
                heightForFields = heightForFields + cell.memberLocation.bounds.height + 2
            }else{
                if cell.memberLocation.text == ""{
                    cell.memberLocation.isHidden = true
                }
                
            }
            
            //For showing 3rd profile field if exists
            if profileFieldsDictionary.count > 0{
                cell.imgUser.frame.origin.y = 20
                cell.memberMutualFriends.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 75), height: 20)
                cell.memberMutualFriends.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberMutualFriends.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberMutualFriends.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberMutualFriends.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberMutualFriends.numberOfLines = 1
                cell.memberMutualFriends.sizeToFit()
                cell.memberMutualFriends.frame.size.width = (UIScreen.main.bounds.width - 75)
                heightForFields = heightForFields + cell.memberMutualFriends.bounds.height + 2
            }else{
                if cell.memberMutualFriends.text == ""{
                    cell.memberMutualFriends.isHidden = true
                }
                
            }
            
            if let url = URL(string: memberInfo["image_profile"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
            }
            
            if let menu = memberInfo["friendship_type"] as? String {
                
                let nameString = menu
                if (nameString == "remove_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.removeFriend(_:)), for: .touchUpInside)
                    optionMenu.tag = 130 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "cancel_request"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "add_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }
            }
            
            return cell
            
        case 003:
            
            //MARK: Requests Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestsCell", for: indexPath) as! FriendRequestTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let memberInfo = self.friendRequests[indexPath.row]
            
            // Set Name People who Likes Content
            cell.title.text = memberInfo.displayname
            cell.title.font = UIFont(name: fontBold, size: FONTSIZENormal)
            cell.title.numberOfLines = 1
            
            // Set Owner Image
            cell.acceptButton.image = UIImage(named: "user_image.png")
            if memberInfo.profileImage != ""{
                let url1 = NSURL(string: memberInfo.profileImage!)
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.acceptButton.image = image
                })
            }
            else{
                cell.imgUser.image = nil
                cell.imgUser.image = imageWithImage( UIImage(named: "user_image.png")!, scaletoWidth: cell.imgUser.bounds.width)
                
            }
            
            cell.acceptButton.tag = 120 + (indexPath as NSIndexPath).row
            cell.acceptButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptFriendRequest(_:)), for: .touchUpInside)
            
            cell.rejectButton.tag = 130 + (indexPath as NSIndexPath).row
            cell.rejectButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.rejectFriendRequest(_:)), for: .touchUpInside)
            return cell
            
        case 004:
            
            // MARK: Contacts Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.labMessage.isHidden = true
            
            let memberInfo = self.contactsList[indexPath.row] as! NSDictionary
            
            var heightForFields: CGFloat = 15.0
            
            cell.imgUser.frame = CGRect(x: 5, y: 5, width: 60, height: 60)
            
            cell.memberOnlineLabel.isHidden = false
            cell.memberAge.isHidden = false
            cell.memberLocation.isHidden = false
            cell.memberMutualFriends.isHidden = false
            
            
            cell.memberOnlineLabel.frame = CGRect(x: cell.imgUser.bounds.width - 15, y: cell.imgUser.bounds.height - 15, width: 10, height: 10)
            cell.memberOnlineLabel.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
            cell.memberOnlineLabel.text = "\(onlineIcon)"
            
            if memberInfo["memberStatus"] as? Int != nil{
                if memberInfo["memberStatus"] as! Int == 1{
                    cell.memberOnlineLabel.textColor = UIColor.init(red: 101/255, green: 204/255, blue: 0, alpha: 1)
                    cell.memberOnlineLabel.layer.shadowColor = shadowColor.cgColor
                }else{
                    cell.memberOnlineLabel.textColor = UIColor.gray
                }
            }
            
            cell.memberOnlineLabel.sizeToFit()
            if memberInfo["memberStatus"] == nil || memberInfo["memberStatus"] as! Int == 0{
                cell.memberOnlineLabel.isHidden = true
            }
            
            
            //Creating an array of profile fields
            var profileFieldsDictionary = Dictionary<String, String>()
            
            if memberInfo["age"] != nil && memberInfo["age"] as! Int  > 0{
                profileFieldsDictionary["age"] = "\(String(describing: memberInfo["age"]))"
            }
            
            if memberInfo["location"] != nil && memberInfo["location"] as! String != ""{
                profileFieldsDictionary["location"] = memberInfo["location"] as? String
            }
            
            if memberInfo["mutualFriendCount"] != nil && memberInfo["mutualFriendCount"] as! Int > 0{
                profileFieldsDictionary["mutualFriends"] = String(describing: memberInfo["mutualFriendCount"])
            }
            
            // Set Name People who Likes Content
            
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 15,width: (UIScreen.main.bounds.width - 75) , height: 30)
            
            if profileFieldsDictionary.count == 0{
                cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 7 + cell.imgUser.bounds.height/2,width: (UIScreen.main.bounds.width - 75) , height: 30)
                cell.memberAge.isHidden = true
                cell.memberLocation.isHidden = true
                cell.memberMutualFriends.isHidden = true
            }
            
            
            cell.labTitle.text = memberInfo["displayname"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.sizeToFit()
            
            heightForFields = 20 + cell.labTitle.bounds.height
            
            //For showing 1st profile field if exists
            if profileFieldsDictionary.count > 0{
                
                cell.memberAge.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 75), height: 20)
                cell.memberAge.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberAge.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "age") != nil{
                    if memberInfo["age"] as! Int != 1{
                        cell.memberAge.text = "\(cakeIcon) " + String(describing: memberInfo["age"]) + " years old"
                    }else{
                        cell.memberAge.text = "\(cakeIcon) " + String(describing: memberInfo["age"]) + " year old"
                    }
                    profileFieldsDictionary.removeValue(forKey: "age")
                }else if profileFieldsDictionary.index(forKey: "location") != nil{
                    
                    cell.memberAge.text = "\(locationIcon) \(String(describing: memberInfo["location"]!))"
                    profileFieldsDictionary.removeValue(forKey: "location")
                    
                }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberAge.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberAge.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberAge.sizeToFit()
                heightForFields = heightForFields + cell.memberAge.bounds.height + 2
                
                
            }else{
                if cell.memberAge.text == ""{
                    cell.memberAge.isHidden = true
                }
            }
            
            //For showing 2nd profile field if exists
            if profileFieldsDictionary.count > 0{
                
                cell.memberLocation.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 75), height: 20)
                cell.memberLocation.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberLocation.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "location") != nil{
                    cell.memberLocation.text = "\(locationIcon) \(String(describing: memberInfo["location"]!))"
                    profileFieldsDictionary.removeValue(forKey: "location")
                }else if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberLocation.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberLocation.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberLocation.sizeToFit()
                heightForFields = heightForFields + cell.memberLocation.bounds.height + 2
            }else{
                if cell.memberLocation.text == ""{
                    cell.memberLocation.isHidden = true
                }
                
            }
            
            //For showing 3rd profile field if exists
            if profileFieldsDictionary.count > 0{
                
                cell.memberMutualFriends.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: heightForFields, width: (UIScreen.main.bounds.width - 75), height: 20)
                cell.memberMutualFriends.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.memberMutualFriends.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                
                if profileFieldsDictionary.index(forKey: "mutualFriends") != nil{
                    if memberInfo["mutualFriendCount"] as! Int != 1{
                        cell.memberMutualFriends.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friends"
                    }else{
                        cell.memberMutualFriends.text = "\(groupIcon) " + String(describing: memberInfo["mutualFriendCount"]!) + " mutual friend"
                    }
                    profileFieldsDictionary.removeValue(forKey: "mutualFriends")
                }
                cell.memberMutualFriends.sizeToFit()
                heightForFields = heightForFields + cell.memberLocation.bounds.height + 10
            }else{
                if cell.memberMutualFriends.text == ""{
                    cell.memberMutualFriends.isHidden = true
                }
                
            }
            
            
            // Set Owner Image
            if let url = URL(string: memberInfo["image_profile"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
            }
            
            if let menu = memberInfo["menus"] as? NSDictionary {
                
                let nameString = menu["name"] as! String
                if (nameString == "remove_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.removeFriend(_:)), for: .touchUpInside)
                    optionMenu.tag = 130 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "cancel_request"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "add_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorMedium)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:16)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }
            }
            
            return cell
        case 005:
            
            //MARK: Invite Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! InviteMemberTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = aafBgColor
            cell.mainView.frame.size.height = cell.frame.size.height-5
            var i = 0
            
            for (key, value) in self.invitationsList {
                if i == (indexPath.row) {
                    
                    var contactName = key as! String
                    if contactName.contains("mobile_"){
                        let stringArray = contactName.components(separatedBy: "_")
                        contactName = stringArray[1]
                    }
                    cell.memberName.text = contactName
                    cell.memberName.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    cell.memberName.numberOfLines = 1
                    cell.memberName.sizeToFit()
                    cell.memberName.frame.size.width = UIScreen.main.bounds.width - (UIScreen.main.bounds.width*0.25 + 15)
                    var contactDetail: String = ""
                    
                    
                    if value as? String == "Invitation sent."{
                        contactDetail = "Invitation sent."
                        cell.inviteButton.isHidden = true
                    }else{
                        cell.inviteButton.isHidden = false
                        if value is String{
                            contactDetail = value as! String
                            cell.inviteButton.tag = 510 + indexPath.row
                            cell.inviteButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.sendInviteMail(_:)), for: UIControl.Event.touchUpInside)
                            
                            
                        }else if value is NSNumber{
                            contactDetail = String(describing: value)
                            cell.inviteButton.tag = 610 + indexPath.row
                            cell.inviteButton.addTarget(self, action: #selector(SuggestionsBrowseViewController.sendInviteMobile(_:)), for: UIControl.Event.touchUpInside)
                        }
                    }
                    
                    
                    cell.memberContact.text = contactDetail
                    
                    break
                }
                i+=1
            }
            
            return cell
        case 006:
            
            //MARK: Friends Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            var memberInfo:NSDictionary
            memberInfo = self.friendsList[indexPath.row] as! NSDictionary
            
            cell.imgUser.frame = CGRect(x: 5, y: 5, width: 60, height: 60)
            
            // Set Name People who Likes Content
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 25,width: (UIScreen.main.bounds.width - 75) , height: 100)
            
            cell.labTitle.text = memberInfo["displayname"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            
            // Set Owner Image
            if let url = URL(string: memberInfo["image_profile"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            
            if let menu = memberInfo["friendship_type"] as? String{
                
                let nameString = menu
                
                if (nameString == "remove_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorDark)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.removeFriend(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = 130 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "cancel_request"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorDark)
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                }else if (nameString == "add_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorDark)
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }
            }
            
            return cell
            
            
        case 007:
            
            //MARK: Sent Friend Request Cell
            self.noOutgoingRequestsIcon.isHidden = true
            self.noOutgoingRequestsMessage.isHidden = true
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentRequestCell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            var memberInfo:NSDictionary
            memberInfo = self.requestsSentList[indexPath.row] as! NSDictionary
            
            cell.imgUser.frame = CGRect(x: 5, y: 5, width: 60, height: 60)
            
            // Set Name People who Likes Content
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 25,width: (UIScreen.main.bounds.width - 75) , height: 100)
            
            cell.labTitle.text = memberInfo["displayname"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            
            // Set Owner Image
            if let url = URL(string: memberInfo["image_profile"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                
            }
            
            if let menu = memberInfo["friendship_type"] as? String{
                
                let nameString = menu
                
                if (nameString == "remove_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorDark)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.removeFriend(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = 130 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "cancel_request"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorDark)
                    
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }else if (nameString == "add_friend"){
                    
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorDark)
                    //  optionMenu.setBackgroundImage(UIImage(named: "icon-option.png"), forState: .normal)
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                    
                    optionMenu.addTarget(self, action: #selector(SuggestionsBrowseViewController.acceptSuggestion(_:)), for: .touchUpInside)
                    
                    optionMenu.tag = 120 + (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                    
                    
                }
            }
            
            return cell
            
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = "cell1" + String(indexPath.row)
            cell.textLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            return cell
        }
        
    }
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let suggestionIndex = indexPath.row
        var memberInfo: AnyObject
        switch activeTableView {
        case 001:
            memberInfo = self.userSuggestions[suggestionIndex]
        case 002:
            memberInfo = self.searchResults[suggestionIndex]
        case 003:
            memberInfo = self.friendRequests[suggestionIndex]
        case 004:
            memberInfo = self.contactsList[suggestionIndex]
        case 005:
            memberInfo = self.invitationsList[suggestionIndex] as AnyObject
        case 006:
            memberInfo = self.friendsList[suggestionIndex] as AnyObject
        case 007:
            memberInfo = self.requestsSentList[suggestionIndex] as AnyObject
        default:
            memberInfo = self.userSuggestions[suggestionIndex]
        }
        
        // if activeTableView != 006
        //   {
        var subjectId: Int = 0
        if activeTableView == 3{
            subjectId = self.friendRequests[suggestionIndex].subject_id
        }else{
            if let userId = memberInfo["user_id"] as? Int {
                subjectId = userId
            }
        }
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(subjectId)"
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        //  }
    }
    
    
    //MARK: Message delegates
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        switch result {
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .sent:
            let indexPath = IndexPath(row: inviteSelectedIndex, section: 0)
            var i = 0
            for (key, _) in self.invitationsList {
                if i == (inviteSelectedIndex) {
                    self.invitationsList.setValue("Invitation sent.", forKey: key as! String)
                    break
                }
                i+=1
            }
            self.invitationsTableView.beginUpdates()
            self.invitationsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            self.invitationsTableView.endUpdates()
            
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: Functions to get content for all tables
    
    func getSuggestions()
    {
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"20", "restapilocation": "", "page": String(suggestionsPageNumber)]
            
            let url = "suggestions/suggestion-listing"
            
            if (suggestionsPageNumber == 1){
                if updateAfterAlert == true{
                    self.userSuggestions.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(url)"]{
                        self.userSuggestions = responseCacheArray as! [AnyObject]
                    }
                    self.suggestionsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            post(parameters, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["users"] != nil {
                                if let suggestion = response["users"] as? NSArray {
                                    self.userSuggestions = self.userSuggestions + (suggestion as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.suggestionsTotalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        self.isPageRefresing = false
                        
                        if self.userSuggestions.count == 0
                        {
                            self.noSuggestionsIcon.isHidden = false
                            self.noSuggestionsMessage.isHidden = false
                            
                        }
                        else
                        {
                            self.noSuggestionsIcon.isHidden = true
                            self.noSuggestionsMessage.isHidden = true
                            
                        }
                        
                        self.suggestionsTableView.reloadData()
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
                
                
            })
        }
    }
    
    func getSearchResults()
    {
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"20", "restapilocation": "", "search": memberSearchBar.text, "page":String(searchResultsPageNumber)]
            
            let url = "members"
            
            if (searchResultsPageNumber == 1){
                if updateAfterAlert == true{
                    self.searchResults.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.searchResultsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            post(parameters as! Dictionary<String, String>, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        self.searchResultsTableView.isHidden = false
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if let members = body["response"] as? NSArray{
                                    self.searchResults = self.searchResults + (members as [AnyObject])
                                }
                                
                                if body["totalItemCount"] != nil{
                                    self.searchResultsTotalItems = body["totalItemCount"] as! Int
                                }
                                
                            }
                            self.isPageRefresing = false
                            
                            if self.searchResults.count == 0
                            {
                                self.noSearchResultsIcon.isHidden = false
                                self.noSearchResultsMessage.isHidden = false
                                
                            }
                            else
                            {
                                self.noSearchResultsIcon.isHidden = true
                                self.noSearchResultsMessage.isHidden = true
                                
                            }
                            
                            self.searchResultsTableView.reloadData()
                            
                        }
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
                
            })
        }
    }
    
    func getFriendRequests()
    {
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"20", "restapilocation": "", "page":String(requestsPageNumber)]
            
            let url = "notifications/friend-request"
            
            if (requestsPageNumber == 1){
                if updateAfterAlert == true{
                    self.friendRequests.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.requestsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            post(parameters, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let membersArray = body["response"] as? NSArray{
                                    self.friendRequests += FriendRequestModel.loadFriendRequests(membersArray)
                                }
                                
                                if body["totalItemCount"] != nil{
                                    self.friendRequestsTotalItems = body["totalItemCount"] as! Int
                                }
                            }
                            
                            if self.friendRequests.count == 0
                            {
                                self.noRequestsIcon.isHidden = false
                                self.noRequestsMessage.isHidden = false
                                
                            }
                            else
                            {
                                self.noRequestsIcon.isHidden = true
                                self.noRequestsMessage.isHidden = true
                                
                            }
                            self.requestsTableView.reloadData()
                            
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            })
        }
    }
    
    func getContacts()
    {
        let phoneContactsList = getPhoneContact()
        for (key,value) in phoneContactsList
        {
            if value as! String == "Identified As Spam"
            {
                phoneContactsList.removeObject(forKey : key)
            }
        }
        if phoneContactsList.count > 0{
            if Reachabable.isConnectedToNetwork(){
                
                var finalString = ""
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: phoneContactsList, options:  [])
                    finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                } catch _ as NSError {
                    // failure
                    //print("Fetch failed: \(error.localizedDescription)")
                }
                
                
                //                let parameters = ["limit":"20", "restapilocation": "", "membershipType": "add_friend", "emails": finalString, "page":String(contactsPageNumber)]
                
                let parameters = ["limit":"20", "restapilocation": "", "membershipType": "add_friend", "page":String(contactsPageNumber)]
                
                
                let url = "members/get-contact-list-members"
                
                if (contactsPageNumber == 1){
                    if updateAfterAlert == true{
                        self.contactsList.removeAll(keepingCapacity: false)
                        removeAlert()
                        self.suggestionsTableView.reloadData()
                    }else{
                        updateAfterAlert = true
                    }
                }
                
                //                spinner.center = view.center
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                postGetContactList(parameters as Dictionary<String, String>, paramUrl:finalString, url: url, method: "POST", postCompleted: { (succeeded, msg) in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary{
                                
                                if response["users"] != nil {
                                    if let suggestion = response["users"] as? NSArray {
                                        self.contactsList = self.contactsList + (suggestion as [AnyObject])
                                    }
                                    
                                    if response["totalItemCount"] != nil{
                                        self.contactsTotalItems = response["totalItemCount"] as! Int
                                    }
                                    
                                    if self.contactsList.count == 0
                                    {
                                        self.noContactsIcon.isHidden = false
                                        self.noContactsMessage.isHidden = false
                                        
                                    }
                                    else
                                    {
                                        self.noContactsIcon.isHidden = true
                                        self.noContactsMessage.isHidden = true
                                        
                                    }
                                    
                                    self.contactsTableView.reloadData()
                                }
                                
                            }
                            
                        }else{
                            // Handle Server Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                    })
                    
                })
                
            }
            
        }
    }
    
    func getInvitationResults()
    {
        
        let phoneContactsList = getPhoneContact()
        for (key,value) in phoneContactsList
        {
            if value as! String == "Identified As Spam"
            {
                phoneContactsList.removeObject(forKey : key)
            }
        }
        if phoneContactsList.count > 0{
            if Reachabable.isConnectedToNetwork(){
                
                var finalString = ""
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: phoneContactsList, options:  [])
                    finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                } catch _ as NSError {
                    // failure
                    //print("Fetch failed: \(error.localizedDescription)")
                }
                
                var parameters = ["limit":"20", "restapilocation": "", "page":String(invitationsPageNumber)]
                let url = "members/get-contact-list-members"
                
                if (invitationsPageNumber == 1){
                    if updateAfterAlert == true{
                        self.invitationsList = [:]
                        removeAlert()
                        self.invitationsTableView.reloadData()
                    }else{
                        updateAfterAlert = true
                    }
                }
                
                //                spinner.center = view.center
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                postGetContactList(parameters, paramUrl:finalString, url: url, method: "POST", postCompleted: { (succeeded, msg) in
                    
                    DispatchQueue.main.async(execute: {
                        
                        activityIndicatorView.stopAnimating()
                        
                        self.isPageRefresing = false
                        
                        if msg{
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary{
                                if response["users"] != nil {
                                    if let list = response["users"] as? NSMutableDictionary {
                                        for (k,v) in list {
                                            self.invitationsList.setValue(v, forKey: "\(k)")
                                        }
                                    }
                                    
                                }
                                if response["totalItemCount"] != nil{
                                    self.invitationsTotalItems = response["totalItemCount"] as! Int
                                }
                                if self.invitationsList.count == 0
                                {
                                    self.noInvitationSuggestionIcon.isHidden = false
                                    self.noInvitationSuggestionMessage.isHidden = false
                                    
                                }
                                else
                                {
                                    self.noInvitationSuggestionIcon.isHidden = true
                                    self.noInvitationSuggestionMessage.isHidden = true
                                    
                                }
                                
                                self.invitationsTableView.reloadData()
                            }
                            
                        }else{
                            // Handle Server Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                    })
                    
                    
                })
            }
            
        }
        
        
    }
    
    func getFriends()
    {
        
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"20", "restapilocation": "", "user_id": String(currentUserId), "page":String(friendsPageNumber)]
            
            let url = "user/get-friend-list"
            
            if (friendsPageNumber == 1){
                if updateAfterAlert == true{
                    self.friendsList.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(url)"]{
                        self.friendsList = responseCacheArray as! [AnyObject]
                    }
                    self.friendsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            post(parameters, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        self.isPageRefresing = false
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["friends"] != nil {
                                if let suggestion = response["friends"] as? NSArray {
                                    self.friendsList = self.friendsList + (suggestion as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.friendsTotalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.friendsList.count == 0
                            {
                                self.noFriendsIcon.isHidden = false
                                self.noFriendsMessage.isHidden = false
                                
                            }
                            else
                            {
                                self.noFriendsIcon.isHidden = true
                                self.noFriendsMessage.isHidden = true
                                
                            }
                            
                            self.friendsTableView.reloadData()
                        }
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
                
            })
        }
    }
    
    func getOutgoingRequests()
    {
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit":"20", "restapilocation": "", "membershipType":"cancel_request", "page":String(outgoingPageNumber)]
            
            let url = "members/get-contact-list-members"
            
            if (outgoingPageNumber == 1){
                if updateAfterAlert == true{
                    self.requestsSentList.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(url)"]{
                        self.requestsSentList = responseCacheArray as! [AnyObject]
                    }
                    self.outgoingTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            //
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            post(parameters, url: url, method: "POST", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["users"] != nil {
                                if let suggestion = response["users"] as? NSArray {
                                    self.requestsSentList = self.requestsSentList + (suggestion as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.outgoingTotalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.requestsSentList.count == 0
                            {
                                self.noOutgoingRequestsIcon.isHidden = false
                                self.noOutgoingRequestsMessage.isHidden = false
                                
                            }
                            else
                            {
                                self.noOutgoingRequestsIcon.isHidden = true
                                self.noOutgoingRequestsMessage.isHidden = true
                                
                            }
                            
                            self.outgoingTableView.reloadData()
                        }
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
                
                
            })
        }
    }
    
    
    //MARK: Accept Reject and Remove Suggestions or Requests Functions
    
    @objc func acceptSuggestion(_ sender:UIButton){
        
        let suggestionIndex = sender.tag - 120
        var memberInfo: AnyObject
        enableSuggestion = true
        switch activeTableView {
        case 001:
            memberInfo = self.userSuggestions[suggestionIndex]
        case 002:
            memberInfo = self.searchResults[suggestionIndex]
        case 003:
            memberInfo = self.friendRequests[suggestionIndex]
        case 004:
            memberInfo = self.contactsList[suggestionIndex]
        case 006:
            memberInfo = self.friendsList[suggestionIndex] as AnyObject
        case 007:
            memberInfo = self.requestsSentList[suggestionIndex] as AnyObject
        default:
            memberInfo = self.userSuggestions[suggestionIndex]
        }
        
        let subjectId = memberInfo["user_id"] as! Int
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let userAction = memberInfo["friendship_type"] as? String
            var url = "user/add"
            if userAction == "cancel_request"{
                url = "user/cancel"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id":String(subjectId)], url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        let indexPath = IndexPath(row: suggestionIndex, section: 0)
                        if userAction == "cancel_request"{
                            memberInfo.setValue("add_friend", forKey: "friendship_type")
                        }else{
                            memberInfo.setValue("cancel_request", forKey: "friendship_type")
                        }
                        switch self.activeTableView {
                        case 001:
                            self.suggestionsTableView.beginUpdates()
                            self.userSuggestions[suggestionIndex] = memberInfo
                            self.suggestionsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.suggestionsTableView.endUpdates()
                        case 002:
                            memberInfo = self.searchResults[suggestionIndex]
                            self.searchResultsTableView.beginUpdates()
                            self.searchResults[suggestionIndex] = memberInfo
                            self.searchResultsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.searchResultsTableView.endUpdates()
                        case 003:
                            memberInfo = self.friendRequests[suggestionIndex]
                            self.requestsTableView.beginUpdates()
                            self.friendRequests[suggestionIndex] = memberInfo as! FriendRequestModel
                            self.requestsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.requestsTableView.endUpdates()
                        case 004:
                            memberInfo = self.contactsList[suggestionIndex]
                            self.contactsTableView.beginUpdates()
                            self.contactsList[suggestionIndex] = memberInfo
                            self.contactsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.contactsTableView.endUpdates()
                        case 006:
                            memberInfo = self.friendsList[suggestionIndex] as AnyObject
                            self.friendsTableView.beginUpdates()
                            self.friendsList[suggestionIndex] = memberInfo
                            self.friendsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.friendsTableView.endUpdates()
                        case 007:
                            memberInfo = self.requestsSentList[suggestionIndex] as AnyObject
                            self.outgoingTableView.beginUpdates()
                            self.requestsSentList[suggestionIndex] = memberInfo
                            self.outgoingTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.outgoingTableView.endUpdates()
                        default:
                            memberInfo = self.userSuggestions[suggestionIndex]
                            self.suggestionsTableView.beginUpdates()
                            self.userSuggestions[suggestionIndex] = memberInfo
                            self.suggestionsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.suggestionsTableView.endUpdates()
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    @objc func removeSuggestionFromList(_ sender:UIButton){
        
        let suggestionIndex = sender.tag - 130
        
        let memberInfo = self.userSuggestions[suggestionIndex]
        let subjectId = memberInfo["user_id"] as! Int
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            enableSuggestion = true
            
            let url = "suggestions/remove"
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id":String(subjectId)], url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        let indexPath = IndexPath(row: suggestionIndex, section: 0)
                        self.suggestionsTableView.beginUpdates()
                        self.userSuggestions.remove(at: suggestionIndex)
                        self.suggestionsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        self.suggestionsTableView.endUpdates()
                        self.suggestionsTableView.reloadData()
                        
                    }
                })
            }
        }
    }
    
    @objc func removeFriend(_ sender:UIButton){
        
        let suggestionIndex = sender.tag - 130
        var memberInfo: AnyObject
        enableSuggestion = true
        switch activeTableView {
        case 001:
            memberInfo = self.userSuggestions[suggestionIndex]
        case 002:
            memberInfo = self.searchResults[suggestionIndex]
        case 003:
            memberInfo = self.friendRequests[suggestionIndex]
        case 004:
            memberInfo = self.contactsList[suggestionIndex]
        case 006:
            memberInfo = self.friendsList[suggestionIndex] as AnyObject
        case 007:
            memberInfo = self.requestsSentList[suggestionIndex] as AnyObject
        default:
            memberInfo = self.userSuggestions[suggestionIndex]
        }
        
        let subjectId = memberInfo["user_id"] as! Int
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            let userAction = memberInfo["friendship_type"] as? String
            var url = "user/add"
            if userAction == "remove_friend"{
                url = "user/remove"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id": String(describing: subjectId)], url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        let indexPath = IndexPath(row: suggestionIndex, section: 0)
                        
                        if userAction == "remove_friend"{
                            memberInfo.setValue("add_friend", forKey: "friendship_type")
                        }else{
                            memberInfo.setValue("remove_friend", forKey: "friendship_type")
                        }
                        switch self.activeTableView {
                        case 001:
                            memberInfo = self.userSuggestions[suggestionIndex]
                            
                            self.suggestionsTableView.beginUpdates()
                            self.userSuggestions[suggestionIndex] = memberInfo
                            self.suggestionsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.suggestionsTableView.endUpdates()
                            
                        case 002:
                            memberInfo = self.searchResults[suggestionIndex]
                            self.searchResultsTableView.beginUpdates()
                            self.searchResults[suggestionIndex] = memberInfo
                            self.searchResultsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.searchResultsTableView.endUpdates()
                            
                        case 003:
                            memberInfo = self.friendRequests[suggestionIndex]
                            self.requestsTableView.beginUpdates()
                            self.friendRequests[suggestionIndex] = memberInfo as! FriendRequestModel
                            self.requestsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.requestsTableView.endUpdates()
                            
                        case 004:
                            memberInfo = self.contactsList[suggestionIndex]
                            self.contactsTableView.beginUpdates()
                            self.contactsList[suggestionIndex] = memberInfo
                            self.contactsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.contactsTableView.endUpdates()
                            
                        case 006:
                            memberInfo = self.friendsList[suggestionIndex] as AnyObject
                            self.friendsTableView.beginUpdates()
                            self.friendsList[suggestionIndex] = memberInfo
                            self.friendsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.friendsTableView.endUpdates()
                            
                        case 007:
                            
                            memberInfo = self.requestsSentList[suggestionIndex] as AnyObject
                            self.outgoingTableView.beginUpdates()
                            self.requestsSentList[suggestionIndex] = memberInfo
                            self.outgoingTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.outgoingTableView.endUpdates()
                            
                        default:
                            memberInfo = self.userSuggestions[suggestionIndex]
                            self.suggestionsTableView.beginUpdates()
                            self.userSuggestions[suggestionIndex] = memberInfo
                            self.suggestionsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                            self.suggestionsTableView.endUpdates()
                        }
                        
                    }
                })
            }
        }
    }
    
    @objc func acceptFriendRequest(_ sender:CustomButton){
        let suggestionIndex = sender.tag - 120
        let memberInfo = friendRequests[suggestionIndex]
        print("\(sender.tag)   \(self.friendRequests.count)    \(suggestionIndex)")
        let subjectId = memberInfo.subject_id!
        let indexPath = IndexPath(row: suggestionIndex, section: 0)
        let displayName = memberInfo.displayname!
        let userImage = sender.image
        enableSuggestion = true
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            
            self.friendRequests.remove(at: suggestionIndex)
            CATransaction.begin()
            self.view.isUserInteractionEnabled = false
            CATransaction.setCompletionBlock({
                self.setFriendConfirmationTip(subjectid: subjectId, image: userImage!, name: displayName)
            })
            if  sender.tag == self.friendRequests.count - 1 {
                self.requestsTableView.reloadData()
            }
            else {
                self.requestsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                self.requestsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
            CATransaction.commit()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id":"\(subjectId)"], url: "/user/confirm", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.view.isUserInteractionEnabled = true
                    if msg{
                    }
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    @objc func rejectFriendRequest(_ sender:UIButton){
        
        let suggestionIndex = sender.tag - 130
        let memberInfo = friendRequests[suggestionIndex]
        let subjectId = memberInfo.subject_id as Int
        enableSuggestion = true
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            self.view.isUserInteractionEnabled = false
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id": String(subjectId)], url: "/user/reject", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        let indexPath = IndexPath(row: suggestionIndex, section: 0)
                        self.requestsTableView.beginUpdates()
                        self.friendRequests.remove(at: suggestionIndex)
                        self.requestsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        self.requestsTableView.endUpdates()
                        self.requestsTableView.reloadData()
                    }
                })
            }
        }
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            self.createTimer(self)
        }
    }
    
    func setFriendConfirmationTip(subjectid: Int, image: UIImage, name: String) {
        if let view = self.friendRequestAcceptView {
            view.removeFromSuperview()
        }
        self.friendRequestAcceptView = FriendConfirmationTip(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.size.width, height: 80))
        self.friendRequestAcceptView.isHidden = true
        self.friendRequestAcceptView.alpha = 0
        keywindow!.addSubview(self.friendRequestAcceptView)
        self.friendRequestAcceptView.confirmationLabel.text = "Congrats! You and \(name) are now friends"
        self.friendRequestAcceptView.userImage.setImage(image, for: .normal)
        self.friendRequestAcceptView.userImage.id = "\(subjectid)"
        self.friendRequestAcceptView.userImage.viewController = self
        self.friendRequestAcceptView.messageButton.name = displayName
        self.friendRequestAcceptView.messageButton.id = "\(subjectid)"
        self.friendRequestAcceptView.messageButton.viewController = self
        self.friendRequestAcceptView.setView(hidden: false)
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func sendInviteMobile(_ sender: UIButton){
        
        let inviteIndex = sender.tag - 610
        var i = 0
        var contactDetail = ""
        for (_, value) in self.invitationsList {
            if i == (inviteIndex) {
                contactDetail = String(describing: value)
                break
            }
            i+=1
        }
        
        
        if !MFMessageComposeViewController.canSendText() {
            //print("can't send message!!")
            return
        }
        
        let messageController =  MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = [contactDetail]
        messageController.body = "Hey, you're invited to join SocialEngine app. Download it now from : http://devaddons1.socialengineaddons.com/mobiledemotesting/siteapi/index/app-page"
        inviteSelectedIndex = inviteIndex
        self.present(messageController, animated: false, completion: nil)
        
    }
    
    @objc func sendInviteMail(_ sender: UIButton){
        
        if !enabledModules.contains("suggestion")
        {
            showToast(message:"Please enable suggestion plugin for send invitation", controller: self)
            
            return
        }
        
        let inviteIndex = sender.tag - 510
        var i = 0
        var contactDetail = ""
        for (key, _) in self.invitationsList {
            if i == (inviteIndex) {
                contactDetail = key as! String
                break
            }
            i+=1
        }
        
        if isValidEmail(testStr: contactDetail) {
            
            if Reachabable.isConnectedToNetwork() {
                removeAlert()
                //                spinner.center = view.center
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                let params = ["emails": contactDetail]
                
                // Send Server Request to Explore Blog Contents with Blog_ID
                post(params, url: "/suggestions/send-invite", method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            let indexPath = IndexPath(row: inviteIndex, section: 0)
                            self.invitationsTableView.beginUpdates()
                            var i = 0
                            for (key, _) in self.invitationsList {
                                if i == (inviteIndex) {
                                    self.invitationsList.setValue("Invitation sent.", forKey: key as! String)
                                    break
                                }
                                i+=1
                            }
                            self.invitationsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                            self.invitationsTableView.endUpdates()
                            self.invitationsTableView.reloadData()
                            if self.friendRequests.count < 1 {
                                //                            self.noFriendRequestView()
                            }
                        }
                    })
                }
            }
            
        }
        
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
