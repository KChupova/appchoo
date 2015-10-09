//
//  ViewController.swift
//  AppChoo
//
//  Created by Kate Chupova on 01.10.15.
//  Copyright (c) 2015 Kate Chupova. All rights reserved.
//

import UIKit
import CoreData

protocol ViewControllerDelegate {
    func expandContainerView()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var ahchooView : UIView!
    @IBOutlet weak var ahchooLabel : UILabel!
    
    var delegate :ViewControllerDelegate?
    
    var ahchoos = [NSManagedObject]()
    var user : User!
    
    @IBAction func expandAction(_: AnyObject) {
        delegate?.expandContainerView()
    }
    
    func addAhchoo () {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Ahchoo", inManagedObjectContext: managedContext)
        let ahchoo = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext) as! Ahchoo
        
        ahchoo.date = NSDate()
        ahchoo.intensity = 0.5
        
        ahchoos.append(ahchoo)
        
        user.ahchoos = NSOrderedSet.init(array: ahchoos)
        
        do {
            try managedContext.save()
        } catch {
            print("Error while saving data")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ahchooView.layer.cornerRadius = ahchooView.frame.size.width / 2
        ahchooView.userInteractionEnabled = true
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(blurView, atIndex: 0)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Height, relatedBy: .Equal, toItem: view,
            attribute: .Height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Width, relatedBy: .Equal, toItem: view,
            attribute: .Width, multiplier: 1, constant: 0))
        
        self.view.addConstraints(constraints)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"User")
        
        var fetchedResults = [User]()
        
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            if fetchedResults.count > 0 {
                user = fetchedResults.first!
                ahchoos = user.ahchoos.array as! [Ahchoo]
            } else {
                user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: managedContext) as! User
                
                user.firstName = "Me"
               // user.isOwner = true
                
                do {
                    try managedContext.save()
                } catch {
                    print("Error while saving new User")
                }
                
            }
        } catch {
            print("Error while fetching data")
        }
        
    }
    
    // MARK: - animations
    
    func randomPointOnCircle(radius:Float, center:CGPoint) -> CGPoint {
        let theta = Float(arc4random_uniform(UInt32.max))/Float(UInt32.max) * Float(M_PI) * 2.0
        let x = radius * cosf(theta)
        let y = radius * sinf(theta)
        return CGPointMake(CGFloat(x)+center.x,CGFloat(y)+center.y)
    }
    
    var ahchooViewFrame : CGRect!
    
    func endAhchooAnimation() {
        if let oldFrame = ahchooViewFrame {
            let newScale = (ahchooView.layer.presentationLayer()?.frame.size.width)! / oldFrame.width
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = newScale
            scale.toValue = 1
            scale.duration = 0.1
            self.ahchooView.layer.addAnimation(scale, forKey: "scale")
            self.ahchooView.layer.removeAnimationForKey("position")
            self.movingTimer.invalidate()
            let redScreen = CABasicAnimation(keyPath: "backgroundColor");
            redScreen.fromValue = ahchooView.layer.backgroundColor as? AnyObject
            redScreen.toValue = UIColor.clearColor().CGColor as AnyObject
            redScreen.duration = 1
            redScreen.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.view.layer.addAnimation(redScreen, forKey:"redScreen")
            
        }
    }
    
    var ahchooCenter : CGPoint!
    var movingTimer : NSTimer!

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInView(self.view)
        
        if CGRectContainsPoint(self.ahchooView.frame, touchLocation) {
            
            ahchooViewFrame = ahchooView.frame
            ahchooCenter = ahchooView.center
            
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 1
            scale.toValue = 1.5
            scale.duration = 2
            scale.removedOnCompletion = false
            scale.fillMode = kCAFillModeForwards
            self.ahchooView.layer.addAnimation(scale, forKey: "scale")
            
            incrementer = Float(0)
            firstPoint = self.randomPointOnCircle(3, center: ahchooCenter)
            self.startMovingAnimation()
            movingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "startMovingAnimation", userInfo: nil, repeats: true)
        }
    }
    
    var firstPoint = CGPoint.init(x: 0, y: 0)
    var incrementer = Float(0)
    
    func startMovingAnimation() {
        
        incrementer += Float(1)
        
        if incrementer > 10 {
            movingTimer.invalidate()
            return
        }
        
        self.ahchooView.layer.removeAnimationForKey("position")
        
        let move = CABasicAnimation(keyPath: "position")
        move.fromValue = NSValue.init(CGPoint: ahchooCenter)
        let point = CGPoint.init(x: firstPoint.x + CGFloat(incrementer), y: firstPoint.y + CGFloat(incrementer))
        move.toValue = NSValue.init(CGPoint: point)
        move.repeatCount = MAXFLOAT
        move.duration = 0.1
        move.autoreverses = true
        self.ahchooView.layer.addAnimation(move, forKey:"position")
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInView(self.view)
        
        if CGRectContainsPoint(self.ahchooView.frame, touchLocation) {
            self.endAhchooAnimation()
            self.addAhchoo()
        }
    }
    
}

