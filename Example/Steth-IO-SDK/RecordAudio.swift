//
//  RecordAudio.swift
//  Steth-IO-Patient
//
//  Created by Alex on 06/12/19.
//  Copyright © 2019 AlexAppadurai. All rights reserved.
//

import UIKit

import Foundation
import AVFoundation
import AudioUnit

//https://gist.github.com/hotpaw2/ba815fc23b5d642705f2b1dedfaf0107
protocol RecordAudioDelegate:NSObjectProtocol {
    func recordAudioRenderInputModification(_ sample:UnsafeMutablePointer<Float>, frame:Int)
    func recordAudioRenderInputSample(_ sample:UnsafeMutablePointer<Float>, frame:Int, audioLevel:Float)
}
// call setupAudioSessionForRecording() during controlling view load
// call startRecording() to start recording in a later UI call
final class RecordAudio: NSObject {
    
    static let `default` = RecordAudio()
    
    private var audioUnit:   AudioUnit?     = nil
    
    private var micPermission   =  false
    public var sessionActive   =  false
    public var isRecording     =  false
    
    public   var sampleRate : Double = 44100.0    // default audio sample rate
    public  var input: UnsafeMutablePointer<Float>!
    private  var output: UnsafeMutablePointer<Float>!
    private  let circBuffSize = 32768        // lock-free circular fifo/buffer size
       private   var circBuffer   = [Float](repeating: 0, count: 32768)  // for incoming samples
    private  var hwSRate = 48000.0   // guess of device hardware sample rate
    private  var micPermissionDispatchToken = 0
    private  var interrupted = false     // for restart from audio interruption notification
    var numberOfChannels: Int       =  1
//    /// keep in-memory on audio buffer
    var buffers: Array<UnsafeMutablePointer<Float>>!
    private   var circInIdx  : Int =  0
       private  var audioLevel : Float  = 0.0
       
//
//
    private var maxFramesPerSlice:UInt32?
    
    weak var delegate:RecordAudioDelegate?
    public var isPause:Bool = false
    //MARK:- Start
    func startRecording() {
        if isRecording { return }
        startAudioSession()
        if sessionActive {
            startAudioUnit()
        }
    }
    
    private func startAudioUnit() {
        var err: OSStatus = noErr
        
        if self.audioUnit == nil {
            setupAudioUnit()         // setup once
        }
        guard let au = self.audioUnit
            else { return }
        input = UnsafeMutablePointer<Float>.allocate(capacity: 48000*20)
        output = UnsafeMutablePointer<Float>.allocate(capacity:  48000*20)
//        buffers = Array<UnsafeMutablePointer<Float>>()
        
        err = AudioUnitInitialize(au)
        if err != noErr { return }
        err = AudioOutputUnitStart(au)  // start
        
        if err == noErr {
            isRecording = true
        }
    }
    
    private func startAudioSession() {
        if (sessionActive == false) {
            // set and activate Audio Session
            do {
                
                let audioSession = AVAudioSession.sharedInstance()
                
                if (micPermission == false) {
                    if (micPermissionDispatchToken == 0) {
                        micPermissionDispatchToken = 1
                        audioSession.requestRecordPermission({(granted: Bool)-> Void in
                            if granted {
                                self.micPermission = true
                                return
                                // check for this flag and call from UI loop if needed
                            } else {
                               // to do
                                // dispatch in main/`UI thread an alert
                                //   informing that mic permission is not switched on
                            }
                        })
                    }
                }
                if micPermission == false { return }
                try audioSession.setCategory(.playAndRecord,mode: .measurement , options: [.allowBluetoothA2DP,.allowAirPlay,])
                // choose 44100 or 48000 based on hardware rate
                // sampleRate = 44100.0
                let preferredIOBufferDuration:TimeInterval = 58 / 1000      // 5.8 milliseconds = 256 samples
                hwSRate = audioSession.sampleRate           // get native hardware rate
//                if hwSRate == 48000.0 { sampleRate = 48000.0 }  // set session to hardware rate
//                if hwSRate == 48000.0 { preferredIOBufferDuration = 0.053 }
                let desiredSampleRate = sampleRate
                try audioSession.setPreferredSampleRate(desiredSampleRate)
                try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
//                try audioSession.overrideOutputAudioPort(.speaker)
                NotificationCenter.default.addObserver(
                    forName: AVAudioSession.interruptionNotification,
                    object: nil,
                    queue: nil,
                    using: myAudioSessionInterruptionHandler )
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                sessionActive = true
            } catch /* let error as NSError */ {
                // handle error here
            }
        }
    }
    //MARK:- Audio setup
    private func setupAudioUnit() {
        
        var componentDesc:  AudioComponentDescription
            = AudioComponentDescription(
                componentType:          OSType(kAudioUnitType_Output),
                componentSubType:       OSType(kAudioUnitSubType_RemoteIO),
                componentManufacturer:  OSType(kAudioUnitManufacturer_Apple),
                componentFlags:         UInt32(0),
                componentFlagsMask:     UInt32(0) )
        
        var osErr: OSStatus = noErr
        
        let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)
        
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
        self.audioUnit = tempAudioUnit
        
