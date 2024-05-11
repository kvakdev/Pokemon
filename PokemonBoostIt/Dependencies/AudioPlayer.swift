//
//  AudioPlayer.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 11/05/2024.
//

import Foundation
import AVFoundation
import ComposableArchitecture

class AudioPlayer: DependencyKey {
    static var liveValue: AudioPlayer = .init()
    static var testValue: AudioPlayer = .init()
    
    var onPlay: ((URL) -> Void)?
    var player: AVAudioPlayer?
    
    init(onPlay: ((URL) -> Void)? = nil) {
        self.onPlay = onPlay
    }
    
    func play(url: URL) throws {
        if let onPlay = self.onPlay {
            onPlay(url)
        } else {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        }
    }
}

extension DependencyValues {
    var audioPlayer: AudioPlayer {
        get { self[AudioPlayer.self] }
        set { self[AudioPlayer.self] = newValue }
    }
}
