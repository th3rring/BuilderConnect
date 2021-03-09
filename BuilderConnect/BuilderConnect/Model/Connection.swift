//
//  Connection.swift
//  BuilderConnect
//
//  Created by Catherine Herring on 2021-03-09.
//

import Foundation
import SwiftUI
import CoreLocation

struct Connection: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    
    var protocal: String
    var address: String
    var port: String
    
    private var iconName: String
    var icon: Image {
        Image(systemName: iconName)
    }
}
