//
//  FriendlyAddress.swift
//  TONSwift
//
//  Created by Sun on 2024/10/22.
//

import Foundation

/// By default, addresses are bounceable for safety of TON transfers.
public let BounceableDefault = true

let bounceableTag: UInt8 = 0x11
let nonBounceableTag: UInt8 = 0x51
let testFlag: UInt8 = 0x80

// MARK: - FriendlyAddress

/// Address encoded in a friendly format
public struct FriendlyAddress: Codable, Hashable {
    // MARK: Properties

    public let isTestOnly: Bool
    public let isBounceable: Bool
    public let address: Address
    
    // MARK: Computed Properties

    var workchain: Int8 { return address.workchain }
    var hash: Data { return address.hash }
        
    // MARK: Lifecycle

    public init(string: String) throws {
        // Convert from url-friendly to true base64
        let string = string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        guard let data = Data(base64Encoded: string) else {
            throw TonError.custom("Address is not correctly encoded in Base64")
        }
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        // 1byte tag + 1byte workchain + 32 bytes hash + 2 byte crc
        if data.count != 36 {
            throw TonError.custom("Unknown address type: byte length is not equal to 36")
        }
        
        let addr = data.subdata(in: 0 ..< 34)
        let crc = data.subdata(in: 34 ..< 36)
        let calcedCrc = addr.crc16()
        
        if calcedCrc[0] != crc[0] || calcedCrc[1] != crc[1] {
            throw TonError.custom("Invalid checksum: \(data)")
        }

        var tag = addr[0]
        if tag & testFlag != 0 {
            isTestOnly = true
            tag = tag ^ testFlag
        } else {
            isTestOnly = false
        }

        if tag != bounceableTag, tag != nonBounceableTag {
            throw TonError.custom("Unknown address tag")
        }

        isBounceable = (tag == bounceableTag)

        let wc: Int8 =
            if addr[1] == 0xFF {
                -1
            } else {
                Int8(addr[1])
            }
        let hash = addr.subdata(in: 2 ..< 34)
        address = Address(workchain: wc, hash: hash)
    }
    
    public init(address: Address, testOnly: Bool = false, bounceable: Bool = BounceableDefault) {
        isTestOnly = testOnly
        isBounceable = bounceable
        self.address = address
    }
        
    // MARK: Functions

    public func toString(urlSafe: Bool = true) -> String {
        var tag = isBounceable ? bounceableTag : nonBounceableTag
        if isTestOnly {
            tag |= testFlag
        }
        
        let wcByte =
            if address.workchain == -1 {
                UInt8.max
            } else {
                UInt8(workchain)
            }
        
        var addr = Data(count: 34)
        addr[0] = tag
        addr[1] = wcByte
        addr[2...] = address.hash
        var addrcrc = Data(count: 36)
        addrcrc[0...] = addr
        addrcrc[34...] = addr.crc16()
                
        if urlSafe {
            return addrcrc.base64EncodedString().replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
        } else {
            return addrcrc.base64EncodedString()
        }
    }
}
