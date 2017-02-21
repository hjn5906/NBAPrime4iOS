//
//  NBATeamsDetailTableVC.swift
//  NBAPrime
//
//  Created by Jegan on 11/29/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit

class NBATeamsDetailTableVC: UITableViewController {
    var jo: String = ""
    var domain: String = ""
    var sport: String = ""
    var format: String = ""
    var accessToken: String = ""
    var json_url: String = ""
    var url: URL!
    var urlString:String = ""
    var players : [NBAPlayer] = []
    var secondsToWait = NBARequestLimit()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configures detail table view
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        self.tableView!.backgroundColor = UIColor.orange
        
        //loads the data
        self.urlString = self.jsonUrlBuilder()
        self.jsonParser(url: self.urlString)
    }
    
    func jsonUrlBuilder()-> String {
        json_url = domain + "/" + sport + "/" + "roster" + "/" + jo + format + "?"
            + "access_token=" + accessToken
        print(json_url)
        return json_url
    }
    
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    func jsonParser(url: String) {
        
        let urlPath = url
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        var request = URLRequest(url: endpoint)
        //have to set a meaningful user agent in order to get json request
        let userAgent = "RIT Student NBAPrime User Agent"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            //http response
            let httpResponse = response! as! HTTPURLResponse
            
            //request limit header
            let limitField = httpResponse.allHeaderFields["xmlstats-api-limit"]!
            print("xmlstats API requests limit per minute: \(limitField)")
            
            //request limit remaining header
            let remainingFiled = httpResponse.allHeaderFields["xmlstats-api-remaining"]!
            print("xmlstats API requests remaining: \(remainingFiled)")
            
            //request limit reset time remaining header
            let resetField = httpResponse.allHeaderFields["xmlstats-api-reset"]!
            print("xmlstats API time remaining before another request can be made: \(resetField)")
            do {
                
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    
                    let remainingConditional = "\(remainingFiled)"
                    
                    //if user is out of request limits, alert user on how many seconds left before they can make a new request
                    //fail-safe for 429 HTTP status code
                    if remainingConditional == "0"{
                        let temp = "\(resetField)"
                        let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                        print("The seconds remaining is \(timeResult)")
                        let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can view your selected team's roster."
                        
                        let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Return to Roster", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated:true, completion:nil)
                    }
                    
                    return

                    //throw JSONError.ConversionFailed
                }
                //second fail safe for 429 error json object since it can bypass jsonParser2's initial fail safe as its format structure can be passed as an NSDictionary
                if let value:AnyObject = json["error"] as? NSDictionary{
                    print("429 ERROR Occured")
                    print (value)
                    let temp = "\(resetField)"
                    let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                    print("The seconds remaining is \(timeResult)")
                    let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can view your selected team's roster."
                    
                    let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Return to Roster", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated:true, completion:nil)
                    
                }
                else {
                    let playerRoster = json["players"] as! NSArray
               
                    var player:NSDictionary
                
                    for object in playerRoster {
                        player = object as! NSDictionary
                    
                        //create player object
                        let playerObj = NBAPlayer()
                    
                        //display name
                        if let playerName = player["display_name"] as? NSString
                        {
                            let playerNameStr = "\(playerName)"
                            playerObj.setName(value: playerNameStr)
                        }
                    
                        //position
                        if let playerPosition = player["position"] as? NSString
                        {
                            let playerPositionStr = "\(playerPosition)"
                            playerObj.setPosition(value: playerPositionStr)
                        }
                    
                        //age
                        if let playerAge = player["age"] as? NSNumber
                        {
                            let playerAgeStr = "\(playerAge)"
                            playerObj.setAge(value: playerAgeStr)
                        }
                    
                        //height
                        if let playerHeight = player["height_formatted"] as? NSString
                        {
                            let playerHeightStr = "\(playerHeight)"
                            playerObj.setHeight(value: playerHeightStr)
                        }
                    
                        //weight
                        if let playerWeight = player["weight_lb"] as? NSNumber
                        {
                            let playerWeightStr = "\(playerWeight)"
                            playerObj.setWeight(value: playerWeightStr)
                        }
                    
                        self.players.append(playerObj)
                    
                    
                    }
            
                        self.refreshTable()
               
                        for player in self.players{
                            print(player.description)
                        }
  
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
        
    
    } //jsonParser
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44.0
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        cell.textLabel!.text = players[indexPath.row].getName()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let temp = jo.replacingOccurrences(of: "-", with: " ")
        let title = temp + " Roster"
        return title
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let name = players[indexPath.row].getName()
        let position = players[indexPath.row].getPosition()
        let age = players[indexPath.row].getAge()
        let height = players[indexPath.row].getHeight()
        let weight = players[indexPath.row].getWeight()
        
        //configurations to create alert controller
        
        let message = "Position: " + position + "\n" + "Age: " + age + "\n" + "Height: " + height + "\n" + "Weight: " + weight + " lbs\n"
        
        
        //customizes the messege body of the alert controller
        let attributes = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        let alert = UIAlertController(title: name, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.setValue(attributes, forKey: "attributedMessage")
        let subview = alert.view.subviews.first! as UIView
        let alertBody = subview.subviews.first! as UIView
        alertBody.backgroundColor = UIColor.orange
        
        
        alert.addAction(UIAlertAction(title: "Return to Roster", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated:true, completion:nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.yellow
    }
    
    
    //updates table view to display nba roster
    func refreshTable() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                return
            }
        }
    } //refreshTable
    
}
