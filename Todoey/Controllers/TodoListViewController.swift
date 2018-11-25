//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]() //Create array of item Objects
    
    //Create a filepath to this app's document directory (for saving data)
    //first? is like using [0] and appendingPathComponent concatonates its arguments onto the end of the path – This part will be the name of the actual file that is created.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask ).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load any persisted data from app documents
        loadItems()
        
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
                let newItem = Item() //Create new Object
                newItem.title = textField.text! //Assign it's title
                self.itemArray.append(newItem) //Add it to array
                
               //Save items to the apps documents plist, so data persists between sessions
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
    func saveData (){
        
        //Save data from itemArray so that it persists between sessions.
        //Create a new plist encoder to use for encoding files. The encoder converts any custom dataTypes into standard dataTypes so they can be saved to a plist (Only standard dataTypes in plists!\!)
        let encoder = PropertyListEncoder()
        do {
            //Try to encode itemArray into a plist file so the encoder can write it to plist
            let data = try encoder.encode(itemArray)
            //Try to write the encoded data to the filepath
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array: \(error)")
        }
        
        //Refresh the data in our tableView
        tableView.reloadData()
    }
    
    func loadItems(){
        //Try to grab a reference to the data filepath
        if let data = try? Data(contentsOf: dataFilePath!) {
            //Create a decoder to convert data from plist back to objects original formatting
            let decoder = PropertyListDecoder()
            do{
            //Decode data and update global variable itemArray with its contents.
            //Must be passed the destination dataType, and the location to get the data.
            itemArray = try decoder.decode([Item].self, from: data) //.self used to refer to the type of object, not an instance of object
            } catch {
                print("Error decoding data: \(error)")
            }
        }
    }
    
}

