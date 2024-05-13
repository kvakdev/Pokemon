//
//  CryLoaderClient.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 10/05/2024.
//

import Foundation
import ComposableArchitecture
import OggDecoder

enum AudioExtension: String {
    case wav
    case ogg
}

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
    
    private func docDir() -> URL {
        return try! FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
    }
    
    private func oggURL(name: String) -> URL {
        urlWith(name: name, fileExtension: .ogg)
    }
    
    private func wavUrl(name: String) -> URL {
        urlWith(name: name, fileExtension: .wav)
    }
    
    private func urlWith(name: String, fileExtension: AudioExtension) -> URL {
        docDir().appending(component: "pokemon-cry-\(name).\(fileExtension.rawValue)", directoryHint: .notDirectory)
    }
    
    func loadCry(remoteUrl: URL, pokemonName: String) async throws -> URL {
        guard !isTestValue else { return testURL() }
        
        if FileManager.default.fileExists(atPath: wavUrl(name: pokemonName).path()) {
            return wavUrl(name: pokemonName)
        }
        
        let destinationURL = oggURL(name: pokemonName)
        let (location, response) = try await URLSession.shared.download(from: remoteUrl)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: location, to: destinationURL)
        
        let decoder = OGGDecoder()
        let oggFile = destinationURL
        
        let resultUrl: URL = await withCheckedContinuation { callback in
            decoder.decode(oggFile) { (savedWavUrl: URL?) in
                guard let url = savedWavUrl else { return }
                
                let cachedUrl = self.wavUrl(name: pokemonName)
                do  {
                    try FileManager.default.moveItem(at: url, to: cachedUrl)
                } catch {
                    debugPrint("error = \(error)")
                }
                callback.resume(returning: cachedUrl)
            }
        }
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        return resultUrl
    }
}

extension DependencyValues {
    var cryLoader: CryLoaderClient {
        get { self[CryLoaderClient.self] }
        set { self[CryLoaderClient.self] = newValue }
    }
}
