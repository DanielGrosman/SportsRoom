//
//  HostGameViewController.swift
//  SportsRoom
//
//  Created by Javier Xing on 2017-12-15.
//  Copyright © 2017 Javier Xing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging


class HostGameViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gameTitleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var skillLevelControl: UISegmentedControl!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var numberOfPlayersSlider: UISlider!
    @IBOutlet weak var numberOfPlayersLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var selectLocationLabel: UILabel!
    @IBOutlet weak var selectedSportLabel: UILabel!
    
    var address = String()
    var longitude = Double()
    var latitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfPlayersLabel.text = "1"
    }
    
    @IBAction func unwindFromMap (sender: UIStoryboardSegue) {
        if sender.source is SetLocationViewController {
            if let senderVC = sender.source as? SetLocationViewController {
                address = senderVC.addressString
                longitude = senderVC.longitudeDouble
                latitude = senderVC.latitudeDouble
                selectLocationLabel.text = address
            }
            self.reloadInputViews()
        }
    }
    
    @IBAction func unwindFromSportSelection (sender: UIStoryboardSegue) {
        if sender.source is SelectSportViewController {
            if let senderVC = sender.source as? SelectSportViewController {
                selectedSportLabel.text = senderVC.sportSelectionLabel.text
            }
            self.reloadInputViews()
        }
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        gameTitleTextField.resignFirstResponder()
        costTextField.resignFirstResponder()
        notesTextField.resignFirstResponder()
    }
    
    @IBAction func gamePosted(_ sender: Any) {
        // userID is equal to the current user's ID
        let userID = Auth.auth().currentUser?.uid
        
        // convert date picker value to a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: datePicker.date)
        
        // convert the segmented control value to a string
        let skillLevelString = skillLevelControl.titleForSegment(at: skillLevelControl.selectedSegmentIndex)
        
        // call the postGame method
        postGame(withUserID: userID!, title: gameTitleTextField.text!, sport: selectedSportLabel.text!.lowercased(), date:dateString, address:selectLocationLabel.text!, longitude:longitude, latitude:latitude, cost: costTextField.text!, skillLevel: skillLevelString!, numberOfPlayers: numberOfPlayersSlider.value, note: notesTextField.text!)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        (sender as AnyObject).setValue(Float(lroundf(numberOfPlayersSlider.value)), animated: true)
        let sliderValue: Float = numberOfPlayersSlider.value
        let sliderNSNumber = sliderValue as NSNumber
        let playerString:String = sliderNSNumber.stringValue
        numberOfPlayersLabel.text = playerString
    }
    
    func postGame(withUserID userID: String, title: String, sport: String, date: String, address: String, longitude: Double, latitude: Double, cost: String, skillLevel: String, numberOfPlayers: Float, note: String) {
        // create a game object
        let ref = Database.database().reference().child("games").childByAutoId()
        let gameIDkey = "gameID"
        let hostIDKey = "hostID"
        let titleKey = "title"
        let sportKey = "sport"
        let dateKey = "date"
        let locationKey = "address"
        let longitudeKey = "longitude"
        let latitudeKey = "latitude"
        let costKey = "cost"
        let skillKey = "skillLevel"
        let playerNumberKey = "numberOfPlayers"
        let noteKey = "notes"
        ref.updateChildValues([hostIDKey:userID,gameIDkey:ref.key,titleKey:title,sportKey:sport,dateKey:date,longitudeKey:longitude, latitudeKey:latitude,locationKey:address,costKey:cost,skillKey:skillLevel,playerNumberKey:numberOfPlayers,noteKey:note])
        
        // assign the game id to the current user's 'hosted games' list
        let userID = Auth.auth().currentUser?.uid
        let gameKey = ref.key
        let refUser = Database.database().reference().child("users").child(userID!).child("hostedGames")
        let hostedgamesKey = gameKey
        refUser.updateChildValues([hostedgamesKey:"true"])
        
        let MessagingTopic = "Message"
        Messaging.messaging().subscribe(toTopic: "/topics/\(gameKey)\(MessagingTopic)")
    }
}
