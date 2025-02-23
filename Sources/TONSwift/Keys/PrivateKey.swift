//
//  PrivateKey.swift
//  TONSwift
//
//  Created by Sun on 2024/10/22.
//

import Foundation

public struct PrivateKey: Key, Equatable, Codable {
    // MARK: Properties

    public let data: Data
    
    // MARK: Lifecycle

    public init(data: Data) {
        self.data = data
    }
}
