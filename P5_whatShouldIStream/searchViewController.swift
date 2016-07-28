//
//  FindViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import CoreData
import DZNEmptyDataSet

class searchViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchTask: NSURLSessionDataTask!
    var guideboxResults = [GuideBoxSearchResults]()
    var searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    
    // fetchedResultsController
    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
        
        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
        //fetchRequest.predicate = NSPredicate(format: "location == %@", self.selectedLocation)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
                                                                       managedObjectContext: self.mainContext(),
                                                                       sectionNameKeyPath: nil,
                                                                       cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var frcDelegate: MoviesFetchedResultsTableViewControllerDelegate = {
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView )
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchBar = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.searchBar.becomeFirstResponder()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "filmRole")
    }
}


extension searchViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)  {
        
        if let task = searchTask {
            task.cancel()
        }
        
        if searchText == ""  {
            guideboxResults = [GuideBoxSearchResults]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        let resource = GuideBox.Resource.searchByTitle
        let parameters = ["showname": searchText]
        
        searchTask = GuideBox.sharedInstance().taskForResource(resource, parameters: parameters) {
            [unowned self] jsonResult, error in
            
            if let error = error {
                print("Error searching for shows: \(error.localizedDescription)" )
                return
            }
            
            // print(jsonResult)
            
            if let showDictionaries = jsonResult.valueForKey("results") as? [[String: AnyObject]] {
                self.searchTask = nil
                
                // guidebox
                self.guideboxResults = showDictionaries.map() {
                    GuideBoxSearchResults(dictionary: $0)
                } // end guideBoxResults
            } // end showDictionaries
            
            // Reload the table on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView!.reloadData()
            }
            
        } // searchTask
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //searchBar.resignFirstResponder()
    }
    
}


extension searchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellReuseId = "movieSearchResults"
        let movie = guideboxResults[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId)
        {
            configureCell(cell, movie: movie)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guideboxResults.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let movie = guideboxResults[indexPath.row]
        
        //        // Alert the delegate
        //        delegate?.actorPicker(self, didPickActor: movie)
        //
        //        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // All right, this is kind of meager. But its nice to be consistent
    func configureCell(cell: UITableViewCell, movie: GuideBoxSearchResults) {
        cell.textLabel!.text = movie.title
    }
    
}


extension searchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //filterContentForSearchText(searchController.searchBar.text!)
        print("updating search results")
        searchMoviesOnGuideBox(searchBar.text!)
    }
    
    func searchMoviesOnGuideBox(searchText: String) {
        
        let trimmedSearchText = searchText.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if let task = searchTask {
            task.cancel()
        }
        
        if trimmedSearchText == ""  {
            guideboxResults = [GuideBoxSearchResults]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        let resource = GuideBox.Resource.searchByTitle
        let parameters = ["showname": trimmedSearchText]
        
        searchTask = GuideBox.sharedInstance().taskForResource(resource, parameters: parameters) {
            [unowned self] jsonResult, error in
            
            if let error = error {
                print("Error searching for shows: \(error.localizedDescription)" )
                return
            }
            
            // print(jsonResult)
            
            if let showDictionaries = jsonResult.valueForKey("results") as? [[String: AnyObject]] {
                self.searchTask = nil
                
                // guidebox
                self.guideboxResults = showDictionaries.map() {
                    GuideBoxSearchResults(dictionary: $0)
                } // end guideBoxResults
            } // end showDictionaries
            
            // Reload the table on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView!.reloadData()
            }
            
        } // searchTask
    }
}



class GuideBoxSearchResults {
    var guideBoxid: String? = ""
    var theMovieDBId: String? = ""
    var title: String? = ""
    
    init(dictionary: [String: AnyObject]) {
        title = dictionary["title"] as? String
        guideBoxid = dictionary["id"] as? String
        theMovieDBId = dictionary["themoviedb"] as? String
        print("GuideBox: \(title)")
        
    }
}

