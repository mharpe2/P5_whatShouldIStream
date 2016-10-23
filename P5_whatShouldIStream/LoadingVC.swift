//
//  LoadingVC.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 8/21/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ChameleonFramework


class LoadingVC: UIViewController {

   let log = XCGLogger.defaultInstance()
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    
    var myView: NVActivityIndicatorView!
    var frame = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log.info("** LoadingVC running")
        
        frame = CGRectMake(self.view.center.x, self.view.center.y, 125.0, 125.0)
        myView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.Pacman) //type: NVActivityIndicatorType.Pacman)
        
        let label = UILabel(frame: frame)
        label.text = "Loading"
        label.sizeToFit()
        label.textColor = UIColor.white
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y
        
        
        self.view.addSubview(label)
        self.view.addSubview(myView)
        loadingView.startAnimation()
        
        
               
        // Do any additional setup after loading the view.
        
        
        print("is the backround changed??")
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
