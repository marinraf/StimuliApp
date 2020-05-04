//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import UIKit
import AudioToolbox
import AVFoundation

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
    

    func setup(songs: [URL?]) {
        let sess = AVAudioSession.sharedInstance()

        do {
            Flow.shared.settings.updateAudioRate(new: sess.sampleRate)
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

        myAUSong = (audio[53], audio[54], audio[55], audio[56], audio[57],
                    audio[58], audio[59], audio[60], audio[61], audio[62])
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

//    func playSong(song: URL, volume: Float) {
//        print("start", CACurrentMediaTime())
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: song, fileTypeHint: AVFileType.mp3.rawValue)
//            audioPlayer?.setVolume(0, fadeDuration: 0)
//            print("play", CACurrentMediaTime())
//            audioPlayer?.play()
//            print("done", CACurrentMediaTime())
//            audioPlayer?.setVolume(volume, fadeDuration: TimeInterval(2))
////            audioPlayer?.setVolume(volume, fadeDuration: TimeInterval(Flow.shared.settings.rampTime))
//            print("volume", CACurrentMediaTime())
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }

    func loadAudios(songs: [URL?]) {


//        for song in songs {
//            guard let song = song else { continue }
//            guard let audioFile = try? AVAudioFile(forReading: song) else { continue }
//
//            if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
//                                          sampleRate: audioFile.fileFormat.sampleRate,
//                                          channels: 1,
//                                          interleaved: false) {
//
//                if let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024) {
//                    try! file.read(into: buf)
//
//                    // this makes a copy, you might not want that
//                    let floatArray = UnsafeBufferPointer(start: buf.floatChannelData![0], count:Int(buf.frameLength))
//                    // convert to data
//                    var data = Data()
//                    for buf in floatArray {
//                        data.append(withUnsafeBytes(of: buf) { Data($0) })
//                    }
//                    // use the data if required.
//                }
//            }
//
//        }

        print("start loading songs", CACurrentMediaTime())
        audioFiles = []

        for i in 0 ..< songs.count {
            guard let song = songs[i] else { continue }

            guard let audioFile = try? AVAudioFile(forReading: song) else { continue }

//            let audioFile2 = AVAudioFile()

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

//            guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
//                                                      frameCapacity: outputFC) else { return }

            var error: NSError? = nil
            let status = converter.convert(to: outputBuffer, error: &error, withInputFrom: inputCallback)
            assert(status != .error)

            print("")
            print("format", outputBuffer.format)
            print("float channel data", outputBuffer.floatChannelData!)
            print("bytes per frame", outputBuffer.format.streamDescription.pointee.mBytesPerFrame)


            let prueba = Array(UnsafeBufferPointer(start: outputBuffer.floatChannelData![0],
                                                   count: Int(outputBuffer.frameLength)))

            print("")
            print("count", prueba.count)
            print("framelength", outputBuffer.frameLength)




////            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!,
////                                               frameCapacity: UInt32(data.count)/(audioFormat?.streamDescription.pointee.mBytesPerFrame)!)
////
////            audioBuffer.frameLength = audioBuffer.frameCapacity
//
//            let channels = UnsafeBufferPointer(start: audioFileBuffer.floatChannelData, count: Int(audioFormat!.channelCount))
//
//            data.copyBytes(to: UnsafeMutablePointer<Float>(channels[0]))
//
//
//            _ = data.copyBytes(to: UnsafeMutableBufferPointer(start: channels[0], count: Int(audioBuffer.frameLength)))



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


//            nose = audioFileBuffer

//            prueba = UnsafeBufferPointer(start: outputBuffer.floatChannelData![0],
//                                       count: Int(outputBuffer.frameLength))




//            let a: [Float] = [1, 2]
//
//            prueba2 = a

//            let prueba1 = UnsafeBufferPointer(start: outputBuffer.floatChannelData![0],
//                                              count: Int(outputBuffer.frameLength))
//
//
//            prueba2 = prueba1.copyBytes(to: UnsafeMutableBufferPointer(start: outputBuffer.floatChannelData![0],
//                                                                      count: Int(outputBuffer.frameLength)))








//
//            let noset2 = noset.copyBytes(to: UnsafeMutableBufferPointer(start: audioFileBuffer.floatChannelData![0], count: Int(audioFileBuffer.frameLength)))



//            let audioFilePlayer = AVAudioPlayerNode()
//            self.audioEngine!.attach(audioFilePlayer)
//            self.audioEngine!.connect(audioFilePlayer,
//                                      to: self.audioEngine!.mainMixerNode,
//                                      format: audioFileBuffer.format)
//            audioFilePlayer.play()
//
//            let audio = AudioFile(url: song, buffer: audioFileBuffer, player: audioFilePlayer)
//
//            audioFiles.append(audio)
        }
        print("songs loaded", CACurrentMediaTime())
    }

    func playSong(song: URL, volume: Float) {
        print("")
        let a = CACurrentMediaTime()
        print("start", 0)

        if let audio = audioFiles.first(where: { $0.url == song }) {

            audioEngine?.mainMixerNode.outputVolume = 0

//            audio.player.volume = 0
//            audioEngine?.reset()





//            while engine.manualRenderingSampleTime < sourceFile.length {
//                do {
//                    let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(sourceFile.length - engine.manualRenderingSampleTime))
//                    let status = try engine.renderOffline(framesToRender, to: buffer)
//                    switch status {
//                    case .success:
//                        // data rendered successfully
//                        try outputFile.write(from: buffer)
//
//                    case .insufficientDataFromInputNode:
//                        // applicable only if using the input node as one of the sources
//                        break
//
//                    case .cannotDoInCurrentContext:
//                        // engine could not render in the current render call, retry in next iteration
//                        break
//
//                    case .error:
//                        // error occurred while rendering
//                        fatalError("render failed")
//                    }
//                } catch {
//                    fatalError("render failed, \(error)")
//                }
//            }






            audio.player.scheduleBuffer(audio.buffer, at: nil, options:AVAudioPlayerNodeBufferOptions.loops)
            let b = CACurrentMediaTime()

//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                self.audioEngine?.mainMixerNode.outputVolume = 0.5
//            })

//            fadeVolumeAndPause(player: audio.player, time: 0.001)

            print("done", (b - a) * 1000)
            print("")
        }
    }

    func fadeVolumeAndPause(player: AVAudioPlayerNode, time: Double) {
        if audioEngine!.mainMixerNode.outputVolume < 1 {
            audioEngine!.mainMixerNode.outputVolume = audioEngine!.mainMixerNode.outputVolume + 0.001

            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                self.fadeVolumeAndPause(player: player, time: time)
            })

