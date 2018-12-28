//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var todoItems : Results<Item>? //Create a new optional Results container that houses Item objects.
        // ^^ Results containers are auto updating and will look for new <Items> that get created and add them to the container
    
    let realm = try! Realm() //Create new instance of Realm
    
    //An optional placeholder of Category. When transitioning from categoryVC the selected category gets assigned here through prepareForSegue
    var selectedCategory : Category? {
        
        //Did set gets auto called when selectedCategory gets assigned
        didSet{
            //Load any persisted data from app documents, passing the request item as the container for results
            loadItems()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print( FileManager.default.urls(for: .documentDirectory , in: .userDomainMask ) )//DEBUG

        
    }

    //MARK: Table View Datasource Methods
    //***************************************
    
    //Set number of selections (columns) in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Set number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1 //Return number of todoItems, or if nil 1
    }
    
    //Set what the contents of each row should be
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Tell table to create a reuseable cells for each cell, using "ToDoItemCell" as the template cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Reference to current item's index
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title//Set each cell's label to corrisponding title in itemArray
            
            //Check if this cell should be checked as done and update its accessoryType accordingly
            cell.accessoryType = item.done ? .checkmark : .none //Ternary statement
        } else { //todoItems is nil
            cell.textLabel?.text = "No items added!"
        }
        
       
        return cell
    }
    
    //MARK: TableView Delegate Methods
    //***************************************
    
    //When a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected: \(itemArray[indexPath.row])")
        
        //If the currently selected row exists
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
//                    realm.delete(item) //Delete item from database
                    item.done = !item.done //Set done to its inverse
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        //Reload tableView
        tableView.reloadData()
        
        //Prevent row from staying highlighted after a click, instead show highlight then animate it away
        tableView.deselectRow(at: indexPath, animated: true) 
    }

    //MARK: Add New Items
    //***************************************
    
    //Add navBar button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Local vars
        var textField = UITextField() //Setup a new UITextField to hold usered entered text
        
        //Create a UI Alert Container
        let alert = UIAlertController(title: "Add New Todoey Items", message: "", preferredStyle: .alert)
        
        //Create an action for the container, and specify its functionality
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
         
            //User pressed alertAction button
            if textField.text != ""{ //Make sure the textField isn't empty
                
                //Save this new item
                if let selectedCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            
                            //Append this item to its parent category's list of items
                            selectedCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new Items: \(error)")
                    }
                }

                
                //Refresh tableView data
                self.tableView.reloadData()
            }
            
        }
        
        //Add a text field to the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item." //Text that shows in field before user types anything)
            textField = alertTextField //Assign alertTextField to textField, this extends its scope to other parts of this method that are outside this closure.
        }
        
        //Add alert to action
        alert.addAction(action)
        
        //Make the alert visible
        present(alert, animated: true, completion: nil)
        
    }
    
    //Method for encoding and saving data to plist file
    //Saves the current state of the persistant container's context
//    func saveData (){
//
//        //Save data from itemArray so that it persists between sessions.
//        do {
//            //Try to save the data that is currently in the context
//            try context.save()
//        } catch {
//            print("Error saving context: \(error)")
//        }
//
//        //Refresh the data in our tableView
//        tableView.reloadData()
//    }
    
    /*******************************************************************************************************************
     * METHOD TO LOAD ITEMS FROM DATA MODEL INTO ITEMARRAY AND UPDATE UI
     * ————————————————————————————————————————————————————————————————————————————————————————————————————————————————
     * Must be given the dataType of the class of item being fetched. In this case, its the data type of our Model
     * Must be given the predicate (search parameters) for the items that it should load. (Assigned a default of nil to allow unassigned calls)
     *******************************************************************************************************************/
    func loadItems(){
        
        //Load all of our item objects from our selecteCategory into the Results container todoItems
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) //Load items from selectedCategory and sort them alphabetically
        
        //Update the UI by Refreshing the data in our tableView
        tableView.reloadData()
    }
    


    
}

////MARK: Search bar functionality
////Extend base class to add searchBar functionality
extension TodoListViewController : UISearchBarDelegate {

    /********************************************************
     * WHAT SHOULD HAPPEN WHEN THE SEARCH BUTTON IS CLICKED
     ********************************************************/

    //What should happen when the search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("You clicked the search button! Searching for \(searchBar.text!)")//DEBUG
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //Filter todoItems to only contain items who's title contain the string from searchBar. Sort the results by creation date.
        
        tableView.reloadData()
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
