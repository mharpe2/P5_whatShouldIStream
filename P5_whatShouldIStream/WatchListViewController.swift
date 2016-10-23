//
//  WatchListViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import CoreData

class WatchListViewController: UIViewController {
    
    let log = XCGLogger.defaultInstance()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Coredata -----------------------------------------------------------
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    // fetchedResultsController
    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
        
        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
        fetchRequest.predicate = NSPredicate(format: "onWatchlist == %@", true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
                                                                       managedObjectContext: self.mainContext(),
                                                                       sectionNameKeyPath: nil,
                                                                       cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var frcDelegate: MoviesFetchedResultsCollectionControllerDelegate = {
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.collectionView )
    }()
    
    //MARK: Life Cycle ---------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedResultsController.setDelegate(self.frcDelegate)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // perform fetch
        
        mainContext().performBlockAndWait() {
            //dispatch_async(dispatch_get_main_queue()) {
            do {
                
                try self.fetchedResultsController.performFetch()
                
                //self.tableView.delegate = self
                //self.tableView.dataSource = self
                
            } catch let error as NSError {
                print("Error performing fetch")
            }
            if self.fetchedResultsController.fetchedObjects?.count == 0{
                print("no results from fetched results")
            } else {
                self.log.info("Count: \(self.fetchedResultsController.fetchedObjects?.count)")
                dispatch_async(dispatch_get_main_queue() ) {
                    self.collectionView.reloadData()
                }
                
            }
        } // end performblockandwait
        
        
        dispatch_get_main_queue().asynchronously(DispatchQueue.main) {
            self.collectionView.reloadData()
        }
    }
    
    
}


extenstion WatchlistViewController UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colCell", forIndexPath: indexPath) as! MemeCollectionCell
        let meme = memes[indexPath.row]
        
        // Setup cell
        cell.memedImage.contentMode = .ScaleAspectFit
        cell.memedImage.image = meme.memeImage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath)
    {
        
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("memeDetailView") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        detailController.memeIndex = indexPath.row
        
        navigationController!.pushViewController(detailController, animated: true)
        
    }
}
