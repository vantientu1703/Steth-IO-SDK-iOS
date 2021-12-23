//
//  ViewController.swift
//  SDKTest
//
//  Created by naveen on 23/04/21.
//

import UIKit
import StethIO
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var samplesPickerView: UIPickerView!
    @IBOutlet weak var modePickerView: UIPickerView!
    var stethManager: StethIOManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermission()
        setupStethIOManager()
    }
    
    private func setupStethIOManager() {
        self.stethManager = StethIOManager.init()
        stethManager.apiKey = "aOHHz2FoX03+2T3ziP9X9YEFZAxKnlAJ6qx4ybl614vLjgjFOOfNZt1ShuCTIKsC"
        stethManager.delegate = self
        stethManager.sampleType = .none
        stethManager.examType = .heart
        stethManager.setupGraphView(graphView: graphView, in: self)
    }
    
    
    private func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            //handle negative scenario here
        }
    }
    
    @IBAction func startAction() {
        do {
            //this is used to change the heart/lung type
            stethManager.examType = .heart

            
            //here we need to process the biquad files and apply filter
            try stethManager.prepare()
            
            //This will start the recording
            try self.stethManager.startRecording()
            
            samplesPickerView.isUserInteractionEnabled = false

        }
        catch {
            print(error)
        }
        
    }
    @IBAction func stopAction() {
        //This will start the recording
        stethManager.stopRecording()
        samplesPickerView.isUserInteractionEnabled = true
    }


}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == modePickerView {
            return 2
        }
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == modePickerView {
            return row == 0 ? "Heart" : "Lung"
        }
        if row == 0{
            return "None"
        } else if row == 1{
            return "Raw Samples"
        } else {
            return "Processed Samples"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == modePickerView {
            self.stethManager.examType = row == 0 ? .heart : .lung
        }
        if row == 0{
            self.stethManager.sampleType = .none
        } else if row == 1{
            self.stethManager.sampleType = .rawSamples
        } else if row == 2 {
            self.stethManager.sampleType = .processedSamples
        }
    }
}


extension ViewController: StethIOManagerDelegate{
    func heartExamBPM(bpm: Double) {
        print("BPM\(bpm)")
    }
    
    func savedAudioSamples(url: URL) {
        if let _ = try? Data(contentsOf: url) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
           
        }
    }
    
    
}
