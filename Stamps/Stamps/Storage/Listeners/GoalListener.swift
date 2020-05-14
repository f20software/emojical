//
//  GoalListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol GoalsListener {
    func startListening(onError: @escaping (Error) -> Void, onChange: @escaping ([Goal]) -> Void)
}
