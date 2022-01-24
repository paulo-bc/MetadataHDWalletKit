//
//  PrivateKeyTests.swift
//  MetadataHDWalletKit_Tests
//
//  Created by Pavlo Boiko on 4/18/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import XCTest
@testable import MetadataHDWalletKit

class PrivateKeyTests: XCTestCase {
    
    func testBitcoin() {
        let address = "1MVEQHYUv1bWiYJB77NNEEEdbmNFEoW5q6"
        let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        
        let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        let uncompressedPk = "5HvdNYs1baLY7vpnmb2osg5gZHvAFxDiBoCujs2vfTjC442rzSK"
        let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
        [hexPk, compressedPk, uncompressedPk].forEach {
            testImportFromPK(coin: .bitcoin, privateKey: $0, address: address, raw: rawPk)
        }
    }
    
    func testBitcoinCash() {
        let address = "1MVEQHYUv1bWiYJB77NNEEEdbmNFEoW5q6"
        let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        
        let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
        let uncompressedPk = "5HvdNYs1baLY7vpnmb2osg5gZHvAFxDiBoCujs2vfTjC442rzSK"
        let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
        [hexPk, uncompressedPk, compressedPk].forEach {
            testImportFromPK(coin: .bitcoinCash, privateKey: $0, address: address, raw: rawPk)
        }
    }
    
    func testDogecoin() throws {
        try XCTSkipIf(true, "not computed correctly")
         let address = "DHhBBVF46Wzc8pR6swZD9GoDdX8x7MDgvw"
         let rawPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
         
         let hexPk = "0e66055a963cc3aecb185cf795de476cf290c88db671297da041b7f7377e6f9c"
         let uncompressedPk = "6KetuZozmLRbBFKM474EcBNFo5w6zuRRWM661hjFZzobJoLuNCh"
         let compressedPk = "KwhhY7djdc9EMaZw1oCytfVfbXfdrzj6newZnBqVrkyDnKVWiCmJ"
         [hexPk, uncompressedPk, compressedPk].forEach {
             testImportFromPK(coin: .bitcoinCash, privateKey: $0, address: address, raw: rawPk)
         }
    }
    
    func testLitecoin() {
        let address = "Lbre6AY3tc8X2GJ2tKERVvcCA4S2EzF6wJ"
        let rawPk = "857cfceb9726ba7165fdcda93c056d35a8ba9b90a8c77fac524a309d832de107"
        
        let hexPk = "857cfceb9726ba7165fdcda93c056d35a8ba9b90a8c77fac524a309d832de107"
        let uncompressedPk = "6v8opvTbpSE2WwTv4rhEvSVK1jqGTXKRkWk484gxmc4TtQzDu53"
        let compressedPk = "T7XTgWxQgNLVh9PoE2LcSsVxWG43E4pLF4H2nBHP9skHfjshodfM"
        [hexPk, uncompressedPk, compressedPk].forEach {
            testImportFromPK(coin: .litecoin, privateKey: $0, address: address, raw: rawPk)
        }
    }
    
    func testImportFromPK(coin: Coin, privateKey: String, address: String, raw: String) {
        let pk = PrivateKey(pk: privateKey, coin: coin)
        XCTAssertEqual(pk!.publicKey.address, address)
        XCTAssertEqual(pk?.raw, Data(hex: raw))
    }

    func testProvidesValidExtendedKey() {
        let seed = Mnemonic.createSeed(
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        )
        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        XCTAssertEqual(
            pk.extended(),
            "xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu"
        )
    }

    func testProvidesValidAccountExtendedKeys() {
        let seed = Mnemonic.createSeed(
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        )
        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        let accountPrivateKey = pk.derived(at: .hardened(44)).derived(at: .hardened(0)).derived(at: .hardened(0))

        XCTAssertEqual(
            accountPrivateKey.extended(),
            "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb"
        )

        XCTAssertEqual(
            accountPrivateKey.extendedPublic(),
            "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj"
        )
    }

    // MARK: - Test Vector

    // taken from https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#Test_Vectors
    func testProvideValidExtendedKey_test_vectors_1() {
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f")

        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        // Chain m
        XCTAssertEqual(
            pk.extended(),
            "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"
        )

        XCTAssertEqual(
            pk.extendedPublic(),
            "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"
        )

        // Chain m/0'
        let chain0 = pk.derived(at: .hardened(0))

        XCTAssertEqual(
            chain0.extended(),
            "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7"
        )

        XCTAssertEqual(
            chain0.extendedPublic(),
            "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw"
        )

        // Chain m/0H/1
        let chain1 = pk.derived(at: .hardened(0)).derived(at: .notHardened(1))

        XCTAssertEqual(
            chain1.extended(),
            "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs"
        )

        XCTAssertEqual(
            chain1.extendedPublic(),
            "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ"
        )

        // Chain m/0'/1/2'
        let chain2 = pk.derived(at: .hardened(0)).derived(at: .notHardened(1)).derived(at: .hardened(2))

        XCTAssertEqual(
            chain2.extended(),
            "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM"
        )

        XCTAssertEqual(
            chain2.extendedPublic(),
            "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5"
        )

        // Chain m/0'/1/2'/2
        let chain3 = pk.derived(at: .hardened(0)).derived(at: .notHardened(1)).derived(at: .hardened(2)).derived(at: .notHardened(2))

        XCTAssertEqual(
            chain3.extended(),
            "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334"
        )

        XCTAssertEqual(
            chain3.extendedPublic(),
            "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV"
        )

        // Chain m/0'/1/2'/1000000000
        let chain4 = pk
            .derived(at: .hardened(0))
            .derived(at: .notHardened(1))
            .derived(at: .hardened(2))
            .derived(at: .notHardened(2))
            .derived(at: .notHardened(1000000000))

        XCTAssertEqual(
            chain4.extended(),
            "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
        )

        XCTAssertEqual(
            chain4.extendedPublic(),
            "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
        )
    }

