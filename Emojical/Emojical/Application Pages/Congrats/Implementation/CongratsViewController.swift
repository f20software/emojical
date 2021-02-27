//
//  CongratsViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 2/13/21.
//  Copyright © 2021 Vladimir Svidersky. All rights reserved.
//

import UIKit

class CongratsViewController : UIViewController, CongratsView {

    // MARK: - UI Outlets
    
    @IBOutlet weak var plate: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var goal: GoalAwardView!
    @IBOutlet weak var award: AwardView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - DI

    var presenter: CongratsPresenterProtocol!

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

        animateIcon()
    }
    
    // MARK: - CongratsView
    
    /// Dismiss button tapped
    var onDismiss: (() -> Void)? 

    /// Loads awards recap data
    func loadData(data: CongratsData) {
        textLabel.text = data.text
        titleLabel.text = data.title

        goal.text = data.goalIcon.emoji
        goal.labelColor = data.goalIcon.backgroundColor
        // TODO: Add support for negative goals here?
        goal.clockwise = true // (data.goalIcon.direction == .positive)
        goal.progress = 0
        goal.progressColor = data.goalIcon.progressColor
        goal.isHidden = false

        award.labelText = data.awardIcon.emoji
        award.labelBackgroundColor = data.awardIcon.backgroundColor
        award.borderColor = data.awardIcon.borderColor
        award.isHidden = true
    }

    // MARK: - Actions
    
    @IBAction func dismissTapped(_ sender: Any) {
        onDismiss?()
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
    
    // Animate progress on the goal icon from 0 to 1.0 and then show award icon
    private func animateIcon() {
        
        goal.animateProgress(to: 1.0, duration: Specs.animation.progressDuration) { [weak self] in
            // Upon completion - animate hiding goal view and showing award view
            self?.award.alpha = 0
            self?.award.isHidden = false
            
            UIView.animate(
                withDuration: Specs.animation.transitionToAwardDuration,
                delay: 0.0, options: [.curveLinear], animations:
            {
                self?.award.alpha = 1
                self?.goal.alpha = 0
            }, completion: { [weak self] _ in
                self?.award.isHidden = false
                self?.goal.isHidden = true
            })
        }
    }
    
    private func configureViews() {
        
        view.backgroundColor = UIColor.clear
        
        dismissButton.setTitle("dismiss_button".localized, for: .normal)
        dismissButton.titleLabel?.font = Theme.main.fonts.boldButtons
        
        titleLabel.font = Theme.main.fonts.listTitle
        textLabel.font = Theme.main.fonts.listBody
        
        plate.backgroundColor = Theme.main.colors.background
        plate.layer.cornerRadius = Specs.modalCornerRadius

        plate.layer.shadowRadius = Specs.shadowRadius
        plate.layer.shadowOpacity = Specs.shadowOpacity
        plate.layer.shadowColor = Theme.main.colors.shadow.cgColor
        plate.layer.shadowOffset = Specs.shadowOffset

        goal.emojiFontSize = Specs.emojiFontSize
        goal.progressLineWidth = Specs.progressLineWidth
        goal.progressLineGap = Specs.progressLineGap
        award.emojiFontSize = Specs.emojiFontSize
        award.borderWidth = Specs.progressLineWidth
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

    /// Line width for the progress around award icon
    static let progressLineWidth: CGFloat = 4.0
    
    /// Gap between progress line and emoji icon
    static let progressLineGap: CGFloat = 2.0
    
    /// Emoji font size for award icon
    static let emojiFontSize: CGFloat = 48.0
    
    struct animation {

        /// Emoji font size for award icon
        static let progressDuration: TimeInterval = 1.0

        /// Emoji font size for award icon
        static let transitionToAwardDuration: TimeInterval = 0.5
    }
}
