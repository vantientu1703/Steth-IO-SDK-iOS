//
//  SpeackerRoute.swift
//  Steth-IO-Patient
//
//  Created by Alex on 06/12/19.
//  Copyright © 2019 AlexAppadurai. All rights reserved.
//

import Foundation
import AVFoundation
import AudioUnit

class SpeackerRoute{
    
    
    // You must set a preferred number of input channels only after setting the audio session’s category and mode and activating the session.
    func setInputToBuiltInMicAndNoiseCancel(inputType: AVAudioSession.Port = AVAudioSession.Port.builtInMic)  throws{
 
        let session = AVAudioSession.sharedInstance();
        try session.setCategory(.playAndRecord, mode: AVAudioSession.Mode.measurement, options: [.allowBluetoothA2DP,.allowAirPlay,.allowBluetooth])
        try session.setActive(true)

        print("About to set input which is currently: %@",session.currentRoute.inputs)
        //NSLog(@"About to set input which is currently: %@", session.currentRoute.inputs);
        
        // Get the set of input ports that are available for routing
        // each item is an AVAudioSessionPortDescription
        guard  let portDescription = (session.availableInputs?.filter { (pd) -> Bool in
            return pd.portType == inputType
        }.first) else {
            throw NSError.init(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "portDescription not available : "])
        }
        if session.inputDataSource != portDescription {
              try session.setPreferredInput(portDescription)
        }
      
        // get available input source from current available input
        if let availableInputs = (session.currentRoute.inputs.filter { (pd) -> Bool in
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
        
        guard let lower = ( (portDescription.dataSources ?? []).filter { (dsd) -> Bool in
            /// datasource descriptoin
            if let l = dsd.location {
                return l == AVAudioSession.Location.lower
            }
            return false
        }.first ) else {
            print("source data is already in av session location lower")
            return;
        }
        
        try portDescription.setPreferredDataSource(lower)
    
    }
    
}