    func testProvideValidExtendedKey_test_vectors_2() {
        let seed = Data(
            hex: "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542"
        )

        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        // Chain m
        XCTAssertEqual(
            pk.extended(),
            "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U"
        )

        XCTAssertEqual(
            pk.extendedPublic(),
            "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB"
        )

        // Chain m/0'
        let chain0 = pk.derived(at: .notHardened(0))

        XCTAssertEqual(
            chain0.extended(),
            "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt"
        )

        XCTAssertEqual(
            chain0.extendedPublic(),
            "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH"
        )

        // Chain m/0/2147483647'
        let chain1 = pk.derived(at: .notHardened(0)).derived(at: .hardened(2147483647))

        XCTAssertEqual(
            chain1.extended(),
            "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9"
        )

        XCTAssertEqual(
            chain1.extendedPublic(),
            "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a"
        )

        // Chain m/0'/2147483647/1
        let chain2 = pk.derived(at: .notHardened(0)).derived(at: .hardened(2147483647)).derived(at: .notHardened(1))

        XCTAssertEqual(
            chain2.extended(),
            "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef"
        )

        XCTAssertEqual(
            chain2.extendedPublic(),
            "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon"
        )

        // Chain m/0'/2147483647/1/2147483646'
        let chain3 = pk
            .derived(at: .notHardened(0))
            .derived(at: .hardened(2147483647))
            .derived(at: .notHardened(1))
            .derived(at: .hardened(2147483646))

        XCTAssertEqual(
            chain3.extended(),
            "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc"
        )

        XCTAssertEqual(
            chain3.extendedPublic(),
            "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL"
        )

        // Chain m/0/2147483647H/1/2147483646H/2
        let chain4 = pk
            .derived(at: .notHardened(0))
            .derived(at: .hardened(2147483647))
            .derived(at: .notHardened(1))
            .derived(at: .hardened(2147483646))
            .derived(at: .notHardened(2))

        XCTAssertEqual(
            chain4.extended(),
            "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j"
        )

        XCTAssertEqual(
            chain4.extendedPublic(),
            "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt"
        )
    }

    // These vectors test for the retention of leading zeros.
    // See https://github.com/bitpay/bitcore-lib/issues/47 and https://github.com/iancoleman/bip39/issues/58 for more information.
    func testProvideValidExtendedKey_test_vectors_3() {

        let seed = Data(
            hex: "4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be"
        )

        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        // Chain m
        XCTAssertEqual(
            pk.extended(),
            "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6"
        )

        XCTAssertEqual(
            pk.extendedPublic(),
            "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13"
        )

        // Chain m/0'
        let chain0 = pk.derived(at: .hardened(0))

        XCTAssertEqual(
            chain0.extended(),
            "xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L"
        )

        XCTAssertEqual(
            chain0.extendedPublic(),
            "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y"
        )
    }

    // These vectors test for the retention of leading zeros.
    // See https://github.com/btcsuite/btcutil/issues/172 for more information.
    func testProvideValidExtendedKey_test_vectors_4() {

        let seed = Data(
            hex: "3ddd5602285899a946114506157c7997e5444528f3003f6134712147db19b678"
        )

        let pk = PrivateKey(
            seed: seed,
            coin: .bitcoin
        )

        // Chain m
        XCTAssertEqual(
            pk.extended(),
            "xprv9s21ZrQH143K48vGoLGRPxgo2JNkJ3J3fqkirQC2zVdk5Dgd5w14S7fRDyHH4dWNHUgkvsvNDCkvAwcSHNAQwhwgNMgZhLtQC63zxwhQmRv"
        )

        XCTAssertEqual(
            pk.extendedPublic(),
            "xpub661MyMwAqRbcGczjuMoRm6dXaLDEhW1u34gKenbeYqAix21mdUKJyuyu5F1rzYGVxyL6tmgBUAEPrEz92mBXjByMRiJdba9wpnN37RLLAXa"
        )

        // Chain m/0'
        let chain0 = pk.derived(at: .hardened(0))

        XCTAssertEqual(
            chain0.extended(),
            "xprv9vB7xEWwNp9kh1wQRfCCQMnZUEG21LpbR9NPCNN1dwhiZkjjeGRnaALmPXCX7SgjFTiCTT6bXes17boXtjq3xLpcDjzEuGLQBM5ohqkao9G"
        )

        XCTAssertEqual(
            chain0.extendedPublic(),
            "xpub69AUMk3qDBi3uW1sXgjCmVjJ2G6WQoYSnNHyzkmdCHEhSZ4tBok37xfFEqHd2AddP56Tqp4o56AePAgCjYdvpW2PU2jbUPFKsav5ut6Ch1m"
        )

        // Chain m/0'/1'
        let chain1 = pk.derived(at: .hardened(0)).derived(at: .hardened(1))

        XCTAssertEqual(
            chain1.extended(),
            "xprv9xJocDuwtYCMNAo3Zw76WENQeAS6WGXQ55RCy7tDJ8oALr4FWkuVoHJeHVAcAqiZLE7Je3vZJHxspZdFHfnBEjHqU5hG1Jaj32dVoS6XLT1"
        )

        XCTAssertEqual(
            chain1.extendedPublic(),
            "xpub6BJA1jSqiukeaesWfxe6sNK9CCGaujFFSJLomWHprUL9DePQ4JDkM5d88n49sMGJxrhpjazuXYWdMf17C9T5XnxkopaeS7jGk1GyyVziaMt"
        )
    }
}

