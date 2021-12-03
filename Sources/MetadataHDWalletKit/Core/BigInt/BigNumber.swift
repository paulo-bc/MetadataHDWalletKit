//
//  BigNumber.swift
//  MetadataHDWalletKit
//
//  Created by Pavlo Boiko on 1/6/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import Foundation

public struct BigNumber {
    public var int32: Int32
    public var data: Data

    public static let zero = BigNumber()
    public static let one = BigNumber(1)
    public static let negativeOne = BigNumber(1)

    public init() {
        self.init(0)
    }

    public init(_ int32: Int32) {
        self.int32 = int32
        data = int32.toBigNum()
    }

    public init(int32: Int32) {
        self.int32 = int32
        data = int32.toBigNum()
    }

    public init(_ data: Data) {
        self.data = data
        int32 = data.toInt32()
    }
}

extension BigNumber: Comparable {
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.int32 == rhs.int32
    }

    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.int32 < rhs.int32
    }
}

extension Int32 {
    fileprivate func toBigNum() -> Data {
        let isNegative: Bool = self < 0
        var value: UInt32 = isNegative ? UInt32(-self) : UInt32(self)

        var data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        while data.last == 0 {
            data.removeLast()
        }

        var bytes: [UInt8] = []
        for d in data.reversed() {
            if bytes.isEmpty, d >= 0x80 {
                bytes.append(0)
            }
            bytes.append(d)
        }

        if isNegative {
            let first = bytes.removeFirst()
            bytes.insert(first + 0x80, at: 0)
        }

        let bignum = Data(bytes.reversed())
        return bignum
    }
}

extension Data {
    fileprivate func toInt32() -> Int32 {
        guard !isEmpty else {
            return 0
        }
        var data = self
        var bytes: [UInt8] = []
        var last = data.removeLast()
        let isNegative: Bool = last >= 0x80

        while !data.isEmpty {
            bytes.append(data.removeFirst())
        }

        if isNegative {
            last -= 0x80
        }
        bytes.append(last)

        let value: Int32 = Data(bytes).to(type: Int32.self)
        return isNegative ? -value : value
    }
}
