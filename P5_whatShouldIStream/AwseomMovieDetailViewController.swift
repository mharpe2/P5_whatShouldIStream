//
//  AwseomMovieDetailViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 9/20/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit

class AwesomMovieDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backroundImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overViewText: UITextView!
    
    var movie: Movie?
    let log = XCGLogger.defaultInstance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let movie = movie else {
            return
        }
        
        titleLabel.text = movie.title
        titleLabel.sizeToFit()
        
        overViewText.text = movie.overview
        overViewText.sizeToFit()
        
        
        let formater = NumberFormatter()
        formater.maximumFractionDigits = 1
        if let rating = movie.voteAverage {
            if let vote = formater.string(from: rating) {
                ratingLabel!.text = "\(vote)"
            }
        }
        ratingLabel.sizeToFit()
        
        // sets starting image backround to
        // row poster then downloads larger if need be.
        self.backroundImage.image = movie.posterImage
        
        if let posterPath = movie.posterPath {
            
            if let savedImage = movie.largelPosterImage {
                dispatch_get_main_queue().asynchronously(DispatchQueue.main) {
                    self.backroundImage.image = savedImage
                }
            } else {
                TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.originalPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.backroundImage.image = image
                            movie.largelPosterImage = image
                           
                        }
                    } else {
                        self.log.error("could not download image for \(movie.title)")
                    }
                }) // end tmbd closure
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        log.info("shareButtonTapped")
        let textToShare = "Check this out"
        
        if let id = movie?.id {
        if let myWebsite = NSURL(string: "https://www.themoviedb.org/movie/\(id)") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender as? UIView
            self.present(activityVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func favoriteButtonTapped(sender: AnyObject) {
        log.info("favoriteButtonTapped")
        movie!.onWatchlist = NSNumber(value: true)
        CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext.saveContext()
    }
}
