//
//  SHA256.swift
//  TONSwift
//
//  Created by Sun on 2024/10/22.
//

import CommonCrypto
import Foundation

extension Data {
    public func sha256() -> Self {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
}
