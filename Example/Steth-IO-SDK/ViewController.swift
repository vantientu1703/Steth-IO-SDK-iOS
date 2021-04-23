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
            let url = RecordAudio.default.write()
            if let u = url {
                writeToFiles(u)
            }
            button.setTitle("Start", for: .normal)
            RecordAudio.default.stopRecording()
            self.errorLabel.text = ""
            RecordAudio.default.delegate = nil
            // this is to dealloc objects
            StethIOManager.instance.stopFiltering()
            return
        }
        
        let ok = SpeackerRoute()
        do {
            try ok.setInputToBuiltInMicAndNoiseCancel(inputType: .builtInMic)
            RecordAudio.default.delegate = self
            RecordAudio.default.sampleRate = 44100
            //this is initializer method
            try StethIOManager.instance.apiKey(apiKey: "aOHHz2FoX03+2T3ziP9X9YEFZAxKnlAJ6qx4ybl614vLjgjFOOfNZt1ShuCTIKsC")
            
            //this is used to change the heart/lung type
            StethIOManager.instance.examType = .heart

            
            //here we need to process the biquad files and apply filter
            try StethIOManager.instance.prepare()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                RecordAudio.default.startRecording()
                button.setTitle("Stop", for: .normal)
            }
            
        }
        catch {
            self.errorLabel.text = error.localizedDescription
            print(error)
        }
        
    }
    
    func writeToFiles(_ url: URL){
        if let _ = try? Data(contentsOf: url) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController : RecordAudioDelegate {
    
    
    func recordAudioRenderInputModification(_ sample: UnsafeMutablePointer<Float>, frame: Int) {
        do{
            //here is the process audio method
            try StethIOManager.instance.processStethAudio(sample: sample, count: frame)
            StethIOManager.instance.recordStethAudioSamples(samples: sample, numSamples: Int32(frame))

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

