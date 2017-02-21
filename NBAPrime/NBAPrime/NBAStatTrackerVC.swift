//
//  NBAStatTrackerVC.swift
//  NBAPrime
//
//  Created by Jegan on 11/1/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit
import AVFoundation

class NBAStatTrackerVC: UIViewController {
    
    var jsonUrlObj = NBAJsonUrl()
    var domain: String = ""
    var wallAudio: AVAudioPlayer!
    var wadeAudio: AVAudioPlayer!
    var derozenAudio: AVAudioPlayer!

    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var wall: UIImageView!
    @IBOutlet weak var wade: UIImageView!
    @IBOutlet weak var derozen: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure host label
        domain = jsonUrlObj.getDomain()
        hostLabel.sizeToFit()
        hostLabel.text = "xmlstats"
        
        //provides user interaction with images
        wall.isUserInteractionEnabled = true
        wade.isUserInteractionEnabled = true
        derozen.isUserInteractionEnabled = true
        
        
        //link dragging capabilities with respective methods
        let panWall = UIPanGestureRecognizer(target: self, action: #selector(self.handleWall(recognizer:)))
        
        let panWade = UIPanGestureRecognizer(target: self, action: #selector(self.handleWade(recognizer:)))
        
        let panDerozen = UIPanGestureRecognizer(target: self, action: #selector(self.handleDerozen(recognizer:)))
        
        
        //adds dragging capabilities to images
        wall.addGestureRecognizer(panWall)
        wade.addGestureRecognizer(panWade)
        derozen.addGestureRecognizer(panDerozen)
        
        
        //creates audio files that go hand in hand with their respective image
        if let wallAudioPath = Bundle.main.path(forResource: "wall", ofType: "mp3"){
            let wallURL = URL(fileURLWithPath: wallAudioPath)
            wallAudio = try? AVAudioPlayer(contentsOf: wallURL)
        }
        
        if let wadeAudioPath = Bundle.main.path(forResource: "wade", ofType: "mp3"){
            let wadeURL = URL(fileURLWithPath: wadeAudioPath)
            wadeAudio = try? AVAudioPlayer(contentsOf: wadeURL)
        }
        
        if let derozenAudioPath = Bundle.main.path(forResource: "derozen", ofType: "mp3"){
            let derozenURL = URL(fileURLWithPath: derozenAudioPath)
            derozenAudio = try? AVAudioPlayer(contentsOf: derozenURL)
        }
        
        
        
        //creates touching capabilities for host label
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        hostLabel.isUserInteractionEnabled = true
        hostLabel.addGestureRecognizer(tap)
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        let urlPath = domain + "/api"
        if let url = URL(string: urlPath){
            
            UIApplication.shared.openURL(url)
        }

    }
    
 
    //provides drag movement for wall image and simultaneously plays wall audio
    func handleWall(recognizer:UIPanGestureRecognizer){
        if recognizer.state == UIGestureRecognizerState.began{
            stopDerozenAudio()
            stopWadeAudio()
            playWallAudio()
    
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            stopWallAudio()
        }
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    //provides drag movement for wade image and simultaneously plays wade audio
    func handleWade(recognizer:UIPanGestureRecognizer){
        
        if recognizer.state == UIGestureRecognizerState.began{
            stopWallAudio()
            stopDerozenAudio()
            playWadeAudio()
            
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            stopWadeAudio()
        }
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    //provides drag movement for derozen image and simultaneously plays derozen audio
    func handleDerozen(recognizer:UIPanGestureRecognizer){
        if recognizer.state == UIGestureRecognizerState.began{
            stopWallAudio()
            stopWadeAudio()
            playDerozenAudio()
            
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            stopDerozenAudio()
        }
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)

    }
    
    //plays wall audio
    func playWallAudio(){
        wallAudio.play()
    }
    
    //stops wall audio
    func stopWallAudio() {
        wallAudio.stop()
    }
    
    //plays wade audio
    func playWadeAudio(){
        wadeAudio.play()
    }
    
    //stops wade audio
    func stopWadeAudio() {
        wadeAudio.stop()
    }
    
    //plays derozen audio
    func playDerozenAudio(){
        derozenAudio.play()
    }
    
    //stops derozen audio
    func stopDerozenAudio() {
        derozenAudio.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
