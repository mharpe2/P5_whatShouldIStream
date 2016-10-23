//
//  FirstViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import CoreData

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var exploreTableView: UITableView!
    
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
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.exploreTableView )
    }()
    
    
    var listId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //TODO: perform fetch
        // Setup Delegates
        self.fetchedResultsController.setDelegate(self.frcDelegate)
        self.exploreTableView.delegate = self
        self.exploreTableView.dataSource = self
        
        let workerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
        workerContext.performBlock() {
        TheMovieDB.sharedInstance().getGenres(TheMovieDB.Resources.MovieGenreList) { result, error in
            if result != nil {
                for (key, value) in result! {
                    _ = Genre(id: key, name: value, context: self.mainContext() )
                }
            }
        }
            workerContext.saveContext()
        }
            
       
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
        }


        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
    
    }

} // End of class - ExploreViewController



extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "MovieTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! MovieTableViewCell!
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return cell
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        
        /* Set cell defaults */
        cell.picture!.image = UIImage(named: "filmRole")
        cell.title!.text = movie.title
        //cell.picture!.contentMode = UIViewContentMode.ScaleAspectFit
        
        if let posterPath = movie.posterPath {
           TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.picture!.image = image
                    }
                } else {
                    print(error)
                }
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].objects.count ?? 0

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        
        let movieDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        
        movieDetailViewController.movie = movie
        
        //self.show
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        //self.presentViewController(movieDetailViewController, animated: true) {
            
            // Code
        }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

}



