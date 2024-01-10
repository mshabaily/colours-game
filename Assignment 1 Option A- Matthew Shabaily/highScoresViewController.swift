//
//  highScoresViewController.swift
//  Assignment 1 Option A- Matthew Shabaily
//
//  Created by Shabaily, Matt on 10/11/2023.
//

import UIKit

class highScoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var highscores : [Substring]?
    
    //A table view's cells are configured to display the records of the array of (String,Int) tuples "highscores"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highscores?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let highscoresTableCell = tableView.dequeueReusableCell(withIdentifier: "highscoresTableCell", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text =  (String(highscores?[indexPath.row] ?? ""))
        print(content.text!)
        highscoresTableCell.contentConfiguration = content
        return highscoresTableCell
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        var highscoresLoad : String?
        highscoresLoad = UserDefaults.standard.string(forKey: "highscoresSaved")
        highscores = highscoresLoad?.split(separator: "/") ?? nil

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
