# Steth-IO-SDK

## Example

To run the example project, clone the repo from the Example directory first.

## Requirements
- The recording frequency must be 44.1khz because the filters are designed in such way.
- The heart/lung filters will work as expected only with Steth IO hardware.

## Installation 📱

### CocoaPods

Use [CocoaPods](http://www.cocoapods.org).

1. Add `pod 'Steth-IO-SDK'` to your *Podfile* with source like below.

```ruby
pod 'Steth-IO-SDK', :git => 'https://github.com/StratoScientific/Steth-IO-SDK-iOS.git'
```
2. Install the pod(s) by running `pod install`.
3. Add `import StethIO` in the .swift files where you want to use it



### SDK Usage ✨
1. In ViewController
    ```swift
    //Initializer
    let stethManager = StethIOManager.init()
    
    //Set delegate to receive bpm and saved samples url
    stethManager.delegate = self
    
    //set the filter mode to heart/lung
    stethManager.examType = .heart //for heart
    stethManager.examType = .lung //for lungs
    
    //set the sample type to none/processedSamples/rawSamples
    stethManager.sampleType = .none
    
    //Pass 'UIView' instance to graphview parameter. This view will render the graph visualisation
    stethManager.setupGraphView(graphView: graphView, in: self)
    
    //Enter your API key here
    try stethManager.apiKey.apiKey(apiKey: "YOUR_API_KEY")
    
    //here we need to process the biquad files and apply filter
    try stethManager.prepare()
    
    //This will start the recording
    try self.stethManager.startRecording()
    
    //This will stop the recording
    try self.stethManager.stopRecording()
    ```
    
## Important ⚠️
The `API_KEY` in the example application will only work for the example application. Using the same key in another application will not work.

## Author

StethIO, stethio@ionixxtech.com

## License

Steth-IO-SDK is available under the MIT license. See the LICENSE file for more info.
