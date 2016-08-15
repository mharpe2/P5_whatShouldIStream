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

class ExploreScrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    let services = ["Netflix", "Amazon Prime"]
    var movies: [Movie]?
    let log = XCGLogger.defaultInstance()
    var storedOffsets = [Int: CGFloat]()
    @IBOutlet weak var tableView: UITableView!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
  
    // fetchedResultsController
    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
        
        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "service", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
                                                                       managedObjectContext: self.mainContext(),
                                                                       sectionNameKeyPath: nil,cacheName: nil)
        
        return fetchedResultsController
    }()
    
    lazy var frcDelegate: MoviesFetchedResultsTableViewControllerDelegate = {
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
       
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?.count ?? 0
        //.sections?[section].objects.count ?? 0
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("streamingServiceRow") as? StreamingServiceRow {
            log.verbose("returning cell \(cell.description)"    )
            return cell
        } else {
            log.verbose("returning empty streaming service row" )
            return StreamingServiceRow()
    }
    
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? StreamingServiceRow else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? StreamingServiceRow else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }

   
}


extension ExploreScrollViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print("in numberOfSectionsInCollectionView()")
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.objects.count
        
        //return (fetchedResultsController.sections?[collectionView.tag].objects.count) ?? 0
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "MovieCollectionViewCell"
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! MovieCollectionViewCell
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return cell
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        
        /* Set cell defaults */
        cell.picture!.image = UIImage(named: "filmRole")
        
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
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
    
   }

extension ExploreScrollViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
            //default:
            //break
        }
    }
    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        
//        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
//        
//        collectionView.performBatchUpdates({() -> Void in
//            
//            for indexPath in self.insertedIndexPaths {
//                self.collectionView.insertItemsAtIndexPaths([indexPath])
//            }
//            
//            for indexPath in self.deletedIndexPaths {
//                self.collectionView.deleteItemsAtIndexPaths([indexPath])
//            }
//            
//            for indexPath in self.updatedIndexPaths {
//                self.collectionView.reloadItemsAtIndexPaths([indexPath])
//            }
//            
//            }, completion: nil)
//    }

    
}
