//
//  PokemonGoMenuButton.swift
//  PokemonCalculator
//
//  Created by LinChe-Ching on 2016/7/23.
//  Copyright © 2016年 Che-ching Lin. All rights reserved.
//

import UIKit

internal class PokemonGoMenuButton: UIButton {

    internal weak var container: UIView?
    var backgroundView: UIView = UIView()
    
    // MARK: life cycle
    init(size: CGSize, menu: PokemonGoMenu, distance: Float, angle: Float = 0) {
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let color = UIColor.init(colorLiteralRed:36.0/255.0, green: 133.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = size.height / 2.0
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = color.CGColor
        let aContainer = createContainer(CGSize(width: size.width, height:CGFloat(distance)), menu: menu)

        // hack view for rotate
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(self)
        aContainer.addSubview(view)
        
        backgroundView = UIView(frame: CGRect(x: -4, y: -4, width: self.bounds.width + 8,height: self.bounds.height + 8))
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height/2.0
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
        backgroundView.layer.borderWidth = 2.0
        backgroundView.alpha = 0.7
        aContainer.insertSubview(backgroundView, atIndex: 0)
        
        container = aContainer
        view.layer.transform = CATransform3DMakeRotation(-CGFloat(angle.degrees), 0, 0, 1)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: configure
    
    private func createContainer(size: CGSize, menu: PokemonGoMenu) -> UIView {
        
        guard let menuSuperView = menu.superview else {
            fatalError("wront circle menu")
        }
        
        let container = Init(UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))) {
            $0.backgroundColor                           = UIColor.clearColor()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.anchorPoint                         = CGPoint(x: 0.5, y: 1)
        }
        menuSuperView.insertSubview(container, belowSubview: menu)
        
        // added constraints
        let height = NSLayoutConstraint(item: container,
                                        attribute: .Height,
                                        relatedBy: .Equal,
                                        toItem: nil,
                                        attribute: .Height,
                                        multiplier: 1,
                                        constant: size.height)
        height.identifier = "height"
        container.addConstraint(height)
        
        let ne_height = NSLayoutConstraint(item: container,
                                           attribute: .Height,
                                           relatedBy: .Equal,
                                           toItem: nil,
                                           attribute: .Height,
                                           multiplier: 1,
                                           constant: size.height)
        ne_height.identifier = "-height"
        container.addConstraint(ne_height)
        
        container.addConstraint(NSLayoutConstraint(item: container,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Width,
            multiplier: 1,
            constant: size.width))
        
        menuSuperView.addConstraint(NSLayoutConstraint(item: menu,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: container,
            attribute: .CenterX,
            multiplier: 1,
            constant:0))
        
        menuSuperView.addConstraint(NSLayoutConstraint(item: menu,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: container,
            attribute: .CenterY,
            multiplier: 1,
            constant:0))
        
        return container
    }
    
    // MARK: methods
    internal func rotatedZ(angle angle: Float, animated: Bool, duration: Double = 0, delay: Double = 0) {
        guard let container = self.container else {
            fatalError("contaner don't create")
        }
        
        let rotateTransform = CATransform3DMakeRotation(CGFloat(angle.degrees), 0, 0, 1)
        if animated {
            UIView.animateWithDuration(
                duration,
                delay: delay,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    container.layer.transform = rotateTransform
                },
                completion: nil)
        } else {
            container.layer.transform = rotateTransform
        }
    }
}

// MARK: Animations

internal extension PokemonGoMenuButton {
    
    internal func showAnimation(distance distance: Float, duration: Double, delay: Double = 0) {
        
        guard let container = self.container else {
            fatalError()
        }
        
        let heightConstraint = self.container?.constraints.filter {$0.identifier == "height"}.first
        let ne_heightConstraint = self.container?.constraints.filter {$0.identifier == "-height"}.first
        
        guard heightConstraint != nil else {
            return
        }
        self.transform = CGAffineTransformMakeScale(0, 0)
        self.container?.layoutIfNeeded()
        
        self.alpha = 0
        heightConstraint?.active = true
        ne_heightConstraint?.active = false
        heightConstraint?.constant = CGFloat(distance)
        ne_heightConstraint?.constant = CGFloat(-distance)
        UIView.animateWithDuration(
            duration,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                container.layoutIfNeeded()
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.backgroundView.alpha = 1
                self.alpha = 1
            }, completion: { (success) -> Void in
        })
    }
    
    internal func hideAnimation(distance distance: Float, duration: Double, delay: Double = 0) {
        
        guard let container = self.container else {
            fatalError()
        }
        
        let heightConstraint = self.container?.constraints.filter {$0.identifier == "height"}.first
        let ne_heightConstraint = self.container?.constraints.filter {$0.identifier == "-height"}.first
        
        guard heightConstraint != nil else {
            return
        }
        heightConstraint?.active = false
        ne_heightConstraint?.active = true
        backgroundView.alpha = 0
        UIView.animateWithDuration(
            duration,
            delay: delay,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                container.layoutIfNeeded()
                self.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: { (success) -> Void in
                self.alpha = 0
                if let _ = self.container {
                    container.removeFromSuperview() // remove container
                }
        })
    }
}

