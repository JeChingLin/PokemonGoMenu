//
//  PokemonGoMenu.swift
//  PokemonCalculator
//
//  Created by LinChe-Ching on 2016/7/23.
//  Copyright © 2016年 Che-ching Lin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// MARK: helpers

@warn_unused_result
func Init<Type>(value: Type, @noescape block: (object: Type) -> Void) -> Type {
    block(object: value)
    return value
}

// MARK: Protocol

/**
 *  menuDelegate
 */
@objc public protocol PokemonGoMenuDelegate {
    
    /**
     Tells the delegate the circle menu is about to draw a button for a particular index.
     
     - parameter menu: The circle menu object informing the delegate of this impending event.
     - parameter button:     A circle menu button object that circle menu is going to use when drawing the row. Don't change button.tag
     - parameter atIndex:    An button index.
     */
    optional func menu(menu: PokemonGoMenu, willDisplay button: UIButton, atIndex: Int)
    
    /**
     Tells the delegate that the specified index is now selected.
     
     - parameter menu: A circle menu object informing the delegate about the new index selection.
     - parameter button:     A selected circle menu button. Don't change button.tag
     - parameter atIndex:    Selected button index
     */
    optional func menu(menu: PokemonGoMenu, buttonDidSelected button: UIButton, atIndex: Int)
    
    /**
     Tells the delegate that the menu was collapsed - the cancel action.
     
     - parameter menu: A circle menu object informing the delegate about the new index selection.
     */
    optional func menuCollapsed(menu: PokemonGoMenu)
}

public class PokemonGoMenu: UIButton {

    // MARK: properties
    
    /// Buttons count
    @IBInspectable public var buttonsCount: Int = 4
    /// Circle animation duration
    @IBInspectable public var duration: Double  = 2
    /// Distance between center button and buttons
    @IBInspectable public var distance: Float   = 100
    /// Delay between show buttons
    @IBInspectable public var showDelay: Double = 0
    
    /// The object that acts as the delegate of the circle menu.
    @IBOutlet weak public var delegate: AnyObject?
    
    public var parentView:UIView? {
        didSet {
            if parentView != nil {
                blurView.frame = UIScreen.mainScreen().bounds
                parentView!.addSubview(blurView)
                parentView!.bringSubviewToFront(self)
                blurView.hidden = true
            }
        }
    }
    
    var buttons: [UIButton]?
    let buutonNames:[String] = ["Game","chalk_bag","Pokemon","shopping_bag"]
    
    private var customNormalIconView: UIImageView!
    private var customSelectedIconView: UIImageView!
    
    let blurView = UIVisualEffectView.init(effect: UIBlurEffect(style: .Light))
    
