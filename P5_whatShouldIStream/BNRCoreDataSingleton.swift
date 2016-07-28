//
//  BNRCoreDataSingleton.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/2/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData
import BNRCoreDataStack


class CoreDataStackManager {
    
    var coreDataStack: CoreDataStack?
    
    //Singleton
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
    }



}
