//
//  Language.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 1/31/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// This class provides support for building various human readable descriptions for goals, awards etc
class Language {

    /// Sticker usage description
    /// For example - "Sticker has been used 100 times. Last time - January 1"
    static func stickerUsageDescription(_ count: Int, lastUsed: Date?) -> String {
        guard count > 0,
            let lastDate = lastUsed else {
            return "sticker_used_0_text".localized
        }

        let df = DateFormatter()
        df.dateStyle = .medium

        if count > 1 {
            return "sticker_used_x_text".localized(count, df.string(from: lastDate))
        } else {
            return "sticker_used_1_text".localized(df.string(from: lastDate))
        }
    }
    
    /// Description for the goal current progress
    /// For example - "You've got 5 stickers this week. You still can get 2 more."
    static func goalCurrentProgress(
        period: Period,
        direction: Direction,
        progress: Int,
        limit: Int
    ) -> String {
        
        var progressText = ""
        switch period {
        case .week:
            if progress == 0 {
                progressText = "you_got_0_stickers_week".localized
            } else if progress == 1 {
                progressText = "you_got_1_sticker_week".localized
            } else {
                progressText = "you_got_x_stickers_week".localized(progress)
            }

        case .month:
            if progress == 0 {
                progressText = "you_got_0_stickers_month".localized
            } else if progress == 1 {
                progressText = "you_got_1_sticker_month".localized
            } else {
                progressText = "you_got_x_stickers_month".localized(progress)
            }

        case .once:
            if progress == 0 {
                progressText = "you_got_0_stickers_total".localized
            } else if progress == 1 {
                progressText = "you_got_1_sticker_total".localized
            } else {
                progressText = "you_got_x_stickers_total".localized(progress)
            }

        default:
            assertionFailure("Not implemented")
            return ""
        }
        
        switch direction {
        case .positive:
            if progress == 0 {
                return "positive_goal_not_reached_0".localized(progressText, limit)
            } else if progress < limit {
                return "positive_goal_not_reached".localized(progressText, (limit-progress))
            } else {
                switch period {
                case .week:
                    return "week_positive_goal_reached".localized(progress)
                case .month:
                    return "month_positive_goal_reached".localized(progress)
                case .once:
                    return "once_positive_goal_reached".localized(progress)
                default:
                    assertionFailure("Not implemented")
                    return ""
                }
            }

        case .negative:
            if progress == 0 {
                return "negative_goal_not_reached_0".localized(progressText, limit)
            } else if progress < limit {
                return "negative_goal_not_reached".localized(progressText, (limit-progress))
            } else if progress == limit {
                return "negative_goal_reached".localized(progressText)
            } else {
                switch period {
                case .week:
                    return "week_negative_goal_breached".localized(progress)
                case .month:
                    return "month_negative_goal_breached".localized(progress)
                case .once:
                    return "once_negative_goal_breached".localized(progress)
                default:
                    assertionFailure("Not implemented")
                    return ""
                }
            }
        }
    }
    
    /// Description of how many times goal has been reached and how long the streak is
    /// For example - "Goal has been reached 5 times, las time - Jan 1, 2021. Current streak - 2 times in a row".
    static func goalReachedDescription(_ count: Int, lastUsed: Date?) -> String {
        guard count > 0,
            let lastDate = lastUsed else {
            return "goal_reached_0_text".localized
        }

        let df = DateFormatter()
        df.dateStyle = .medium

        if count > 1 {
            return "goal_reached_x_text".localized(count, df.string(from: lastDate))
        } else {
            return "goal_reached_1_text".localized(count, df.string(from: lastDate))
        }
    }
    
    static func goalStreakDescription(_ streak: Int) -> String {
        if streak > 0 {
            return "current_streak_x".localized(streak)
        } else {
            return "current_streak_0".localized
        }
    }

    /// Goal description
    /// For example - "Weekly goal. 5 times or more."
    static func goalDescription(_ goal: Goal) -> String {
        // Goal always should have limit
        guard goal.limit > 0 else {
            return ""
        }

        switch goal.period {
        case .week:
            switch goal.direction {
            case .positive:
                return "week_positive_x".localized(goal.limit)
            case .negative:
                return "week_negative_x".localized(goal.limit)
            }
            
        case .month:
            switch goal.direction {
            case .positive:
                return "month_positive_x".localized(goal.limit)
            case .negative:
                return "month_negative_x".localized(goal.limit)
            }
            
        case .once:
            switch goal.direction {
            case .positive:
                return "once_positive_x".localized(goal.limit)
            case .negative:
                return "once_negative_x".localized(goal.limit)
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
            
        case .once:
            return "once_goal".localized

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
    
    /// Week recap message based on number on goals and number of reached goals
    static func weekRecapForGoals(total: Int, reached: Int) -> String {
        
        // Single goal?
        if total == 1 {
            if reached == 0 {
                return "week_recap_message_0_1".localized
            } else /* if reachedGoals == 1 */ {
                return "week_recap_message_1_1".localized
            }
        }
        
        // Multiple goals
        if reached == 0 {
            return "week_recap_message_0_x".localized
        } else if reached == 1 {
            return "week_recap_message_1_x".localized
        } else if reached < total {
            return "week_recap_message_x_y".localized(reached)
        } else {
            return "week_recap_message_x_x".localized
        }
    }
    
    /// Positive cheer message when goal is reached. Including award history
    /// e.g. You've reached your "Goal Name" goal. You now have earned this award 10 times total and 3 times in a row! Keep that streak going!
    static func positiveCheerMessage(goalName: String?, streak: Int?, count: Int?) -> String {
        var text = ""
        if let name = goalName {
            text = "goal_reached_name".localized(name)
        } else {
            text = "goal_reached_no_name".localized
        }

        if (streak ?? 0) > 1 && (count ?? 0) > 0 {
            text = text + " " + "award_streak_count_description".localized(count ?? 0, streak ?? 0)
        } else if (count ?? 0) > 1 {
            text = text + " " + "award_count_description".localized(count ?? 0)
        }
        
        return text
    }
}
