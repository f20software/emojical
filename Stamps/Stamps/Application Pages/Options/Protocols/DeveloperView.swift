//
//  DeveloperView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/30/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol DeveloperView: AnyObject {

    /// Return UIViewController instance (so we can present and mail stuff from Presenter class)
    var viewController: UIViewController? { get }
    
    // MARK: - Updates

    /// Load view data
    func loadData(_ sections: [OptionsSection])
}
