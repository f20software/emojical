//
//  StampsListener.swift
//  Stamps
//
//  Created by Alexander on 12.05.2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation

protocol StampsListener {
    func startListening(onError: @escaping (Error) -> Void, onChange: @escaping ([Stamp]) -> Void)
}
