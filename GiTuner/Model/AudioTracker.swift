//
//  AudioTracker.swift
//  GiTuner
//
//  Created by 陳孟澤 on 2020/6/2.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

import Foundation
import AudioKit

struct AudioTracker {
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    let noteFrequencies:[Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let notes = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let octaves = [1,2,3,4,5,6]
    
    init() {
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    func getFrequncyInfo() -> (rowNumber: Int?, frequency:Float, offset: Float) {
        if tracker.amplitude > 0.1 {
            let trackerFrequency = Float(tracker.frequency)
            
            guard trackerFrequency < 7_000 else {
                // This is a bit of hack because of modern Macbooks giving super high frequencies
                return (nil, 0, 0)
            }
            
            
            // frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            var frequency = trackerFrequency
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }
            
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            
            let octave = Int(log2f(trackerFrequency / frequency))
            let offset = trackerFrequency - (noteFrequencies[index] * pow(Float(2), Float(octave)))
            
            let row = notes.count * (octave-1) + index
            
            return (row, trackerFrequency, offset);
        }
        //amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
        return (nil, 0, 0)
    }
    
    /**
      row divided by 12 notes, the quotient is the index of octave and remainder is the index of notes
     */
    func convertRowToNote(_ row: Int) -> (note: String, octave: Int){
        let index = Int(row / notes.count) // row / 12 notes
        let octave = octaves[index]
        let note = notes[row - index * notes.count]
        return (note, octave)
    }
    
}
