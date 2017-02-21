//
//  AppDelegate.swift
//  NBAPrime
//
//  Created by Jegan on 11/1/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var teamList: [String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        loadData()
        let j = NBAJsonUrl(teamNames: teamList)
        
        //connect to storyboard view controllers
        let tabBarController = window?.rootViewController as? UITabBarController
        let statTracker = tabBarController!.viewControllers![0] as! NBAStatTrackerVC
        let navVC = tabBarController!.viewControllers![1] as! UINavigationController
        let teamsCollectionVC = navVC.viewControllers[0] as! NBATeamsCollectionVC
        let animatedVC = tabBarController!.viewControllers![2] as! NBAAnimatedVC
        let boxScoreVC = tabBarController!.viewControllers![3] as! NBABoxScoreVC
        
        //pass NBAjsonUrl object to view controllers that request json url
        statTracker.jsonUrlObj = j
        teamsCollectionVC.jsonUrlObj  = j
        animatedVC.jsonUrlObj = j
        boxScoreVC.jsonUrlObj = j
    
        
        return true
    }
    
    //load teams.plist and append team names to an array
    func loadData(){
        if let path = Bundle.main.path(forResource: "teams", ofType: "plist"){
            if let tempDict = NSDictionary(contentsOfFile: path){
                let tempArray = (tempDict.value(forKey: "teams") as! NSArray) as Array
                for team in tempArray {
                    teamList.append(team as! String)
                }
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

