//
//  SolutionViewController.swift
//  ALFGOFarming
//
//  Created by Paul on 8/6/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

final class SolutionViewController: UIViewController {

    var itemCounts: [DropItem : Int] = [.bone : 30, .fang : 5]
    var areas: [Area] = [demo]

    @IBOutlet var barsStackView: UIStackView!
    @IBOutlet var infoLabel: UILabel!

    private var locationBarViews: [FarmLocation : BarView] = [:]

    // Temporary hard-coded bone & fang
    @IBOutlet var bonePickerView: ImpatientPickerView!
    @IBOutlet var fangPickerView: ImpatientPickerView!
    private var totalBoneConstraint: NSLayoutConstraint!
    private var totalFangConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupBars()
        setupConstraints()
        setupPickers()
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // TODO: bubblesort?
//
//        for view in stackView.arrangedSubviews {
//            guard let barView = view as? BarView else { continue }
//            view.isHidden = (barView.barBase.bounds.width == 0)
//        }
//    }

}


extension SolutionViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 101
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item: DropItem
        let constraint: NSLayoutConstraint
        switch pickerView {
        case bonePickerView:
            item = .bone
            constraint = totalBoneConstraint
        case fangPickerView:
            item = .fang
            constraint = totalFangConstraint
        default: return
        }
        itemCounts[item] = row
        constraint.constant = CGFloat(row)
        setupLabel()
    }

    func setupPickers() {
        if let boneCount = itemCounts[.bone] {
            bonePickerView.selectRow(boneCount, inComponent: 0, animated: false)
            bonePickerView.notifyScrolled = { [unowned self] in self.totalBoneConstraint.constant = CGFloat($0)}
        }
        if let fangCount = itemCounts[.fang] {
            fangPickerView.selectRow(fangCount, inComponent: 0, animated: false)
            fangPickerView.notifyScrolled = { [unowned self] in self.totalFangConstraint.constant = CGFloat($0)}
        }
    }
}


private extension SolutionViewController {

    func setupLabel() {
        infoLabel.text = String(describing: itemCounts)
    }

    func setupBars() {
        for area in areas {
            for location in area.locations {
                let barView = BarView.view(named: "\(area.name): \(location.name)")
                barsStackView.addArrangedSubview(barView)
                locationBarViews[location] = barView
            }
        }
    }

    func setupConstraints() {

        // To be activated all at once at the end
        var constraints = [NSLayoutConstraint]()

        // Compose an array of layout guides for each type of item
        var itemLayoutGuides: [DropItem : [UILayoutGuide]] = [:]

        // Create a layout guide per item per location, each relates to the bar (which represents the number
        // of times farmed at the location) multiplied by the item's drop rate
        for area in areas {
            for location in area.locations {
                guard let barView = locationBarViews[location] else { continue }

                for (item, rate) in location.drops {
                    let layoutGuide = UILayoutGuide()
                    view.addLayoutGuide(layoutGuide)
                    constraints.append(layoutGuide.widthAnchor.constraint(equalTo: barView.barBase.widthAnchor, multiplier: rate))
                    itemLayoutGuides[item, default: []].append(layoutGuide)
                }
            }
        }

        // Setup constraints that put each item's array of layout guides into a strip, and give it an overall width constraint
        var totalWidthLayoutGuides: [DropItem : UILayoutGuide] = [:]

        for (item, layoutGuides) in itemLayoutGuides {
            let totalWidthLayoutGuide = UILayoutGuide()
            view.addLayoutGuide(totalWidthLayoutGuide)
            totalWidthLayoutGuides[item] = totalWidthLayoutGuide

            constraints.append(contentsOf: constraintsLiningUpLayoutGuides(layoutGuides, totalWidthLayoutGuide: totalWidthLayoutGuide))
        }

        // Strip's overall width constraint represents desired item counts
        // Keep a reference to these constraints, so they can be changed
        for (item, count) in itemCounts {
            guard let guide = totalWidthLayoutGuides[item] else { continue }
            let totalWidthConstraint = guide.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(count))
            switch item {
            case .bone: totalBoneConstraint = totalWidthConstraint
            case .fang: totalFangConstraint = totalWidthConstraint
            default: break
            }
            constraints.append(totalWidthConstraint)
        }

        // Objective function: total AP cost, works similarly
        var objectiveGuides: [UILayoutGuide] = []
        for area in areas {
            for location in area.locations {
                guard let barView = locationBarViews[location] else { continue }

                let guide = UILayoutGuide()
                view.addLayoutGuide(guide)

                // Possible problems: On one hand, frames might not be allowed to be allowed to have super big width
                // On the other hand, it rounds final frame values to integers (or multiples of 0.5?) so we lose precision
                let scaledCost = CGFloat(location.apCost) / 100

                constraints.append(guide.widthAnchor.constraint(equalTo: barView.barBase.widthAnchor, multiplier: scaledCost))
                objectiveGuides.append(guide)
            }
        }

        let totalCostLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(totalCostLayoutGuide)

        constraints.append(contentsOf: constraintsLiningUpLayoutGuides(objectiveGuides, totalWidthLayoutGuide: totalCostLayoutGuide))

        // Minimizing total width constraint
        let objectiveConstraint = totalCostLayoutGuide.widthAnchor.constraint(equalToConstant: 0)
        objectiveConstraint.priority = UILayoutPriority(rawValue: 999)
        constraints.append(objectiveConstraint)

        // Activate everything at once for performance
        NSLayoutConstraint.activate(constraints)
    }

    // Helper: Form a connected strip of layout guides at the view's top leading, with 0 height
    func constraintsLiningUpLayoutGuides(_ layoutGuides: [UILayoutGuide], totalWidthLayoutGuide: UILayoutGuide) -> [NSLayoutConstraint] {
        precondition(!layoutGuides.isEmpty)

        var constraints: [NSLayoutConstraint] = []

        for guide in layoutGuides + [totalWidthLayoutGuide] {
            constraints.append(contentsOf: [
                guide.topAnchor.constraint(equalTo: view.topAnchor),
                guide.heightAnchor.constraint(equalToConstant: 0)
                ])
        }

        constraints.append(contentsOf: [
            totalWidthLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalWidthLayoutGuide.leadingAnchor.constraint(equalTo: layoutGuides.first!.leadingAnchor),
            totalWidthLayoutGuide.trailingAnchor.constraint(equalTo: layoutGuides.last!.trailingAnchor)
            ])

        var previous = layoutGuides.first!
        for next in layoutGuides.dropFirst() {
            constraints.append(next.leadingAnchor.constraint(equalTo: previous.trailingAnchor))
            previous = next
        }

        return constraints
    }

}















