//
//  MenuViewController.swift
//  Assignment 1 Option A- Matthew Shabaily
//
//  Created by Shabaily, Matt on 10/11/2023.
//

import UIKit
import AVFoundation

//Array of audioclip names and urls, populated by the getAllMP3FileNameURLs function
var audioClips = [String:URL]()

class MenuViewController: UIViewController {
    
    //The timer used to handle button presse by the menu
    var timer:Timer?
    
    //The AVAudioPlayer used to play sounds when menu buttons are pressed
    var audioPlayer: AVAudioPlayer?
    
    //Information passed to handle button presses visually
    var buttonFields:(UIButton,String,Double)?
    
    @IBOutlet weak var scoreboardButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!
    @IBOutlet weak var singlePlayerButton: UIButton!
    
    func getAllMP3FileNameURLs() -> [String:URL] {
        var filePaths = [URL]() //URL array
        var audioFileNames = [String]() //String array
        var theResult = [String:URL]()

        let bundlePath = Bundle.main.bundleURL
        do {
            try FileManager.default.createDirectory(atPath: bundlePath.relativePath, withIntermediateDirectories: true)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: bundlePath, includingPropertiesForKeys: nil, options: [])
            
            // filter the directory contents
            filePaths = directoryContents.filter{ $0.pathExtension == "mp3" }
            
            //get the file names, without the extensions
            audioFileNames = filePaths.map{ $0.deletingPathExtension().lastPathComponent }
        } catch {
            print(error.localizedDescription) //output the error
        }
        //print(audioFileNames) //for debugging purposes only
        for loop in 0..<filePaths.count { //Build up the dictionary.
            theResult[audioFileNames[loop]] = filePaths[loop]
            print(theResult)
        }
        return theResult
    }
    
    func setupAudioPlayer(toPlay audioFileURL:URL) {
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Can't play the audio \(audioFileURL.absoluteString)")
            print(error.localizedDescription)
        }
    }
    
    //Timer function called to dim the menu buttons after an allotted 0.55 seconds
    @objc func buttonHighlightTimer(){
        if((timer != nil)) {
            let buttonFields = timer!.userInfo as? (UIButton,Double,String)
            let button = buttonFields!.0
            let hueColor = buttonFields!.1
            let segueName = buttonFields!.2
            button.tintColor = UIColor(hue: hueColor, saturation: 1, brightness: 0.4, alpha: 1)
            timer?.invalidate()
            timer = nil
            self.audioPlayer = nil
            performSegue(withIdentifier: segueName, sender: nil)
        }
    }
    
    //IBAction to segue through a naviagation controller, to the single player mode
    @IBAction func singleplayerButtonPress(_ sender: Any) {
        singlePlayerButton.tintColor = UIColor(hue: 0.13, saturation: 1, brightness: 1, alpha: 1)
        let buttonFields = (singlePlayerButton,0.13,"toSingleplayer")
        let sound = audioClips["yellow"]
        setupAudioPlayer(toPlay: sound!) //prepare it for playing
        self.audioPlayer?.play()
        timer = Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(buttonHighlightTimer), userInfo: buttonFields, repeats: false)
    }
    
    //IBAction to segue through a naviagation controller, to the multi player mode
    @IBAction func multiplayerButtonPress(_ sender: Any) {
        multiPlayerButton.tintColor = UIColor(hue: 0.59, saturation: 1, brightness: 1, alpha: 1)
        let buttonFields = (multiPlayerButton,0.59,"toPlayerMenu")
        let sound = audioClips["blue"]
        setupAudioPlayer(toPlay: sound!) //prepare it for playing
        self.audioPlayer?.play()
        timer = Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(buttonHighlightTimer), userInfo: buttonFields, repeats: false)
    }
    
    //IBAction to segue through a naviagation controller, to the scoreboard
    @IBAction func scoreboardButtonPress(_ sender: Any) {
        scoreboardButton.tintColor = UIColor(hue: 0.01, saturation: 1, brightness: 1, alpha: 1)
        let buttonFields = (scoreboardButton,0.01,"toHighScoresTable")
        let sound = audioClips["red"]
        setupAudioPlayer(toPlay: sound!) //prepare it for playing
        self.audioPlayer?.play()
        timer = Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(buttonHighlightTimer), userInfo: buttonFields, repeats: false)
    }
    
    //Preparation for segue to update the player count variable to one should the singleplayer option be selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingleplayer"{
            let viewController = segue.destination as! ViewController
            viewController.playerCount = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioClips = getAllMP3FileNameURLs()
        // Do any additional setup after loading the view.
    }
}
