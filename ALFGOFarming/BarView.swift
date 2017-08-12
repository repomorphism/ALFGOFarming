//
//  BarView.swift
//  ALFGOFarming
//
//  Created by Paul on 8/6/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

class BarView: UIView {

    // Set constraints to this view's width
    @IBOutlet var barBase: UIView!

    @IBOutlet var fillBarConstraint: NSLayoutConstraint!
    @IBOutlet var label: UILabel!

    var name: String = "" {
        didSet { label.text = name }
    }

    class func view(named name: String) -> BarView {
        let view = Bundle.main.loadNibNamed("BarView", owner: self, options: nil)?.first as! BarView
        view.name = name
        return view
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 40)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.text = "\(name) (\(Int(barBase.bounds.width.rounded())))"
    }

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        fillBarConstraint.isActive = false
//    }

    // TODO: animation
//    var isFilled: Bool {
//        get { return fillBarConstraint.isActive }
//        set { fillBarConstraint.isActive = newValue }
//    }

}

