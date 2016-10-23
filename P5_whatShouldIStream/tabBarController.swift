//
//  tabBarController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 9/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import ChameleonFramework

class tabBarController: UITabBarController {


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
         dispatch_get_main_queue().asynchronously(DispatchQueue.main) {
        self.view.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: [UIColor.blackColor])
            //self.view.colo
            self.view.setNeedsDisplay()
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

}
