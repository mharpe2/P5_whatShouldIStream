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
import ChameleonFramework
import NVActivityIndicatorView
import ImageIO

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
    
{
    
    // segmented control index into coredata group labels
    let topSegment = "top"
    let segment: [String] = ["top", "genres", "goingaway", "upcoming"]
    var selectedListGroup = 0
    var predicate = NSPredicate()
    let log = XCGLogger.defaultInstance()
    var storedOffsets = [Int: CGFloat]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainViewActivityIndicator: UIActivityIndicatorView!
    
    var imageView: UIImageView!
    
    
    //MARK: CoreData ------------------------------------------------------------------
    
    var listFRC: FetchedResultsController<List>!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    lazy var genreContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
    //lazy var  updateWorkerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
    
    lazy var frcDelegate: ListFetchedResultsTableViewControllerDelegate = {
        
        return ListFetchedResultsTableViewControllerDelegate(tableView: self.tableView)
    }()
    
    private func getListFRCWithGroup(name: String) -> FetchedResultsController<List>
    {
        
        let fetchRequest = NSFetchRequest(entityName: List.entityName)
        fetchRequest.predicate = NSPredicate(format: "group = %@", name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        let fetchedResultsController = FetchedResultsController<List>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.mainContext(), sectionNameKeyPath: "index", cacheName: nil)
        //self.tableView.reloadData()
        return fetchedResultsController
        
    }
    
    
    //MARK: LifeCycle -------------------------------------------------------------------
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: There is a concurency error here!!!! The error does not show because coredata debug
        // -com.apple.CoreData.ConcurrencyDebug 1 is not enabled.......
        // * NEED TO FIX
        
        //set delegates
        listFRC = getListFRCWithGroup( segment[selectedListGroup]  )
        
        // load exising lists
        //self.mainContext().performBlockAndWait() {
        self.mainContext().performBlockAndWait() {
            do {
                
                self.listFRC.setDelegate(self.frcDelegate)
                try self.listFRC.performFetch()
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
            } catch _  {
                self.log.error(" Error fetching lists and movies")
            }
            
            self.log.info("Found \(self.listFRC.count) ")
        }
        
        self.mainContext().performBlockAndWait() {
            // check for updated list online
            CoreNetwork.performUpdateInBackround( self.mainContext() )
            self.mainContext().saveContext()
        }
        
    }
    
    
    //MARK: TableView Methods ------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return listFRC.sections?.count ?? 1
        
        if let sections = listFRC.sections , sections.count > 0 {
            return sections[section].objects.count
        } else {
            return 0
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "streamingServiceRow") as? StreamingServiceRow {
            log.verbose("returning cell \(cell.description)"    )
            return cell
        } else {
            log.verbose("returning empty streaming service row" )
            return StreamingServiceRow()
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? StreamingServiceRow else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        log.info("Setting cell to index \(indexPath.section)")
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? StreamingServiceRow else { return }
        
        storedOffsets[indexPath.section] = tableViewCell.collectionViewOffset
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return listFRC.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = listFRC.sections else { return nil }
        return sections[section].objects[0].name ?? nil
    }
    
    // MARK: Segmented Controller
    
    // change segment
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex > segment.count {
            return
        }
        
        let selectedSegment = segment[sender.selectedSegmentIndex]
        listFRC = getListFRCWithGroup( selectedSegment )
        listFRC.setDelegate(frcDelegate)
        do {
            try self.listFRC.performFetch()
        }
        catch _ {
            log.error("switch group to \(selectedSegment)")
        }
        
        
        var rankedGenres: [Genre]? = []
        if selectedSegment == "genres" {
            let fetchRequest = NSFetchRequest(entityName: Genre.entityName)
            fetchRequest.sortDescriptors = []
            
            mainContext().performBlock() {
                do {
                    if let fetchResults = (try? self.mainContext().executeFetchRequest(fetchRequest)) as! [Genre]? {
                        
                        rankedGenres = fetchResults
                        rankedGenres!.sortInPlace({$0.movies!.count > $1.movies!.count})
                        
                        // build an array of images
                        var imageArray: [UIImage] = [UIImage]()
                        //for genre in rankedGenres! {
                        var genre = rankedGenres?.first
                            
                            if let genreMovies = genre!.movies {
                                for movie in genreMovies {
                                    if let myMovie = movie as? Movie {
                                        if var image = myMovie.posterImage{
                                            let thumbnail = self.makeThumbNail(image)
                                            imageArray.append(thumbnail)
                                        }
                                    }
                                }
                            }
                        //} // End for genre in rankedGenres
                        
                        // dispaly image collage
                        let collageImage = CollageImage.collageImage(self.view.frame, images: imageArray)
                        self.imageView = UIImageView(image: collageImage)
                       //self.imageView.contentMode = .TopLeft
                        self.view.addSubview(self.imageView)
                        
                    }
                } catch _ {
                    self.log.error("fuckall")
                }
                
            }
        }
    }
    
    
    func makeThumbNail(image: UIImage) -> UIImage {
    
        let size = image.size.applying(CGAffineTransform(scaleX: 0.25, y: 0.25))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!

    }
    
    // try to create notification class
    
    func notificationSlideUP() {
        let maxX = self.view.frame.maxX
        let maxY = self.view.frame.maxY
        let height = (self.view.frame.height) / 6
        
        var notificationView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0.0, maxY - height, maxX, maxY), type: .SquareSpin, color: UIColor.blueColor() )
        //notificationView.backgroundColor = UIColor.redColor()
        notificationView.startAnimation()
        view.addSubview(notificationView)
        
        //Nvactivity View
        
        //var activityView = NVActivityIndicatorView(frame: CGRectMake(0.0, 0.0, (notificationView.frame.maxX)/4, (notificationView.frame.maxY)))
        
        //        var activityView: NVActivityIndicatorView = NVActivityIndicatorView(frame: notificationView.frame, color: UIColor.flatGreenColorDark() )
        //        activityView.backgroundColor = UIColor.blueColor()
        //        activityView.startAnimation()
        //
        //        notificationView.addSubview(activityView)
        
        delay(5) {
            notificationView.removeFromSuperview()
        }
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            DispatchTime.now(
                dispatch_time_t(DispatchTime.now),
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            DispatchQueue.main,
            closure
        )
    }
    
} // End of class


