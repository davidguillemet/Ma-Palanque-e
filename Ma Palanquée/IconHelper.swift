//
//  IconHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 25/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

enum Icon: String
{
    case Menu = "\u{e636}"
    case University = "\u{e60f}"
    case Plane = "\u{e625}"
    case Plus = "\u{e623}"
    case Done = "\u{e66c}"
    case Save = "\u{e65f}"
    case CloseCircled, CancelCircled = "\u{e681}"
    case Trash = "\u{e609}"
    case Unlocked = "\u{e607}"
    case Locked = "\u{e63f}"
    case Ribbon = "\u{e61a}"
    case Close = "\u{e680}"
    case Settings = "\u{e666}"
    case Back = "\u{e687}"
    case More = "\u{e632}"
    case AddUser = "\u{e6a9}"
    case Users = "\u{e693}"
    case Refresh = "\u{e6c2}"
}

/*enum Icon: String
{
    case Menu = "\u{f0c9}"
    case University = "\u{f19d}"

    case Plane = "\u{f072}"
    case Plus = "\u{f067}"
    case Done = "\u{f00c}"
    case Save = "\u{f0c7}"
    case Close = "\u{f00d}"
    case Trash = "\u{f014}"
    case Unlocked = "\u{f09c}"
    case Locked = "\u{f023}"
    case Ribbon = "\u{f005}"
    case Close2 = "\u{e680}"
    case Settings = "\u{f013}"
    case Cancel = "\u{f05e}"
    case Back = "\u{f053}"
}*/

class IconHelper
{
    fileprivate static var IconFontStroke = "Pe-icon-7-stroke"
    fileprivate static var IconFontAwesome = "fontawesome"
    fileprivate static var DefaultFontSize: CGFloat = 34
    
    fileprivate static var CurrentFontName = IconFontStroke
    
    class func SetLabelIcon(_ label: UILabel, icon: Icon, fontSize: CGFloat?, center: Bool)
    {
        label.font = UIFont(name: CurrentFontName, size: fontSize ?? DefaultFontSize)
        label.textColor = UIColor.lightGray
        
        if (center)
        {
            label.textAlignment = .center
        }

        label.text = icon.rawValue
        
    }
    
    class func SetIcon(forBarButtonItem button: UIBarButtonItem, icon: Icon, fontSize: CGFloat?)
    {
        let font = UIFont(name: CurrentFontName, size: fontSize ?? DefaultFontSize)
        
        button.setTitleTextAttributes([NSFontAttributeName: font!], for: .normal)
        button.title = icon.rawValue
    }

    class func SetButtonIcon(_ button: UIButton, icon: Icon, fontSize: CGFloat?, center: Bool)
    {
        SetLabelIcon(button.titleLabel!, icon: icon, fontSize: fontSize, center: center)
        button.setTitle(icon.rawValue, for: UIControlState())
   }

    class func SetCircledIcon(_ label: UILabel, icon: Icon, fontSize: CGFloat?, center: Bool)
    {
        SetLabelIcon(label, icon: icon, fontSize: fontSize, center: center)
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.borderWidth = 1.0;
        let maxLength: CGFloat = label.frame.height > label.frame.width ? label.frame.height : label.frame.width
        label.layer.cornerRadius = maxLength / 2
    }
    
    
    
    class func WriteDiveLevel(_ diverLevelUi: UILabel, _ diveLevel: DiveLevel)
    {
        diverLevelUi.adjustsFontSizeToFitWidth = true
        diverLevelUi.text = diveLevel.stringValue
        
        let colors = PreferencesHelper.GetDiveLevelColors(diveLevel)
        diverLevelUi.backgroundColor = colors.color
        diverLevelUi.textColor = colors.reversedColor
        diverLevelUi.layer.cornerRadius = diverLevelUi.layer.frame.width / 2
        diverLevelUi.clipsToBounds = true
    }
}
