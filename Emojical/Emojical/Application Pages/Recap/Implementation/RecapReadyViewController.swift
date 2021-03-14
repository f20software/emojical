//
//  CongratsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class RecapReadyViewController : UIViewController, RecapReadyView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - DI

    var presenter: RecapReadyPresenterProtocol!

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
    
    // MARK: - CongratsView
    
    /// Review button tapped
    var onReview: (() -> Void)?

    /// Dismiss button tapped
    var onDismiss: (() -> Void)? 

    /// Loads awards recap data
    func loadData(data: RecapReadyData) {
        textLabel.text = data.text
        titleLabel.text = data.title
    }

    // MARK: - Actions
    
    @IBAction func dismissTapped(_ sender: Any) {
        onDismiss?()
    }

    @IBAction func reviewTapped(_ sender: Any) {
        onReview?()
    }

    // Handling panning gesture for the CongratsView to allow for manual dismiss
    @IBAction func handlePanning(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)

        // Move view down / up if necessary - x coordinate is ignored
        bottomConstraint.constant = Specs.bottomButtonsMargin - translation.y
        
        // When gesture ended - see if passed threshold - dismiss the view otherwise
        // roll back to the initial state
        if gesture.state == .ended {
            if translation.y > Specs.dismissThreshold {
                onDismiss?()
            } else {
                // Rollback and show full stamp selector
                bounceToInitialState()
            }
        }
    }

    // MARK: - Private helpers
    
    private func configureViews() {
        
        view.backgroundColor = UIColor.clear
        
        dismissButton.setTitle("dismiss_button".localized, for: .normal)
        dismissButton.titleLabel?.font = Theme.main.fonts.boldButtons
        dismissButton.setTitleColor(UIColor.systemRed, for: .normal)

        reviewButton.setTitle("review_button".localized, for: .normal)
        reviewButton.titleLabel?.font = Theme.main.fonts.boldButtons
        reviewButton.setTitleColor(Theme.main.colors.tint, for: .normal)

        titleLabel.font = Theme.main.fonts.listTitle
        textLabel.font = Theme.main.fonts.listBody
        
        plate.backgroundColor = Theme.main.colors.background
        plate.layer.cornerRadius = Specs.modalCornerRadius

        plate.layer.shadowRadius = Specs.shadowRadius
        plate.layer.shadowOpacity = Specs.shadowOpacity
        plate.layer.shadowColor = Theme.main.colors.shadow.cgColor
        plate.layer.shadowOffset = Specs.shadowOffset
    }
    
    func bounceToInitialState() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
            options: [.curveEaseInOut], animations:
        {
            self.bottomConstraint.constant = Specs.bottomButtonsMargin
            self.view.layoutIfNeeded()
        })
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
