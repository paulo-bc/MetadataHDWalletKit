//
//  PrivateKey.swift
//  MetadataHDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation
import CryptoSwift

public enum PrivateKeyError: Error {
    case decodingError
}

enum PrivateKeyType {
    case hd
    case nonHd
}

let secp256k1CurveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!

public struct PrivateKey {
    public let raw: Data
    public let chainCode: Data
    public let index: UInt32
    public let coin: Coin
    private var keyType: PrivateKeyType

    // Additional properties
    public var depth: UInt8
    public var parentFingerprint: UInt32

    var fingerprint: UInt32 {
        // "The first 32 bits of the identifier are called the fingerprint."
        let fingerprintData = getFingerprint(publicKey: publicKey.data)
        return fingerprintData.uint32
    }

    public init(seed: Data, coin: Coin) {
        let output = Crypto.HMACSHA512(key: "Bitcoin seed".data(using: .ascii)!, data: seed)
        raw = output[0..<32]
        chainCode = output[32..<64]
        index = 0
        self.coin = coin
        keyType = .hd
        depth = 0
        parentFingerprint = 0
    }

    public init?(pk: String, coin: Coin) {
        switch coin {
        case .ethereum:
            raw = Data(hex: pk)
        default:
            let utxoPkType = UtxoPrivateKeyType.pkType(for: pk, coin: coin)
            switch utxoPkType {
            case .some(let pkType):
                switch pkType {
                case .hex:
                    raw = Data(hex: pk)
                case .wifUncompressed:
                    let decodedPk = Base58.decode(pk) ?? Data()
                    let wifData = decodedPk.dropLast(4).dropFirst()
                    raw = wifData
                case .wifCompressed:
                    let decodedPk = Base58.decode(pk) ?? Data()
                    let wifData = decodedPk.dropLast(4).dropFirst().dropLast()
                    raw = wifData
                }
            case .none:
                return nil
            }
        }
        chainCode = Data(capacity: 32)
        index = 0
        self.coin = coin
        keyType = .nonHd
        self.depth = 0
        self.parentFingerprint = 0
    }

    private init(
        privateKey: Data,
        chainCode: Data,
        depth: UInt8,
        parentFingerprint: UInt32,
        index: UInt32,
        coin: Coin
    ) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.index = index
        self.coin = coin
        self.keyType = .hd
        self.depth = depth
        self.parentFingerprint = parentFingerprint
    }

    public var publicKey: PublicKey {
        PublicKey(privateKey: raw, coin: coin)
    }

    public func wifCompressed() -> String {
        var data = Data()
        data += coin.wifAddressPrefix
        data += raw
        data += UInt8(0x01)
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }

    public func wifUncompressed() -> String {
        var data = Data()
        data += coin.wifAddressPrefix
        data += raw
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }

    public func get() -> String {
        switch coin {
        case .bitcoin: fallthrough
        case .litecoin: fallthrough
        case .dash: fallthrough
        case .bitcoinCash:
            return wifCompressed()
        case .dogecoin:
            return wifUncompressed()
        case .ethereum:
            return raw.toHexString()
        }
    }

    public func derived(at node: DerivationNode) -> PrivateKey {
        guard keyType == .hd else { fatalError() }
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }

        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            data += Crypto.generatePublicKey(data: raw, compressed: true)
        }

        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex

        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])

        let derivedPrivateKey = ((BInt(data: raw) + factor) % secp256k1CurveOrder).data
        let derivedChainCode = digest[32..<64]

        let depth = depth + 1

        let fingerprint = getFingerprint(publicKey: publicKey.data).uint32

        return PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            depth: depth,
            parentFingerprint: fingerprint,
            index: derivingIndex,
            coin: coin
        )
    }

    public func sign(hash: Data) throws -> Data {
        try Crypto.sign(hash, privateKey: raw)
    }
}

private func getFingerprint(publicKey: Data) -> Data {
    let publicKeyDigest = SHA2(variant: .sha256)
        .calculate(for: publicKey.bytes)
    return Data(RIPEMD160.hash(Data(publicKeyDigest)))
}

private func rawIndexToIndex(rawIndex: UInt32) -> UInt32 {
    let hardenedBit: UInt32 = 0x80000000
    let result = rawIndex & (~hardenedBit)
    return result
}

private func indexToRawIndex(index: UInt32) -> UInt32 {
    let hardenedBit: UInt32 = 0x80000000
    let result = index | hardenedBit
    return result
}

extension PrivateKey: Equatable {
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        lhs.raw.hex == rhs.raw.hex &&
        lhs.chainCode == rhs.chainCode &&
        lhs.index == rhs.index &&
        lhs.coin == rhs.coin &&
        lhs.keyType == rhs.keyType
    }
}

extension PrivateKey {

