//
//  GenreTableViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 21-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class GenreTableViewController: UITableViewController {

    public var genres = Array<Genre>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        self.tableView.allowsMultipleSelection = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func getSelectedGenres() -> Array<Genre> {
       let selectedRows = self.tableView.indexPathsForSelectedRows
        var genreArray = Array<Genre>()
        if selectedRows != nil, (selectedRows?.count)! > 0 {
            for indexPath in selectedRows! {
                genreArray.append(genres[indexPath.row])
            }
        }
        return genreArray
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.backgroundColor = .black
        let genre = genres[indexPath.row]
        cell.textLabel?.text = genre.name!
        cell.textLabel?.textColor = .white

        return cell
    }
 


}
