//
//  DayViewController.swift
//  Stamps
//
//  Created by Vladimir Svidersky on 1/20/20.
//  Copyright © 2020 Vladimir Svidersky. All rights reserved.
//

import UIKit

class DayViewController : UIViewController {
    
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var monthTitle: UILabel!
    @IBOutlet weak var dayTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dayView.layer.cornerRadius = 5.0
        self.dayView.clipsToBounds = true
        // self.dayView.backgroundColor = UIColor.gray
        
        self.dayView.layer.borderColor = UIColor.darkGray.cgColor
        self.dayView.layer.borderWidth = 0.5
    }

    @objc func dayViewTapped(sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self.dayView)
        
        if self.dayView.bounds.contains(loc) == false {
            self.dismiss(animated: true) {
                //
            }
        }
    }
}
