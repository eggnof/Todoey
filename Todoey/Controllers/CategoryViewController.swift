//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/27/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    //Initialize a new Realm Object
    let realm = try! Realm()
    
    //A container of type Results that can hold Category objects
    //Results is an auto updating container from Realm. Any time you perform a Realm quiery it returns it as a results object.
    //So to be able to quiery our data and contain it, categories must be of type Results, and not Array or List.
    var categories : Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load data from Realm for app use
        loadItems()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        /************************************
         *  Create Properties for out alert
         ************************************/
        
        var textField = UITextField() //Create a text field container to holder user response
        
        let alert = UIAlertController(title: "Create new category", message: "", preferredStyle: .alert) //Create an alert that will prompt the user
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //Make sure textField's text isn't empty
            if textField.text != ""{
                
                let newCategory = Category() //Create a new Category object from our data model, and assign it to this this the current context
                newCategory.name = textField.text! //Force unwrap (textField's text is an optional) and we already checked to make sure it isn't ""
                
                //Add our newly created Category object to our categoryArray
//                self.categories.append(newCategory) //Now using Realm, no need to append, Realm's Results container auto updates when new Category items are added.
                
                //Save items to the coreData storage, so data persists between sessions
                self.save(category: newCategory)
                
                //Reload the tableView to update it's content
                self.tableView.reloadData()
            }
        }
        
        /****************************************************
         *  Assign our properties and display alert to user
         ****************************************************/
        
        //Add the alert to our textField, prompting the user
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item." //Placeholder text that appears before use has entered anything
            textField = alertTextField //Assign whatever the user enters to textField
        }
        
        //Add the action to our alert
        alert.addAction(action)
        
        //Present the alert to the user
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - TableView Data Source Methods
    /************************************************************************************/
    
    //How many rows are in this section?
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //Nil Coalescing Operator. Return categories.count if its not nil, else return 1
    }
    
    //Set what the contents of each row should be. This gets called for each row in table (Established in numberOfRowsInSection method)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Tell table to create a reuseable cells for each cell, using "categoryCell" as the template cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        //Reference to current item's index
        let item = categories?[indexPath.row]
        
        cell.textLabel?.text = item?.name ?? "No categories added yet!" //Set each cell's label to corrisponding title in categoryArray. Using Nil Coalescing Operator to provide an if clause incase categories is nil.
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    /************************************************************************************/
    
    //A cell was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Transition to another viewController
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //Action that should happen before seque is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Get a reference to the destination viewController as its class type
        let destination = segue.destination as! TodoListViewController
        
        //Get a reference to the currently selected row (IPFSR is an optional, optionalBinding)
        if let indexPath = tableView.indexPathForSelectedRow {
            
            //A valid destination exists, Set selectedCategory inside destination
            destination.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    /************************************************************************************/
    
    //Method for saving data to realm
    func save(category: Category){
        
        do {
            //Try to save the data to Realm
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category: \(error)")
        }
        
        //Refresh the data in our tableView
        tableView.reloadData()
    }
    
    /*******************************************************************************************************************
     * METHOD TO LOAD ITEMS FROM REALM AND UPDATE UI
     *******************************************************************************************************************/
    func loadItems(){
        
        //Load all of this type of object from Realm db
         categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)

        //Update the UI by Refreshing the data in our tableView
        tableView.reloadData()
    }
    
}

extension CategoryViewController : UISearchBarDelegate {
    
    /********************************************************
     * WHAT SHOULD HAPPEN WHEN THE SEARCH BUTTON IS CLICKED
     ********************************************************/
    
    //What should happen when the search button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Calling Category Search!") //DEBUG
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true) //Filter todoItems to only contain items who's title contain the string from searchBar. Sort the results alphabetically by title.
    }
    
    /********************************************************
     * textDidChange:
     * CALLED EVERYTIME THE TEXT INSIDE SEARCH BAR CHANGES
     * —————————————————————————————————————————————————————
     * Use this to clear search results when text is removed
     ********************************************************/
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Search bar changed, but is now empty — Text was removed.
        if searchBar.text?.count == 0 {
            loadItems() //Reload to default state
            
            //Tell the DispatchQueue to make run this call on the main thread - Don't wait for other tasks to finish first
            DispatchQueue.main.async {             //DispatchQueue is responsibile for assigning tasks to different threads
                //Tell searchBar it is no longer the focus – Dismisses keyboard and texdt cursor
                searchBar.resignFirstResponder()
            }
        }
    }

}
