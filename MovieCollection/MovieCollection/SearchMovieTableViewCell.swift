//
//  SearchMovieTableViewCell.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 12-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    public var starsView : UIView?
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    public func setImage(imageUrl: String){
        let url = URL(string: imageUrl)
        self.movieImage?.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
            self.movieImage?.image = image
        })
    }

}
