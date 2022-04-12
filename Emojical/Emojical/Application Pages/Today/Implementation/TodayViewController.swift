//
//  TodayViewController.swift
//  Emojical
//
//  Created by Vladimir Svidersky on 12/06/2020.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit
import AudioToolbox

class TodayViewController: UIViewController {

    // MARK: - Outlets

    /// List of awards / goals on the top of the view
    @IBOutlet weak var awards: WeeklyAwardsView!

    /// Constraint to hide awards list if there are no goals defined
    @IBOutlet weak var separatorTopConstraint: NSLayoutConstraint!

    /// Days header view
    @IBOutlet weak var daysHeader: DaysHeaderView!

    @IBOutlet var prevWeek: UIBarButtonItem!
    @IBOutlet var nextWeek: UIBarButtonItem!

    @IBOutlet var dayCollectionViewsArray: [DayColumnView]!
    
    @IBOutlet weak var stampSelector: StampSelectorView!
    @IBOutlet weak var stampSelectorBottomContstraint: NSLayoutConstraint!

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var plusButtonBottomContstraint: NSLayoutConstraint!

    @IBOutlet weak var recapBubbleView: RecapBubbleView!
    @IBOutlet weak var recapBubbleBottomContstraint: NSLayoutConstraint!

    // MARK: - DI

    lazy var coordinator: TodayCoordinatorProtocol = {
        TodayCoordinator(parent: self.navigationController)
    }()

    // MARK: - State
    
    // Recap bubble data model - so we know when it is's changed
    private var recapBubbleData: RecapBubbleData?
    
    var presenter: TodayPresenterProtocol!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = TodayPresenter(
            repository: Storage.shared.repository,
            stampsListener: Storage.shared.stampsListener(),
            awardsListener: Storage.shared.awardsListener(),
            goalsListener: Storage.shared.goalsListener(),
            awardManager: AwardManager.shared,
            coach: CoachMessageManager.shared.coachListener(),
            calendar: CalendarHelper.shared,
            view: self,
            coordinator: coordinator,
            main: tabBarController as? MainCoordinatorProtocol
        )
        
        configureViews()
        updateColors()
        presenter.onViewDidLoad()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.onViewWillDisappear()
    }
    
    // MARK: - TodayView callback properties
    
    /// Is called when user tapped on the stamp in the bottom stamp selector
    var onStampInSelectorTapped: ((Int64) -> Void)?

    /// User tapped on create new stamp in the bottom stamp selector
    var onNewStickerTapped: (() -> Void)?

    /// Is called when user tapped on the day header, day index 0...6 is passed
    var onDayHeaderTapped: ((Int) -> Void)?

    /// User tapped on the previous week button
    var onPrevWeekTapped: (() -> Void)?

    /// User tapped on the next week button
    var onNextWeekTapped: (() -> Void)?

    /// User tapped on the plus button
    var onPlusButtonTapped: (() -> Void)?

    /// User wants to dismiss Stamp Selector (by dragging it down)
    var onCloseStampSelector: (() -> Void)?

    /// User tapped on the award icon on the top
    var onAwardTapped: ((Int) -> Void)?

    /// User tapped on the recap button
    var onRecapTapped: (() -> Void)?

    /// User wants to dismiss Awards Recap view (by dragging it down)
    var onAwardsRecapDismiss: (() -> Void)?
    
    /// Distance from the bottom of the screen to the top edge of Sticker Selector
    var stickerSelectorSize: Float {
        return Float(stampSelector.frame.height + Specs.bottomButtonsMargin)
    }
    
    // MARK: - Actions
    
    @IBAction func prevButtonTapped(_ sender: Any) {
        onPrevWeekTapped?()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        onNextWeekTapped?()
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        onPlusButtonTapped?()
    }
    
    @IBAction func recapButtonTapped(_ sender: Any) {
        onRecapTapped?()
    }

    // Handling panning gesture inside StampSelector view
    @IBAction func handleStampSelectorPanning(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        // Move stamp selector down / up if necessary - x coordinate is ignored
        stampSelectorBottomContstraint.constant = Specs.bottomButtonsMargin - translation.y
        
        // When gesture ended - see if passed threshold - dismiss the view otherwise
        // roll back to the full state
        if gesture.state == .ended {
            if translation.y > stampSelector.bounds.height / 2 {
                onCloseStampSelector?()
            } else {
                // Rollback and show full stamp selector 
                showStampSelector(.fullSelector)
            }
        }
    }
    
    // MARK: - Private helpers

    // Move stamp selector and mini button according to the state
    private func adjustStampSelectorButtonConstraintsForState(_ state: SelectorState) {
        stampSelectorBottomContstraint.constant = (state == .fullSelector) ?
            Specs.bottomButtonsMargin :
            -(stampSelector.bounds.height + Specs.bottomButtonsMargin + 50)
        
        plusButtonBottomContstraint.constant = (state == .miniButton) ?
            Specs.bottomButtonsMargin :
            -(plusButton.bounds.height + Specs.bottomButtonsMargin + 50)
        view.layoutIfNeeded()
    }

    // Move stamp selector and mini button according to the state
    private func adjustRecapBubbleButtonConstraints(hidden: Bool) {
        recapBubbleBottomContstraint.constant = hidden ?
            -(recapBubbleView.bounds.height + Specs.bottomButtonsMargin + 50) :
            Specs.bottomButtonsMargin
        view.layoutIfNeeded()
    }

    private func configureViews() {
        
        // We want to pass exact same width to all daily columns. Otherwise,
        // if we just rely on the auto-layout, there will be some fraction difference
        // between them, and that would make vertical spacing between stickers
        // not even and visible for the user.
        
        let width = dayCollectionViewsArray.first!.bounds.width
        for (index, day) in dayCollectionViewsArray.enumerated() {
            day.stickerSize = floor(width)
            
            day.onDayTapped = { () in
                self.onDayHeaderTapped?(index)
            }
        }

        // Hide buttons initially
        adjustStampSelectorButtonConstraintsForState(.hidden)
        adjustRecapBubbleButtonConstraints(hidden: true)

        prevWeek.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        nextWeek.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!

        awards.onAwardTapped = { (goalId) in
            self.onAwardTapped?(goalId)
        }
        daysHeader.onDayTapped = { (index) in
            self.onDayHeaderTapped?(index)
        }
        stampSelector.onStampTapped = { (stampId) in
            self.onStampInSelectorTapped?(stampId)
        }
        stampSelector.onNewStickerTapped = { () in
            self.onNewStickerTapped?()
        }
        recapBubbleView.onTapped = { () in
            self.onRecapTapped?()
        }
    }
    
    private func updateColors() {
        plusButton.layer.shadowRadius = Specs.shadowRadius
        plusButton.layer.shadowOpacity = Specs.shadowOpacity
        plusButton.layer.shadowColor = Theme.main.colors.shadow.cgColor
        plusButton.layer.shadowOffset = Specs.shadowOffset
        plusButton.layer.cornerRadius = Specs.miniButtonCornerRadius
        plusButton.backgroundColor = Theme.main.colors.secondaryBackground
    }
}

