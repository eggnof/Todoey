//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var defaults = UserDefaults.standard //Setup reference to userDefault database to store persistant data
    
    var itemArray = [Item]() //Create array of item Objects

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let newItem = Item() //Create new item from Item class
        newItem.title = "Buy Milk" //Assign its title
        itemArray.append(newItem) //Add it to array

        let newItem2 = Item() //Create new item from Item class
        newItem2.title = "Buy Other Stuff" //Assign its title
        itemArray.append(newItem2) //Add it to array
        
        //Check if user has saved itemArray data to userDefaults, if yet load data back into itemArray
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            //Defaults were found, assign them to itemArray
            itemArray = items
        }
        
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
        
        //Tell table to create as and reuseable cells for each cell, using "ToDoItemCell" as the template
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Reference to current item's index
        let item = itemArray[indexPath.row]
        
        print(item.title)//DEBUG
        
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
        
        //Check current done property and set it to its inverse
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        //Reload tableView to refresh cell's accessoryType
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
                
                //TODO: blank items can still be created if user enters whitespace only
                
                //Create new Item object using textFields current value and append it to itemArray
                let newItem = Item() //Create new Object
                newItem.title = textField.text! //Assign it's title
                self.itemArray.append(newItem) //Add it to array
                
                //Save textFields array into userDefaults for persistant storage
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                
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
    
}

