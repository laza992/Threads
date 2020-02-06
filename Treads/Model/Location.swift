//
//  Location.swift
//  Treads
//
//  Created by developer on 11.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    dynamic public private(set) var latitude = 0.0
    dynamic public private(set) var longitude = 0.0
    
    convenience init( latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
