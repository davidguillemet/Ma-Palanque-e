//
//  IconHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 25/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

enum IconValue: String
{
    case IconMenu = "\u{e636}"
    case IconUniversity = "\u{e60f}"
    case IconPlane = "\u{e625}"
    case IconPlus = "\u{e623}"
    case IconDone = "\u{e66c}"
    case IconSave = "\u{e65f}"
    case IconClose = "\u{e681}"
    case IconTrash = "\u{e609}"
    case IconUnlocked = "\u{e607}"
    case IconLocked = "\u{e63f}"
    case IconRibbon = "\u{e61a}"
    case IconClose2 = "\u{e680}"
}

class IconHelper
{
    private static var IconFontStroke = "Pe-icon-7-stroke"
    private static var IconFontAwesome = "FontAwesome"
    private static var DefaultFontSize: CGFloat = 34
    
    private static var CurrentFontName = IconFontStroke
    
    class func SetLabelIcon(label: UILabel, icon: IconValue, fontSize: CGFloat?, center: Bool)
    {
        label.font = UIFont(name: CurrentFontName, size: fontSize ?? DefaultFontSize)
        label.textColor = UIColor.lightGrayColor()
        
        if (center)
        {
            label.textAlignment = .Center
            /*let attributedString = NSMutableAttributedString(string: icon.rawValue)
            let style = NSMutableParagraphStyle()
            //style.firstLineHeadIndent = 1.0
            style.alignment = NSTextAlignment.Center
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: attributedString.length))
            label.attributedText = attributedString*/
        }
        else
        {
            //label.text = icon.rawValue
        }
        label.text = icon.rawValue
        
    }
    
    class func SetButtonIcon(button: UIButton, icon: IconValue, fontSize: CGFloat?, center: Bool)
    {
        SetLabelIcon(button.titleLabel!, icon: icon, fontSize: fontSize, center: center)
        button.setTitle(icon.rawValue, forState: .Normal)
    }
    
    class func SetCircledIcon(label: UILabel, icon: IconValue, fontSize: CGFloat?, center: Bool)
    {
        SetLabelIcon(label, icon: icon, fontSize: fontSize, center: center)
        label.layer.borderColor = UIColor.lightGrayColor().CGColor
        label.layer.borderWidth = 1.0;
        let maxLength: CGFloat = label.frame.height > label.frame.width ? label.frame.height : label.frame.width
        label.layer.cornerRadius = maxLength / 2
    }
    
    class func SetBarButtonIcon(barButton: UIBarButtonItem, icon: IconValue, fontSize: CGFloat?, center: Bool)
    {
        barButton.title = icon.rawValue
        barButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: CurrentFontName, size: fontSize ?? DefaultFontSize)!], forState: UIControlState.Normal)
        barButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 100), forBarMetrics: .Default)
    }
    
    /*class func SetIcon(button: UIButton, icon: IConValue, fontSize: CGFloat?, center: Bool)
    {
        button.titleLabel
    }*/
}