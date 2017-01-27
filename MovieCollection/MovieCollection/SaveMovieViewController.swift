//
//  SaveMovieViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 21-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class SaveMovieViewController: UIViewController, UIPopoverPresentationControllerDelegate, serviceDataReceiver, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var movieImageView: UIImageView!

    @IBOutlet weak var creditsTableView: UITableView!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var releaseDateTextField: UITextField!
    @IBOutlet weak var movieNameTextField: UITextField!
    @IBOutlet weak var genreButton: UIButton!
    
    @IBOutlet weak var seenSegmentedControl: UISegmentedControl!

    var movie = MovieDetailed(dictionary: NSDictionary())
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Add a Movie"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white

        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(self.dismissPicker))
        
        releaseDateTextField.inputAccessoryView = toolBar
        
        genreButton.titleLabel?.frame = genreButton.bounds
        
        setMovieData()
        
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
        let switchBarbuttonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveViewButtonPressed(_:)))
        switchBarbuttonItem.tintColor = .white
        if self.tabBarController != nil {
            self.tabBarController?.navigationItem.rightBarButtonItem = switchBarbuttonItem
        }
        else if self.navigationController != nil {
            self.navigationController?.navigationItem.rightBarButtonItem = switchBarbuttonItem
        }
        self.navigationItem.rightBarButtonItem = switchBarbuttonItem
        
    }
    
    
    // MARK: - Image
    @IBAction func imageViewButtonPressed(_ sender: UIButton) {
        showImageAlert()
    }
    
    private func showImageAlert(){
        let alert = UIAlertController(title: "Get the image from:", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {  _ in
            self.getCamera()
        }
        let photoLibrary = UIAlertAction(title: "Select Photo", style: .default) {  _ in
            self.getPhotoLibrary()
        }
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(cameraAction)
        alert.addAction(photoLibrary)

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = movieImageView
                popoverController.sourceRect = movieImageView.bounds
            }
            break
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera is not available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    private func getPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    var localImageUsed = false
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            movieImageView.contentMode = .scaleAspectFit
            movieImageView.image = pickedImage
            localImageUsed = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - SaveMovie
    @objc private func saveViewButtonPressed(_ sender: UIBarButtonItem) {
        var valid = true
        if overviewTextView.text != "", movieNameTextField.text != "", releaseDateTextField.text != "", movie?.genres != nil, (movie?.genres?.count)! > 0, movie?.cast != nil, (movie?.cast?.count)! > 0, movie?.crew != nil, (movie?.crew?.count)! > 0 {
            movie?.overview = overviewTextView.text
            movie?.title = movieNameTextField.text
            movie?.release_date = getDate()
            if seenSegmentedControl.selectedSegmentIndex == 0 {
                movie?.seen = true
            }
            else {
                movie?.seen = false
            }
        }
        else {
            valid = false
        }
        if valid {
            saveMovie()
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "Not all fields are filled in, fill in all fields!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getDate() -> String{
        let formatter = Localisation.getLocaleDateFormatter()
        let date = formatter.date(from: releaseDateTextField.text!)
        let dbformat = DateFormatter()
        dbformat.dateFormat = "YYYY-MM-dd"
        return dbformat.string(from: date!)
    }
    private func saveMovie() {
        if movie?.id! == nil {
            movie?.id = generateRandomNumber(min: 100000, max: 999999)
        }
        if localImageUsed {
            saveImageLocally()
        }
        let db = MovieCollectorDatabase()
        
        db.insertMovie(movie: (movie?.dictionaryRepresentation())!)
        let alert = UIAlertController(title: "Movie inserted!", message: "The movie is succesfully added to your collection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }

    private func saveImageLocally() {
        do{
            let image = movieImageView.image!
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(movie!.id!).png")
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
                movie?.poster_path = "LOCAL"
                movieImageView.image = nil
                let filePath = documentsURL.appendingPathComponent("\(movie!.id!).png").path
                if FileManager.default.fileExists(atPath: filePath) {
                    self.movieImageView.image = UIImage(contentsOfFile: filePath)
                }
            }
        }
        catch let error as NSError{
            print(error)
        }
    }
    

    
    func generateRandomNumber(min: Int, max: Int) -> Int {
        let randomNum = Int(arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min))
        return randomNum
    }
    
    private func setMovieData(){
        
        if  movie?.overview == nil{
            overviewTextView.text = "Insert movie overview here..."
            
        }
        else {
            overviewTextView.text = movie?.overview!
            releaseDateTextField.text = Localisation.getDateFormattedToLocale(dateAsString: (movie?.release_date!)!)
            movieNameTextField.text = movie?.title!
            if (movie?.genres?.count)! > 0 {
                genreButton.setTitle(createGenreString(), for: .normal)
            }
            else{
                genreButton.setTitle("Genre(s)", for: .normal)
            }
            let url = URL(string: URLS.IMAGE_URL.appending((movie?.poster_path)!))
            self.movieImageView?.kf.setImage(with: url!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
                self.movieImageView?.image = image
            })
        }
        
        creditsTableView.reloadData()
    }

    private func getGenres() -> Array<Genre> {
        let db = MovieCollectorDatabase()
        let genreDictArray = db.getGenres()
        var genres = Array<Genre>()
        for genreDict in genreDictArray {
            genres.append(Genre(dictionary: genreDict)!)
        }
        return genres
    }
    
    // MARK: - GenreSelection
    private var genreTableView : GenreTableViewController?
    
    @IBAction func genreButtonPressed(_ sender: UIButton) {
        if genreTableView == nil {
            genreTableView = GenreTableViewController()
            genreTableView?.genres = getGenres()
        }
        genreTableView?.modalPresentationStyle = .popover
        genreTableView?.preferredContentSize = CGSize(width: sender.bounds.width, height: self.view.frame.height/2)
        genreTableView?.popoverPresentationController?.permittedArrowDirections = .up
        genreTableView?.popoverPresentationController?.sourceView = sender as UIView
        genreTableView?.popoverPresentationController?.delegate = self
        genreTableView?.popoverPresentationController?.sourceRect = sender.bounds

        self.present(genreTableView!, animated: true, completion: nil)
        for genre in (movie?.genres)!{
            selectRow(tableView: genreTableView!, genre: genre)
        }

    }
    private func selectRow(tableView: GenreTableViewController, genre: Genre) {

        if let row = tableView.genres.index(where: {$0.id == genre.id}) {
            let indexPath = IndexPath(row: row, section: 0)
            genreTableView?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        movie?.genres = genreTableView?.getSelectedGenres()
        genreButton.setTitle(createGenreString(), for: .normal)
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle{
        return .none
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    // MARK: - Dateinput
    @IBAction func releaseDateTextInputPressed(_ sender: UITextField) {
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = Localisation.getLocaleDateFormatter()

        releaseDateTextField.text = dateFormatter.string(from: sender.date)
    }
    

    func dismissPicker() {
        view.endEditing(true)
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (movie?.cast?.count)! + 1
        } else {
            return (movie?.crew?.count)! + 1
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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        if indexPath.section == 0 {
            if (movie?.cast?.count)! > indexPath.row {
                let person = (movie?.cast?[indexPath.row])! as Cast
                cell?.textLabel?.text = "\(person.name!) as \(person.character!)"
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "addCell")
            }
        } else {
            if (movie?.crew?.count)! > indexPath.row {
                let person = (movie?.crew?[indexPath.row])! as Crew
                cell?.textLabel?.text = "\(person.name!) as \(person.job!)"
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "addCell")
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            switch indexPath.section {
            case 0:
                movie?.cast?.remove(at: indexPath.row)
            case 1:
                movie?.cast?.remove(at: indexPath.row)
            default:
                break
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
        }
    }
    
    // MARK: - DataReceivedFromService
    func dataReceivedFromService(data : Any, id : requestID) {
        debugPrint("[SearchMovieViewController] data received")
        switch id {
        case .GETCREDITS:
            debugPrint("[SearchMovieViewController] received credits")
            handleCredits(credits: data as! CreditsAPIResponse)
        default:
            break
        }
    }
    
    private func handleCredits(credits: CreditsAPIResponse) {
        if movie?.id! == credits.id! {
            let detailedMovie = (movie?.getMovieDetailed())!
            detailedMovie.cast = credits.cast
            detailedMovie.crew = credits.crew
            let db = MovieCollectorDatabase()
            let array = db.getGenresByIds(ids: detailedMovie.genre_ids!)
            detailedMovie.genres = Array<Genre>()
            for genre in array {
                detailedMovie.genres?.append(Genre(dictionary: genre)!)
            }
            movie = detailedMovie
            setMovieData()
        }
    }
    // MARK: - UnwindSegue
    @IBAction func unwindToSaveMovieViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            switch identifier {
            case "unwindToSaveMovieViewControllerWithSegue":
                if let vc = segue.source as? SearchPersonViewController {
                    addPerson(vc: vc)
                }
            default:
                break
            }
        }
    }

    private func addPerson(vc: SearchPersonViewController) {
        switch vc.searchForPerson! {
        case .cast:
            if let person = vc.selectedPerson as? Cast {
                movie?.cast?.append(person)
            }
            break
        case .crew:
            if let person = vc.selectedPerson as? Crew {
                movie?.crew?.append(person)
            }
            break
        }
        creditsTableView.reloadData()
    }
    
    // MARK: - PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "searchActorSegue":
                if let vc = segue.destination as? SearchPersonViewController {
                    let cell = sender as! UITableViewCell
                    let index = creditsTableView.indexPath(for: cell)
                    switch (index?.section)! {
                    case 0:
                        vc.searchForPerson = .cast
                    case 1:
                        vc.searchForPerson = .crew
                    default:
                        break
                    }
                }
            default:
                break
            }
            
        }
    }
    
}

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
