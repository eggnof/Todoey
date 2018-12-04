//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/27/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    //Get Reference to this application's context
    let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load data from persistant container from previous app uses
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
                
                let newItem = Category(context: self.context) //Create a new Category object from our data model, and assign it to this this the current context
                newItem.name = textField.text! //Force unwrap (textField's text is an optional) and we already checked to make sure it isn't ""
                
                //Add our newly created Category object to our categoryArray
                self.categoryArray.append(newItem)
                
                //Save items to the coreData storage, so data persists between sessions
                self.saveData()
                
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
        return categoryArray.count
    }
    
    //Set what the contents of each row should be. This gets called for each row in table (Established in numberOfRowsInSection method)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Tell table to create a reuseable cells for each cell, using "categoryCell" as the template cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        //Reference to current item's index
        let item = categoryArray[indexPath.row]
        
        cell.textLabel?.text = item.name //Set each cell's label to corrisponding title in categoryArray
        
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
            destination.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    /************************************************************************************/
    
    //Method for encoding and saving data to plist file
    //Saves the current state of the persistant container's context
    func saveData (){
        
        //Save data from itemArray so that it persists between sessions.
        do {
            //Try to save the data that is currently in the context
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        
        //Refresh the data in our tableView
        tableView.reloadData()
    }
    
    /*******************************************************************************************************************
     * METHOD TO LOAD ITEMS FROM DATA MODEL INTO ITEMARRAY AND UPDATE UI
     * ————————————————————————————————————————————————————————————————————————————————————————————————————————————————
     * Must be given the dataType of the class of item being fetched. In this case, its the data type of our Model
     *******************************************************************************************************************/
    func loadItems(with request : NSFetchRequest<Category> = Category.fetchRequest() ){ //Using = in the argument declaration gives it a default value if one isn't passed when calling
        
        //Try to pull the request into the context
        do {
            //Data was pulled assign it to our global call var itemArray
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        //Update the UI by Refreshing the data in our tableView
        tableView.reloadData()
    }
    
}
