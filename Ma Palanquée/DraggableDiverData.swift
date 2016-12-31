//
//  Drag.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 30/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation


class Drag
{
    // The highest level view
    static var parentView : UIView? = nil
    
    // Snapshot of the draggable Diver TableView cell
    static var cellSnapshot : UIView? = nil
    
    // An indicator when the drag target is not applicable
    fileprivate static var errorIndicatorView : UIView? = nil
    
    static var insertionIndicatorView : UIView? = nil
    
    // The eoffset between the center of the cell and the start position of the long gesture
    static var offSetWithCenter: CGPoint? = nil
    
    // The target Collection Item on which the long gesture started
    static var targetCollectionItemIndexPath : IndexPath? = nil
    
    // The target TableView cell on which the long gesture started
    static var targetTableRowIndexPath : IndexPath? = nil

    // The initial Collection Item on which the long gesture started
    static var initialCollectionItemIndexPath : IndexPath? = nil
    
    // The initial TableView cell on which the long gesture started
    static var initialTableRowIndexPath : IndexPath? = nil
    
    // Initialize the Drag gesture data strictire from a Table row and the container view
    static func Initialize(_ cell: UIView, parentView: UIView, centerOffset: CGPoint)
    {
        // 1. populate the parent view
        Drag.parentView = parentView
        
        // 2. set the offset between cell center and gesture position
        Drag.offSetWithCenter = centerOffset
        
        // 3. Build the snapshot
        Drag.cellSnapshot = BuildSnapshopOfCell(cell, parentView: parentView)
        
        // 4. Build error and insertion indicators
        Drag.errorIndicatorView = BuildErrorIndicatorView(parentView)
        Drag.insertionIndicatorView = BuildInsertionIndicator(parentView)
    }
    
    static func Terminate(_ finalDestination: CGPoint)
    {
        Drag.HideErrorIndicatorView()
        Drag.HideInsertionIndicatorView()
        
        UIView.animate(
            withDuration: 0.25,
            animations: { () -> Void in
                Drag.cellSnapshot!.center.x = finalDestination.x
                Drag.cellSnapshot!.center.y = finalDestination.y
                Drag.cellSnapshot!.transform = CGAffineTransform.identity
                Drag.cellSnapshot!.alpha = 0.0
            },
            completion: { (finished) -> Void in
                if finished
                {
                    Drag.Clear()
                }
            }
        )
    }
    
    // Returns true if the Drag gesture has been initialzed from a valid table row
    static var IsInitialized: Bool
    {
        get
        {
            return cellSnapshot != nil
        }
    }
    
    static func ShowErrorIndicatorView()
    {
        if (Drag.errorIndicatorView != nil)
        {
            Drag.errorIndicatorView!.center = CGPoint(x: Drag.cellSnapshot!.frame.origin.x, y: Drag.cellSnapshot!.frame.origin.y + 40)
            Drag.errorIndicatorView!.isHidden = false
        }
    }

    static func HideErrorIndicatorView()
    {
        if (Drag.errorIndicatorView != nil)
        {
            Drag.errorIndicatorView!.isHidden = true
        }
    }
    
    static func HideInsertionIndicatorView()
    {
        if (Drag.insertionIndicatorView != nil)
        {
            Drag.insertionIndicatorView!.isHidden = true
        }
    }
    static func ShowInsertionIndicatorView(_ position: CGPoint, width: CGFloat)
    {
        if (Drag.insertionIndicatorView != nil)
        {
            Drag.insertionIndicatorView!.frame.size.width = width
            Drag.insertionIndicatorView!.frame.origin = position
            Drag.insertionIndicatorView!.isHidden = false
        }
    }
    
    // MARK: Private functions
    fileprivate static func BuildSnapshopOfCell(_ inputView: UIView, parentView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        // Convert the cell center to the parent coordinate system
        let center = Drag.parentView!.convert(inputView.center, from: inputView.superview)
        cellSnapshot.center = center
        cellSnapshot.alpha = 0.0
        
        // Add snapshopt as subview
        parentView.addSubview(cellSnapshot)
        
        UIView.animate(
            withDuration: 0.25,
            animations: { () -> Void in
                cellSnapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                cellSnapshot.alpha = 0.50
                //cell.alpha = 0.5
            },
            completion: { (finished) -> Void in
                if finished
                {
                    //cell.hidden = true
                }
            }
        )
        
        return cellSnapshot
    }

    fileprivate static func BuildErrorIndicatorView(_ parentView: UIView) -> UIView
    {
        let errorIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let indicatorLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        IconHelper.SetCircledIcon(indicatorLabel, icon: Icon.Close, fontSize: 26, center: true)
        indicatorLabel.textColor = UIColor.red
        indicatorLabel.layer.borderColor = UIColor.red.cgColor
        indicatorLabel.backgroundColor = ColorHelper.ForbiddenIconBackground
        indicatorLabel.clipsToBounds = true
        
        errorIndicatorView.isHidden = true
        errorIndicatorView.addSubview(indicatorLabel)
        
        parentView.addSubview(errorIndicatorView)
        
        return errorIndicatorView
    }
    
    fileprivate static func BuildInsertionIndicator(_ parentView: UIView) -> UIView
    {
        let insertionIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 3))
        insertionIndicatorView.backgroundColor = ColorHelper.InsertionIndicator
        insertionIndicatorView.isHidden = true
        parentView.addSubview(insertionIndicatorView)
        return insertionIndicatorView
    }
    
    // Clear the Drag data structure and releases UI resources
    fileprivate static func Clear()
    {
        // Remove views
        if (errorIndicatorView != nil)
        {
            errorIndicatorView!.isHidden = true
            errorIndicatorView!.removeFromSuperview()
        }
        if (insertionIndicatorView != nil)
        {
            insertionIndicatorView!.isHidden = true
            insertionIndicatorView!.removeFromSuperview()
        }
        if (cellSnapshot != nil)
        {
            cellSnapshot!.removeFromSuperview()
        }
        
        cellSnapshot = nil
        errorIndicatorView = nil
        insertionIndicatorView = nil
        offSetWithCenter = nil
        targetCollectionItemIndexPath = nil
        targetTableRowIndexPath = nil
    }

}
