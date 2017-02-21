//
//  NBABoxScoreVC.swift
//  NBAPrime
//
//  Created by Jegan on 12/10/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit
var boxVal = ""
var boxVal2 = ""

class NBABoxScoreVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var t1:UILabel!
    @IBOutlet weak var t1q1: UILabel!
    @IBOutlet weak var t1q2: UILabel!
    @IBOutlet weak var t1q3: UILabel!
    @IBOutlet weak var t1q4: UILabel!
    @IBOutlet weak var t1Total: UILabel!
    @IBOutlet weak var t2: UILabel!
    @IBOutlet weak var t2q1: UILabel!
    @IBOutlet weak var t2q2: UILabel!
    @IBOutlet weak var t2q3: UILabel!
    @IBOutlet weak var t2q4: UILabel!
    @IBOutlet weak var t2Total: UILabel!
    @IBOutlet weak var resultButton: UIButton!
    
    @IBOutlet weak var teamPicker: UIPickerView!
    
    var jsonUrlObj = NBAJsonUrl()
    var secondsToWait = NBARequestLimit()
    var nbaTeams:[String] = []
    
    var domain: String = ""
    var sport: String = ""
    var format: String = ""
    var accessToken: String = ""
    var json_url: String = ""
    var url: URL!
    var urlString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //away box score placeholders
        t1.text = "Away"
        t1q1.text = "0"
        t1q2.text = "0"
        t1q3.text = "0"
        t1q4.text = "0"
        t1Total.text = "0"
        
        //home box score placeholders
        t2.text = "Home"
        t2q1.text = "0"
        t2q2.text = "0"
        t2q3.text = "0"
        t2q4.text = "0"
        t2Total.text = "0"
        
        //button configurations
        resultButton.layer.cornerRadius = 0.5 * resultButton.bounds.size.width
        resultButton.clipsToBounds = true
        
        domain = jsonUrlObj.getDomain()
        sport = jsonUrlObj.getSport()
        format = jsonUrlObj.getFormat()
        accessToken = jsonUrlObj.getAccesToken()
        nbaTeams = jsonUrlObj.getTeamNames()
        boxVal = jsonUrlBuilder(value: nbaTeams[0])
        
        teamPicker.dataSource = self
        teamPicker.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //builds json url path for team results to get event id that will be passed to the subsequent json url builder
    func jsonUrlBuilder(value: String)-> String {
        let joFormatted = value.replacingOccurrences(of: "_", with: "-")
        json_url = domain + "/" + sport + "/" + "results" + "/" + joFormatted + format + "?"
            + "season=2017&event_status=completed&last=1&" + "access_token=" + accessToken
        
        return json_url
    }
    
    //builds second json url path for box score
    func jsonUrlBuilder2(value: String)-> String {
        
        json_url = domain + "/" + sport + "/" + "boxscore" + "/" + value + format + "?" + "access_token=" + accessToken
        
        return json_url
    }
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    enum JSONError2: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON box score failed"
    }
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    
    //IMPORTANT! - The API that returns the JSON will return a 429 HTTP status code error if you make more than 6 API requests per minute/1 request every 10 seconds
    
    //parses json and calls second jsonParser once a game's event id is retrieved
    func jsonParser(url: String) {
        
        let urlPath = url
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        var request = URLRequest(url: endpoint)
        let userAgent = "RIT Student NBAPrime User Agent"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
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
                
                
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray else {
                    let remainingConditional = "\(remainingFiled)"
                    
                    //if user is out of request limits, alert user on how many seconds left before they can make a new request
                    //fail-safe for 429 HTTP status code
                    if remainingConditional == "0"{
                        let temp = "\(resetField)"
                        let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                        print("The seconds remaining is \(timeResult)")
                        let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can view your selected team's box score."
                        
                        let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Return to Box Score", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated:true, completion:nil)
                    }
                    return
                    
                    //throw JSONError.ConversionFailed
                }
                //print(json)
                var team:NSDictionary
                for object in json {
                    team = object as! NSDictionary
                    
                    //gets game event id
                    if let gameId = team["event_id"] as? NSString{
                        let gameIdStr = "\(gameId)"
                        
                        //passes event id to second json parser to build and retrieve box score data
                        DispatchQueue.global(qos: .userInitiated).sync {
                            DispatchQueue.main.sync {
                                boxVal2 = gameIdStr
                                let gameUrl = self.jsonUrlBuilder2(value: boxVal2)
                                self.jsonParser2(url: gameUrl)
                                return
                            }
                        }
                    }
                }
                
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
    } //jsonParser
    
    
    //parses second json and gather appropiate box score information
    func jsonParser2(url: String) {
        let urlPath = url
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        var request = URLRequest(url: endpoint)
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
                    throw JSONError2.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    
                    let remainingConditional = "\(remainingFiled)"
                    
                    //if user is out of request limits, alert user on how many seconds left before they can make a new request
                    //fail-safe for 429 HTTP status code
                    if remainingConditional == "0"{
                        let temp = "\(resetField)"
                        let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                        print("The seconds remaining is \(timeResult)")
                        let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can view your selected team's box score."
                        
                        let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Return to Box Score", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated:true, completion:nil)
                    }
                    return

                    //throw JSONError2.ConversionFailed
                }
                //away team's name
                print (json)
                
                //second fail safe for 429 error json object since it can bypass jsonParser2's initial fail safe as its format structure can be passed as an NSDictionary
                if let value:AnyObject = json["error"] as? NSDictionary{
                    print("429 ERROR Occured")
                    print (value)
                    let temp = "\(resetField)"
                    let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                    print("The seconds remaining is \(timeResult)")
                    let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can view your selected team's box score."
                    
                    let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Return to Box Score", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated:true, completion:nil)
                    
                }
                else {
                    let awayTeam = json["away_team"]! as! NSDictionary
                    let awayTeamName = awayTeam["last_name"]! as! NSString
                
                    //away team quarter scores
                    let awayScores = json["away_period_scores"]! as! NSArray
                    let awayScore1 = awayScores[0] as! NSNumber
                    let awayScore2 = awayScores[1] as! NSNumber
                    let awayScore3 = awayScores[2] as! NSNumber
                    let awayScore4 = awayScores[3] as! NSNumber
                
                    //away team total score
                    let awayStatTotals = json["away_totals"]! as! NSDictionary
                    let awayScoreTotal = awayStatTotals["points"]! as! NSNumber
                
                
                    //home team's name
                    let homeTeam = json["home_team"]! as! NSDictionary
                    let homeTeamName = homeTeam["last_name"]! as! NSString
                
                    //home team quarter scores
                    let homeScores = json["home_period_scores"]! as! NSArray
                    let homeScore1 = homeScores[0] as! NSNumber
                    let homeScore2 = homeScores[1] as! NSNumber
                    let homeScore3 = homeScores[2] as! NSNumber
                    let homeScore4 = homeScores[3] as! NSNumber
                
                    //home team total score
                    let homeStatTotals = json["home_totals"]! as! NSDictionary
                    let homeScoreTotal = homeStatTotals["points"]! as! NSNumber

                    //updates box score label components with respective information
                    DispatchQueue.global(qos: .userInitiated).sync {
                        DispatchQueue.main.sync {
                            print(awayTeamName)
                            self.t1.text = (awayTeamName as String)
                            self.t1q1.text = "\(awayScore1)"
                            self.t1q2.text = "\(awayScore2)"
                            self.t1q3.text = "\(awayScore3)"
                            self.t1q4.text = "\(awayScore4)"
                            self.t1Total.text = "\(awayScoreTotal)"
                        
                            print(homeTeamName)
                            self.t2.text = (homeTeamName as String)
                            self.t2q1.text = "\(homeScore1)"
                            self.t2q2.text = "\(homeScore2)"
                            self.t2q3.text = "\(homeScore3)"
                            self.t2q4.text = "\(homeScore4)"
                            self.t2Total.text = "\(homeScoreTotal)"
                        
                        }
                    }
                }
  
            } catch let error as JSONError2 {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
        
    } //jsonParser2
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nbaTeams.count
    }
    
    
    //displays customized titles inside the picker view
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let pickerTitleFormatted = nbaTeams[row].replacingOccurrences(of: "_", with: " ")
        let attributedPickerTitle = NSAttributedString(string: pickerTitleFormatted, attributes: [NSForegroundColorAttributeName : UIColor.yellow])
        return attributedPickerTitle
    }
    
    //builds the first json url path based on picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        boxVal = jsonUrlBuilder(value: nbaTeams[row])
   
    }
    
    //parses, retreives and loads data into the box score when the results button is clicked
    @IBAction func parseBox(sender: UIButton){
        jsonParser(url: boxVal)

    }
    
    
    
    

    

}
