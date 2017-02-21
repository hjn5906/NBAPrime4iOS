//
//  NBAAnimatedVC.swift
//  NBAPrime
//
//  Created by Jegan on 12/7/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit

//passes either "win"/"loss" to view
var dataVal = ""

class NBAAnimatedVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var teamPicker: UIPickerView!
    @IBOutlet weak var teamView: UIView!
    var jsonUrlObj = NBAJsonUrl()
    var nbaTeams:[String] = []
    var secondsToWait = NBARequestLimit()
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var loadedLabel: UILabel!
    
    var domain: String = ""
    var sport: String = ""
    var format: String = ""
    var accessToken: String = ""
    var json_url: String = ""
    var url: URL!
    var urlString:String = ""
    var pickerURL = ""
    var loadedTeamName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        domain = jsonUrlObj.getDomain()
        sport = jsonUrlObj.getSport()
        format = jsonUrlObj.getFormat()
        accessToken = jsonUrlObj.getAccesToken()
        nbaTeams = jsonUrlObj.getTeamNames()
        loadedLabel.text = ""
        loadedTeamName = nbaTeams[0].replacingOccurrences(of: "_", with: " ")
        
        //default initial value - Atlanta Hawks
        pickerURL = jsonUrlBuilder(value: nbaTeams[0])
        teamPicker.dataSource = self
        teamPicker.delegate = self
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  
    //builds json url path
    func jsonUrlBuilder(value: String)-> String {
        let joFormatted = value.replacingOccurrences(of: "_", with: "-")
        json_url = domain + "/" + sport + "/" + "results" + "/" + joFormatted + format + "?"
            + "season=2017&event_status=completed&last=1&" + "access_token=" + accessToken
        
        return json_url
    }
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    //reference: http://stackoverflow.com/questions/31805045/how-to-parse-json-in-swift-using-nsurlsession
    
    //parse json and retrieves data
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
                        dataVal = ""
                        let temp = "\(resetField)"
                        let timeResult = self.secondsToWait.resetSecondsRemaining(value: temp)
                        print("The seconds remaining is \(timeResult)")
                        let message = "API request limit reached! Wait \(timeResult) seconds for xmlstats to update before you can load your selected team's game result."
                        
                        let alert = UIAlertController(title: "xmlstats", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Return to Results", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated:true, completion:nil)
                    }
                    
                    return

                    //throw JSONError.ConversionFailed
                }

                var team:NSDictionary
                for object in json {
                    team = object as! NSDictionary
                    if let result = team["team_event_result"] as? NSString{
                        let resultStr = "\(result)"
                        print(resultStr)
                        
                        //game result stored that will be passed to the animated view
                        dataVal = resultStr
                    }
                }

                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            }.resume()
    } //jsonParser

    
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
        //resets game result if different team selected
        dataVal = ""
        pickerURL = jsonUrlBuilder(value: nbaTeams[row])
        loadedTeamName = nbaTeams[row]
        print(pickerURL)
        
    }
    
    //loads the selected team's information (loaded here rather than in didSelectRow to prevent too many requests being made)
    @IBAction func loadData(_ sender: UIButton ) {
       
        if pickerURL == ""{
            print("error")
        }
        
        let loadedTeamFormatted = loadedTeamName.replacingOccurrences(of: "_", with: " ")
        loadedLabel.text = loadedTeamFormatted + " loaded"
        loadedLabel.alpha = 100
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(3)
        UIView.setAnimationCurve(.easeInOut)
        loadedLabel.alpha = 0
        UIView.commitAnimations()
        jsonParser(url: pickerURL)

    }
    

    
}
