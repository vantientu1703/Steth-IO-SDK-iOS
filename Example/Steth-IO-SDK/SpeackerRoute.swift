//
//  SpeackerRoute.swift
//  StethIOGraph
//
//  Created by Alex on 06/12/19.
//  Copyright © 2019 AlexAppadurai. All rights reserved.
//

import Foundation
import AVFoundation
import AudioUnit

class SpeackerRoute{
    
    
    // You must set a preferred number of input channels only after setting the audio session’s category and mode and activating the session.
    func setInputToBuiltInMicAndNoiseCancel(inputType: AVAudioSession.Port)  throws{
        let session = AVAudioSession.sharedInstance();
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetoothA2DP,.allowAirPlay])
//        try session.setActive(true)
       

        print("About to set input which is currently: %@",session.availableInputs)
        //NSLog(@"About to set input which is currently: %@", session.currentRoute.inputs);
        
        // Get the set of input ports that are available for routing
        // each item is an AVAudioSessionPortDescription
        guard  let portDescription = (session.availableInputs?.filter { (pd) -> Bool in
            print("type===>\(pd.portName)")
            return pd.portType == inputType
        }.first) else {
            throw NSError.init(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "portDescription not available : "])

        }
        print("selectef===>\(portDescription)")
        try session.setPreferredInput(portDescription)
//        try session.setpr
        // get available input source from current available input
        if let availableInputs = ( session.currentRoute.inputs.filter { (pd) -> Bool in
            return pd.portType == portDescription.portType
        }.first) {
            if let ds = availableInputs.selectedDataSource?.location, ds == AVAudioSession.Location.lower{
                       /// to do
                       print("source data is already in av session location lower")
                       return;
                   }
            // call in 5 secs or so to try again? or maybe with preferred set when the call is done the phone will switch to the microphone.
            print("inputPort was NOT set. Perhaps they are on a phone call! : \(portDescription.description)")
        }
        
       
        
//        try session.setActive(true)
        
    }
    
    static func currentRouteIsTinnyBuiltInSpeaker() -> Bool {
       let session = AVAudioSession.sharedInstance()
        var foundOnPhoneSpeaker = false
        var foundBlueTooth = false
        for aPort in session.currentRoute.outputs {
            let portType = aPort.portType
            if (portType == .builtInSpeaker) || (portType == .builtInReceiver) {
                foundOnPhoneSpeaker = true // we will get feedback...
            }
            if (portType == .bluetoothA2DP) || (portType == .bluetoothLE) || (portType == .airPlay) {
                foundBlueTooth = true // we should not stop audio.
            }
        }

        if foundBlueTooth {
            return false // bluetooth likely fine
        }
        if foundOnPhoneSpeaker {
            return true // tinny speaker AVAudioSessionPortBuiltInSpeaker AVAudioSessionPortBuiltInReceiver
        }

        return false // otherwise ok I guess.
    }
}
