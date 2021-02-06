//
//  Localizer.swift
//  FMClient
//
//  Created by Alexander Rogachev on 19.07.2020.
//  Copyright © 2020 Feed Me LLC. All rights reserved.
//

import Foundation

private class Localizator {

    static let sharedInstance = Localizator()

    func localize(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
}

extension String {
    var localized: String {
        return Localizator.sharedInstance.localize(self)
    }

    func localized(_ args: CVarArg...) -> String {
        return String.init(format: self.localized, arguments: args as [CVarArg])
    }
}
