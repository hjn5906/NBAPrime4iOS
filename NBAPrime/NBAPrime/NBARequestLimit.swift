//
//  NBARequestLimit.swift
//  NBAPrime
//
//  Created by Jegan on 12/10/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import Foundation

class NBARequestLimit:NSObject {
    
    override init(){
        super.init()
    }
    
    //returns the time difference between the future wait time placed my xmlstats and the client's current time
    func resetSecondsRemaining(value: String) -> String {
        let timeInterval:TimeInterval = (value as NSString).doubleValue
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let timeRemaining = Int(timeInterval)
        let timeDifference = timeRemaining - timestamp
        let result = "\(timeDifference)"
        return result
    }
    

}
