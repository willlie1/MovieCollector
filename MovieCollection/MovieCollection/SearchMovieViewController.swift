//
//  SearchMovieViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 12-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import HCSStarRatingView

class SearchMovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, serviceDataReceiver {
    
    @IBOutlet weak var searchMoviesTableView: UITableView!
    private var movies = Array<MovieMDB>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Search Movies"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let service = appDelegate.service
        service.delegate = self
        
        service.getGenres()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - SearchMovie
    @IBAction func searchMovieFieldChanged(_ sender: UITextField) {
        if sender.text! != "" {
            searchMovie(searchString: sender.text!)
        }
    }

    private func searchMovie(searchString: String) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let service = appDelegate.service
        service.delegate = self
        service.searchMovie(query: searchString)
    }
    
    // MARK: - GenreString
    private func getGenresAsString(genreIds: Array<Int>) -> String {
        let db = MovieCollectorDatabase()
        let genreDictArray = db.getGenresByIds(ids: genreIds)
        var genres = Array<Genre>()
        for genreDict in genreDictArray {
            genres.append(Genre(dictionary: genreDict)!)
        }
        return createGenreString(genresArray: genres)
    }
    
    private func createGenreString(genresArray: Array<Genre>) -> String{
        var genreString = ""
        var genres = 0
        for genre in genresArray {
            genreString = genreString.appending(genre.name!)
            if genres < genresArray.count - 1{
                genreString = genreString.appending(", ")
            }
            genres += 1
        }
        return genreString
    }
    
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMovieCell") as! SearchMovieTableViewCell
        let movie = movies[indexPath.row]
        
        cell.setImage(imageUrl: URLS.IMAGE_URL.appending(movie.poster_path!))
        cell.movieNameLabel.text = movie.title!
        cell.genresLabel.text = getGenresAsString(genreIds: movie.genre_ids!)
        cell.yearLabel.text = movie.release_date!
        cell.starsView = createStarsView(frame: cell.ratingLabel.frame, superView: cell.contentView, rating: movie.vote_average!, starsView: cell.starsView)
        cell.ratingLabel.text = "ASDFASDFASDFASDFASDFASDFAASDF"
        cell.ratingLabel.textColor = .clear
        
        return cell
    }
    
    // MARK: - DataReceivedFromService
    func dataReceivedFromService(data : Any, id : requestID) {
        debugPrint("[SearchMovieViewController] data received")
        switch id {
        case .GENRES:
            debugPrint("[SearchMovieViewController] received genres")
            insertGenresToDatabase(genres: data as! [Genre])
        case .SEARCHMOVIE:
            debugPrint("[SearchMovieViewController] received movies")
            handleMovies(movies: data as! [MovieMDB])
        default:
            break
        }
        
    }
    
    
    private func handleMovies(movies: [MovieMDB]){
        debugPrint("[SearchMovieViewController] handling movies")
        if movies.count > 0{
            let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
            let service = appDelegate.service
            service.delegate = self
            self.movies = movies
            self.searchMoviesTableView.reloadData()
        }
    }
    
    private func insertGenresToDatabase(genres : [Genre]) {
        debugPrint("[SearchMovieViewController] insert genres to database")
        let db = MovieCollectorDatabase()
        var arrayOfGenres = Array<NSDictionary>()
        for genre in genres {
            arrayOfGenres.append(genre.dictionaryRepresentation())
        }
        db.bulkInsertGenres(genreDictionarys: arrayOfGenres)
        
    }
    
    // MARK: - createStars
    private func createStarsView(frame: CGRect, superView: UIView, rating: Double, starsView: UIView?) -> UIView{
        if starsView != nil {
            starsView?.removeFromSuperview()
        }
        let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width + 10, height: frame.height+3)
        let starRatingView = HCSStarRatingView(frame: newFrame)
        starRatingView.maximumValue = 10;
        starRatingView.minimumValue = 0;
        starRatingView.isEnabled = false
        starRatingView.value = CGFloat(rating);
        starRatingView.tintColor = .yellow;
        starRatingView.backgroundColor = .clear
        superView.addSubview(starRatingView)
        return starRatingView
    }
    
    // MARK: - PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "movieSelectedSegue":
                if let vc = segue.destination as? SaveMovieViewController {
                    let cell = sender as! UITableViewCell
                    let index = searchMoviesTableView.indexPath(for: cell)
                    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
                    let service = appDelegate.service
                    service.delegate = vc
                    service.getCredits(id: (movies[index!.row].id!))
                    let movieToSend = self.movies[(index?.row)!] as MovieMDB
                    vc.movie = MovieDetailed(dictionary: movieToSend.dictionaryRepresentation())
                }
            default:
                break
            }
            
        }
    }

}
