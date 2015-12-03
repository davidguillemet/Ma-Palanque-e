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
    private static var errorIndicatorView : UIView? = nil
    
    static var insertionIndicatorView : UIView? = nil
    
    // The eoffset between the center of the cell and the start position of the long gesture
    static var offSetWithCenter: CGPoint? = nil
    
    // The target Collection Item on which the long gesture started
    static var targetCollectionItemIndexPath : NSIndexPath? = nil
    
    // The target TableView cell on which the long gesture started
    static var targetTableRowIndexPath : NSIndexPath? = nil

    // The initial Collection Item on which the long gesture started
    static var initialCollectionItemIndexPath : NSIndexPath? = nil
    
    // The initial TableView cell on which the long gesture started
    static var initialTableRowIndexPath : NSIndexPath? = nil
    
    // Initialize the Drag gesture data strictire from a Table row and the container view
    static func Initialize(cell: UIView, parentView: UIView, centerOffset: CGPoint)
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
    
    static func Terminate(finalDestination: CGPoint)
    {
        Drag.HideErrorIndicatorView()
        Drag.HideInsertionIndicatorView()
        
        UIView.animateWithDuration(
            0.25,
            animations: { () -> Void in
                Drag.cellSnapshot!.center.x = finalDestination.x
                Drag.cellSnapshot!.center.y = finalDestination.y
                Drag.cellSnapshot!.transform = CGAffineTransformIdentity
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
            Drag.errorIndicatorView!.hidden = false
        }
    }

    static func HideErrorIndicatorView()
    {
        if (Drag.errorIndicatorView != nil)
        {
            Drag.errorIndicatorView!.hidden = true
        }
    }
    
    static func HideInsertionIndicatorView()
    {
        if (Drag.insertionIndicatorView != nil)
        {
            Drag.insertionIndicatorView!.hidden = true
        }
    }
    static func ShowInsertionIndicatorView(position: CGPoint, width: CGFloat)
    {
        if (Drag.insertionIndicatorView != nil)
        {
            Drag.insertionIndicatorView!.frame.size.width = width
            Drag.insertionIndicatorView!.frame.origin = position
            Drag.insertionIndicatorView!.hidden = false
        }
    }
    
    // MARK: Private functions
    private static func BuildSnapshopOfCell(inputView: UIView, parentView: UIView) -> UIView
    {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        // Convert the cell center to the parent coordinate system
        let center = Drag.parentView!.convertPoint(inputView.center, fromView: inputView.superview)
        cellSnapshot.center = center
        cellSnapshot.alpha = 0.0
        
        // Add snapshopt as subview
        parentView.addSubview(cellSnapshot)
        
        UIView.animateWithDuration(
            0.25,
            animations: { () -> Void in
                cellSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
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

    private static func BuildErrorIndicatorView(parentView: UIView) -> UIView
    {
        let errorIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let indicatorLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        IconHelper.SetCircledIcon(indicatorLabel, icon: IconValue.IconClose2, fontSize: 26, center: true)
        indicatorLabel.textColor = UIColor.redColor()
        indicatorLabel.layer.borderColor = UIColor.redColor().CGColor
        indicatorLabel.backgroundColor = ColorHelper.ForbiddenIconBackground
        indicatorLabel.clipsToBounds = true
        
        errorIndicatorView.hidden = true
        errorIndicatorView.addSubview(indicatorLabel)
        
        parentView.addSubview(errorIndicatorView)
        
        return errorIndicatorView
    }
    
    private static func BuildInsertionIndicator(parentView: UIView) -> UIView
    {
        let insertionIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 3))
        insertionIndicatorView.backgroundColor = ColorHelper.InsertionIndicator
        insertionIndicatorView.hidden = true
        parentView.addSubview(insertionIndicatorView)
        return insertionIndicatorView
    }
    
    // Clear the Drag data structure and releases UI resources
    private static func Clear()
    {
        // Remove views
        if (errorIndicatorView != nil)
        {
            errorIndicatorView!.hidden = true
            errorIndicatorView!.removeFromSuperview()
        }
        if (insertionIndicatorView != nil)
        {
            insertionIndicatorView!.hidden = true
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