extension TodayViewController: TodayView {
    
    /// Show/hide top awards strip
    func showAwards(_ show: Bool) {
        separatorTopConstraint.constant = show ? 70 : -1
    }

    /// Show/hide recap button
    func showRecapBubble(_ show: Bool, data: RecapBubbleData?) {
        // Bail our early if we need to hide recap bubble
        guard show,
            let data = data else
        {
            adjustRecapBubbleButtonConstraints(hidden: true)
            return
        }

        if recapBubbleData != data {
            recapBubbleData = data
            recapBubbleView.loadData(data.icons, message: data.message)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
            options: [.curveEaseInOut], animations:
        {
            self.adjustRecapBubbleButtonConstraints(hidden: false)
        })
    }

    /// Update page title
    func setTitle(to title: String) {
        navigationItem.title = title
    }

    /// Loads header data
    func loadWeekHeader(data: [DayHeaderData]) {
        guard data.count == 7 else { return }
        daysHeader.loadData(data)
    }

    /// Loads stamps  data into day columns
    func loadDays(data: [[StickerData]]) {
        guard data.count == 7 else { return }
        
        // Mapping 7 data objects to 7 day views
        for (day, view) in zip(data, dayCollectionViewsArray) {
            view.loadData(day)
        }
    }

    /// Loads awards data
    func loadAwards(data: [GoalOrAwardIconData]) {
        awards.loadData(data)
    }

    /// Loads stamps into stamp selector
    func loadStampSelector(data: [StampSelectorElement]) {
        stampSelector.loadData(data)
    }
    
    /// Show/hide next/prev button
    func showNextPrevButtons(showPrev: Bool, showNext: Bool) {
        navigationItem.leftBarButtonItem = showPrev ? prevWeek : nil
        navigationItem.rightBarButtonItem = showNext ? nextWeek : nil
    }

    /// Show/hide stamp selector and plus button
    func showStampSelector(_ state: SelectorState) {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0,
            options: [.curveEaseInOut], animations:
        {
            self.adjustStampSelectorButtonConstraintsForState(state)
        })
    }
}

// MARK: - Specs
fileprivate struct Specs {
    
    /// Stamp selector mini button corner radius
    static let miniButtonCornerRadius: CGFloat = 8.0
    
    /// Bottom buttons (both full and small) margin from the edge
    static let bottomButtonsMargin: CGFloat = 20.0

    /// Shadow radius
    static let shadowRadius: CGFloat = 8.0
    
    /// Shadow opacity
    static let shadowOpacity: Float = 0.4
    
    /// Shadow offset
    static let shadowOffset = CGSize.zero
}
