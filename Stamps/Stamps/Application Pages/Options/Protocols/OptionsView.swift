//
//  StickersView.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/10/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

protocol OptionsView: AnyObject {

    /// Return UIViewController instance (so we can present and mail stuff from Presenter class)
    var viewController: UIViewController? { get }
    
    // MARK: - Updates

    /// Update page title
    func updateTitle(_ text: String)

    /// Load view data
    func loadData(_ sections: [Section])
}
