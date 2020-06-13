//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import UIKit
import AudioToolbox
import AVFoundation

var soundCounter: Int = 1

struct AudioFile {
    let url: URL
    let buffer: AVAudioPCMBuffer
    let player: AVAudioPlayerNode
}


class AudioSystem {

    var audioEngine: AVAudioEngine?
    var myAUNode: AVAudioUnit?
    var mixer = AVAudioMixerNode()
    var audioPlayer: AVAudioPlayer?
    var originalCounter: Int = 0
    var audioFiles: [AudioFile] = []
    var sess: AVAudioSession?
    

    func setup(songs: [URL?]) {
        sess = AVAudioSession.sharedInstance()

        if let sess = sess {
            do {
                let durationBuffer = Constants.bufferAudio
                try sess.setCategory(.playback, mode: .default, options: [])
                try sess.setPreferredIOBufferDuration(durationBuffer)
                try sess.setActive(true)

                Flow.shared.settings.updateAudioRate(new: sess.sampleRate)
                myAUSampleRateHz = Float(Flow.shared.settings.audioRate)
            } catch { }
        }

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

        loadAudios(songs: songs)
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

    func playAudios(audio: [Float]) {
        Timer.scheduledTimer(withTimeInterval: Flow.shared.frameControl.delay, repeats: false) { (_) in
            self.playAudiosDelay(audio: audio)
        }
    }

    func playAudiosDelay(audio: [Float]) {
        myAUToneCounterStop = 0
        myAUChangingTones = audio[0]
        myAUNumberOfAudios = Int32(audio[1] + 0.1)

        myAUStart = (Int(audio[3]), Int(audio[4]), Int(audio[5]), Int(audio[6]), Int(audio[7]),
                     Int(audio[8]), Int(audio[9]), Int(audio[10]), Int(audio[11]), Int(audio[12]))

        myAUEnd = (Int(audio[13]), Int(audio[14]), Int(audio[15]), Int(audio[16]), Int(audio[17]),
                   Int(audio[18]), Int(audio[19]), Int(audio[20]), Int(audio[21]), Int(audio[22]))

        myAUFrequency = (audio[23], audio[24], audio[25], audio[26], audio[27],
                         audio[28], audio[29], audio[30], audio[31], audio[32])

        myAUAmplitude = (audio[33], audio[34], audio[35], audio[36], audio[37],
                         audio[38], audio[39], audio[40], audio[41], audio[42])

        myAUChannel = (audio[43], audio[44], audio[45], audio[46], audio[47],
                       audio[48], audio[49], audio[50], audio[51], audio[52])

        myAUPhase = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        myAUSong = (Int32(audio[53] + 0.1), Int32(audio[54] + 0.1), Int32(audio[55] + 0.1), Int32(audio[56] + 0.1),
                    Int32(audio[57] + 0.1), Int32(audio[58] + 0.1), Int32(audio[59] + 0.1), Int32(audio[60] + 0.1),
                    Int32(audio[61] + 0.1), Int32(audio[62] + 0.1))

        myAUToneCounter = audio[2].toInt

        self.originalCounter = myAUToneCounter
    }

    
    func stopAudio() {
        Timer.scheduledTimer(withTimeInterval: Flow.shared.frameControl.delay, repeats: false) { (_) in
            self.stopAudioDelay()
        }
    }

    func stopAudioDelay() {
        if myAUToneCounter > 10 {
            myAUToneCounterStop = Int(myAUChangingTones)
        }
    }

    func pauseAudio() {
        originalCounter = myAUToneCounter
        myAUToneCounter = 0
    }

    func resumeAudio() {
        myAUToneCounter = originalCounter
    }

    func loadAudios(songs: [URL?]) {
        audioFiles = []

        for i in 0 ..< songs.count {
            guard let song = songs[i] else { continue }

            guard let audioFile = try? AVAudioFile(forReading: song) else { continue }

            let inputFormat = audioFile.processingFormat

            let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                             sampleRate: Double(Flow.shared.settings.audioRate),
                                             channels: 2,
                                             interleaved: false)!

            guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else { continue }

            let inputFC = UInt32(audioFile.length)
            guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat,
                                                     frameCapacity: inputFC) else { continue }

            let outputFC = inputFC / UInt32(inputFormat.sampleRate) * UInt32(Flow.shared.settings.audioRate)
            guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
                                                      frameCapacity: outputFC) else { continue }
            do {
                try audioFile.read(into: inputBuffer)
            } catch{
                print("over")
            }

            let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return inputBuffer
            }

            var error: NSError? = nil
            let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputCallback)
            assert(status != .error)

            if i == 0 {
                myAudios.0 = outputBuffer
            } else if i == 1 {
                myAudios.1 = outputBuffer
            } else if i == 2 {
                myAudios.2 = outputBuffer
            } else if i == 3 {
                myAudios.3 = outputBuffer
            } else if i == 4 {
                myAudios.4 = outputBuffer
            } else if i == 5 {
                myAudios.5 = outputBuffer
            } else if i == 6 {
                myAudios.6 = outputBuffer
            } else if i == 7 {
                myAudios.7 = outputBuffer
            } else if i == 8 {
                myAudios.8 = outputBuffer
            } else if i == 9 {
                myAudios.9 = outputBuffer
            } else if i == 10 {
                myAudios.10 = outputBuffer
            } else if i == 11 {
                myAudios.11 = outputBuffer
            } else if i == 12 {
                myAudios.12 = outputBuffer
            } else if i == 13 {
                myAudios.13 = outputBuffer
            } else if i == 14 {
                myAudios.14 = outputBuffer
            } else if i == 15 {
                myAudios.15 = outputBuffer
            } else if i == 16 {
                myAudios.16 = outputBuffer
            } else if i == 17 {
                myAudios.17 = outputBuffer
            } else if i == 18 {
                myAudios.18 = outputBuffer
            } else if i == 19 {
                myAudios.19 = outputBuffer
            }
        }
    }
}
