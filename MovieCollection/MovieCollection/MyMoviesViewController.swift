
//  MyMoviesViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 11-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import HCSStarRatingView

class MyMoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var myMoviesView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    private var movies = Array<MovieDetailed>()
    private var tableView : UITableView?
    private var collectionView : UICollectionView?
    private var refreshControl: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "My Movies"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        getMovies()
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
        if tableView == nil, collectionView == nil {
            collectionView = createCollectionView()
            self.myMoviesView.addSubview(collectionView!)
        } else if tableView != nil {
            tableView?.contentInset = .zero;
        } else if collectionView != nil {
            collectionView?.contentInset = UIEdgeInsets.zero;
        }
        
        let switchBarbuttonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(switchViewButtonPressed(_:)))
        switchBarbuttonItem.tintColor = .white
        self.tabBarController?.navigationItem.rightBarButtonItem = switchBarbuttonItem
    }
    
    // MARK: - Data management
    @IBAction func searchTextFieldEditingChanged(_ sender: UITextField) {
        if searchTextField.text != "" {
            reloadData()
        }
    }
    
    private func getMovies() {
        var searchTitle : String?
        if searchTextField?.text != ""{
            searchTitle = searchTextField.text
        }
        
        let db = MovieCollectorDatabase()
        
        let arrayOfDictMovies = db.getMovies(searchTitle: searchTitle)
        var arrayOfMovies = Array<MovieDetailed>()
        for movie in arrayOfDictMovies {
            arrayOfMovies.append(MovieDetailed(dictionary: movie)!)
        }
        
        movies = arrayOfMovies
    }
    
    @objc private func reloadData() {
        getMovies()
        if tableView != nil {
            tableView?.reloadData()
        }
        else {
            collectionView?.reloadData()
        }
        
        refreshControl.endRefreshing()
    }
    
    // MARK: - View management
    private func createTableView() -> UITableView{
        if tableView != nil {
            tableView?.removeFromSuperview()
        }
        let view = UITableView()
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.rowHeight = UITableViewAutomaticDimension
        view.estimatedRowHeight = 200
        view.keyboardDismissMode = .interactive
        view.frame = CGRect(x: 0, y: 0, width: self.myMoviesView.bounds.size.width, height: self.myMoviesView.bounds.size.height)
        view.register(UINib(nibName: "MyMovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MyMovieCell")
        view.addSubview(refreshControl)
        return view
    }
    
    private func createCollectionView() -> UICollectionView {
        if collectionView != nil {
            collectionView?.removeFromSuperview()
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.footerReferenceSize = CGSize(width: 0, height: 0)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 0)
        flowLayout.minimumLineSpacing = 6.0;
        flowLayout.minimumInteritemSpacing = 6.0;
        flowLayout.itemSize = itemSize
        let frame = CGRect(x: 0, y: 0, width: self.myMoviesView.bounds.size.width, height: self.myMoviesView.bounds.size.height)
        let view = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.isScrollEnabled = true
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true
        view.bounces = true
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: "MyMovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyMovieCell")
        view.addSubview(refreshControl)
        return view

    }
    
    private func switchView(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        if tableView != nil {
            collectionView = createCollectionView()
            UIView.transition(from: tableView!, to: collectionView!, duration: 0.6, options: .transitionFlipFromTop, completion: { completion in
                self.tableView = nil
                sender.isEnabled = true
            })
        } else {
            tableView = createTableView()
            UIView.transition(from: collectionView!, to: tableView!, duration: 0.6, options: .transitionFlipFromTop, completion: { completion in
                self.collectionView = nil
                sender.isEnabled = true
            })
        }
    }
    
    func switchViewButtonPressed(_ sender: UIBarButtonItem) {
        switchView(sender)
    }
    
    // MARK: Navigation
    private func showMovieDetail(indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailView = storyboard.instantiateViewController(withIdentifier: "MyMovieDetailViewController") as! MyMovieDetailViewController
        detailView.movie = movie
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell") as! MyMoviesTableViewCell
        let movie = movies[indexPath.row]

        cell.movieNameLabel.text = movie.title!
        cell.yearLabel.text = Localisation.getDateFormattedToLocale(dateAsString: movie.release_date!)
        if movie.poster_path == "LOCAL" {
            cell.setImageFromLocal(movieId: movie.id!)
        }
        else {
            cell.setImage(imageUrl: URLS.IMAGE_URL.appending((movie.poster_path)!))
        }
        
        cell.starsView = createStarsView(frame: cell.ratingLabel.frame, superView: cell.contentView, rating: movie.vote_average!, starsView: cell.starsView)
        cell.ratingLabel.text = String(movie.vote_average!)
        cell.ratingLabel.textColor = .clear
        if movie.seen {
            cell.alreadySeenImageView.image = #imageLiteral(resourceName: "SeenImage")
        }
        else {
            cell.alreadySeenImageView.image = #imageLiteral(resourceName: "NotSeenImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMovieDetail(indexPath: indexPath)
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    var itemSize: CGSize {
        set {
            
        }
        get {
            var numberOfColumns: CGFloat = 2
            if self.myMoviesView!.frame.width >  self.myMoviesView!.frame.height {
                numberOfColumns = 3
            }
            
            let itemWidth = (self.myMoviesView!.frame.width - (numberOfColumns - 1 * 6)) / numberOfColumns - 5
            let itemheight = (200/119) * itemWidth
            return CGSize(width: itemWidth, height: itemheight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyMovieCell", for: indexPath) as! MyMoviesCollectionViewCell
        
        let movie = movies[indexPath.row]
        if movie.poster_path == "LOCAL" {
            cell.setImageFromLocal(movieId: movie.id!)
        }
        else {
            cell.setImage(imageUrl: URLS.IMAGE_URL.appending((movie.poster_path)!))
        }
        
        cell.movieNameLabel.text = movie.title!
        cell.yearLabel.text = Localisation.getDateFormattedToLocale(dateAsString: movie.release_date!)
    
        if movie.seen {
            cell.alreadySeenImageView.image = #imageLiteral(resourceName: "SeenImage")
        }
        else {
            cell.alreadySeenImageView.image = #imageLiteral(resourceName: "NotSeenImage")
        }

        
        cell.starsView = createStarsView(frame: CGRect(x: cell.ratingLabel.frame.width/4, y: 0, width: cell.ratingLabel.frame.width/2, height: cell.ratingLabel.frame.height), superView: cell.ratingLabel, rating: movie.vote_average!, starsView: cell.starsView)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        showMovieDetail(indexPath: indexPath)
        
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
    
    // MARK: - DidRotate
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        

        coordinator.animateAlongsideTransition(in: nil, animation: nil, completion: { _ in
            if self.tableView != nil {
                self.tableView = self.createTableView()
                self.myMoviesView.addSubview(self.tableView!)
            }
            else if self.collectionView != nil {
                self.collectionView = self.createCollectionView()
                self.myMoviesView.addSubview(self.collectionView!)
            }
        
        })
        
    }
    
    
}
