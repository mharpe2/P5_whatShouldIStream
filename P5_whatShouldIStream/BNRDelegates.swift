//
//  BNRDelegates.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/5/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import BNRCoreDataStack
import CoreData

//MARK: BNR Delegate

//MARK: TableView Delegate

class MoviesFetchedResultsTableViewControllerDelegate: FetchedResultsControllerDelegate {
    
    private weak var tableView: UITableView?
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func fetchedResultsControllerDidPerformFetch(controller: FetchedResultsController<Movie>) {
        tableView?.reloadData()
    }
    
    func fetchedResultsControllerWillChangeContent(controller: FetchedResultsController<Movie>) {
        tableView?.beginUpdates()
    }
    
    func fetchedResultsControllerDidChangeContent(controller: FetchedResultsController<Movie>) {
        tableView?.endUpdates()
    }
    
    func fetchedResultsController(controller: FetchedResultsController<Movie>,
                                  didChangeObject change: FetchedResultsObjectChange<Movie>) {
        switch change {
        case let .Insert(_, indexPath):
            tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        case let .Delete(_, indexPath):
            tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        case let .Move(_, fromIndexPath, toIndexPath):
            tableView?.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            
        case let .Update(_, indexPath):
            tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func fetchedResultsController(controller: FetchedResultsController<Movie>,
                                  didChangeSection change: FetchedResultsSectionChange<Movie>) {
        switch change {
        case let .Insert(_, index):
            tableView?.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            
        case let .Delete(_, index):
            tableView?.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
        }
    }
}


//MARK: Collection View Delegate

class MoviesFetchedResultsCollectionViewControllerDelegate: FetchedResultsControllerDelegate {
    
    private weak var collectionView: UICollectionView?
    private var blockOperations: [NSBlockOperation] = []
    
    
    // MARK: - Lifecycle
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    //MARK: Deinit
    deinit {
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll(keepCapacity: false)
    }
    
    
    func fetchedResultsControllerDidPerformFetch(controller: FetchedResultsController<Movie>) {
        collectionView?.reloadData()
    }
    
    func fetchedResultsControllerWillChangeContent(controller: FetchedResultsController<Movie>) {
        //collectionView?.beginUpdates()
        //blockOperations.removeAll(keepCapacity: false)
    }
    
    func fetchedResultsControllerDidChangeContent(controller: FetchedResultsController<Movie>) {
        //collectionView?.endUpdates()
        blockOperations.forEach { $0.start() }
        
    }
    
    
    func fetchedResultsController(controller: FetchedResultsController<Movie>,
                                  didChangeObject change: FetchedResultsObjectChange<Movie>) {
    }
    
    func fetchedResultsController(controller: FetchedResultsController<Movie>, didChangeSection change: FetchedResultsSectionChange<Movie>) {
        
        switch change {
            
        case let .Insert(_, index):
            let op = NSBlockOperation { [weak self] in
                self!.collectionView?.insertSections(NSIndexSet(index: index) )
            }
            blockOperations.append(op)
            
            //        case .Insert:
            //            guard let newIndexPath = newIndexPath else { return }
            //            let op = NSBlockOperation { [weak self] in self?.collectionView!.insertItemsAtIndexPaths([newIndexPath]) }
            //            blockOperations.append(op)
            //
            //        case .Update:
            //            guard let newIndexPath = newIndexPath else { return }
            //            let op = NSBlockOperation { [weak self] in self?.collectionView!.reloadItemsAtIndexPaths([newIndexPath]) }
            //            blockOperations.append(op)
            //
            //        case .Move:
            //            guard let indexPath = newIndexPath else { return }
            //            guard let newIndexPath = newIndexPath else { return }
            //            let op = NSBlockOperation { [weak self] in self?.collectionView!.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath) }
            //            blockOperations.append(op)
            //
            //        case .Delete:
            //            guard let indexPath = newIndexPath else { return }
            //            let op = NSBlockOperation { [weak self] in self?.collectionView!.deleteItemsAtIndexPaths([indexPath]) }
            //            blockOperations.append(op)
        default:
            return
        }
    }
}

