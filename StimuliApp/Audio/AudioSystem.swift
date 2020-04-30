//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import UIKit
import AudioToolbox
import AVFoundation


class AudioSystem {

    var audioEngine: AVAudioEngine?
    var myAUNode: AVAudioUnit?
    var mixer = AVAudioMixerNode()
    var audioPlayer: AVAudioPlayer?
    var originalCounter: Int = 0

    func setup() {
        let sess = AVAudioSession.sharedInstance()

        do {
            myAUSampleRateHz = Float(Flow.shared.settings.audioRate)
            let durationBuffer = 1 * (256.0/Double(Flow.shared.settings.audioRate))
            try sess.setCategory(.playback, mode: .default, options: [])
            try sess.setPreferredIOBufferDuration(durationBuffer) // 256 samples
            try sess.setActive(true)
        } catch { }

        audioEngine = AVAudioEngine()

        let myUnitType = kAudioUnitType_Generator
        let mySubType: OSType = 1
        let compDesc = AudioComponentDescription(componentType: myUnitType,
                                                 componentSubType: mySubType,
                                                 componentManufacturer: 0x666f6f20, // 4 hex byte OSType 'foo'
            componentFlags: 0,
            componentFlagsMask: 0 )

        AUAudioUnit.registerSubclass(MyAudioUnit.self,
                                     as: compDesc,
                                     name: "MyAudioUnit", // my AUAudioUnit subclass
            version: 1)

        let outFormat = audioEngine!.outputNode.outputFormat(forBus: 0)
        AVAudioUnit.instantiate(with: compDesc,
                                options: .init(rawValue: 0)) { (audiounit, error) in

                                    if let audiounit = audiounit {
                                        self.myAUNode = audiounit // save AVAudioUnit
                                        self.audioEngine!.attach(audiounit)
                                        self.audioEngine!.connect(audiounit,
                                                                  to: self.audioEngine!.mainMixerNode,
                                                                  format: outFormat)
                                    } else {
                                        print("")
                                        print("ERROR AV AUDIO")
                                        print(error!)
                                        print("END ERROR")
                                        print("")
                                    }
        }
    }

    func begin() {
        myAUAmplitude = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let outputFormat = audioEngine!.outputNode.inputFormat(forBus: 0) // AVAudioFormat
        audioEngine!.connect(audioEngine!.mainMixerNode,
                             to: audioEngine!.outputNode,
                             format: outputFormat)
        audioEngine!.prepare()

        do {
            try audioEngine!.start()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func playSound(audio: [Float]) {
        myAUToneCounter = audio[2].toInt
        myAUToneCounterStop = 0
        self.originalCounter = myAUToneCounter
        myAUChangingTones = audio[0]
        myAUNumberOfAudios = Int32(audio[1] + 0.1)

        myAUStart = (audio[3], audio[4], audio[5], audio[6], audio[7],
                     audio[8], audio[9], audio[10], audio[11], audio[12])

        myAUEnd = (audio[13], audio[14], audio[15], audio[16], audio[17],
                   audio[18], audio[19], audio[20], audio[21], audio[22])

        myAUFrequency = (audio[23], audio[24], audio[25], audio[26], audio[27],
                         audio[28], audio[29], audio[30], audio[31], audio[32])

        myAUAmplitude = (audio[33], audio[34], audio[35], audio[36], audio[37],
                         audio[38], audio[39], audio[40], audio[41], audio[42])

        myAUChannel = (audio[43], audio[44], audio[45], audio[46], audio[47],
                       audio[48], audio[49], audio[50], audio[51], audio[52])
        myAUPhase = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    func stopSound() {
        if myAUToneCounter > 10 {
            myAUToneCounterStop = Int(myAUChangingTones)
        }
    }

    func pauseSound() {
        originalCounter = myAUToneCounter
        myAUToneCounter = 0
    }

    func resumeSound() {
        myAUToneCounter = originalCounter
    }

    func playSong(song: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func stopSong() {
        audioPlayer?.stop()
    }

    func pauseSong() {
        audioPlayer?.pause()
    }

    func resumeSong() {
        audioPlayer?.play()
    }
}
