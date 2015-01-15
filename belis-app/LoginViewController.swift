//
//  ViewController.swift
//  BelIS
//
//  Created by Thorsten Hell on 01/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit
import QuartzCore


class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground();
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
       
    }
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setBackground();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setBackground() {
//        var background:CAGradientLayer = CAGradientLayer();
//        background.frame = view.bounds
//        let cor1 = UIColor.blackColor().CGColor
//        let cor2 = UIColor.whiteColor().CGColor
//        let arrayColors = [cor1, cor2]
//        background.colors = arrayColors
//        view.layer.insertSublayer(background, atIndex: 0)
//        println(view.layer.sublayers)
    }

    @IBAction func loginButtonTabbed(sender: AnyObject) {
        let mainView = self.storyboard?.instantiateViewControllerWithIdentifier("mainView") as MainViewController;
        self.presentViewController(mainView, animated: true, completion: {} );
        
    }
}