//            var dispatchTime = dispatch_time(DispatchTime.now(), Int64(0.1 * Double(NSEC_PER_SEC)))
//            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                self.fadeVolumeAndPause()
//            })

        }
//        } else {
//            player.pause()
//            player.volume = 1.0
//        }
    }

//    func playSong(song: URL, volume: Float) {
//        print("")
//        let a = CACurrentMediaTime()
//        print("start", 0)
//        let audioFilePlayer = AVAudioPlayerNode()
//
//        if let songToPlay = audioFileBuffers.first(where: { $0.0 == song }) {
//            self.audioEngine!.attach(audioFilePlayer)
//            let b = CACurrentMediaTime()
//            print("before play", (b - a) * 1000)
//            self.audioEngine!.connect(audioFilePlayer,
//                                      to: self.audioEngine!.mainMixerNode,
//                                      format: songToPlay.1.format)
//            let c = CACurrentMediaTime()
//            print("play", (c - b) * 1000)
//            audioFilePlayer.play()
//            let d = CACurrentMediaTime()
//            print("after play", (d - c) * 1000)
//            audioFilePlayer.scheduleBuffer(songToPlay.1, at: nil, options:AVAudioPlayerNodeBufferOptions.loops)
//            let e = CACurrentMediaTime()
//            print("done", (e - d) * 1000)
//        }
//    }

    func stopSong() {
        print("stop", CACurrentMediaTime())
        audioPlayer?.stop()
    }

    func pauseSong() {
        print("pause", CACurrentMediaTime())
        audioPlayer?.pause()
    }

    func resumeSong() {
        audioPlayer?.play()
    }

    func fadeOutSong() {
//        print("fadeOut", CACurrentMediaTime())
//        let serialQueue = DispatchQueue(label: "fadeOutStop")
//
//        serialQueue.async {
//            print("Task 1 started", CACurrentMediaTime())
//            audioPlayer?.setVolume(0, fadeDuration: 0.003)
//            perform(#selector(fadeOutSong), with: nil, afterDelay: 0.1)
//            print("Task 1 finished", CACurrentMediaTime())
//        }
//        print("doing other thing", CACurrentMediaTime())

        print("fadeOut", CACurrentMediaTime())
        audioPlayer?.setVolume(0, fadeDuration: 0.003)
    }
}
