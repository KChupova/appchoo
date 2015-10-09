//
//  StatisticsViewController.swift
//  AppChoo
//
//  Created by Kate Chupova on 08.10.15.
//  Copyright © 2015 Kate Chupova. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController, ViewControllerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x,
                y:view.center.y + translation.y)
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            if let view = recognizer.view {
                let velocity = recognizer.velocityInView(self.view)
                if velocity.y > 0 {
                    if (view.center.y < self.view.center.y + 50) {
                        self.animateUpView(view)
                    } else {
                        self.animateDownView(view)
                    }
                } else {
                    if (view.center.y < self.view.center.y + view.frame.size.height - 100) {
                        self.animateUpView(view)
                    } else {
                        self.animateDownView(view)
                    }
                }
            }
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    func animateUpView(view: UIView) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            view.center = self.view.center
        })
    }
    
    func animateDownView(view: UIView) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            view.center = CGPoint.init(x: self.view.center.x, y: self.view.center.y + view.frame.size.height - 50)
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "AhchooViewSegue"{
            let vc = segue.destinationViewController as! ViewController
            vc.delegate = self
        }
    }
    
    // MARK: - ViewController delegate
    
    func expandContainerView() {
        if containerView.center.y > self.view.center.y {
            self.animateUpView(containerView)
        } else {
            self.animateDownView(containerView)
        }
    }
    
}
