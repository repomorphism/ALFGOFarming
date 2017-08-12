//
//  FarmLocation.swift
//  ALFGOFarming
//
//  Created by Paul on 8/6/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


struct FarmLocation {
    let name: String
    let apCost: Int
    let drops: [DropItem : CGFloat]
}

extension FarmLocation: Hashable, Equatable {
    static func ==(lhs: FarmLocation, rhs: FarmLocation) -> Bool {
        return lhs.name == rhs.name &&
            lhs.apCost == rhs.apCost &&
            lhs.drops == rhs.drops
    }

    var hashValue: Int {
        return name.hash
    }
}
