//
//  Settings.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/17/16.
//  Copyright © 2016 MJH. All rights reserved.
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?usp=sharing
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?
//https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs/export?format=txt


import UIKit
import CoreImage

struct MasterLists {
    static let filename = "wsis.txt"
    static let googleDriveLocation = "https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs-hseeds/export?format=txt"
}

struct Service {
    static let Netflix = "Netflix"
    static let Amazon = "Amazon Prime"
    
}

//MARK: Extentions


// MARK: Date Extention
// http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift
extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

//MARK: String Extension

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    //https://www.codebeaulieu.com/32/How-to-add-a-character-at-a-particular-index-in-string-in-Swift-2
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    
}

//MARK: UIImage extension
//http://stackoverflow.com/questions/31510330/how-to-efficiently-create-a-multi-row-photo-collage-from-an-array-of-images-in-s

class CollageImage{
    
    class func collageImage (rect: CGRect, images: [UIImage]) -> UIImage {
        
        let maxImagesPerRow = 3
        var maxSide : CGFloat = 0.0
        
        if images.count >= maxImagesPerRow {
            maxSide = max(rect.width / CGFloat(maxImagesPerRow), rect.height / CGFloat(maxImagesPerRow))
        } else {
            maxSide = max(rect.width / CGFloat(images.count), rect.height / CGFloat(images.count))
        }
        
        var index = 0
        var currentRow = 1
        var xtransform:CGFloat = 0.0
        var ytransform:CGFloat = 0.0
        var smallRect:CGRect = CGRectZero
        
        var composite: CIImage? // used to hold the composite of the images
        
        for img in images {
            
            index += 1
            let x = index % maxImagesPerRow //row should change when modulus is 0
            
            //row changes when modulus of counter returns zero @ maxImagesPerRow
            if x == 0 {
                
                //last column of current row
                smallRect = CGRectMake(xtransform, ytransform, maxSide, maxSide)
                
                //reset for new row
                currentRow += 1
                xtransform = 0.0
                ytransform = (maxSide * CGFloat(currentRow - 1))
                
            } else {
                
                //not a new row
                smallRect = CGRectMake(xtransform, ytransform, maxSide, maxSide)
                xtransform += CGFloat(maxSide)
            }
            
            // Note, this section could be done with a single transform and perhaps increase the
            // efficiency a bit, but I wanted it to be explicit.
            //
            // It will also use the CI coordinate system which is bottom up, so you can translate
            // if the order of your collage matters.
            //
            // Also, note that this happens on the GPU, and these translation steps don't happen
            // as they are called... they happen at once when the image is rendered. CIImage can
            // be thought of as a recipe for the final image.
            //
            // Finally, you an use core image filters for this and perhaps make it more efficient.
            // This version relies on the convenience methods for applying transforms, etc, but
            // under the hood they use CIFilters
            var ci = CIImage(image: img)!
            
            ci = ci.applying(CGAffineTransform(scaleX: maxSide / img.size.width, y: maxSide / img.size.height))
            ci = ci.applying(CGAffineTransform(translationX: smallRect.origin.x, y: smallRect.origin.y))
            
            if composite == nil {
                
                composite = ci
                
            } else {
                
                composite = ci.compositingOverImage(composite!)
            }
        }
        
        let cgIntermediate = CIContext(options: nil).createCGImage(composite!, from: composite!.extent)
        let finalRenderedComposite = UIImage(cgImage: cgIntermediate!)
        
        return finalRenderedComposite
    }
    
}
