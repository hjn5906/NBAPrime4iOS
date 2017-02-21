//
//  NBAPlayer.swift
//  NBAPrime
//
//  Created by Jegan on 11/14/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import Foundation

class NBAPlayer: NSObject {
    
    var name: String = ""
    var position: String = ""
    var age: String = ""
    var height: String = ""
    var weight: String = ""

    convenience override init(){
        self.init(name: "Unknown", position: "Unknown",age: "Unknown", height: "Unknown", weight: "Unknown")
    }
    
     init(name: String, position: String, age: String, height: String, weight: String){
        super.init()
        setName(value: name)
        setPosition(value: position)
        setAge(value: age)
        setHeight(value: height)
        setWeight(value: weight)
    }
    
    override var description: String {
        return "------------\nName: " + getName() + "\nPostion: " + getPosition() + "\nAge: " + getAge() + "\nHeight: " + getHeight() + "\nWeight: " + getWeight()
    }
    
    func getName() -> String {
        return name
    }
    
    func setName(value: String) {
        name = value
    }

    
    func getPosition() -> String {
        return position
    }
    
    func setPosition(value: String) {
        position = value
    }
    
    func getAge() -> String {
        return age
    }
    
    func setAge(value: String) {
        age = value
    }

    func getHeight() -> String {
        return height
    }
    
    func setHeight(value: String) {
        height = value
    }

    func getWeight() -> String {
        return weight
    }
    
    func setWeight(value: String) {
        weight = value
    }


    
}
