//
//  CategoryRow.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/5/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import CoreData


class StreamingServiceRow: UITableViewCell
{
    // set this in calling view controller
    //var fetchedResultsController: FetchedResultsController<Movie>?
    var viewController: UIViewController?
    @IBOutlet weak var collectionView: UICollectionView!
       
    var movies: [Movie]?
    
    var tableViewCell = UITableViewCell()
   
}

extension StreamingServiceRow: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 4
        let hardCodedPadding: CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
}
