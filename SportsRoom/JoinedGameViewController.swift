//
//  JoinedGameViewController.swift
//  SportsRoom
//
//  Created by Javier Xing on 2017-12-15.
//  Copyright © 2017 Javier Xing. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase


class JoinedGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var gamesArrayDetails: [Game] = []
    {
        didSet{
            if let tableView = self.tableView {
                tableView.reloadData()
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getJoinedGames()
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        getJoinedGames()
//        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gamesArrayDetails = [Game]()
    }
    
    
    
    
    func getJoinedGames () {
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(userID!).child("joinedGames")

        //        ref.observeSingleEvent(of: .value) {(snapshot) in
        //            let value = snapshot.value as? [String:String] ?? [:]
        //            let gamesArrayID = Array(value.keys)
        //            for id in gamesArrayID {
        //                let ref = Database.database().reference().child("games").child(id)
        //                ref.observeSingleEvent(of: .value) { (snapshot) in
        //                    let game = Game(snapshot: snapshot)
        //                    self.gamesArrayDetails.append(game)
        //                    self.tableView.reloadData()
        //                }
        //            }
        //        }

        ref.observe(.value) { (snapshot) in
            let value = snapshot.value as? [String:String] ?? [:]
            let gamesArrayID = Array(value.keys)
            for id in gamesArrayID {
                let ref = Database.database().reference().child("games").child(id)
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    let game = Game(snapshot: snapshot)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                    let gameDate = dateFormatter.date(from: game.date)
                    
                    if gameDate! < Date() {
                        let gameKey = game.gameID
                        let refUser = Database.database().reference().child("users").child(userID!).child("joinedGames")
                        refUser.child(gameKey).removeValue()
                        let refGame = Database.database().reference().child("games").child(gameKey).child("joinedPlayers")
                        refGame.child(userID!).removeValue()
                    }
                    else {
                        self.gamesArrayDetails.append(game)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "joined") {
            if let indexPath = tableView.indexPathForSelectedRow {
                let game = gamesArrayDetails[indexPath.row]
                let VC2 : DetailsViewController = segue.destination as! DetailsViewController
                VC2.btnText =  DetailsViewController.ButtonState.joined
                VC2.currentGame = game
            }
        }
    }
    
    
    //    Mark: - DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return gamesArrayDetails.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "joinCell", for: indexPath)
        let game = gamesArrayDetails[indexPath.row]
        cell.textLabel?.text = game.title
        cell.detailTextLabel?.text = game.sport
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Joined Games")
    }
    
}
