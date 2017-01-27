//
//  SearchPersonViewController.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 21-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit

enum searchForPerson {
    case cast
    case crew
}

class SearchPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, serviceDataReceiver, UITextFieldDelegate {

    public var searchForPerson : searchForPerson?
    public var selectedPerson : Person?
    private var persons = Array<Person>()
    
    @IBOutlet weak var searchPersonTextField: UITextField!
    @IBOutlet weak var personsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        switch searchForPerson! {
        case .cast:
            searchPersonTextField.placeholder = "Search cast..."
        case .crew:
            searchPersonTextField.placeholder = "Search crew..."
        }
        
        personsTableView.contentInset = UIEdgeInsets.zero;
//        performSegue(withIdentifier: "unwindToSaveMovieViewControllerWithSegue", sender: self)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SearchPerson
    
    @IBAction func searchPersonTextFieldEditingDidEnd(_ sender: UITextField) {
        if let query = sender.text, query != "" {
            searchPerson(searchString: query)
        }
    }
    
    private func searchPerson(searchString: String) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let service = appDelegate.service
        service.delegate = self
        
        
        service.searchPerson(query: searchString)
    }
    
    // MARK: - AlertView
    private func showAlert() {
        var message : String
        var title : String
        switch searchForPerson! {
        case .cast:
            title = "Enter character"
            message = "Enter the character name of \(selectedPerson!.name!)."
            break
        case .crew:
            title = "Enter job"
            message = "Enter the job name of \(selectedPerson!.name!)"
            break
            
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            if alert != nil, let textfield = alert?.textFields?[0] {
                self.addPersonJobOrCharacter(jobOrCharacter: textfield.text!)
                self.unwindToSaveMovieViewController()
            }
        }
        saveAction.isEnabled = false
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(saveAction)
        alert.addTextField { textField in
            textField.placeholder = title
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                saveAction.isEnabled = textField.text != ""
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addPersonJobOrCharacter(jobOrCharacter: String) {
        switch searchForPerson! {
        case .cast:
            if let cast = selectedPerson as? Cast {
                cast.character = jobOrCharacter
            }
            break
        case .crew:
            if let crew = selectedPerson as? Crew {
                crew.job = jobOrCharacter
            }
            break
            
        }
    }
    
    private func unwindToSaveMovieViewController() {
        performSegue(withIdentifier: "unwindToSaveMovieViewControllerWithSegue", sender: self)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = .lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell")
        let person = persons[indexPath.row]
        cell?.textLabel?.text = person.name
        cell?.textLabel?.textColor = .white
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchForPerson! {
        case .cast:
            selectedPerson = Cast(dictionary: persons[indexPath.row].dictionaryRepresentation())
            break
        case .crew:
            selectedPerson = Crew(dictionary: persons[indexPath.row].dictionaryRepresentation())
            break
        }
        showAlert()
        
    }
    
    // MARK: - DataReceivedFromService
    func dataReceivedFromService(data : Any, id : requestID) {
        debugPrint("[persons] data received")
        switch id {
        case .SEARCHPERSON:
            debugPrint("[SearchPersonViewController] received persons")
            handlePersons(persons: data as! [Person])
        default:
            break
        }
        
    }
    
    private func handlePersons(persons: [Person]){
        debugPrint("[persons] handling persons")
        if persons.count > 0{
            self.persons = persons
            self.personsTableView.reloadData()
        }
    }


 

}
