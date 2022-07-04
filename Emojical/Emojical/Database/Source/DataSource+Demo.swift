//
//  DataSource+ImportExport.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import Foundation
import GRDB

//
// Import/Export is not publicly available feature yet. I'm using it to
// move data from my personal phone that I'm using for beta-testing
// into clean simulators, so I can test various things locally.
//
// Export is available from the Options page on the app. Json file will be generated
// and attached to compose mail ready for emailing.
//
// Save off backup.json file into /Users/sha/Desktop folder and uncomment call
// for importDatabase() method
//

extension DataSource {

    /// Find stamp by its label (returns first matching or nil
    func stickerByLabel(_ label: String) -> Stamp? {
        do {
            return try dbQueue.read { db -> StoredStamp? in
                let request = StoredStamp.filter(StoredStamp.Columns.label == label && StoredStamp.Columns.deleted == false)
                return try request.fetchOne(db)
            }?.toModel()
        }
        catch { }
        return nil
    }

    /// Create initial database entires
    func createInitialStickers() {
        // Stickers
        let stickers = [
            ("⭐️", "Star", Theme.main.colors.palette[2]),
            ("🏐", "Exercise", Theme.main.colors.palette[3]),
            ("📖", "Read Book", Theme.main.colors.palette[5]),
            ("🤩", "Good Day", Theme.main.colors.palette[2]),
        ]

        for (emoji, name, color) in stickers {
            do {
                try dbQueue.inDatabase { db in
                    var stored = StoredStamp(
                        name: name,
                        label: emoji,
                        color: color.hex)
                    try stored.save(db)
                }
            }
            catch {}
        }
    }

    /// Create demo database entires
    func createDemoEntries(from date: Date) {
        // Stickers
        let stickers = [
            ("⚽️", "Soccer Game", Theme.main.colors.palette[4]),
            ("🧘🏻‍♀️", "Yoga", Theme.main.colors.palette[5]),
            ("💦", "Drink Water", Theme.main.colors.palette[5]),
            ("👍", "Good Day", Theme.main.colors.palette[2]),
            ("🌲", "Hike", Theme.main.colors.palette[4]),
            ("📕", "Read Book", Theme.main.colors.palette[0]),
        ]
        
        let goals = [
            ("⚽️", "Play Soccer", Period.week, Direction.positive, 3),
            ("🧘🏻‍♀️,⚽️,🌲", "Be Active", Period.month, Direction.positive, 15),
            ("💦", "Drink Water", Period.week, Direction.positive, 6),
            ("👍", "Be positive", Period.week, Direction.positive, 3),
        ]
        
        // Backwards from `date` date
        let diary = [
            ("⚽️,💦,📕,👍"),
            ("💦,🌲"),
            ("⚽️,💦,📕,🧘🏻‍♀️,👍"),
            ("⚽️,📕"),
            ("⚽️,💦,📕,🧘🏻‍♀️,👍"),
            ("⚽️,💦,🌲"),
            ("💦,📕,👍"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("💦,🧘🏻‍♀️,🌲"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("⚽️,🧘🏻‍♀️,📕"),
            ("⚽️,🧘🏻‍♀️,📕,👍,🌲"),
            ("⚽️,💦,🌲"),
            ("💦,📕,👍"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("💦,🧘🏻‍♀️,🌲"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("⚽️,🧘🏻‍♀️,📕"),
            ("⚽️,🧘🏻‍♀️,📕,👍,🌲"),
            ("⚽️,📕"),
            ("⚽️,💦,📕,🧘🏻‍♀️,👍"),
            ("⚽️,💦,🌲"),
            ("💦,📕,👍"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("💦,🧘🏻‍♀️,🌲"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("⚽️,🧘🏻‍♀️,📕"),
            ("⚽️,🧘🏻‍♀️,📕,👍,🌲"),
            ("⚽️,💦,🌲"),
            ("💦,📕,👍"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("💦,🧘🏻‍♀️,🌲"),
            ("🧘🏻‍♀️,💦,📕,👍"),
            ("⚽️,🧘🏻‍♀️,📕"),
            ("⚽️,🧘🏻‍♀️,📕,👍,🌲"),
            ("⚽️,📕"),
            ("⚽️,💦,📕,🧘🏻‍♀️,👍"),
            ("⚽️,💦,🌲"),
            ("💦,📕,👍"),
        ]
        
        for (emoji, name, color) in stickers {
            do {
                try dbQueue.inDatabase { db in
                    var stored = StoredStamp(
                        name: name,
                        label: emoji,
                        color: color.hex)
                    try stored.save(db)
                }
            }
            catch {}
        }
        
        for (emoji, name, period, direction, limit) in goals {
            do {
                let emojies = emoji.split(separator: ",")
                let stickersIds = emojies.compactMap({
                    let id = stickerByLabel(String($0))?.id
                    return id != nil ? "\(id!)" : nil
                }).joined(separator: ",")
                try dbQueue.inDatabase { db in
                    var stored = StoredGoal(
                        name: name,
                        period: period,
                        direction: direction,
                        limit: limit,
                        stamps: stickersIds
                    )
                    try stored.save(db)
                }
            }
            catch {}
        }
        
        var day = date
        for emoji in diary {
            do {
                let emojies = emoji.split(separator: ",")
                let stickersIds = emojies.compactMap({
                    stickerByLabel(String($0))?.id
                })

                day = day.byAddingDays(-1)
                try stickersIds.forEach({ id in
                    try dbQueue.inDatabase { db in
                        var stored = StoredDiary(
                            date: day.databaseKey,
                            count: 1,
                            stampId: id
                        )
                        try stored.save(db)
                    }
                })
            }
            catch {}
        }

        // Update statistics for each sticker
        let stickersIds: [Int64] = stickers.compactMap({
            return stickerByLabel(String($0.0))?.id
        })
        
        updateStatsForStamps(stickersIds)
    }
    
    /// Don't use - only when need to fix database on my device
    func createAdHocEntries() {
        do {
            try ["2022-02-10", "2022-01-27", "2022-01-13"].forEach({ date in
                try dbQueue.inDatabase { db in
                    var stored = StoredDiary(
                        date: date,
                        count: 1,
                        stampId: 43
                    )
                    try stored.save(db)
                }
            })
        }
        catch {}
    }

}