    public init(frame: CGRect, normalIcon: String?, selectedIcon: String?, buttonsCount: Int = 3, duration: Double = 2,
                distance: Float = 100) {
        super.init(frame: frame)
        
        if let icon = normalIcon {
            setImage(UIImage(named: icon), forState: .Normal)
        }
        
        if let icon = selectedIcon {
            setImage(UIImage(named: icon), forState: .Selected)
        }
        
        self.buttonsCount = buttonsCount
        self.duration     = duration
        self.distance     = distance
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        addActions()
        customNormalIconView = addCustomImageView(state: .Normal)
        
        customSelectedIconView = addCustomImageView(state: .Selected)
        if customSelectedIconView != nil {
            customSelectedIconView.alpha = 0
        }
        setImage(UIImage(named: "pokemonball"), forState: .Normal)
        setImage(UIImage(named: "close"), forState: .Selected)
    }

    
    // MARK: configure
    private func addActions() {
        self.addTarget(self, action: #selector(PokemonGoMenu.onTap), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: actions
    func onTap() {
        if buttonsIsShown() == false {
            buttons = createButtons()
        }
        let isShow = !buttonsIsShown()
        let duration  = isShow ? 0.6 : 0.3
        buttonsAnimationIsShow(isShow: isShow, duration: duration)
        tapBounceAnimation()
        tapRotatedAnimation(0.3, isSelected: isShow)
    }
    
    func buttonHandler(sender: UIButton) {
        guard case let sender as PokemonGoMenuButton = sender else {
            return
        }
        
        if buttons != nil {
            
            if customNormalIconView != nil && customSelectedIconView != nil {
                let dispatchTime: dispatch_time_t = dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(0 * Double(NSEC_PER_SEC)))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.delegate?.menu?(self, buttonDidSelected: sender, atIndex: sender.tag)
                })
            }
        }
    }
    
    // MARK: methods
    public func hideButtons(duration: Double, hideDelay: Double = 0) {
        if buttons == nil {
            return
        }
        
        buttonsAnimationIsShow(isShow: false, duration: duration, hideDelay: hideDelay)
        
        tapBounceAnimation()
        tapRotatedAnimation(0.3, isSelected: false)
    }
    /**
     Check is sub buttons showed
     */
    public func buttonsIsShown() -> Bool {
        guard let buttons = self.buttons else {
            return false
        }
        
        for button in buttons {
            if button.alpha == 0 {
                return false
            }
        }
        return true
    }
    
    // MARK: create
    private func createButtons() -> [UIButton] {
        var buttons = [UIButton]()
        for index in 0..<self.buttonsCount {
            var angle: Float = 0
            switch index {
            case 0:
                angle = 0
                break
            case 1:
                angle = 63
                break
            case 2:
                angle = 297
                break
            case 3:
                angle = 0
                break
            default:
                break
            }
            let distance = Float(self.bounds.size.height/2.0)
            let button = Init(PokemonGoMenuButton(size: self.bounds.size, menu: self, distance:distance, angle: angle)) {
                $0.setImage(UIImage(named: self.buutonNames[index]), forState: .Normal)
                $0.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
                $0.contentMode = UIViewContentMode.ScaleAspectFit
                $0.tag = index
                $0.addTarget(self, action: #selector(PokemonGoMenu.buttonHandler(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                $0.alpha = 0
            }
            buttons.append(button)
        }
        return buttons
    }
    
    private func addCustomImageView(state state: UIControlState) -> UIImageView? {
        guard let image = imageForState(state) else {
            return nil
        }
        
        let iconView = Init(UIImageView(image: image)) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode                               = .Center
            $0.userInteractionEnabled                    = false
        }
        addSubview(iconView)
        
        // added constraints
        iconView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .Height, multiplier: 1, constant: bounds.size.height))
        
        iconView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .Width, multiplier: 1, constant: bounds.size.width))
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: iconView,
            attribute: .CenterX, multiplier: 1, constant:0))
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: iconView,
            attribute: .CenterY, multiplier: 1, constant:0))
        
        return iconView
    }
    
    // MARK: animations
    private func buttonsAnimationIsShow(isShow isShow: Bool, duration: Double, hideDelay: Double = 0) {
        guard let buttons = self.buttons else {
            return
        }
        
        for index in 0..<self.buttonsCount {
            guard case let button as PokemonGoMenuButton = buttons[index] else { continue }
            var angle: Float = 0
            var _distance: Float = 0
            switch index {
            case 0:
                angle = 0
                _distance = 356
                break
            case 1:
                angle = 63
                _distance = 161
                break
            case 2:
                angle = 297
                _distance = 161
                break
            case 3:
                angle = 0
                _distance = 204
                break
            default:
                break
            }
            if isShow == true {
                delegate?.menu!(self, willDisplay: button, atIndex: index)
                blurView.hidden = false
                button.rotatedZ(angle: angle, animated: false, delay: Double(index) * showDelay)
                button.showAnimation(distance: _distance, duration: duration, delay: Double(index) * showDelay)
            } else {
                button.hideAnimation(
                    distance: -_distance,
                    duration: duration, delay: hideDelay)
            }
        }
        if isShow == false { // hide buttons and remove
            UIView.animateWithDuration(0.4, animations: {
                self.blurView.alpha = 0.0;
                }, completion: {
                    finished in
                    self.blurView.hidden = true
            })
            self.buttons = nil
            self.delegate?.menuCollapsed!(self)
        }
        else{
            blurView.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.blurView.alpha = 1.0;
            })
        }
    }
    
    private func tapBounceAnimation() {
        self.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5,
                                   options: UIViewAnimationOptions.CurveLinear,
                                   animations: { () -> Void in
                                    self.transform = CGAffineTransformMakeScale(1, 1)
            },
                                   completion: nil)
    }
    
    private func tapRotatedAnimation(duration: Float, isSelected: Bool) {
        
        let addAnimations: (view: UIImageView, isShow: Bool) -> () = { (view, isShow) in
            var fromOpacity      = 1
            var toOpacity        = 0
            if isShow == true {
                fromOpacity = 0
                toOpacity   = 1
            }
            
            let fade = Init(CABasicAnimation(keyPath: "opacity")) {
                $0.duration            = NSTimeInterval(duration)
                $0.fromValue           = fromOpacity
                $0.toValue             = toOpacity
                $0.timingFunction      = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                $0.fillMode            = kCAFillModeForwards
                $0.removedOnCompletion = false
            }
            view.layer.addAnimation(fade, forKey: nil)
        }
        
        if customNormalIconView != nil && customSelectedIconView != nil {
            addAnimations(view: customNormalIconView, isShow: !isSelected)
            addAnimations(view: customSelectedIconView, isShow: isSelected)
        }
        selected = isSelected
        self.alpha = 1
    }

    private func hideCenterButton(duration duration: Double, delay: Double = 0) {
        UIView.animateWithDuration( NSTimeInterval(duration), delay: NSTimeInterval(delay),
                                    options: UIViewAnimationOptions.CurveEaseOut,
                                    animations: { () -> Void in
                                        self.transform = CGAffineTransformMakeScale(0.001, 0.001)
            }, completion: nil)
    }
    
    private func showCenterButton(duration duration: Float, delay: Double) {
        UIView.animateWithDuration( NSTimeInterval(duration), delay: NSTimeInterval(delay), usingSpringWithDamping: 0.78,
                                    initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear,
                                    animations: { () -> Void in
                                        self.transform = CGAffineTransformMakeScale(1, 1)
                                        self.alpha     = 1
            },
                                    completion: nil)
        
        let rotation = Init(CASpringAnimation(keyPath: "transform.rotation")) {
            $0.duration        = NSTimeInterval(1.5)
            $0.toValue         = (0)
            $0.fromValue       = (Float(-180).degrees)
            $0.damping         = 10
            $0.initialVelocity = 0
            $0.beginTime       = CACurrentMediaTime() + delay
        }
        let fade = Init(CABasicAnimation(keyPath: "opacity")) {
            $0.duration            = NSTimeInterval(0.01)
            $0.toValue             = 0
            $0.timingFunction      = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            $0.fillMode            = kCAFillModeForwards
            $0.removedOnCompletion = false
            $0.beginTime           = CACurrentMediaTime() + delay
        }
        let show = Init(CABasicAnimation(keyPath: "opacity")) {
            $0.duration            = NSTimeInterval(duration)
            $0.toValue             = 1
            $0.timingFunction      = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            $0.fillMode            = kCAFillModeForwards
            $0.removedOnCompletion = false
            $0.beginTime           = CACurrentMediaTime() + delay
        }
        
        if customNormalIconView != nil {
            customNormalIconView.layer.addAnimation(rotation, forKey: nil)
            customNormalIconView.layer.addAnimation(show, forKey: nil)
        }
        
        if customSelectedIconView != nil {
            customSelectedIconView.layer.addAnimation(fade, forKey: nil)
        }
    }

}

// MARK: extension

internal extension Float {
    var radians: Float {
        return self * (Float(180) / Float(M_PI))
    }
    
    var degrees: Float {
        return self  * Float(M_PI) / 180.0
    }
}

internal extension UIView {
    
    var angleZ: Float {
        let radians: Float = atan2(Float(self.transform.b), Float(self.transform.a))
        return radians.radians
    }
}