//MARK: CollectionView Methods ---------------------------------------------------------

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = listFRC.sections {
            return sections.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = listFRC.sections else {
            return 0
        }
        
        log.info("tag: \(collectionView.tag)")
        return sections[collectionView.tag].objects[0].movies.count ?? 0
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //cell.backgroundColor = model[collectionView.tag][indexPath.item]
        
        /* Get cell type */
        let cellReuseIdentifier = "MovieCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! MovieCollectionViewCell
        
        guard let sections = listFRC.sections else {
            return UICollectionViewCell()
        }
        
        let allListsInSection = sections[collectionView.tag].objects
        let movies = allListsInSection[0].movies
        let movie = movies[indexPath.row] as! Movie
        
        // Set cell defaults
        cell.picture!.image = UIImage(named: "filmRole")
        
        
        if let posterPath = movie.posterPath {
            cell.activityIndicator.startAnimating()
            
            if let savedImage = movie.posterImage {
                dispatch_get_main_queue().asynchronously(DispatchQueue.main) {
                    cell.picture!.image = savedImage
                    cell.activityIndicator.stopAnimating()
                }
            } else {
                TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.picture!.image = image
                            movie.posterImage = image
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        print(error)
                        cell.activityIndicator.stopAnimating()
                    }
                }) // end tmbd closure
            }
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        guard let sections = listFRC.sections else {
            return
        }
        
        let allListsInSection = sections[collectionView.tag].objects
        let movies = allListsInSection[0].movies
        let movie = movies[indexPath.row] as! Movie
        
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "AwesomeMovieDetailViewController") as! AwesomMovieDetailViewController
        
        movieDetailViewController.movie = movie
        
        self.present(movieDetailViewController, animated: true) {
            
            // Code
        }
    }
} // End of extension of class

extension ExploreViewController {
    
    func updateListsinBackround() {
        
    }
}
