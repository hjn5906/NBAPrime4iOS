//
//  NBAAnimatedView.swift
//  NBAPrime
//
//  Created by Jegan on 12/4/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit

class NBAAnimatedView: UIView {

    //outlets
    @IBOutlet var mjlol: UIImageView!
    @IBOutlet var mjgrin: UIImageView!
    @IBOutlet var mjcry: UIImageView!
    @IBOutlet var jawalrus: UIImageView!
    @IBOutlet var myman: UIImageView!
    @IBOutlet var banderas: UIImageView!
    @IBOutlet var resultsText: UILabel!
    
    @IBOutlet var orangeView: UIView!
    
    //will hold either "win" or "loss" based on team result
    var pickerValue:String = ""
    
    init(frame: CGRect, pickerValueRet: String){
        super.init(frame: frame)
        setPickerVal(value: pickerValueRet)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPickerVal(value:String){
        pickerValue = value
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func awakeFromNib() {
        becomeFirstResponder() //to listen for motion events, the view needs to be first responder
    }
    
    @IBAction func showHideSmilies(sender: UIButton){
        
        //set first animation
        UIView.beginAnimations("animation1", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(.easeInOut)
        
        
        //frames for winners
        var frameW1 = jawalrus.frame
        var frameW2 = myman.frame
        var frameW3 = banderas.frame
        
        //frames for losers
        var frameL1 = mjlol.frame
        var frameL2 = mjgrin.frame
        var frameL3 = mjcry.frame
        
        
        if dataVal == "win" {
            resultsText.text = "Good win bruh!"
            frameW1.origin.x += 120
            jawalrus.alpha = 1.0
            
            frameW2.origin.x += 120
            myman.alpha = 1.0
            
            frameW3.origin.x += 120
            banderas.alpha = 1.0
            
            jawalrus.frame = frameW1
            myman.frame = frameW2
            banderas.frame = frameW3
        }
            
        else if dataVal == "loss" {
            resultsText.text = "Hold this L."
            frameL1.origin.x += -120
            mjlol.alpha = 1.0
        
            frameL2.origin.x += -120
            mjgrin.alpha = 1.0
        
            frameL3.origin.x += -120
            mjcry.alpha = 1.0
            
            mjlol.frame = frameL1
            mjgrin.frame = frameL2
            mjcry.frame = frameL3
        }
        //alerts user if they did not click the load game buton first
        else if dataVal == "" {
            print("nope")
            //configurations to create alert controller
            
            let message = "Must load game result first."
            
            
            //customizes the messege body of the alert controller
            let attributes = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: UIColor.white])
            
            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.setValue(attributes, forKey: "attributedMessage")
            let subview = alert.view.subviews.first! as UIView
            let alertBody = subview.subviews.first! as UIView
            alertBody.backgroundColor = UIColor.orange
            
            
            alert.addAction(UIAlertAction(title: "Return to Results", style: UIAlertActionStyle.default, handler: nil))
            let tabBarController = window?.rootViewController as? UITabBarController
            let animatedVC = tabBarController!.viewControllers![2] as! NBAAnimatedVC
            animatedVC.present(alert, animated:true, completion:nil)

        }

        //perform first animation - moves from original start
        UIView.commitAnimations()
        
        //set second animation
        UIView.beginAnimations("animation2", context: nil)
        UIView.setAnimationDelay(3)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(.easeInOut)
        
        if dataVal == "win" {
            frameW1.origin.x += -120
            frameW2.origin.x += -120
            frameW3.origin.x += -120
            
            jawalrus.frame = frameW1
            myman.frame = frameW2
            banderas.frame = frameW3
        }
            
        else if dataVal == "loss" {
            frameL1.origin.x += 120
            frameL2.origin.x += 120
            frameL3.origin.x += 120
            
            mjlol.frame = frameL1
            mjgrin.frame = frameL2
            mjcry.frame = frameL3
        }

        //perform second animations - moves back to original start
        UIView.commitAnimations()
        
    }
    
    
}
