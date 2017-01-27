//
//  MyMovieDetailViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 12-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import HCSStarRatingView

class MyMovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, serviceDataReceiver {
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var plotTextView: UITextView!
    @IBOutlet weak var actorsTableView: UITableView!
    @IBOutlet weak var movieSeenButton: UIButton!
    @IBOutlet weak var seenMovieImageView: UIImageView!
    @IBOutlet weak var seenMovieButton: UIButton!
    
    public var movie : MovieDetailed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVideo()
        actorsTableView.rowHeight = UITableViewAutomaticDimension
        actorsTableView.estimatedRowHeight = 100
        setMovieInfo()
    }
    
    override func viewDidLayoutSubviews() {
        createStarsView(frame:ratingLabel.frame, superView: self.view, rating: (movie?.vote_average)!)
        ratingLabel.textColor = .clear
    }
    
    // MARK: - createStars
    private func createStarsView(frame: CGRect, superView: UIView, rating: Double) {
        let starRatingView = HCSStarRatingView(frame: frame)
        starRatingView.maximumValue = 10;
        starRatingView.minimumValue = 0;
        starRatingView.isEnabled = false
        starRatingView.value = CGFloat(rating);
        starRatingView.tintColor = .yellow;
        starRatingView.backgroundColor = .clear
        superView.addSubview(starRatingView)
    }
    
    // MARK: - SetMovieData
    private func getVideo(){
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let service = appDelegate.service
        service.delegate = self
        service.getVideo(id: (movie?.id)!)
    }
    
    @IBAction func seenMovieButtonPressed(_ sender: UIButton) {
        let db = MovieCollectorDatabase()
        db.setMovieSeenValue(seenValue: !(movie?.seen)!, movieId: (movie?.id)!)
        movie?.seen = !(movie?.seen)!
        if (movie?.seen)! {
            seenMovieButton.setTitle("I have not seen this movie yet!", for: .normal)
        }
        else {
            seenMovieButton.setTitle("I have already seen this movie!", for: .normal)
        }
        setMovieSeen()
    }
    
    private func setMovieInfo() {
        if let movie = movie {
            movieNameLabel.text = movie.title!
            genreLabel.text = createGenreString()
            yearLabel.text = Localisation.getDateFormattedToLocale(dateAsString: movie.release_date!)
            
            setImageInImageView()
            plotTextView.text = movie.overview!
            seenMovieImageView.tintColor = .lightGray
            setMovieSeen()
        }
    }
    
    private func setMovieSeen(){
        if (movie?.seen)! {
            seenMovieImageView.image = #imageLiteral(resourceName: "SeenImage").withRenderingMode(.alwaysTemplate)
        }
        else {
            seenMovieImageView.image = #imageLiteral(resourceName: "NotSeenImage").withRenderingMode(.alwaysTemplate)
        }
    }

    private func setImageInImageView() {
        if movie!.poster_path == "LOCAL" {
            setImageFromLocal(movieId: (movie!.id)!)
        }
        else {
            let url = URL(string: URLS.IMAGE_URL.appending((movie?.poster_path)!))
            self.movieImageView?.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
                self.movieImageView?.image = image
            })
        }
        
    }
    
    private func setImageFromLocal (movieId: Int){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(movieId).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            self.movieImageView?.image = UIImage(contentsOfFile: filePath)
        }
    }
    
    private func createGenreString() -> String{
        assert((movie != nil))
        var genreString = ""
        var genres = 0
        for genre in (movie?.genres)! {
            genreString = genreString.appending(genre.name!)
            if genres < (movie?.genres?.count)! - 1{
                genreString = genreString.appending(", ")
            }
            genres += 1
        }
        return genreString
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (movie?.cast?.count)!
        } else {
            return (movie?.crew?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Cast"
        } else {
            return "Crew"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = .lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActorCell")
        if indexPath.section == 0 {
            let person = (movie?.cast?[indexPath.row])! as Cast
            cell?.textLabel?.text = "\(person.name!) as \(person.character!)"
        } else {
            let person = (movie?.crew?[indexPath.row])! as Crew
            cell?.textLabel?.text = "\(person.name!) as \(person.job!)"
        }
        return cell!
    }
    
    // MARK: - DataReceivedFromService
    func dataReceivedFromService(data : Any, id : requestID) {
        debugPrint("[MyMovieDetailViewController] data received")
        switch id {
        case .VIDEOURL:
            debugPrint("[MyMovieDetailViewController] received genres")
            handleVideoUrl(video: data as! Video)
        default:
            break
        }
    }
    
    private var videoKey : String?
    private func handleVideoUrl(video: Video){
        if let videoIdString = video.key, video.site == "YouTube" {
            let switchBarbuttonItem = UIBarButtonItem(title: "Trailer", style: .plain, target: self, action: #selector(showVideo))
            self.videoKey = videoIdString
            switchBarbuttonItem.tintColor = .white
            self.navigationItem.rightBarButtonItem = switchBarbuttonItem
        }
    }
    
    @objc private func showVideo() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let youtubeWebViewController = storyboard.instantiateViewController(withIdentifier: "YoutubeWebViewController") as! YoutubeWebViewController
        youtubeWebViewController.videoKey = videoKey
        self.navigationController?.pushViewController(youtubeWebViewController, animated: true)
    }
}
