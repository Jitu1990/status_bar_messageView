//
//  JStausBarMessageView.swift
//  eDuru
//
//  Created by Jitendra Solanki on 4/28/17.
//  Copyright © 2017 Headerlabs. All rights reserved.
//

import UIKit

//MARK:- Constant
let BARVIEW_HEIGHT:CGFloat = 64
let BARVIEW_WIDTH:CGFloat = UIScreen.main.bounds.size.width

class JStausBarMessageView: UIView {

    //MARK:- Private properties
    
    // to set background color of the message label
    private var messageLblBackgroundColor:UIColor = UIColor(red: 226/255.0, green: 151/255.0, blue: 76/255.0, alpha: 0.8){
        didSet{
            self.lblMessage.backgroundColor = self.messageLblBackgroundColor
        }
    }
    
    //to set tintColor of self
    private var barTintColor:UIColor = UIColor(red: 5.0, green: 31, blue: 75, alpha: 1.0){
        
        didSet{
            self.tintColor = self.barTintColor
        }
    }
    
    //to set the textColor of the message label
    private var textColor:UIColor = UIColor.white{
        didSet{
            self.lblMessage.textColor = self.textColor
        }
    }
    
    //MARK:- Properties setter and getter
    var messageBarTintColor:UIColor{
        set{
            self.barTintColor = newValue
        }get{
            
            return self.barTintColor
        }
    }
    
    var messageLabelTextColor:UIColor{
        set{
           self.textColor = newValue
        }get{
            return self.textColor
        }
    }
    
    var messageBackgroundColor:UIColor{
        set{
            self.messageLblBackgroundColor = newValue
        }get{
            return self.messageLblBackgroundColor
        }
    }
    
    
    //MARK:- iVar
    //Message label, to display the message
    lazy var lblMessage:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 226/255.0, green: 151/255.0, blue: 76/255.0, alpha: 0.8)
        return label
    }()
    
    // a timer to auto hide the JStatusBarMessageView after a time interval
    var autoTimer:Timer?
    
    
    //singleton
    static var sharedMessageView:JStausBarMessageView = {
        let instance  = JStausBarMessageView(frame: CGRect(x: 0, y: 0, width: BARVIEW_WIDTH, height: BARVIEW_HEIGHT))
        
        //check for orientation 
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications{
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
       //instance.initalizeView()
        return instance
    }()
    
    
    //MARK:-
    override func didMoveToWindow() {
        //add observer to observe the change in the orientation
        if self.superview != nil{
            NotificationCenter.default.addObserver(self, selector: #selector(didDeviceChangeOrientation), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        }else{
            //remove observer
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        }
    }
    
 
    //MARK:- deviceOrientationDidChange notification
    func didDeviceChangeOrientation(){
        initalizeView()
    }
    
    //MARK: setup view
     private func initalizeView(){
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: BARVIEW_HEIGHT)
        
        self.tintColor = self.tintColor
        
        self.layer.zPosition = CGFloat(FLT_MAX)
        self.backgroundColor = UIColor.clear
        self.isExclusiveTouch = true
        self.isMultipleTouchEnabled = false
        
        //setup lable view 
        self.lblMessage.frame = self.frame
        self.lblMessage.textAlignment = .center
        self.lblMessage.lineBreakMode = .byTruncatingTail
        self.lblMessage.numberOfLines = 2
        if lblMessage.superview == nil{
            self.addSubview(lblMessage)
        }
        
        //add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideStatusBarMessageView))
        self.addGestureRecognizer(tap)
        
    }
    //MARK:- Instacne method

    func hideStatusBarMessageView(){
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { 
            var frame = self.frame
            frame.origin.y -= BARVIEW_HEIGHT
            self.frame = frame
        }) { (finished) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.windowLevel = UIWindowLevelNormal
            
            if self.autoTimer != nil{
                self.autoTimer!.invalidate()
                self.autoTimer = nil
            }
            self.removeFromSuperview()
        }
     }
    
    func statusBarMessageViewWith(message:String, autoHide:Bool, onTouch:(()->Void)?){
        
         initalizeView()
        
        if autoTimer != nil{
            autoTimer!.invalidate()
            autoTimer = nil
        }
        
        self.lblMessage.text = message
        
        var tempFrame = self.frame
        tempFrame.origin.y -= BARVIEW_HEIGHT
        self.frame = tempFrame
        
        if autoHide{
            autoTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(hideStatusBarMessageView), userInfo: nil, repeats: false)
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.windowLevel = UIWindowLevelStatusBar
        appDelegate.window?.addSubview(self)
        
        //show status bar message view
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            var frame = self.frame
            frame.origin.y += BARVIEW_HEIGHT
            self.frame  = frame
        }) { (finished) in
            
        }
        
    }
    
 }
