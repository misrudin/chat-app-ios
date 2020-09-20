//
//  Extensions.swift
//  Messages
//
//  Created by BMG MacbookPro on 16/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    public var width: CGFloat {
        return self.frame.size.width
    }
        
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var bottom: CGFloat {
        return self.frame.size.height +  self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var right: CGFloat {
        return self.frame.size.width +  self.frame.origin.x
    }
}

extension Notification.Name {
    static let didLoginNotification = Notification.Name("didLoginNotification")
}
