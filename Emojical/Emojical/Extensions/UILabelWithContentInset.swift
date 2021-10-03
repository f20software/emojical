//
//  UILabelWithContentInset.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 10/03/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

/// Subclass of UILabel that exposes content edge insets
/// Taken from https://stackoverflow.com/questions/27459746/adding-space-padding-to-a-uilabel
class UILabelWithContentInset: UILabel {

    /// Content insets to add padding from label sides
    var contentInsets = UIEdgeInsets.zero

    override var intrinsicContentSize: CGSize {
        numberOfLines = 0

        var contentSize = super.intrinsicContentSize
        contentSize.height += (contentInsets.top + contentInsets.bottom)
        contentSize.width += (contentInsets.left + contentInsets.right)
        return contentSize
    }

    override func drawText(in rect:CGRect) {
        let r = rect.inset(by: contentInsets)
        super.drawText(in: r)
    }

    override func textRect(forBounds bounds:CGRect, limitedToNumberOfLines n:Int) -> CGRect {
        let b = bounds
        let tr = b.inset(by: contentInsets)
        // that line of code MUST be LAST in this function, NOT first
        let ctr = super.textRect(forBounds: tr, limitedToNumberOfLines: 0)
        return ctr
    }
}
