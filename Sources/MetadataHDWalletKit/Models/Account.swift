//
//  Account.swift
//  MetadataHDWalletKit
//
//  Created by Pavlo Boiko on 04.07.18.
//

import Foundation

public struct Account {

    public init(privateKey: PrivateKey) {
        self.privateKey = privateKey
    }

    public let privateKey: PrivateKey

    public var rawPrivateKey: String {
        privateKey.get()
    }

    public var rawPublicKey: String {
        privateKey.publicKey.get()
    }

    public var address: String {
        privateKey.publicKey.address
    }
}
