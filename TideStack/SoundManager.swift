//
//  SoundManager.swift
//  TideStack
//

import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private var isEnabled = true
    
    private init() {}
    
    func playDropSound() {
        // Block drop sound - soft thud
        playSystemSound(id: 1104)
    }
    
    func playPerfectSound() {
        // Perfect placement - chime
        playSystemSound(id: 1325)
    }
    
    func playComboSound() {
        // Combo - rising tone
        playSystemSound(id: 1330)
    }
    
    func playGameOverSound() {
        // Game over - descending tone
        playSystemSound(id: 1329)
    }
    
    private func playSystemSound(id: UInt32) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
    
    func toggleSound() {
        isEnabled.toggle()
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}
