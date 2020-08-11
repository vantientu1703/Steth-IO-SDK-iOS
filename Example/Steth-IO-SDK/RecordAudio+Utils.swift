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

