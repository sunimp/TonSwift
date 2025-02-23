//
//  WalletContractV3Test.swift
//  TONSwiftTests
//
//  Created by Sun on 2024/10/22.
//

import BigInt
@testable import TONSwift
import TweetNacl
import XCTest

final class WalletContractV3Test: XCTestCase {
    // MARK: Properties

    private let publicKey = Data(hex: "5754865e86d0ade1199301bbb0319a25ed6b129c4b0a57f28f62449b3df9c522")!
    private let secretKey =
        Data(
            hex: "34aebb9ea454967f16c407c0f8877763e86212116468169d93a3dcbcafe530c95754865e86d0ade1199301bbb0319a25ed6b129c4b0a57f28f62449b3df9c522"
        )!
    
    // MARK: Functions

    func testWalletContractV3() throws {
        try testR1()
        try testR2()
    }
    
    private func testR1() throws {
        let contractR1 = try WalletV3(workchain: 0, publicKey: publicKey, revision: .r1)
        
        XCTAssertEqual(try contractR1.address(), try Address.parse("EQBJp7j5N40GXJbAqFSnfTV1Af4ZTyHIMpRbKcudNhWJbbNO"))
        XCTAssertEqual(
            try contractR1.stateInit.data?.toString(),
            "x{0000000029A9A3175754865E86D0ADE1199301BBB0319A25ED6B129C4B0A57F28F62449B3DF9C522}"
        )
        XCTAssertEqual(
            try contractR1.stateInit.code?.toString(),
            "x{FF0020DD2082014C97BA9730ED44D0D70B1FE0A4F2608308D71820D31FD31FD31FF82313BBF263ED44D0D31FD31FD3FFD15132BAF2A15144BAF2A204F901541055F910F2A3F8009320D74A96D307D402FB00E8D101A4C8CB1FCB1FCBFFC9ED54}"
        )
        
        let transfer = try contractR1.createTransfer(args: args())
        let signedData = try transfer.signMessage(signer: WalletTransferSecretKeySigner(secretKey: secretKey))
        let cell = try Cell(data: signedData)
        XCTAssertEqual(try cell.toString(), """
            x{69F1EA5C971E9889111C705568732F513D8419E6BB0A022D01E8620EE81067BBA08A89264E8200152F831241E95108A0E432FA4397B940045213383FBA0E3B0C}
            """)
    }
    
    private func testR2() throws {
        let contractR2 = try WalletV3(workchain: 0, publicKey: publicKey, revision: .r2)
        
        XCTAssertEqual(try contractR2.address(), try Address.parse("EQA0D_5WdusaCB-SpnoE6l5TzdBmgOkzTcXrdh0px6g3zJSk"))
        XCTAssertEqual(
            try contractR2.stateInit.data?.toString(),
            "x{0000000029A9A3175754865E86D0ADE1199301BBB0319A25ED6B129C4B0A57F28F62449B3DF9C522}"
        )
        XCTAssertEqual(
            try contractR2.stateInit.code?.toString(),
            "x{FF0020DD2082014C97BA218201339CBAB19F71B0ED44D0D31FD31F31D70BFFE304E0A4F2608308D71820D31FD31FD31FF82313BBF263ED44D0D31FD31FD3FFD15132BAF2A15144BAF2A204F901541055F910F2A3F8009320D74A96D307D402FB00E8D101A4C8CB1FCB1FCBFFC9ED54}"
        )
        
        let transfer = try contractR2.createTransfer(args: args())
        let signedData = try transfer.signMessage(signer: WalletTransferSecretKeySigner(secretKey: secretKey))
        let cell = try Cell(data: signedData)
        XCTAssertEqual(try cell.toString(), """
            x{69F1EA5C971E9889111C705568732F513D8419E6BB0A022D01E8620EE81067BBA08A89264E8200152F831241E95108A0E432FA4397B940045213383FBA0E3B0C}
            """)
    }
    
    private func args() throws -> WalletTransferData {
        return try WalletTransferData(
            seqno: 62,
            messages: [
                .internal(
                    to: Address.parse("kQD6oPnzaaAMRW24R8F0_nlSsJQni0cGHntR027eT9_sgtwt"),
                    value: BigUInt(0.1 * 1000000000),
                    textPayload: "Hello, world!"
                ),
            ],
            sendMode: SendMode(payMsgFees: true),
            timeout: 1680178356
        )
    }
}
