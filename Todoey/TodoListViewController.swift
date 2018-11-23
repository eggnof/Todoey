//
//  ViewController.swift
//  Todoey
//
//  Created by Bryce Poole on 11/23/18.
//  Copyright © 2018 Bryce Poole. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = ["Buy Milk","Buy Peanut Butter","Fix Sink"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: Table View Datasource Methods
    
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
        
        cell.textLabel?.text = itemArray[indexPath.row] //Set eacb cell's label to corrisponding label in itemArray
        
        return cell
    }
    
    //MARK: TableView Delegate Methods
    
    //When a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected: \(itemArray[indexPath.row])")
        
        //Check if cell has a check mark
        if(tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark)
        {
            //If yes, remove checkmark from selected row
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            //If no, add a checkmark on selected row
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Prevent row from staying highlighted after a click, instead show highlight then animate it away
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

