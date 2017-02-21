//
//  NBAJsonUrl.swift
//  NBAPrime
//
//  Created by Jegan on 11/1/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import Foundation

class NBAJsonUrl: NSObject {
    
    //IMPORTANT! - For extra security measures, the provided access token expires 2017-01-08
    private var accessToken:String = "d9488955-d7aa-47b7-ba4c-ad71bb6a06e4"
    private var keychain = KeychainSwift()
    var domain: String = ""
    var sport: String = ""
    var format: String = ""
    var teamNames: [String] = []
    
    
    convenience override init(){
        self.init(teamNames:[])
    }
    init(teamNames:[String]){
        super.init()
        setAccesToken()
        setDomain()
        setSport()
        setFormat()
        setTeamNames(value: teamNames)
    }
    
    func getAccesToken() -> String {
        //only including this if statement as a fail-safe in case keychain doesn't cooperate with lab machines and to ensure my app will work during presentation regardless
        if keychain.get("access token") == nil {
            print("keychain key not found: directly returning accessToken")
            return accessToken
        }
        return keychain.get("access token")!
    }
    
    func setAccesToken() {
         keychain.set(accessToken, forKey: "access token")
    }
    
    func getDomain() -> String {
        return domain
    }
    
    func setDomain() {
        domain = "https://erikberg.com"
    }
    
    func getSport() -> String {
        return sport
    }
    
    func setSport() {
        sport = "nba"
    }
    
    func getFormat() -> String {
        return format
    }
    
    func setFormat() {
        format = ".json"
    }
    
    func getTeamNames() -> [String] {
        return teamNames
    }
    
    func setTeamNames(value:[String]) {
        teamNames = value
    }
        

}
