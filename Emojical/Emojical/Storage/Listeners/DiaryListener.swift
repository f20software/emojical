//
//  DiaryListener.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol DiaryListener {

    /// Start listening to changes in the Diary table - only interested in count
    func startListening(onChange: @escaping (Int) -> Void)
}
