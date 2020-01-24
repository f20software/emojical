//
//  DataSource.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import UIKit

class DataSource {

    // Singleton instance
    static let shared = DataSource()
    
    // Private data storage - right now only local
    var stamps: [Stamp]
    
    // Simplest storage for stamps for given day. Dicrionary in the following format:
    // YYYYMMDD: ABCDE
    var diary: [String: [Int]]
    
    private init() {
        self.stamps = [
            Stamp(id: 1, label: "run", name: "Exercise", color: UIColor(hex: "8cba51"), favorite: true),
            Stamp(id: 2, label: "wineglass", name: "Drink", color: UIColor(hex: "0f4c75"), favorite: true),
            Stamp(id: 3, label: "steak", name: "Red meat", color: UIColor(hex: "c9485b"), favorite: true),
            Stamp(id: 4, label: "cupcake", name: "Sweets", color: UIColor(hex: "4d4646"), favorite: true),
            Stamp(id: 5, label: "frown", name: "Not feeling good", color: UIColor(hex: "3282b8"), favorite: true)
        ]
        self.diary = [String: [Int]]()
    }

    func stampById(_ identifier: Int) -> Stamp? {
        return stamps.first { $0.id == identifier }
    }
    
    func favoriteStamps() -> [Stamp] {
        return stamps.filter { $0.favorite == true }
    }
    
    private func keyForDate(_ date: DateYMD) -> String {
        return "\(date.year)-\(date.month)-\(date.day)"
    }
    
    func stampsForDay(_ day: DateYMD) -> [Int] {
        return diary[keyForDate(day)] ?? []
    }
    
    func setStampsForDay(_ day: DateYMD, stamps: [Int]) {
        diary[keyForDate(day)] = stamps
    }
    
}
