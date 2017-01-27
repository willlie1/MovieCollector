//
//  MyMoviesTableViewCell.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 11-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import Kingfisher

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var alreadySeenImageView: UIImageView!
    @IBOutlet weak var movieImageLabel: UIImageView!
    public var starsView : UIView?


    public func setImage(imageUrl: String){
        if imageUrl == "LOCAL" {
            print("imageURL is a local image use the proper method")
        }
        let url = URL(string: imageUrl)
        
        self.movieImageLabel?.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
            self.movieImageLabel?.image = image
        })
    }
    
    public func setImageFromLocal (movieId: Int){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(movieId).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            self.movieImageLabel?.image = UIImage(contentsOfFile: filePath)
        }
    }

}