    public static func from(
        privateKey: Data,
        chainCode: Data,
        depth: UInt8,
        parentFingerprint: UInt32,
        index: UInt32,
        coin: Coin
    ) -> Self {
        self.init(
            privateKey: privateKey,
            chainCode: chainCode,
            depth: depth,
            parentFingerprint: parentFingerprint,
            index: index,
            coin: coin
        )
    }

    /// Provides the extended private key
    public func extended() -> String {

        func getPrivKeyBytes33() -> [UInt8] {
            let zeros = raw.count < 33 ? [UInt8](repeating: 0, count: 33 - raw.count) : []
            var bytes = [UInt8]()
            bytes += zeros + raw
            return bytes
        }

        let serialized = serialize(
            coinVersion: coin.privateKeyVersion,
            key: Data(getPrivKeyBytes33())
        )
        let checksummed = addChecksum(data: serialized)
        let encoded = Base58.encode(checksummed)
        return encoded
    }

    /// Provides the extended public key
    public func extendedPublic() -> String {
        let serialized = serialize(
            coinVersion: coin.publicKeyVersion,
            key: publicKey.compressedPublicKey
        )
        let checksummed = addChecksum(data: serialized)
        let encoded = Base58.encode(checksummed)
        return encoded
    }

    private func serialize(coinVersion: UInt32, key: Data) -> Data {
        var bytes = [UInt8]()
        // version: puts xprv or xpub at the start
        bytes += Data(from: coinVersion.bigEndian).bytes
        // depth: how many times this child has been derived from master key (0 = master key)
        bytes += [depth]
        // fingerprint: created from parent public key (allows you to spot adjacent xprv and xpubs)
        bytes += Data(from: parentFingerprint).bytes
        // index: the index of this child key from the parent
        bytes += index.bytes
        // chainCode: the current chain code being used for this key
        bytes += chainCode
        // the private key or public key you want to create a serialized extended key for (prepend 0x00 for private)
        bytes += key
        assert(bytes.count == 78)
        return Data(bytes)
    }

    /// Adds SHA256 twice to the given data
    /// - Parameter data: A `Data` object to be processed
    /// - Returns: A processed `Data` object
    private func addChecksum(data: Data) -> Data {
        data + data.doubleSHA256.prefix(4)
    }

    public static func from(extended: String) -> Result<Self, PrivateKeyError> {

        func initFromBytes(bytes: [UInt8]) -> Result<Self, PrivateKeyError> {
            // Both pub and private extended keys are 78 bytes
            guard bytes.count == 78 else {
                return .failure(.decodingError) // Not enough data
            }

            let depth: UInt8 = bytes[4]

            let parentFingerprint: [UInt8] = Array(bytes[5..<9])
            let parentFingerprintAsUInt32 = Data(parentFingerprint)
                .uint32
                .bigEndian

            let childIndex: UInt32 = Data(Array(bytes[9..<13])).uint32

            let chainCode: [UInt8] = Array(bytes[13..<45])

            let keyBytes: [UInt8] = Array(bytes[45..<78])

            let ecKey = Array(keyBytes[1..<33])

            let pk = PrivateKey(
                privateKey: Data(ecKey),
                chainCode: Data(chainCode),
                depth: depth,
                parentFingerprint: parentFingerprintAsUInt32,
                index: childIndex,
                coin: .bitcoin
            )

            return .success(pk)
        }

        guard let decoded = Base58.decode(extended) else {
            return .failure(.decodingError)
        }
        guard decoded.count == 82 else {
            return .failure(.decodingError) // Not enough data
        }

        let checksum = Array(decoded.bytes[78..<82])
        let bytes = Array(decoded.bytes[0..<78])
        let hash = Data(bytes).doubleSHA256.prefix(4).bytes

        guard hash[0..<4] == checksum[0..<4] else {
            return .failure(.decodingError)
        }

        return initFromBytes(bytes: bytes)
    }
}

extension Data {

    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }

    var uint16: UInt16 {
        get {
            let i16array = withUnsafeBytes { $0.load(as: UInt16.self) }
            return i16array
        }
    }

    var uint32: UInt32 {
        get {
            let i32array = withUnsafeBytes { $0.load(as: UInt32.self) }
            return i32array
        }
    }
}

protocol BytesRepresentable {
    var bytes: [UInt8] { get }
}

extension BytesRepresentable {
    func toBytes<T: Numeric>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) { unsafePointer in
            unsafePointer.withMemoryRebound(to: UInt8.self, capacity: count) { ptr in
                UnsafeBufferPointer(start: ptr, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}

extension UInt16: BytesRepresentable {
    var bytes: [UInt8] {
        toBytes(
            endian: littleEndian,
            count: MemoryLayout<UInt16>.size
        )
    }
}

extension UInt32: BytesRepresentable {
    var bytes: [UInt8] {
        toBytes(
            endian: littleEndian,
            count: MemoryLayout<UInt32>.size
        )
    }
}

extension UInt64: BytesRepresentable {
    var bytes: [UInt8] {
        toBytes(
            endian: littleEndian,
            count: MemoryLayout<UInt64>.size
        )
    }
}
