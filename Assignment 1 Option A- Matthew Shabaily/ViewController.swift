//
//  ViewController.swift
//  Assignment 1 Option A- Matthew Shabaily
//
//  Created by Shabaily, Matt on 08/11/2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
    
    //Class variables:
    
    //Boolean value to signify if a button is curerently being pressed
    var buttonBusy = true
    
    
    //AVAudioPlayer imported from AVFoundation: used to play all button press sounds
    var audioPlayer: AVAudioPlayer?
    
    //Timer used to output the computer opponent's sequence
    var sequenceTimer: Timer?
    
    //Timer used to wait for a player to finish their response sequence
    var waitForInput: Timer?
    
    //The main gameloop timer, producing one tick every second - continuing the game to the next round on the last's completion
    var gameLoop: Timer?
    
    //A tuple array storing each score achieved by a player, alongside their name (or their team's name in multiplayer))
    var highscores:[(String,Int)]? = []
    
    //The generated sequence, beginning at 10 characters - before being regenerated with 5 more for each completed sequence
    var sequence:String? = ""
    //The current position in the sequence, incrementing as the computer opponent moves through its sequence
    var sequencePosition: Int? = 0
    
    //A variable storing the current person's turn - being 0 if it is the computer's and between 1 and 5 for each player
    var userTurn:Int? = 0
    
    //A variable storing the current round limit, incrementing by 5 after each completed sequence
    var roundLimit:Int? = 2
    //A variable storing the current round
    var round:Int? = 1
    //A variable used to store the numerical user who's turn is next - this is used to simplify swapping
    var nextUserTurn:Int? = 0
    
    //A variable storing the user's response sequence thus far
    var userInput:String? = ""
    //A variable storing the user's points thus far
    var userPoints:Int? = 0
    
    //A variable to signify that the main gameloop can continue to the next round, only set to true on intial running or after a round is ready to end
    var restart:Bool? = true
    
    //The number of players, initialized to one via a segue from the MenuViewController if singleplayer is selected
    //If the main view controller is loaded via segue from the playerMenuViewController (where the number of players in multiplayer is decided), then this will be reset to the player amount there
    var playerCount:Int?
    //The player's names, with a maximum of five (as per the spec) - there is initially one player named "player" for the singleplayer mode
    //Multiple player names can be appended from the playerMenuViewController
    var playerNames:[String] = ["Player","","","",""]

    //Outlets are defined for the Storyboard components (some of which are initally hidden)
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var gameOverPopup: UIView!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    
    //Debug mode here is set to true on initialization - just used to print the sequence to ease marking (on a hypothetical release this would be set to false)
    let debugMode = true
    
    //Function to setup the AVAudioPlayer to play sound files (using .mp3 URLs loaded in the MenuViewController)
    //Credit: Phil Jimmieson
    func setupAudioPlayer(toPlay audioFileURL:URL) {
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Can't play the audio \(audioFileURL.absoluteString)")
            print(error.localizedDescription)
        }
    }
    
    //Function to generate a random sequence of numbers between zero and three, equating to the four colors of the sequence
    func sequenceGenerator(amount:Int){
        sequence = ""
        for _ in 0...amount-1{
            let randInt = Int.random(in: 0...3)
            sequence? += "\(randInt)"
        }
    }
    
    //Fuction to output the color to ease marking (dependant on debug mode being true)
    func printSequence(){
        if debugMode == false{
            return
        }
        for color in sequence!{
            if color == "0"{
                print ("yellow")
            }
            if color == "1"{
                print ("blue")
            }
            if color == "2"{
                print ("red")
            }
            if color == "3"{
                print ("green")
            }
        }
    }
    
    //Function called via the sequence timer to output the next color in the sequence to the player (simulating the pressing of the according button)
    @objc func outputSequence() {
        if sequenceTimer != nil{
            var buttonDetected : UIButton
            var colorDetected : String
            var hueDetected : Double
            
            //Sets the appropriate sequence position, offset by however many colors into the sequence the computer is
            let position = sequence!.index(sequence!.startIndex, offsetBy: sequencePosition!)
            
            //Catches if the sequence's first character equals zero (signifying yellow)
            if sequence![position] == "0" {
                
                //Information about the color is saved into variables, to be passed to the function responsible for simulating button presses
                buttonDetected = yellowButton
                colorDetected = "yellow"
                hueDetected = 0.13
                
                //Increments the sequence position, now being ready for the net color in the sequence
                sequencePosition! += 1
            }
            else if sequence![position] == "1"{
                
                buttonDetected = blueButton
                colorDetected = "blue"
                hueDetected = 0.59
                
                sequencePosition! += 1
            }
            else if sequence![position] == "2"{
                
                buttonDetected = redButton
                colorDetected = "red"
                hueDetected = 0.01

                sequencePosition! += 1
            }
            else{
                
                buttonDetected = greenButton
                colorDetected = "green"
                hueDetected = 0.375

                sequencePosition! += 1
            }
            
            //Responds to the simulated button press visually
            respondToButtonPress(button: buttonDetected, color: colorDetected, colorHue: hueDetected)
            
            //Catches if the number of buttons pressed by the computer is equal to the round number, and stops the turn
            if sequencePosition! == round!{
                sequenceTimer?.invalidate()
                sequenceTimer = nil
                sequencePosition = 0
                //Updates the UILabel turnLabel to inform the next player that it is their turn
                turnLabel.text = ("\(playerNames[nextUserTurn!-1])'s Turn")
            }
        }
    }
    
    //Function to compare the user's inputted sequence to the computer generated one
    //If the sequence is correct then
    func checkInput(){
        let position = sequence!.index(sequence!.startIndex, offsetBy: userInput!.count-1)
        if userInput![position] != sequence![position]{
            
            //The game over label displays the game state at the end of a game, here it is "game over" (the player has lost)
            gameOverLabel.text = "Game Over!"
            
            //An appropriate title is given to the button used to restart the game
            playAgainButton.setTitle("Try Again", for: UIControl.State.normal)
            
            //Cleanup of user points and sequence variables, and displaying of the "game over" screen
            endGame()
        
        }
    }
    
    
    //Function called to set the buttonBusy variable to false, allowing the user to select their next color
    func freeButton(){
        buttonBusy = false
    }
    
    //Function called to respond to the pressing of a button, primarily in terms of UI/UX
    func respondToButtonPress(button:UIButton, color:String, colorHue:Double){
        
        //The button is set to be busy, preventing the spamming of colors
        buttonBusy = true
        
        //The sound is determined by retrieving the URL from the audioClips dictionary, defined in the MenuViewController
        let sound = audioClips[color]
        
        //The audio player is setup and played for the appropriate sound passed into the function
        setupAudioPlayer(toPlay: sound!) //prepare it for playing
        self.audioPlayer?.play() //and play it
        
        //The button's brightness level is set to 1, highlighting it
        button.tintColor = UIColor(hue: colorHue, saturation: 1, brightness: 1, alpha: 1)
        
        //A wait of 0.5 seconds is done via the DispatchQueue, after which code is ran to return the button to dull
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.resetButtonBrightness(buttonName: button, hueValue: colorHue)
        }
    }
    
    //Function to reset the button's brightness to a normal level (called exclusivly by the the respondToButtonPress function)
    func resetButtonBrightness(buttonName: UIButton, hueValue:Double) {
        buttonName.tintColor = UIColor(hue: hueValue, saturation: 1, brightness: 0.4, alpha: 1)
        
        //The audio player is also set to nil by the function (since by this point the sound is done playing and the player can be cleaned up)
        self.audioPlayer = nil
        
        //A further wait of 0.3 seconds is carried out via the DispatchQueue, to ensure that the user cannot spam any buttons
        //After this period the buttons are freed to be pressed again
        self.freeButton()
    }
    
    //IBActions that handle a button presses
    //Here the user's color selection is handled and the record of their input is saved - and checked with a call to checkInput()
    //The button presses are also visully handled by the respondToButtonPress function
    @IBAction func yellowButtonPressed(_ sender: Any) {
        //Buttons presses are only proccessed if the button busy variable is false (meaning nothing is being spammed), and the userTurn != 0 (meaning it is not the computer's turn)
        if buttonBusy == false && userTurn != 0{
            respondToButtonPress(button: yellowButton, color: "yellow", colorHue: 0.13)
            userInput? += "0"
            checkInput()
        }
    }
    @IBAction func blueButtonPressed(_ sender: Any) {
        if buttonBusy == false && userTurn != 0{
            respondToButtonPress(button: blueButton, color: "blue", colorHue: 0.59)
            userInput? += "1"
            checkInput()
        }
    }
    @IBAction func redButtonPressed(_ sender: Any) {
        if buttonBusy == false && userTurn != 0{
            respondToButtonPress(button: redButton, color: "red", colorHue: 0.01)
            userInput? += "2"
            checkInput()
        }
    }
    @IBAction func greenButtonPressed(_ sender: Any) {
        if buttonBusy == false && userTurn != 0{
            respondToButtonPress(button: greenButton, color: "green", colorHue: 0.375)
            userInput? += "3"
            checkInput()
        }
    }
    
    //A function ran in the initialization stage, ensuring that any highscores saved within UserDefaults are loaded properly
    //The highscores are saved in UserDefaults in the form of a string, with each record being separated by a "/"
    //This means that in order to sort the scores by their points, they must be converted into a (String,Int) tuple
    func populateHighscores(){
        
        //The highscores are loaded from the key "highscoresSaved"
        let highscoresLoad = UserDefaults.standard.string(forKey: "highscoresSaved")
        
        //The function is exited if there are no highscores saved
        if highscoresLoad == ""{
            return
        }
        
        //Before the scores can be converted into a tuple, each individual record must be separated (by splitting the string based on the "/" separator
        let splitRecords : [Substring]? = highscoresLoad?.split(separator: "/")
        
        if splitRecords == nil{
            return
        }
        
        //The records are iterated over and separated again by the ":" separator (splitting the names and scores)
        for loop in 0...splitRecords!.count/2{
            
            let nextRecord = splitRecords![loop].split(separator: ":")
            
            //Tuples are constructed from the elements of each of these doubly split arrays
            let nextName : String = String(nextRecord[0])
            let nextScore : Int = Int(nextRecord[1])!
            let nextRecordAsTuple : (String,Int) = (nextName,nextScore)
            
            //The tuples are then finally appended to the tuple array of highscores
            highscores?.append(nextRecordAsTuple)
        }
    }
    
    //This function is called to configure the game over popup view, and to set it's visibility to true
    func endGame(){
        
        //Depending on the amount of players, the field where players enter their name/team name has its placeholder text changed to reflect which of the two is being inputted
        if playerCount! == 1{
            nameField.placeholder = "Enter Name (Optional)"
        }
        else{
            nameField.placeholder = "Enter Team Name (Optional)"
        }
        
        //The game over popup view stops being hidden from the player(s)
        gameOverPopup.isHidden = false
        if gameOverLabel.text == "You Win!"{
            nameField.isHidden = true
        }
        else{
            nameField.isHidden = false
        }
        
        //The buttonBusy variable is also set to true here, ensuring that the game cannot be played while the game over popup view is shown
        buttonBusy = true
    }
    
    //A validation function to ensure that the player's name/team name does not contain characters used by the highscores persistant data storage algorithm to split records
    //Called upon entry of a player's name after the round ends (returning true if the name passes all checks)
    func validatePlayerName() -> Bool{
        //The name entered into the UITextField "nameField" is checked to determine if it contins ":" or "/"
        //Since these characters are used to split the scoreboard records, they cannot be entered as names
        if nameField.text!.contains(":") || nameField.text!.contains("/"){
            
            //A UIAlertController is created to alert the user that they cannot proceed with their name
            let nameWarning = UIAlertController(title: "Sorry!", message: "Name cannot contain ':' or '/'", preferredStyle: .alert)
            
            //A UIAlertAction is added, allowing the alert to be dismissed
            let nameWarningEscape = UIAlertAction(title: "Okay", style:.default)
            nameWarning.addAction(nameWarningEscape)
            
            //The alert is presented, and the function is exited - allowing the user to retry with a different name
            present(nameWarning, animated: true)
            return false
        }
        else{
            return true
        }
    }
    
    //Function to save and sort the highscore of a finished game in the scoreboard - within an array of String,Int tuples that are saved in UserDefaults
    //This is called on the completion of a round, after the player(s) has/have lost and pressed the try again button (given that they have supplied a name)
    func saveHighscore(){
        
        //A tuple is constructed from the entered name and points, before being appended to the tuple array "highscores"
        let scoreRecord : (String,Int) = (player: nameField.text! ,points: userPoints!)
        highscores?.append(scoreRecord)
        
        //The highscores array is sorted based on the second element of each tuple (the numerical score)
        highscores!.sort{
            ($0.1 > $1.1)
        }
        
        //The highscores array is iterated through to create a string with each record separated by a "/" (and with each name/points value being separated by a ":")
        var highscoresSave = ""
        for loop in (0...highscores!.count-1){
            highscoresSave += "\(highscores![loop].0):\(highscores![loop].1)/"
        }
        
        //The altered String is then saved in UserDefaults with the key "highscoresSaved"
        UserDefaults.standard.set(highscoresSave, forKey: "highscoresSaved")
    }
    
    //An IBAction linked to the button used to start a new round
    //Depending on if the player has sucessfully repeated a full sequence the text of this button will say "You Win!" or "Game Over!"
    //This text is checked for, to determine which game state is currently occuring
    //If a user wants to record their score on the scoreboard, this button is also used to confirm that they have entered their name
    @IBAction func playAgain(_ sender: Any) {
        
        //If the name does not pass the validation checks, the function ends immediatly (with all error handling being done by the validation function)
        if(!validatePlayerName()){
            return
        }
        
        //Otherwise, the current gamestate is checked for by the text displayed by the UILabel "gameOverLabel"
        //If it does not display "You Win!" but displays "Game Over!", then the round is reset
        else if gameOverLabel.text! == "Game Over!"{

            //The round limit is reset to a 10 length color sequence, and the player/team 's points are reset to 0 (the points label being changed to reflect this)
            roundLimit = 10
            userPoints = 0
            pointsLabel.text = "\(userPoints!) Points"
            
            //If the nameField's text is empty, it is inferred that the player/team do not wish to record their score
            //Otherwise, the saveHighscore() fuction records and sorts the new leaderboard
            if nameField.text != ""{
                saveHighscore()
            }
        }
        
        //If the gameOverLabel displays anything other than "Game Over", the gamestate is inferred to be a player/team victory
        //This means that the round limit must be incremented by 5 before the next sequence is generated
        else{
            roundLimit? += 5
        }
        
        //The view contining the game over view is hidden, in preparation for a new turn
        gameOverPopup.isHidden = true
        
        //The round number is also reset, in preparation of a new game
        round = 1
        
        //Finally a new sequence is generated to reflect the round limit, and the next round is set to begin with the "restart" variable being set to true
        sequenceGenerator(amount: roundLimit!)
        restart = true
    }
    
    
    //Function called by the waitForInput timer, being checked each second to determine if the user's turn is ready to end
    @objc func inputSequenceChecker(){
        
        //Checks if the user has selected as many colours as the round number, in which case the round is over
        //Otherwise the round number is incremented
        if userInput!.count == round!{
            round! += 1
            
            //Awards points equivilant to the sequence length
            if userInput! == sequence!.prefix(round!-1){
                userPoints? += userInput!.count
                
                //Updates the points label accordingly
                pointsLabel.text = "\(userPoints!) Points"
                
                //So long as the round limit has not been reached, a new round can be begun - by setting the restart variable to true
                if round != roundLimit!+1{
                    restart = true
                }
            }
        }
        
        //Checks if round has reached it's limit, in which case points are awarded and the new round limit is established
        if round == roundLimit!+1{
            gameOverLabel.text = "You Win!"
            playAgainButton.setTitle("Next Round", for: UIControl.State.normal)
            endGame()
        }
    }
    
    @objc func gameLoopTrigger(){
        
        //Checks if a new round is ready to begin
        if restart == true{
            
            //Prevents a round from starting while one is underway
            restart = false
            
            //Here the next user to play is configured, if multiplayer was selected then this will increment until the player count is reached
            if nextUserTurn! < playerCount!{
                nextUserTurn! += 1
            }
            
            //Otherwise the next user to play will always be 1 (since the computer goes first)
            else{
                nextUserTurn = 1
            }
            
            userTurn = -1
            userInput = ""
            //Changes the label to respect this
            turnLabel.text = "My Turn"
            //Begins playing the computers turn at one action per second
            sequenceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(outputSequence), userInfo: nil, repeats: true)
            //Waits for the user to finish their turn
            waitForInput = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(inputSequenceChecker), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The comment beneath this one can be "uncommented" and ran if you'd like to reset the scoreboard during testing
        //UserDefaults.standard.set("", forKey: "highscoresSaved")
        
        yellowButton.tintColor = UIColor(hue: 0.13, saturation: 1, brightness: 0.4, alpha: 1)
        blueButton.tintColor = UIColor(hue: 0.59, saturation: 1, brightness: 0.4, alpha: 1)
        redButton.tintColor = UIColor(hue: 0.01, saturation: 1, brightness: 0.4, alpha: 1)
        greenButton.tintColor = UIColor(hue: 0.375, saturation: 1, brightness: 0.4, alpha: 1)
        
        populateHighscores()
        
        //Creates initial 10 colour sequence
        sequenceGenerator(amount: roundLimit!)
        printSequence()
        //Begins main game loop
        gameLoop = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameLoopTrigger), userInfo: nil, repeats: true)
    }
}

