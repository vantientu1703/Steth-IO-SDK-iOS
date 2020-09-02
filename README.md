# Steth-IO-SDK

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- The recording frequency must be 44.1khz because the filters are designed in such way.
- The heart/lung filters will work as expected only with Steth IO hardware.

## Installation

To install simply add the following line to your Podfile:

```ruby
pod 'Steth-IO-SDK', :git => 'https://github.com/StratoScientific/Steth-IO-SDK-iOS.git'
```


### Using SDK
1. In ViewController
    ```
    //Initializer
    try StethIOManager.instance.apiKey(apiKey: "YOUR_API_KEY")
    
    //here we need to process the biquad files and apply filter
    try StethIOManager.instance.prepare()
    
    //set the filter mode to heart/lung
    StethIOManager.instance.examType = .heart //for heart
    StethIOManager.instance.examType = .lung //for lungs
    
    //here is the process audio method
    //sample - array of float samples
    //count - sample count
    try StethIOManager.instance.processStethAudio(sample: sample, count: frame)
    
    //Stop Filtering
    // this is to dealloc filter objects
    StethIOManager.instance.stopFiltering()
    ```
## Author

dhinesh-raju, dhinesh.raju@ionixxtech.com

## License

Steth-IO-SDK is available under the MIT license. See the LICENSE file for more info.
