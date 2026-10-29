//
//  Item.swift
//  ExpenseTracker
//
//  Created by Ateeq Ahmed on 29/10/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