        guard let au = self.audioUnit
            else { return }
        
        // Enable I/O for input.
        
        var one_ui32: UInt32 = 1
        
        let outputBus: UInt32   =  0
        let inputBus: UInt32    =  1
        
        osErr = AudioUnitSetProperty(au,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input,
                                     inputBus,
                                     &one_ui32,
                                     UInt32(MemoryLayout<UInt32>.size))
        
        // Set format to 32-bit Floats, linear PCM
        let nc = 1  // 2 channel stereo
        var streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate:        Double(sampleRate),
            mFormatID:          kAudioFormatLinearPCM,
            mFormatFlags:       ( kAudioFormatFlagsNativeFloatPacked ),
            mBytesPerPacket:    UInt32(nc * MemoryLayout<UInt32>.size),
            mFramesPerPacket:   1,
            mBytesPerFrame:     UInt32(nc * MemoryLayout<UInt32>.size),
            mChannelsPerFrame:  UInt32(nc),
            mBitsPerChannel:    UInt32(8 * (MemoryLayout<UInt32>.size)),
            mReserved:          UInt32(0)
        )
        // UInt32 one = 1;
        var one = 1
        osErr = AudioUnitSetProperty(au,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input, inputBus,
                                     &one, UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        // set the stream format we want on the input to the outputbus (ie the format we are sending into the hardware render unit.)
        osErr = AudioUnitSetProperty(au,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input, outputBus,
                                     &streamFormatDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        // set the stream format we want on its input BUS - on the output of it (ie the format we are getting on callbacks from the hardware renderer)
        osErr = AudioUnitSetProperty(au,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Output,
                                     inputBus,
                                     &streamFormatDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        var numFramesPerBuffer:UInt32 = 1200;
        var size = UInt32(MemoryLayout<UInt32>.size)
        osErr = AudioUnitSetProperty(au,
                                     kAudioUnitProperty_MaximumFramesPerSlice,
                                     kAudioUnitScope_Global,
                                     outputBus,
                                     &numFramesPerBuffer, size)
        osErr = AudioUnitGetProperty(au,
        kAudioUnitProperty_MaximumFramesPerSlice,
        kAudioUnitScope_Global,
        outputBus,
        &numFramesPerBuffer,
        &size)
        self.maxFramesPerSlice = numFramesPerBuffer
        
        /// input audio callback
        var inputcallbackStruct
            = AURenderCallbackStruct(inputProc: inputCallback,
                                     inputProcRefCon:
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        osErr = AudioUnitSetProperty(au,AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
                                     AudioUnitScope(kAudioUnitScope_Global),
                                     inputBus,
                                     &inputcallbackStruct,
                                     UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        
        var outputcallbackStruct
            = AURenderCallbackStruct(inputProc: renderCallback,
                                     inputProcRefCon:
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        osErr = AudioUnitSetProperty(au,AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback),
                                     AudioUnitScope(kAudioUnitScope_Input),
                                     0,
                                     &outputcallbackStruct,
                                     UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        
    }
    //MARK:- AU  Callback
    
    /// https://stackoverflow.com/questions/27598404/whats-the-difference-with-render-callback-function-and-input-callback-function
    var inputCallback: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        frameCount,
        ioData ) -> OSStatus in
        
        let audioObject = unsafeBitCast(inRefCon, to: RecordAudio.self)
        var err: OSStatus = noErr
        
              
        // set mData to nil, AudioUnitRender() should be allocating buffers
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: UInt32(frameCount.sizeOf),
                mData: nil))
        
        if let au = audioObject.audioUnit {
            err = AudioUnitRender(au,
                                  ioActionFlags,
                                  inTimeStamp,
                                  inBusNumber,
                                  frameCount,
                                  &bufferList)
        }
//        if (frameCount > audioObject.maxFramesPerSlice!) {
//              frameCount = audioObject.maxFramesPerSlice;
//        }
        
        audioObject.processMicrophoneBuffer( inputDataList: &bufferList,
                                             frameCount: UInt32(frameCount) )
        
        return noErr
    }
    /// https://stackoverflow.com/questions/33715628/aurendercallback-in-swift
    let renderCallback: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        frameCount,
        ioData ) -> OSStatus in

        let audioObject = unsafeBitCast(inRefCon, to: RecordAudio.self)
        if audioObject.isPause {
            // no action
            return noErr
        }
        /// clear the audio to send microphone
        if let data = ioData {
             var audioBufferListPtr = UnsafeMutableAudioBufferListPointer.init(data)
                           let mBuffers : AudioBuffer = audioBufferListPtr[0]
                     audioBufferListPtr.forEach { (ab) in
                         if let d = ab.mData{
                             memset(ab.mData, 0, MemoryLayout<UInt32>.size * Int(ab.mDataByteSize))
                         }
                         // make a loop
         //                ab.mdata[i] = ringbuffer.read()
         //                memcpy(ab.mData, audioObject.input, Int(frameCount) *  MemoryLayout<Float>.size)
                         let fdata = ab.mData?.assumingMemoryBound(to: Float.self)
//                         audioObject.delegate?.playOutput(fdata, frame: Int(frameCount))
                        
                        memcpy(fdata,audioObject.input , Int(frameCount) * 4);
                        var lastVal = audioObject.input[ Int(frameCount) - 1];
                        fdata?[Int(frameCount)] = lastVal;
                     }
            //send to bluetooth
//            print("audi inp==\(audioObject.input.pointee)")
//            memcpy(audioObject.output,audioObject.input , frameCount.sizeOf);
//            print("audi out==\(audioObject.output.pointee)")
        }
        return noErr
    }
    //MARK:- Microphone buffer
    func processMicrophoneBuffer(   // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )  {
        if isPause {
            // no action
            return
        }
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]
        let count = Int(frameCount)
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)

        if let unsafeNewAudioFloat = bufferPointer?.assumingMemoryBound(to: Float.self){
//            buffers.append(unsafeNewAudioFloat)
           
            self.delegate?.recordAudioRenderInputModification(unsafeNewAudioFloat, frame: count)
            memcpy(input, unsafeNewAudioFloat, Int(frameCount) * 4)
            self.delegate?.recordAudioRenderInputSample(unsafeNewAudioFloat, frame: count, audioLevel: 0)
            
        }
    
}
     func stopRecording() {
        if let aunit = self.audioUnit {
            AudioUnitUninitialize(aunit)
            AudioComponentInstanceDispose(aunit);
            self.audioUnit = nil
//            buffers.removeAll()
            input.deallocate()
            output.deallocate()
            isRecording = false
            isPause = false
        }
//        free(input)
//        free(output)
    }
    
    func replay() {
        if isRecording == false {
            
        }
    }
    
    //MARK:- Notification
    func myAudioSessionInterruptionHandler(notification: Notification) -> Void {
        let interuptionDict = notification.userInfo
//        print("myAudioSessionInterruptionHandler", interuptionDict)
        if let interuptionType = interuptionDict?[AVAudioSessionInterruptionTypeKey] {
            let interuptionVal = AVAudioSession.InterruptionType(
                rawValue: (interuptionType as AnyObject).uintValue )
            if (interuptionVal == AVAudioSession.InterruptionType.began) {
                if (isRecording) {
                    stopRecording()
                    isRecording = false
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setActive(false)
                        sessionActive = false
                    } catch {
                    }
                    interrupted = true
                }
            } else if (interuptionVal == AVAudioSession.InterruptionType.ended) {
                if (interrupted) {
                    // potentially restart here
                }
            }
        }
    }
    deinit {
        print("StethViewController *******************************")
    }
}


extension AVAudioSession {

    static var isHeadphonesConnected: Bool {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        return session.isHeadphonesConnected
    }

    var isHeadphonesConnected: Bool {
        return !availableInputs!.filter { $0.isHeadphones }.isEmpty
    }

}

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headsetMic
    }
}

