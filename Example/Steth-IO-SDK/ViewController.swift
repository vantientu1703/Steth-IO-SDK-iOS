//
//  ViewController.swift
//  Example
//
//  Created by Alex on 18/05/20.
//  Copyright © 2020 StethIO. All rights reserved.
//

import UIKit
import StethIO


class ViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
         try? StethIOManager.instance.apiKey(apiKey: "ypAPq9sohb1SHmKmlJFZdjSmbBmFmwMQWBK+I24AQlHzJYf7MDDpyAM6bouj2vib")
        //StethIOManager
        // Do any additional setup after loading the view.
    }
 
    @IBAction func startButtonAction(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        if RecordAudio.default.isRecording {
            button.setTitle("Start", for: .normal)
            RecordAudio.default.stopRecording()
            RecordAudio.default.delegate = nil
            // this is to dealloc objects
            StethIOManager.instance.stopFiltering()
            return
        }
        
        let ok = SpeackerRoute()
        do {
            try ok.setInputToBuiltInMicAndNoiseCancel(inputType: .builtInMic)
            RecordAudio.default.delegate = self
            
            //this is initializer method
            try StethIOManager.instance.apiKey(apiKey: "ypAPq9sohb1SHmKmlJFZdjSmbBmFmwMQWBK+I24AQlHzJYf7MDDpyAM6bouj2vib")
            
            //here we need to process the biquad files and apply filter
            try StethIOManager.instance.prepare()
            
            //this is used to change the heart/lung type
            StethIOManager.instance.examType = .lung
            
            RecordAudio.default.startRecording()
             button.setTitle("Stop", for: .normal)
        }
        catch {
            self.errorLabel.text = error.localizedDescription
            print(error)
        }
       
    }
    
}

extension ViewController : RecordAudioDelegate {
   
    
    func recordAudioRenderInputModification(_ sample: UnsafeMutablePointer<Float>, frame: Int) {
        do{
//            let sam = sample.pointee
            //here is the process audio method
            try StethIOManager.instance.processStethAudio(sample: sample, count: frame)
            print(sample.pointee)
            print(StethIOManager.instance.examType)
        }catch {
            self.errorLabel.text = error.localizedDescription
            print(error)
        }
      
    }
    
    func recordAudioRenderInputSample(_ sample: UnsafeMutablePointer<Float>, frame: Int, audioLevel: Float) {
        
    }
    
    
}

