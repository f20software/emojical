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
    @IBOutlet weak var text2Label: UILabel!
    @IBOutlet weak var text2Bubble: UIView!


    // MARK: - DI

    var presenter: WelcomePresenterProtocol!
    
    var gap: Float = 10.0

    // MARK: - State
    
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
    
    // MARK: - CongratsView
    
    /// Dismiss button tapped
    var onDismiss: (() -> Void)? 

    /// Loads data
    func loadData(data: WelcomeData) {
//      textLabel.text = data.text
        // titleLabel?.text = data.title
    }

    // MARK: - Actions
    
    @IBAction func dismissTapped(_ sender: Any) {
        onDismiss?()
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        
        dismissButton.setTitle("Got it".localized, for: .normal)
        dismissButton.layer.cornerRadius = 15.0
        dismissButton.layer.shadowOffset = Specs.shadowOffset
        dismissButton.layer.shadowOpacity = Specs.shadowOpacity
        dismissButton.layer.shadowRadius = Specs.shadowRadius
        
        text1Label.font = Theme.main.fonts.listBody
        text2Label.font = Theme.main.fonts.listBody

        text1Bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        text1Bubble.layer.cornerRadius = 15.0
        text2Bubble.backgroundColor = Theme.main.colors.tint.withAlphaComponent(0.2)
        text2Bubble.layer.cornerRadius = 15.0
        
        bottomConstraint.constant = CGFloat(gap + 50.0 /* tabbar height */)
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Bottom constraint for the initial modal view position
    static let bottomButtonsMargin: CGFloat = 160.0
    
    /// Panning threshold after which view will be dismissed
    static let dismissThreshold: CGFloat = 250.0
    
    /// Modal corner radius
    static let modalCornerRadius: CGFloat = 20.0
    
    /// Shadow radius
    static let shadowRadius: CGFloat = 8.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.4
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero

    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 48.0
    
    struct animation {

        /// Emoji font size for award icon
        static let progressDuration: TimeInterval = 1.0

        /// Emoji font size for award icon
        static let transitionToAwardDuration: TimeInterval = 0.5
    }
}
