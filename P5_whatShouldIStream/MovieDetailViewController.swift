//
//  MovieDetailViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/31/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit

class MovieDetailViewController: UITableViewController {
    
    private let kTableviewHeaderHeight: CGFloat = 280.0
    private let kTableHeaderCutAway: CGFloat = 0
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: outlets
    @IBOutlet weak var posterImage: UIImageView!
    
    var movie: Movie?
    
    var navItem = UINavigationItem()
    var backItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: nil, action: #selector(buttonPressed))

    //    let titleItem = UINavigationItem()
    //    var tmdbRating: UILabel?

    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var effectiveHeight: CGFloat {
        return kTableviewHeaderHeight - kTableHeaderCutAway/2
    }

    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var scrollview = UIScrollView()
       // scrollview
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set up header view
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        
        // table header mask layer
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()

        
        
        navItem.leftBarButtonItem = backItem
        navItem.title = movie?.title
        navBar.setItems([navItem], animated: true)
        
        //set movie title & Overview
        //movieTitle.title = movie?.title
        //overview.text = movie?.overview
        //print(overview.text)
        //overview.sizeToFit()

//        //animate ratings on scrollView
//        tmdbRating = UILabel()
//        let formater = NSNumberFormatter()
//        formater.maximumFractionDigits = 1
//        if let rating = movie?.voteAverage {
//            tmdbRating!.text = "TMDB Rating: \(formater.stringFromNumber(rating))"
//            print(tmdbRating?.text)
//            tmdbRating?.center = CGPoint(x: 1, y: 12)
//            ratingsScrollView.addSubview(tmdbRating!)

//            
//            UIView.animateWithDuration( 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
//                self.tmdbRating?.center = CGPoint(x: 1, y: 12)
//                }, completion: nil)
 //       }
        

        //create place holder image
        posterImage!.image = UIImage(named: "filmRole")

        //scrollView.contentSize.height = 1000
        
        
        guard movie != nil else {
            return
        }
        
        if movie?.posterImage != nil {
            //self.posterImage.contentMode = .ScaleAspectFit
            self.posterImage.image = movie?.posterImage
        } else {
            if let posterPath = movie!.posterPath {
                TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.DetailPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.posterImage.image! = image
                        }
                    } else {
                        print(error)
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
//    @IBAction func buttonPressed(sender: AnyObject) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func buttonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: effectiveHeight + kTableHeaderCutAway/2)
        if (tableView.contentOffset.y < -effectiveHeight) {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + kTableHeaderCutAway/2
        }
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height - kTableHeaderCutAway))
        headerMaskLayer?.path = path.CGPath
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieDetailCell") as! MovieDetailCell
        cell.overview.text = movie?.overview
        cell.overview.numberOfLines = 0
        cell.overview.sizeToFit()
        
        
        let formater = NSNumberFormatter()
        formater.maximumFractionDigits = 1
        if let rating = movie?.voteAverage {
            if let vote = formater.stringFromNumber(rating) {
                cell.rating!.text = "TMDB Rating: \(vote)"
            }
        }
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func addToWatchList(sender: AnyObject) {
        if let favoriteMovie = movie {
            print("add to Favorites")
            favoriteMovie.onWatchlist = NSNumber(bool: true)
            CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext.saveContext()
        }
    }
}
