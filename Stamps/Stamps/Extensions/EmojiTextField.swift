//
//  EmojiTextField.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 3/7/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

// Extension to UITextField to force Emoji keyboard
class EmojiTextField: UITextField {

    override var textInputContextIdentifier: String? { "" }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}
