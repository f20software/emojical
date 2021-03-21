//
//  WelcomeViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/28/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class WelcomeViewController : UIViewController, WelcomeView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var text1Label: UILabel!
    @IBOutlet weak var text1Bubble: UIView!
    @IBOutlet weak var text2Label: UILabel?
    @IBOutlet weak var text2Bubble: UIView?

    // MARK: - DI

    var presenter: WelcomePresenterProtocol!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.onViewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.onViewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - WelcomeView
    
    /// Dismiss button tapped
    var onDismiss: (() -> Void)? 

    /// Configure layout
    func setBottomMargin(margin: Float) {
        bottomConstraint.constant =
            CGFloat(margin) + Specs.tabbarHeight + Specs.bottomMargin
    }

    /// Loads data
    func loadData(data: WelcomeData) {
        if data.messages.count > 0 {
            text1Label?.text = data.messages[0]
        }
        if data.messages.count > 1 {
            text2Label?.text = data.messages[1]
        }
        dismissButton.setTitle(data.buttonText, for: .normal)
    }

    // MARK: - Actions
    
    @IBAction func dismissTapped(_ sender: Any) {
        onDismiss?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)

        dismissButton.layer.cornerRadius = Specs.textBubbleRadius
        dismissButton.layer.shadowOffset = Specs.shadowOffset
        dismissButton.layer.shadowOpacity = Specs.shadowOpacity
        dismissButton.layer.shadowRadius = Specs.shadowRadius
        
        text1Label.font = Theme.main.fonts.listBody
        text1Bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        text1Bubble.layer.cornerRadius = Specs.textBubbleRadius

        text2Label?.font = Theme.main.fonts.listBody
        text2Bubble?.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        text2Bubble?.layer.cornerRadius = Specs.textBubbleRadius
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Accomodate for the height of tabbar
    static let tabbarHeight: CGFloat = 50.0

    /// Margin between bottom edge of sticker selector and lowest element of welcome screen
    static let bottomMargin: CGFloat = 16.0

    /// Modal corner radius
    static let textBubbleRadius: CGFloat = 15.0
    
    /// Shadow radius
    static let shadowRadius: CGFloat = 8.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.4
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero
}
