//
//  ImpatientPickerView.swift
//  ALFGOFarming
//
//  Created by Paul on 8/9/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

class ImpatientPickerView: UIPickerView {

    var notifyScrolled: ((_ estimatedRow: Int) -> Void)?

    private var observation: NSKeyValueObservation?
    private var foundTableView: UITableView?

    override func layoutSubviews() {
        super.layoutSubviews()
        let newTableView = findTableView()
        if foundTableView != newTableView {
            foundTableView = newTableView
            observeTableScroll()
        }
    }

    private func findTableView() -> UITableView {
        var queue = subviews
        var tableView: UITableView?

        while let view = queue.popLast() {
            if let table = view as? UITableView {
                tableView = table
                break
            }
            else if !view.subviews.isEmpty {
                queue = view.subviews + queue
            }
        }

        return tableView!
    }

    private func observeTableScroll() {
        let tableView = findTableView()

        observation = tableView.layer.observe(\.bounds, options: [.new, .initial, .old, .prior]) { [weak self] object, change in
            if let rows = tableView.indexPathsForVisibleRows?.map({ $0.row }), !rows.isEmpty {
                let middleRow = rows[rows.count / 2]
                self?.notifyScrolled?(middleRow)
            }
        }
    }

}
