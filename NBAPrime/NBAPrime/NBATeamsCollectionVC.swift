//
//  NBATeamsCollectionVC.swift
//  NBAPrime
//
//  Created by Jegan on 11/22/16.
//  Copyright © 2016 Jegan Ndow. All rights reserved.
//

import UIKit

class NBATeamsCollectionVC: UICollectionViewController {
    var jsonUrlObj = NBAJsonUrl()
    var nbaTeams:[String] = []
    var teamLogos:[String] = []
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nbaTeams = jsonUrlObj.getTeamNames()
        
        //conforms to the nba logos path names + extension
        for team in nbaTeams{
            teamLogos.append(team + ".png")
        }
        
        for logo in teamLogos {
            print(logo)
        }
        print(teamLogos.count)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return  teamLogos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCell", for: indexPath)
        
        let logoImageView:UIImageView = (cell.viewWithTag(100) as? UIImageView)!
        
        //displays team logos
        logoImageView.image = UIImage(named: teamLogos[indexPath.item])

    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let jo = jsonUrlObj.getTeamNames()[indexPath.item]
        let joFormatted = jo.replacingOccurrences(of: "_", with: "-")
        print(joFormatted)
        
        //passes data on to a detailed table view
        let teamsDetailVC = NBATeamsDetailTableVC(style: .grouped)
        teamsDetailVC.jo = joFormatted
        teamsDetailVC.domain = jsonUrlObj.getDomain()
        teamsDetailVC.sport = jsonUrlObj.getSport()
        teamsDetailVC.accessToken = jsonUrlObj.getAccesToken()
        teamsDetailVC.format = jsonUrlObj.getFormat()
        
        navigationController?.pushViewController(teamsDetailVC, animated: true)
        
    }

    
}
