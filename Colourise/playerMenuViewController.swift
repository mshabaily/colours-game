//
//  playerMenuViewController.swift
//  Assignment 1 Option A- Matthew Shabaily
//
//  Created by Shabaily, Matt on 10/11/2023.
//

import UIKit

class playerMenuViewController: UIViewController {
    
    var playerCount:Int? = 2
    var playerNames:[String] = ["","","","",""]

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var player5View: UIView!
    @IBOutlet weak var player4View: UIView!
    @IBOutlet weak var player3View: UIView!
    @IBOutlet weak var stepperObject: UIStepper!
    
    @IBOutlet weak var name1: UITextField!
    @IBOutlet weak var name2: UITextField!
    @IBOutlet weak var name3: UITextField!
    @IBOutlet weak var name4: UITextField!
    @IBOutlet weak var name5: UITextField!
    
    //Views are shown or hidden based on the number of players selected by a stepper
    @IBAction func playersStepper(_ sender: Any)
    {
        playerCount = (Int)(stepperObject.value)
        if playerCount! > 2{
            player3View.isHidden = false
        }
        else{
            player3View.isHidden = true
        }
        if playerCount! > 3{
            player4View.isHidden = false
        }
        else{
            player4View.isHidden = true
        }
        if playerCount! > 4{
            player5View.isHidden = false
        }
        else{
            player5View.isHidden = true
        }
    }
    @IBAction func start(_ sender: Any) {
        //The player's names are retrieved from text fields
        playerNames[0] = name1.text!
        playerNames[1] = name2.text!
        playerNames[2] = name3.text!
        playerNames[3] = name4.text!
        playerNames[4] = name5.text!
        performSegue(withIdentifier: "toMultiplayer", sender: nil)
    }
    
    //A segue is prepared for by updating the player count and player names of the main view controller, to handle multiplayer mode properly
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMultiplayer"{
            let viewController = segue.destination as! ViewController
            viewController.playerCount = playerCount!
            viewController.playerNames = playerNames
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.tintColor = UIColor(hue: 0.13, saturation: 0, brightness: 0.57, alpha: 1)

        // Do any additional setup after loading the view.
    }
}
