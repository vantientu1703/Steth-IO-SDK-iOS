//
//  RecordAudio+Utils.swift
//  Steth-IO-Patient
//
//  Created by Alex on 06/12/19.
//  Copyright © 2019 AlexAppadurai. All rights reserved.
//

import Foundation
import AudioUnit
import AVFoundation
import StethIO

let  kAudioFrequencyExact:Double = 44100.0;

extension RecordAudio{
    // used when pressing stop to avoid pops
    func applyVolumeReduction(_ startingVolume :Double,_ timeToZero :Double,_ buff0:UnsafeMutablePointer<Float>?,buff1:UnsafeMutablePointer<Float>?, frame:UInt32)-> Double{
        let volumePerFrame = 1/kAudioFrequencyExact/timeToZero;
        var volume = startingVolume;
        for i in 0..<Int(frame) {
            let gain = Float(volume*volume*volume)
            volume -= volumePerFrame;
            if let b0 = buff0{
                b0[i] = b0[i]*gain;
            }
            if let b1 = buff1{
                b1[Int(i)] = b1[i]*gain;}
        }
        return volume
    }
    
    func write()->URL?{
        let sampleCount = StethIOManager.instance.numStethSamplesRecorded()
        let buffers:UnsafeMutablePointer<Float> = StethIOManager.instance.recordedStethAudioSamples()
        defer {
            StethIOManager.instance.clearRecordedStethAudio()
        }
        //let buffers:UnsafeMutablePointer<Float> = glsteth_filterSoundBuffer(obj)
        //let sampleCount = glsteth_filterSoundBufferSize(obj);
        //        let sampleCount = Int(kAudioFrequencyExact * endTime)
      return  write(buffers: buffers, sampleCount: Int(sampleCount));
    }
    func write(buffers: UnsafeMutablePointer<Float>, sampleCount:Int)-> URL? {
        //https://stackoverflow.com/questions/42178958/write-array-of-floats-to-a-wav-audio-file-in-swift

        var docPath = ""
        
        let dm = DirectoryManager(folderType: DirectoryManager.LocalFolder.examAudio)
        docPath = dm.path
        let url = URL.init(fileURLWithPath: "\(docPath)exam-\(Int.random(in: 0...10000)).wav")
        
        let SAMPLE_RATE =  RecordAudio.default.sampleRate
        
        let outputFormatSettings = [
            AVFormatIDKey:kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey:32,
            AVLinearPCMIsFloatKey: true,
//              AVLinearPCMIsBigEndianKey: false,
            AVSampleRateKey: SAMPLE_RATE,
            AVNumberOfChannelsKey: 1
            ] as [String : Any]
        
        let audioFile = try? AVAudioFile(forWriting: url, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)
        
        let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
        
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(sampleCount))
        
        // i had my samples in doubles, so convert then write
        for i in 0..<sampleCount {
            outputBuffer?.floatChannelData!.pointee[i] = buffers[i]
        }
        outputBuffer?.frameLength = AVAudioFrameCount( sampleCount)
        do{
            try audioFile?.write(from: outputBuffer!)
            
        } catch let error as NSError {
            print("error:", error.localizedDescription)
        }
        return url;
    }
    
}

extension UInt32{
    var sizeOf:Int{
        return MemoryLayout<UInt32>.size * Int(self)
    }
    var sizeOfU:UInt32{
        return UInt32(MemoryLayout<UInt32>.size * Int(self))
    }
}
extension Float{
    var sizeOf:Int{
        return MemoryLayout<Float>.size * Int(self)
    }
    var toIn16T:UInt32{
        var f = self;
        if (f > 1.0){ f = 1.0;}
        if (f < 0){ f = 1.0;}
        return UInt32(f * 0x7fff);
    }
    
}
extension Int{
    var sizeOf:Int{
        return  MemoryLayout<UInt32>.size * self
    }
}

