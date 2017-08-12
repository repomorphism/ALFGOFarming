//
//  DropItem.swift
//  ALFGOFarming
//
//  Created by Paul on 8/6/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation

enum DropItem: String {
    case bone = "Unlucky Bone"
    case fang = "Dragon Fang"
    case dust = "Void's Refuse"
    case talon = "Talon of Chaos"

    static let allItems: [DropItem] = [.bone, .fang, .dust, talon]
}

extension DropItem: CustomDebugStringConvertible {
    var debugDescription: String {
        return rawValue
    }
}
