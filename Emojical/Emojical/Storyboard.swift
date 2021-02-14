//
//  Storyboard.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/25/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

enum Storyboard: String {
    case Stickers
    case Today
    case Stats
    case Recap
    case Goal
    case Sticker
    case SelectStickers
    case GoalsLibrary
    case Developer
    case Options
    case Congrats

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }

    func initialViewController<T: UIViewController>() -> T? {
        return self.instance.instantiateInitialViewController() as? T
    }

    func viewController<T: UIViewController>(withIdentifier name: String) -> T? {
        return self.instance.instantiateViewController(withIdentifier: name) as? T
    }
}
