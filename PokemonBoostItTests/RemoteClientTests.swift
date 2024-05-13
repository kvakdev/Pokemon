//
//  RemoteClientTests.swift
//  PokemonBoostItTests
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import XCTest
@testable import PokemonBoostIt

final class RemoteClientTests: XCTestCase {

    func test_testClient_returnsPredefinedDetails() async throws {
        let sut = RemoteDetailsClient.testValue
        let expectedDetails = try await sut.fetchDetails(URL(string: "http://any-url.com")!)
        
        XCTAssertNotNil(expectedDetails)
    }
    
    func test_sampleJSON_isReachable() {
        let url = Bundle(for: RemoteClient.self).url(forResource: "Details", withExtension: nil)
        
        XCTAssertNotNil(url)
    }
    
}
