//
//  ExploreScrollViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/5/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
import BNRCoreDataStack
import XCGLogger

class ExploreScrollViewController: UIViewController, UITableViewDataSource, EntityMonitorDelegate {
    
    let services = ["Netflix", "Amazon Prime"]
    var movies: [Movie]?
    let log = XCGLogger.defaultInstance()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    var coredataSaveNotification: EntityMonitor<Movie>!
    
    
    // fetchedResultsController
    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
        
        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
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
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        coredataSaveNotification = EntityMonitor<Movie>(context: mainContext(), frequency: .OnChange, filterPredicate: nil)
        coredataSaveNotification.setDelegate(self)
        
        // perform fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error performing fetch")
        }
        if self.fetchedResultsController.fetchedObjects?.count == 0{
            print("no results from fetched results")
        } else {
            print("results > 0")
            movies = self.fetchedResultsController.fetchedObjects
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //        subsribeToCoredataNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return services.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return services[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("streamingServiceRow") as! StreamingServiceRow
        
        //inject movies and navigation controller
        //otherwise cell cannot launch movieDetailView
        cell.fetchedResultsController = fetchedResultsController
        cell.viewController = self
        tableView.reloadData()
        cell.collectionView.reloadData()
        
        return cell.tableViewCell
    }
    
    func entityMonitorObservedInserts(monitor: EntityMonitor<Movie>, entities: Set<Movie>) {
        log.verbose("coredata delegate")
    }
    
    /**
     Callback for when objects matching the predicate have been deleted
     - parameter monitor: The `EntityMonitor` posting the callback
     - parameter entities: The set of deleted matching objects
     */
    func entityMonitorObservedDeletions(monitor: EntityMonitor<Movie>, entities: Set<Movie>)  {
        
        log.verbose("coredata delegate")
    }
    
    /**
     Callback for when objects matching the predicate have been updated
     - parameter monitor: The `EntityMonitor` posting the callback
     - parameter entities: The set of updated matching objects
     */
    func entityMonitorObservedModifications(monitor: EntityMonitor<Movie>, entities: Set<Movie>) {
        log.verbose("coredata delegate")
    }
    
    
    //    func subsribeToCoredataNotification() {
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("coreDataDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: nil)
    //    }
    //
    //    func coreDataDidSave() {
    //        log.info("coreDataDidSave")
    //
    //    }
}

//extension ExploreViewController: EntityMonitorDelegate {
//
//    func entityMonitorObservedInserts(monitor: EntityMonitor<Movie>, entities: Set<Movie>) {
//
//    }
//
//    /**
//     Callback for when objects matching the predicate have been deleted
//     - parameter monitor: The `EntityMonitor` posting the callback
//     - parameter entities: The set of deleted matching objects
//     */
//    func entityMonitorObservedDeletions(monitor: EntityMonitor<Movie>, entities: Set<Movie>)  {
//
//    }
//
//    /**
//     Callback for when objects matching the predicate have been updated
//     - parameter monitor: The `EntityMonitor` posting the callback
//     - parameter entities: The set of updated matching objects
//     */
//    func entityMonitorObservedModifications(monitor: EntityMonitor<Movie>, entities: Set<Movie>) {
//
//    }
//
//}
