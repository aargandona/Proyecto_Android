//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 5/27/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//  See LICENSE.txt for this sample’s licensing information.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class MealTableViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: Properties
    
    var meals = [Meal]()
    var mealsSearchResults = [Meal]()
    
    var realm:Realm?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        realm = try! Realm()
        print (" the path real is \(realm?.path)")

    }
    
    //Response Data
    var data:NSData?
    
    @IBAction func ratingSort(sender: AnyObject) {
        meals.sortInPlace({$0.rating > $1.rating})
        self.tableView.reloadData()
    }
 
    @IBAction func refreshMeals(sender: UIBarButtonItem) {
        //Append the new meals from server
        loadSampleMealsFromRestApi()
        self.tableView.reloadData()
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()

        //Searchbar init
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Load meals data
        loadSampleMealsFromRestApi()
    }
    
    func loadSampleMealsFromDB() {
        for me in (realm?.objects(MealDB.self))! {
            let img = UIImage(data: me.photo!)
            let meal = Meal(name: me.name, photo: img, rating: me.rating, latitud: me.latitud, longitud: me.longitud, id: me.id)
            meals.append(meal!)
        }
        self.tableView.reloadData()
        
        GlobalVariables.sharedManager.meals = meals
    }
    
    func loadSampleMealsFromRestApi() {
        
        // populate using Rest
        Alamofire.request(.GET, "http://localhost:3000/meals")
            .responseJSON { response in
                //print(response.request)  // original URL request
                print(response.response) // URL response
                //print(response.data)     // server data
                
                //print(response.result)   // result of response serialization
                
                switch response.result {
                    case .Success:
                        print("Success")
                        
                        // Save data
                        self.data = response.data
                    
                        // Parse JSON to Model
                        let json = JSON(data: response.data!)
                        
                        for (key,subJson):(String, JSON) in json {

                            let newId = subJson["id"].string!
                            let mealsById = self.meals.filter({$0.id == newId})
                            
                            if mealsById.count == 0 {
                            // add new Meal
                            let newMeal = Meal(name: subJson["name"].string!,
                                photo: nil,
                                rating: subJson["rating"].int!,
                                latitud: subJson["latitud"].double!,
                                longitud: subJson["longitud"].double!,
                                id: subJson["id"].string!)
                            
                            // Retrieve Image
                            Alamofire.request(.GET, subJson["photo"].string!)
                                .responseJSON {img in
                                
                                    // Create image from source
                                    let imagen = UIImage(data: img.data!)
                                    
                                    // Set photo image and append to meal list
                                    newMeal?.photo = imagen
                                    self.meals.append(newMeal!)
                                    GlobalVariables.sharedManager.meals.append(newMeal!)
                                    
                                    // Reload data Table
                                    self.tableView.reloadData()
                                    
                                    // Persist in DB
                                    let filter = "id='\((newMeal?.id)!)'"
                                    let selectedMeals = self.realm?.objects(MealDB.self).filter(filter)
                                    
                                    // Check if meal already stored into DB
                                    if selectedMeals?.count == 0 {
                                        let newMealDB = MealDB()
                                        newMealDB.name = (newMeal?.name)!
                                        newMealDB.photo = UIImagePNGRepresentation((newMeal?.photo)!)
                                        newMealDB.rating = (newMeal?.rating)!
                                        newMealDB.id = (newMeal?.id)!
                                        newMealDB.latitud = (newMeal?.latitud)!
                                        newMealDB.longitud = (newMeal?.longitud)!
                                        
                                        // save new meal
                                        try! self.realm?.write {
                                            self.realm?.add(newMealDB)
                                        }
                                    }
                            }
                            //>>
                            }//End If
                    }
                    
                    case .Failure(let error):
                        print(error)
                        self.loadSampleMealsFromDB()
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return meals.count
        if searchController.active && searchController.searchBar.text != "" {
            return mealsSearchResults.count
        }
        return meals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MealTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        //let meal = meals[indexPath.row]
        let meal: Meal
        if searchController.active && searchController.searchBar.text != "" {
            meal = mealsSearchResults[indexPath.row]
        } else {
            meal = meals[indexPath.row]
        }
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            var idSelected = meals[indexPath.row].id
            
            if searchController.active && searchController.searchBar.text != "" {
                idSelected = mealsSearchResults[indexPath.row].id
                mealsSearchResults.removeAtIndex(indexPath.row)
                
                let selectedIndex = meals.indexOf({$0.id == idSelected}) //mealList.first
                meals.removeAtIndex(selectedIndex!)
                GlobalVariables.sharedManager.meals.removeAtIndex(selectedIndex!)
                
                tableView.reloadData()
            }
            else{
                meals.removeAtIndex(indexPath.row)
                GlobalVariables.sharedManager.meals.removeAtIndex(indexPath.row)

                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            //Dele from DB
            let filter = "id='\(idSelected)'"
            let mealDB = realm?.objects(MealDB.self).filter(filter)
            
            // Delete an object with a transaction
            try! realm!.write {
                self.realm!.delete(mealDB!)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let mealDetailViewController = segue.destinationViewController as! MealViewController
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? MealTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
        else if segue.identifier == "MapViewSegue"{
            print("Select MapViewSegue.")
        }
    }
    

    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                
            } else {
                // Add a new meal.
                let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
                meals.append(meal)
                
                //Add to Global var
                GlobalVariables.sharedManager.meals.append(meal)
                
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }
    
    // Search Controller
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        mealsSearchResults = meals.filter { candy in
            return candy.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        //Update shared meals
        GlobalVariables.sharedManager.meals.removeAll()
        if searchText != "" {
            GlobalVariables.sharedManager.meals = mealsSearchResults
        }
        else{
            GlobalVariables.sharedManager.meals = meals
        }
        //>>
        
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    
    //>>
}
