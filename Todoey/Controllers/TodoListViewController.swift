//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]() //Create array of item Objects
    
    //An optional placeholder of Category. When transitioning from categoryVC the selected category gets assigned here through prepareForSegue
    var selectedCategory : Category? {
        
        //Did set gets auto called when selectedCategory gets assigned
        didSet{
            //Load any persisted data from app documents, passing the request item as the container for results
            loadItems()
        }
    }
    
    //Go into app delegate, grab reference to the persistant containers' context
    //This will act as a staging area for data that we want to save, and give us a way to save it
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return itemArray.count //Return number of rows in array
    }
    
    //Set what the contents of each row should be
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Tell table to create a reuseable cells for each cell, using "ToDoItemCell" as the template cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Reference to current item's index
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title //Set each cell's label to corrisponding title in itemArray
        
        //Check if this cell should be checked as done and update its accessoryType accordingly
        cell.accessoryType = item.done ? .checkmark : .none //Ternary statement
        
        return cell
    }
    
    //MARK: TableView Delegate Methods
    //***************************************
    
    //When a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected: \(itemArray[indexPath.row])")
        
//        context.delete(itemArray[indexPath.row]) //Delete the item from itemArray at the current index from the context. Still requires a saveContext to be called later, context is only temporary!
//        itemArray.remove(at: indexPath.row) //Remove the item at the current index from itemArray
        
        //Check current done property and set it to it's inverse
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        //Save items to the apps documents plist, so data persists between sessions
        saveData()
        
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
                
                //TODO: BUG: blank items can still be created if user enters whitespace only
                
                //Create new Item object using textFields current value and append it to itemArray
                let newItem = Item(context: self.context) //Create a new Item from dataModel and assign its contenxt
                newItem.title = textField.text! //Assign it's title
                newItem.done = false //Assign its done status
                newItem.parentCategory = self.selectedCategory//Set the parent category of new item
                self.itemArray.append(newItem) //Add it to array
                
               //Save items to the coreData storage, so data persists between sessions
                self.saveData()
                
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
    func saveData (){
        
        //Save data from itemArray so that it persists between sessions.
        do {
            //Try to save the data that is currently in the context
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        //Refresh the data in our tableView
        tableView.reloadData()
    }
    
    /*******************************************************************************************************************
     * METHOD TO LOAD ITEMS FROM DATA MODEL INTO ITEMARRAY AND UPDATE UI
     * ————————————————————————————————————————————————————————————————————————————————————————————————————————————————
     * Must be given the dataType of the class of item being fetched. In this case, its the data type of our Model
     * Must be given the predicate (search parameters) for the items that it should load. (Assigned a default of nil to allow unassigned calls)
     *******************************************************************************************************************/
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ){ //Using = in the argument declaration gives it a default value if one isn't passed when calling
        
        //Create a filter that only returns items who's parent category matches the current selectedCategory
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //*** Assign the filter to our request ***
        //Option binding, in case predicate is unassigned at call
        if let additionalPredicate = predicate {
            //Combine predicates, so we have a list of pre-filtered predicate items that come in from the arguments (from searchBarSearchButtonClicked)
            //Then categoryPredicate further filters those items to only contain ones that match the parent category
            //Compount predicate combines both search results into a single predicate result
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate , additionalPredicate])
        } else {
            //No additional predicate was passed (such as an initial search from the searchBar). Filter with just the category
            request.predicate = categoryPredicate
        }
        // *******
        
        //Try to pull the request into the context~~
        do {
            //Data was pulled assign it to our global call var itemArray
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        //Update the UI by Refreshing the data in our tableView
        tableView.reloadData()
    }
    


    
}

//MARK: Search bar functionality
//Extend base class to add searchBar functionality
extension TodoListViewController : UISearchBarDelegate {
    
    /********************************************************
     * WHAT SHOULD HAPPEN WHEN THE SEARCH BUTTON IS CLICKED
     ********************************************************/
    
    //What should happen when the search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Create a request object to hold retrieved items
        let request : NSFetchRequest<Item> = Item.fetchRequest() //Must be given the dataType of the class of item being fetched. Here Item is a placeholder for your model's dataType
        
        //create a a query looking for titles that contain the text currently in the searchBar (made case and diacritic insensitive with [cd]!)
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //Create a sort descriptor to sort the query (sorts alphabetically by title, in ascending order)
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ] //Expects an array of descriptors
        
        //Try to pull the request into the context, assign it to our tableView, and update UI (assignment happens inside function)
        loadItems(with: request, predicate: predicate)
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
