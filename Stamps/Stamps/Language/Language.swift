//
//  Language.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/31/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// Conviniece extension to String to capitalize first letter
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

/// This class provides support for building various human readable descriptions for goals, awards etc
class Language {

    /// Sticker usage description
    /// For example - "Sticker has been used 100 times. Last time - January 1"
    static func stickerUsageDescription(_ sticker: Stamp) -> String {
        guard sticker.count > 0 else {
            return "sticker_not_user_yet".localized
        }

        var result = ""
        if sticker.count > 1 {
            result += "sticker_used_x_times".localized(sticker.count)
        } else {
            result += "sticker_used_1_time".localized
        }
            
        if let last = sticker.lastUsed {
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", " + "last_time_date".localized(df.string(from: last))
        } else {
            result += "."
        }

        return result
    }
    
    /// Description for the goal current progress
    /// For example - "You've got 5 stickers this week. You still can get 2 more."
    static func goalCurrentProgress(
        period: Period,
        direction: Direction,
        progress: Int,
        limit: Int
    ) -> String {
        
        switch period {
        case .week:
            switch direction {
            case .positive:
                if progress < limit {
                    return "week_positive_goal_not_reached".localized(progress, (limit-progress))
                } else {
                    return "week_positive_goal_reached".localized(progress)
                }

            case .negative:
                if progress < limit {
                    return "week_positive_goal_not_reached".localized(progress, (limit-progress))
                } else if progress == limit {
                    return "week_positive_goal_reached".localized(progress)
                } else {
                    return "week_positive_goal_breached".localized(progress)
                }
            }
            
        case .month:
            switch direction {
            case .positive:
                if progress < limit {
                    return "month_positive_goal_not_reached".localized(progress, (limit-progress))
                } else {
                    return "month_positive_goal_reached".localized(progress)
                }

            case .negative:
                if progress < limit {
                    return "month_positive_goal_not_reached".localized(progress, (limit-progress))
                } else if progress == limit {
                    return "month_positive_goal_reached".localized(progress)
                } else {
                    return "month_positive_goal_breached".localized(progress)
                }
            }

        default:
            assertionFailure("Not implemented")
            return ""
        }
    }
    
    /// Description of how many times goal has been reached and how long the streak is
    /// For example - "Goal has been reached 5 times, las time - Jan 1, 2021. Current streak - 2 times in a row".
    static func goalHistoryDescription(_ goal: Goal, streak: Int? = nil) -> String {
        guard goal.count > 0 else {
            return "goal_not_reached_yet".localized
        }

        var result = ""
        if goal.count > 1 {
            result += "goal_reached_x_times".localized(goal.count)
        } else {
            result += "goal_reached_1_time".localized
        }
            
        if let last = goal.lastUsed {
            let df = DateFormatter()
            df.dateStyle = .medium
            result += ", " + "last_time_date".localized(df.string(from: last))
        } else {
            result += "."
        }
        
        if streak != nil && streak! > 1 {
            result += " " + "current_streak_x".localized(streak!)
        }
            
        return result
    }

    /// Goal description
    /// For example - "Weekly goal. 5 times or more."
    static func goalDescription(_ goal: Goal) -> String {
        switch goal.period {
        case .week:
            if goal.limit > 0 {
                switch goal.direction {
                case .positive:
                    return "week_positive_x".localized(goal.limit)
                case .negative:
                    return "week_negative_x".localized(goal.limit)
                }
            } else {
                return "week_no_limit".localized
            }
            
        case .month:
            if goal.limit > 0 {
                switch goal.direction {
                case .positive:
                    return "month_positive_x".localized(goal.limit)
                case .negative:
                    return "month_negative_x".localized(goal.limit)
                }
            } else {
                return "month_no_limit".localized
            }

        default:
            assertionFailure("Not implemented")
            return ""
        }
    }
    
    /// Goal with period
    /// For example - "weekly goal"
    static func goalWithPeriod(_ period: Period) -> String {
        switch period {
        case .week:
            return "weekly_goal".localized
            
        case .month:
            return "monthly_goal".localized
            
        default:
            assertionFailure("Not implemented")
            return ""
        }
    }
    
    /// Award reached state description
    /// For example: "Earned on Jan 1, 2021, by getting 5 stickers."
    static func awardDescription(
        reached: Bool,
        direction: Direction,
        date: String,
        count: Int,
        limit: Int,
        period: Period
    ) -> String {
        let goal = goalWithPeriod(period).capitalizingFirstLetter()
        switch direction {
        case .positive:
            if reached {
                return "award_positive_reached".localized(date, count)
            } else {
                return "award_positive_not_reached".localized(goal, count, limit)
            }

        case .negative:
            if reached {
                return "award_negative_reached".localized(date, count, limit)
            } else {
                return "award_negative_not_reached".localized(goal, count, limit)
            }
        }
    }
    
    /// Sticker used in goals description
    /// For example - "Sticker used in the 'Do Good' goal."
    static func stickerUsedInGoals(_ goals: [Goal]) -> String {
        if goals.count == 0 {
            return "sticker_used_no_goal".localized
        } else if goals.count == 1 {
            return "sticker_used_1_goal".localized(goals.first?.name ?? "")
        } else {
            let text = goals.map({ "'\($0.name)'" }).sentence
            return "sticker_used_x_goals".localized(text)
        }
    }
}
