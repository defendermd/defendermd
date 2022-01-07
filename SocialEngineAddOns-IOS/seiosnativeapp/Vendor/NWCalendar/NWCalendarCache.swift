//
//  NWCalendarCache.swift
//  NWCalendarDemo
//
//  Created by Nicholas Wargnier on 7/24/15.
//  Copyright (c) 2015 Nick Wargnier. All rights reserved.
//

import Foundation

class NWCalendarCache {
    
    private lazy var __once: () = {
        self.cache = NSCache()
    }()
    
    static let sharedCache = NWCalendarCache()
    
    fileprivate var token: Int = 0
    
    var cache: NSCache<AnyObject, AnyObject>!
    
    
    init() {
        _ = self.__once
    }
    
    func objectForKey(_ key: AnyObject) -> AnyObject? {
        return cache.object(forKey: key)
    }
    
    func setObjectForKey(_ object: AnyObject, key: AnyObject) {
        cache.setObject(object, forKey: key)
    }

}
