//
//  MessageOperation.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 3/14/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import Foundation

/// This class encapsulate Coach message object that needs to be handled by TodayPresenter
class CoachMessageOperation: Operation {
    
    var message: CoachMessage
    var handler: TodayPresenterProtocol
    var shown: Bool
    
    override var isFinished: Bool {
        get { return shown }
        set {
            self.willChangeValue(forKey: "isFinished")
            self.shown = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    init(handler: TodayPresenterProtocol, message: CoachMessage) {
        self.handler = handler
        self.message = message
        self.shown = false
    }
    
    override func start() {
        handler.showCoachMessage(message) {
            self.isFinished = true
        }
    }
}
