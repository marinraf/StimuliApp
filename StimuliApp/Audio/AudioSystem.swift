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
        var shouldUseMacConfiguration = false
        
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                shouldUseMacConfiguration = true
            }
        }
        
        if shouldUseMacConfiguration {
            let tempEngine = AVAudioEngine()
            let value = tempEngine.outputNode.outputFormat(forBus: 0).sampleRate
            print(value)
            Flow.shared.settings.updateAudioRate(new: value)
            myAUSampleRateHz = Float(Flow.shared.settings.audioRate)
        } else {
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
        
        var shouldUseMacConfiguration = false
        
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                shouldUseMacConfiguration = true
            }
        }
        
        let outputFormat: AVAudioFormat
        if shouldUseMacConfiguration {
            outputFormat = AVAudioFormat(standardFormatWithSampleRate: Double(Flow.shared.settings.audioRate),
                                         channels: 2)!
        } else {
            outputFormat = audioEngine!.outputNode.inputFormat(forBus: 0)
        }
        
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
        let sampleDelay = myAUSampleRateHz * Float(Flow.shared.frameControl.delay)

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

        myAUToneCounter = Int(audio[2]  + sampleDelay)

        self.originalCounter = myAUToneCounter
    }

    func stopAudio(forceStop: Bool) {
        if !Task.shared.testUsesLongAudios || forceStop {
            if myAUToneCounter > 10 {
                myAUToneCounterStop = Int(myAUChangingTones)
            }
        }
    }

    func pauseAudio() {
        if !Task.shared.testUsesLongAudios {
            originalCounter = myAUToneCounter
            myAUToneCounter = 0
        }
    }

    func resumeAudio() {
        if !Task.shared.testUsesLongAudios {
            myAUToneCounter = originalCounter
        }
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
            } else if i == 20 {
                myAudios.20 = outputBuffer
            } else if i == 21 {
                myAudios.21 = outputBuffer
            } else if i == 22 {
                myAudios.22 = outputBuffer
            } else if i == 23 {
                myAudios.23 = outputBuffer
            } else if i == 24 {
                myAudios.24 = outputBuffer
            } else if i == 25 {
                myAudios.25 = outputBuffer
            } else if i == 26 {
                myAudios.26 = outputBuffer
            } else if i == 27 {
                myAudios.27 = outputBuffer
            } else if i == 28 {
                myAudios.28 = outputBuffer
            } else if i == 29 {
                myAudios.29 = outputBuffer
            } else if i == 30 {
                myAudios.30 = outputBuffer
            } else if i == 31 {
                myAudios.31 = outputBuffer
            } else if i == 32 {
                myAudios.32 = outputBuffer
            } else if i == 33 {
                myAudios.33 = outputBuffer
            } else if i == 34 {
                myAudios.34 = outputBuffer
            } else if i == 35 {
                myAudios.35 = outputBuffer
            } else if i == 36 {
                myAudios.36 = outputBuffer
            } else if i == 37 {
                myAudios.37 = outputBuffer
            } else if i == 38 {
                myAudios.38 = outputBuffer
            } else if i == 39 {
                myAudios.39 = outputBuffer
            } else if i == 40 {
                myAudios.40 = outputBuffer
            } else if i == 41 {
                myAudios.41 = outputBuffer
            } else if i == 42 {
                myAudios.42 = outputBuffer
            } else if i == 43 {
                myAudios.43 = outputBuffer
            } else if i == 44 {
                myAudios.44 = outputBuffer
            } else if i == 45 {
                myAudios.45 = outputBuffer
            } else if i == 46 {
                myAudios.46 = outputBuffer
            } else if i == 47 {
                myAudios.47 = outputBuffer
            } else if i == 48 {
                myAudios.48 = outputBuffer
            } else if i == 49 {
                myAudios.49 = outputBuffer
            } else if i == 50 {
                myAudios.50 = outputBuffer
            } else if i == 51 {
                myAudios.51 = outputBuffer
            } else if i == 52 {
                myAudios.52 = outputBuffer
            } else if i == 53 {
                myAudios.53 = outputBuffer
            } else if i == 54 {
                myAudios.54 = outputBuffer
            } else if i == 55 {
                myAudios.55 = outputBuffer
            } else if i == 56 {
                myAudios.56 = outputBuffer
            } else if i == 57 {
                myAudios.57 = outputBuffer
            } else if i == 58 {
                myAudios.58 = outputBuffer
            } else if i == 59 {
                myAudios.59 = outputBuffer
            } else if i == 60 {
                myAudios.60 = outputBuffer
            } else if i == 61 {
                myAudios.61 = outputBuffer
            } else if i == 62 {
                myAudios.62 = outputBuffer
            } else if i == 63 {
                myAudios.63 = outputBuffer
            } else if i == 64 {
                myAudios.64 = outputBuffer
            } else if i == 65 {
                myAudios.65 = outputBuffer
            } else if i == 66 {
                myAudios.66 = outputBuffer
            } else if i == 67 {
                myAudios.67 = outputBuffer
            } else if i == 68 {
                myAudios.68 = outputBuffer
            } else if i == 69 {
                myAudios.69 = outputBuffer
            } else if i == 70 {
                myAudios.70 = outputBuffer
            } else if i == 71 {
                myAudios.71 = outputBuffer
            } else if i == 72 {
                myAudios.72 = outputBuffer
            } else if i == 73 {
                myAudios.73 = outputBuffer
            } else if i == 74 {
                myAudios.74 = outputBuffer
            } else if i == 75 {
                myAudios.75 = outputBuffer
            } else if i == 76 {
                myAudios.76 = outputBuffer
            } else if i == 77 {
                myAudios.77 = outputBuffer
            } else if i == 78 {
                myAudios.78 = outputBuffer
            } else if i == 79 {
                myAudios.79 = outputBuffer
            } else if i == 80 {
                myAudios.80 = outputBuffer
            } else if i == 81 {
                myAudios.81 = outputBuffer
            } else if i == 82 {
                myAudios.82 = outputBuffer
            } else if i == 83 {
                myAudios.83 = outputBuffer
            } else if i == 84 {
                myAudios.84 = outputBuffer
            } else if i == 85 {
                myAudios.85 = outputBuffer
            } else if i == 86 {
                myAudios.86 = outputBuffer
            } else if i == 87 {
                myAudios.87 = outputBuffer
            } else if i == 88 {
                myAudios.88 = outputBuffer
            } else if i == 89 {
                myAudios.89 = outputBuffer
            } else if i == 90 {
                myAudios.90 = outputBuffer
            } else if i == 91 {
                myAudios.91 = outputBuffer
            } else if i == 92 {
                myAudios.92 = outputBuffer
            } else if i == 93 {
                myAudios.93 = outputBuffer
            } else if i == 94 {
                myAudios.94 = outputBuffer
            } else if i == 95 {
                myAudios.95 = outputBuffer
            } else if i == 96 {
                myAudios.96 = outputBuffer
            } else if i == 97 {
                myAudios.97 = outputBuffer
            } else if i == 98 {
                myAudios.98 = outputBuffer
            } else if i == 99 {
                myAudios.99 = outputBuffer
            }
        }
    }
}
