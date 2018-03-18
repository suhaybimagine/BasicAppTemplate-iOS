//
//  UIKitExtensions.swift
//  IzwetnaApp
//
//  Created by AhmeDroid on 12/13/17.
//  Copyright © 2017 Imagine Technologies. All rights reserved.
//

import UIKit
import QuartzCore

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
    var shadowUIColor: UIColor {
        set {
            self.shadowColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.shadowColor!)
        }
    }
}

extension UIColor {

    convenience init(valueRed red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}

extension String {
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func compressingWhiteSpaces() -> String {
        
        let nString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            
            let regEx = try NSRegularExpression(pattern: "\\s+", options: .allowCommentsAndWhitespace)
            return regEx.stringByReplacingMatches(in: nString,
                                                  options: .reportCompletion,
                                                  range: NSRange(location: 0, length: nString.count),
                                                  withTemplate: " ")
        }catch let error {
            
            print("Error compressing white spaces: \(error.localizedDescription)")
            return nString
        }
    }
}

extension NSAttributedString {
    
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.height
    }
}

extension UIImage {
    
    func imageWithColor(_ color:UIColor) -> UIImage {
        
        let size = self.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext();
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.normal)
        
        let rect = CGRect(x:0.0, y:0.0, width:size.width, height:size.height);
        
        context?.clip(to: rect, mask: self.cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return image;
    }
}


extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class RoundedButton : UIButton {
    
    var borderLayer = CAShapeLayer()
    var corners:UIRectCorner?
    var radii:CGSize?
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat)
    {
        borderLayer.lineWidth = 1.0
        borderLayer.strokeColor = UIColor.clear.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        let radii = CGSize(width: radius, height: radius)
        borderLayer.path = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: radii).cgPath
        
        self.corners = corners
        self.radii = radii
        self.layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.layer.bounds
        
        if let _corners = self.corners,
            let _radii = self.radii {
            borderLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            byRoundingCorners: _corners,
                                            cornerRadii: _radii).cgPath
        }
    }
}

extension UIButton {
    
    func setBackground( _ color:UIColor ) -> Void {
        
        if let blayer = self.layer.sublayers?.first as? CAShapeLayer {
            
            blayer.fillColor = color.cgColor
        } else {
            
            self.backgroundColor = color
        }
    }
    
    func clearBackground() -> Void {
        
        if let blayer = self.layer.sublayers?.first as? CAShapeLayer {
            blayer.fillColor = UIColor.clear.cgColor
        } else {
            self.backgroundColor = nil
        }
    }
    
    func setStroke(color:UIColor, width:CGFloat) -> Void {
        
        if let blayer = self.layer.sublayers?.first as? CAShapeLayer {
            
            blayer.strokeColor = color.cgColor
            blayer.lineWidth = width
        } else {
            
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        }
    }
    
    func clearStroke() -> Void {
        
        if let blayer = self.layer.sublayers?.first as? CAShapeLayer {
            
            blayer.strokeColor = UIColor.clear.cgColor
        } else {
            
            layer.borderWidth = 0.0
            layer.borderColor = nil
        }
    }
}
