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
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        errorLabel.text = ""
        errorLabel.textColor = .red
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
            RecordAudio.default.sessionActive = true
            RecordAudio.default.delegate = self
            
            //this is initializer method
            try StethIOManager.instance.apiKey(apiKey: "aOHHz2FoX03+2T3ziP9X9YEFZAxKnlAJ6qx4ybl614vLjgjFOOfNZt1ShuCTIKsC")
            
            //here we need to process the biquad files and apply filter
            try StethIOManager.instance.prepare()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                StethIOManager.instance.examType = .heart
                
                RecordAudio.default.startRecording()
                button.setTitle("Stop", for: .normal)
            }
            //this is used to change the heart/lung type
            
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
            //here is the process audio method
            try StethIOManager.instance.processStethAudio(sample: sample, count: frame)
            DispatchQueue.main.async {
                self.errorLabel.textColor = .green
                self.errorLabel.text = "Recording=====> \(StethIOManager.instance.examType)"
            }
            
        }catch {
            self.errorLabel.text = error.localizedDescription
            print(error)
        }
        
    }
    
    func recordAudioRenderInputSample(_ sample: UnsafeMutablePointer<Float>, frame: Int, audioLevel: Float) {
        
    }
    
    
}

