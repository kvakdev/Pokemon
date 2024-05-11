//
//  CryLoaderClient.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 10/05/2024.
//

import Foundation
import ComposableArchitecture
import OggDecoder

class CryLoaderClient: DependencyKey {
    static var liveValue: CryLoaderClient = CryLoaderClient()
    static var previewValue: CryLoaderClient = CryLoaderClient(isTestValue: true)
    
    enum LoadError: String, Error {
        case noDestinationUrl
    }
    
    private var isTestValue = false
    
    init(isTestValue: Bool = false) {
        self.isTestValue = isTestValue
    }
    
    func testURL() -> URL {
        return Bundle(for: CryLoaderClient.self).url(forResource: "output", withExtension: "wav")!
    }
    
    func loadCry(remoteUrl: URL) async throws -> URL {
        guard !isTestValue else { return testURL() }
        
        let destinationURL = try? FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                          create: false).appending(component: "pokemon-cry.ogg")
        
        guard let destinationURL else { throw LoadError.noDestinationUrl }
        
        let request = URLRequest(url: remoteUrl)
        
        let (location, response) = try await URLSession.shared.download(from: remoteUrl)
       
        try FileManager.default.removeItem(at: destinationURL)
        
        try FileManager.default.moveItem(at: location, to: destinationURL)
        debugPrint("copied Location:", destinationURL)
        
        let decoder = OGGDecoder()
        let oggFile = destinationURL
        let resultUrl: URL = await withCheckedContinuation { callback in
            decoder.decode(oggFile) { (savedWavUrl: URL?) in
                // Do whatever you want with URL
                // If convert was fail, returned url is nil
                guard let url = savedWavUrl else { return }
                
                callback.resume(returning: url)
            }
        }
        
        return resultUrl
    }
}

extension DependencyValues {
    var cryLoader: CryLoaderClient {
        get { self[CryLoaderClient.self] }
        set { self[CryLoaderClient.self] = newValue }
    }
}
