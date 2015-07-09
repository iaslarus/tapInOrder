//
//  ViewController.swift
//  TapInOrder
//
//  Created by School on 6/26/15.
//  Copyright (c) 2015 sunspot. All rights reserved.
//

import UIKit

import Darwin

class ViewController: UIViewController {
    
    var buttonState = [Bool]()
    var buttonList = [UIButton]()
    //var places:[(Int,Int)] = [(100, 200), (450, 250), (350, 450), (600, 400), (800, 150), (700, 600), (850, 500), (200, 300), (100, 550), (300, 600)]
        var places:[(Int,Int)] = [(100, 200), (450, 250), (350, 450), (600, 400)]
    var order = [Int]()
    var numplaces = 0
    var currpressed = 0
    var numRepeats = 0
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func Reset(sender: AnyObject) {
        
        println("in reset")
        
        numplaces = 0
        numRepeats = 0
        
        randomizeOrder()
        drawsequence()
        currpressed = 0
        
    }
    
    func enableButtons() {
        for (index, i) in enumerate(order) {
             buttonList[index].addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
   
    func disableButtons() {
        for (index, i) in enumerate(order) {
            buttonList[index].removeTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    
    func randomizeOrder() {
        
        println("randomizing order")
        
        order = [Int]()
        numplaces = 0
        
        var array = [Int]()
        for i in 0...places.count-1 {
            array.append(i)
        }
        
        for var k=places.count-1; k>=0; --k{
            var random = Int(arc4random_uniform(UInt32(k)))
            order.append(array[random])
            array.removeAtIndex(random)
        }
        
        println("order is \(order)")
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        randomizeOrder()
        
        
        for (index, i) in enumerate(order) {
            let(a,b) = places[i]
            
            var x : CGFloat = CGFloat(a)
            var y : CGFloat = CGFloat(b)
            
            let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            buttonList.append(button)
            button.frame = CGRectMake(x, y, 50, 50)
            button.backgroundColor = UIColor.redColor()
            self.view.addSubview(button)
            
            println("do stuff")
            
            buttonState.append(false)
            
        }
        
        drawsequence()
    }
    
    
    func drawsequence() {
        
        println("drawing sequence")
        
        for (index, i) in enumerate(order) {
            if index <= numplaces {
                println("Setting \(index) to button \(i)")
                
                var delayTime:Double = Double(2+(2*index))
                
                delay(delayTime){
                    self.buttonList[index].backgroundColor = UIColor.greenColor()
                }
                delay(delayTime+2){
                    self.buttonList[index].backgroundColor = UIColor.redColor()
                    println("Drawing \(index)")
                }
                
            }
        }
        
        delay(2*Double(order.count)) {
            self.enableButtons()
        }

    }
    
    func selectionDone(n:Int, status:Bool) {
        disableButtons()
        
        println("selection done")
        
        if status == false {
            
            if numRepeats < 2 {
                repeat()
            }
            else{
                
                resultLabel.text = "Spatial span is \(numplaces)"
                
            }
            
        } else {
            //println("nump=\(numplaces) blc=\(buttonList.count)")
            
            if numplaces < buttonList.count-1{
                next()
            } else {
                resultLabel.text = "Spatial span is \(numplaces)"
            }
            
        }
        
        println("Done in \(n)! \(status)")
    }
    
    func repeat(){
        for (index, i) in enumerate(order) {
            buttonList[index].backgroundColor = UIColor.lightGrayColor()
        }
        
        delay(1.1) {
            for (index, i) in enumerate(self.order) {
                self.buttonList[index].backgroundColor = UIColor.lightGrayColor()
            }
        }
        
        delay(10) {
            println("in repeat")
            for (index, i) in enumerate(self.order) {
                self.buttonList[index].backgroundColor = UIColor.redColor()
            }
        }
        delay(15) {
            self.currpressed = 0
            self.numRepeats += 1
            self.drawsequence()
        }
        
        
    }
    
    func next(){
        delay(1) {
            println("next")
            self.numRepeats = 0
            self.numplaces = self.numplaces + 1
            self.currpressed = 0
            self.drawsequence()
        }
        
    }
    
    func buttonAction(sender:UIButton!)
    {
        println("Button tapped")
        for i in 0...buttonList.count-1 {
            if sender == buttonList[i] {
                println("In button \(i)")
                
                sender.backgroundColor = UIColor.blackColor()
                
                delay(1) {
                    sender.backgroundColor = UIColor.redColor()
                }
                
                if i != currpressed {
                    println("BA: Problem \(i) is not \(currpressed)")
                    selectionDone(i, status:false)
                    return
                }
                else if currpressed == numplaces {
                    println("BA: at end of list cp=\(currpressed) i=\(i) - all OK")
                    selectionDone(i, status:true)
                    return
                }
                println("BA: \(i) is good")
                
                currpressed = currpressed + 1
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }    /*
    func drawBox(size:CGSize) -> UIImage {
    
    let bounds = CGRect(origin: CGPoint.zeroPoint, size: size)
    let opaque = false
    let scale: CGFloat = 0
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
    let context = UIGraphicsGetCurrentContext()
    
    // Setup complete, do drawing here
    CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
    //CGContextSetLineWidth(context, 2.0)
    
    CGContextFillRect(context, bounds)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
    
    
    }
    */
    
    let delayconst = 5.0
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)/delayconst)), dispatch_get_main_queue(), closure)
        
        
    }
    
}