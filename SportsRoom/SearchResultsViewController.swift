//
//  SearchResultsViewController.swift
//  SportsRoom
//
//  Created by Javier Xing on 2017-12-15.
//  Copyright © 2017 Javier Xing. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchedSport: String!
    var currentLocation: CLLocation?
    var pulledData: Dictionary<String,Any> = [:]
    
    var searchResults: [Dictionary<String, Any>] = []
    {
        didSet{
            self.tableView.reloadData()
        }
    }
    var locationManager = LocationManager()
    let ref = Database.database().reference(withPath: "games/")
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        locationManager.getCurrentLocation { [weak self] (location: CLLocation) in
            guard let welf = self else { return }
            welf.pullFireBaseData { [weak location] (gameCoordinates, searchedGame) in
                guard let wLocation = location else { return }
                let distance = wLocation.distance(from: gameCoordinates)
                print(distance)
                //            print(searchedGame)
                if ( Int(distance) < 30000 ){
                    self?.searchResults.append(searchedGame)
                    print(welf.searchResults, "\n\n\n\n\n")
                    //                                self?.tableView.reloadData()
                }
                
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "search") {
            let VC2 : DetailsViewController = segue.destination as! DetailsViewController
            VC2.btnText =  DetailsViewController.ButtonState.search
        }
    }
    
    
    //    Mark: - Datasource methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return searchResults.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? SearchTableViewCell else{fatalError("The dequeued cell is not an instance of SearchTableViewCell.")}
        let entry: [String: Any]? = searchResults[indexPath.row]
        
        if let entry = entry {
            cell.titleLabel.text = entry["title"] as? String
            cell.sportLabel.text = entry["sport"] as? String
            cell.locationLabel.text = entry["address"] as? String
            cell.timeLabel.text = entry["date"] as? String
            
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    func pullFireBaseData(completion: @escaping (_ coordinate: CLLocation, _ gameDetails : Dictionary<String, Any>) -> Void) {
        
        ref.queryOrdered(byChild: "sport").queryEqual(toValue: searchedSport.lowercased()).observe(.childAdded) { [weak self] (snapshot) in
            guard let welf = self else { return }
            welf.pulledData = snapshot.value as! Dictionary
            for entry in welf.pulledData {
                let key = entry.0 as String
                if (key == "coordinates"){
                    let dicCoordinates = entry.1 as! Dictionary<String, Any>
                    let gameCoordinates = CLLocation(latitude: dicCoordinates["latitude"] as! CLLocationDegrees , longitude: dicCoordinates["longitude"] as! CLLocationDegrees)
                    print(gameCoordinates)
                    completion(gameCoordinates, welf.pulledData)
                    //                    print(self.pulledData)
                }
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        ref.removeAllObservers()
    }
    
    deinit {
        print("Deallocated")
    }
    
    
}
