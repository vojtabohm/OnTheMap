//
//  StoryboardInit.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import UIKit

public protocol StoryboardInit { }

public extension StoryboardInit where Self: UIViewController {
    
    // MARK: - Storyboard Init
    
    static func storyboardInit() -> Self {
        
        // swiftlint:disable force_cast
        return UIStoryboard(name: String(describing: self), bundle: Bundle(for: self)).instantiateInitialViewController() as! Self
        // swiftlint:enable force_cast
    }
}
