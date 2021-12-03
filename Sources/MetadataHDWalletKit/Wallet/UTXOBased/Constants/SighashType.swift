//
//  SighashType.swift
//  MetadataHDWalletKit
//
//  Created by Pavlo Boiko on 1/7/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import Foundation

private let SIGHASH_ALL: UInt8 = 0x01 // 00000001
private let SIGHASH_NONE: UInt8 = 0x02 // 00000010
private let SIGHASH_SINGLE: UInt8 = 0x03 // 00000011
private let SIGHASH_FORK_ID: UInt8 = 0x40 // 01000000
private let SIGHASH_ANYONECANPAY: UInt8 = 0x80 // 10000000

private let SIGHASH_OUTPUT_MASK: UInt8 = 0x1f // 00011111

public struct SighashType {
    fileprivate let uint8: UInt8
    init(_ uint8: UInt8) {
        self.uint8 = uint8
    }

    private var outputType: UInt8 {
        uint8 & SIGHASH_OUTPUT_MASK
    }

    public var isAll: Bool {
        outputType == SIGHASH_ALL
    }

    public var isSingle: Bool {
        outputType == SIGHASH_SINGLE
    }

    public var isNone: Bool {
        outputType == SIGHASH_NONE
    }

    public var hasForkId: Bool {
        (uint8 & SIGHASH_FORK_ID) != 0
    }

    public var isAnyoneCanPay: Bool {
        (uint8 & SIGHASH_ANYONECANPAY) != 0
    }

    public enum BCH {
        public static let ALL = SighashType(SIGHASH_FORK_ID + SIGHASH_ALL) // 01000001
        public static let NONE = SighashType(SIGHASH_FORK_ID + SIGHASH_NONE) // 01000010
        public static let SINGLE = SighashType(SIGHASH_FORK_ID + SIGHASH_SINGLE) // 01000011
        public static let ALL_ANYONECANPAY = SighashType(SIGHASH_FORK_ID + SIGHASH_ALL + SIGHASH_ANYONECANPAY) // 11000001
        public static let NONE_ANYONECANPAY = SighashType(SIGHASH_FORK_ID + SIGHASH_NONE + SIGHASH_ANYONECANPAY) // 11000010
        public static let SINGLE_ANYONECANPAY = SighashType(SIGHASH_FORK_ID + SIGHASH_SINGLE + SIGHASH_ANYONECANPAY) // 11000011
    }

    public enum BTC {
        public static let ALL = SighashType(SIGHASH_ALL) // 00000001
        public static let NONE = SighashType(SIGHASH_NONE) // 00000010
        public static let SINGLE = SighashType(SIGHASH_SINGLE) // 00000011
        public static let ALL_ANYONECANPAY = SighashType(SIGHASH_ALL + SIGHASH_ANYONECANPAY) // 10000001
        public static let NONE_ANYONECANPAY = SighashType(SIGHASH_NONE + SIGHASH_ANYONECANPAY) // 10000010
        public static let SINGLE_ANYONECANPAY = SighashType(SIGHASH_SINGLE + SIGHASH_ANYONECANPAY) // 10000011
    }

    static func hashTypeForCoin(coin: Coin) -> SighashType {
        switch coin {
        case .bitcoinCash:
            return BCH.ALL
        default:
            return BTC.ALL
        }
    }
}

extension UInt8 {
    public init(_ hashType: SighashType) {
        self = hashType.uint8
    }
}

extension UInt32 {
    public init(_ hashType: SighashType) {
        self = UInt32(UInt8(hashType))
    }
}
