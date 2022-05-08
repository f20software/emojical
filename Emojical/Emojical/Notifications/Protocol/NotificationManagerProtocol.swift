//
//  NotificationManager.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/28/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

protocol NotificationManagerProtocol: AnyObject {

    /// Refresh reminder notifications - deletes existing ones and re-create based on the settings
    func refreshNotifications()
    
    /// Request notification authorization
    func requestAuthorization()

}
