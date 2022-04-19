# VerticalFlowLayout

This implementation is built using a `UICollectionView` and a custom flowLayout.

<a href="https://github.com/rastaman111/VerticalFlowLayout">
    <img src="https://img.shields.io/cocoapods/v/VerticalFlowLayout.svg?style=flat"  alt="cocoapods version">
</a>
    
<a href="https://github.com/rastaman111/VerticalFlowLayout/blob/master/LICENSE">
    <img alt="GitHub" src="https://img.shields.io/github/license/rastaman111/VerticalFlowLayout.svg">
</a>

<a href="https://cocoapods.org/pods/VerticalCardSwiper">
    <img src="https://img.shields.io/cocoapods/p/VerticalCardSwiper.svg?style=flat?" alt="platform">
</a>

<a href="https://swift.org/blog/swift-5-released/">
    <img src="https://img.shields.io/badge/swift-5.0-brightgreen.svg" alt="swift5.0">
</a>

<div>
  <img src="./Replay.gif" alt="Replay" width="250">
</div>

# Table of contents

  * [Requirements](#requirements)
  * [Installation](#installation)
     - [CocoaPods](#cocoapods)
     - [Swift Package Manager](#swift-package-manager)
     - [Carthage](#carthage)
     - [Manually](#manually)
  * [Usage](#usage)
  * [License](#license)
  * [Donation](#donation)

## Requirements
* iOS 11.0+
* Swift 5

## Installation

### CocoaPods
Add Instructions to your Podfile:

```ruby
pod 'VerticalFlowLayout'
```

Then, run the following command:

```bash
$ pod install
```

### Swift Package Manager
In Xcode, use File > Swift Packages > Add Package Dependency and use `https://github.com/rastaman111/VerticalFlowLayout`.

### Carthage
To install with [Carthage](https://github.com/Carthage/Carthage), simply add the following line to your Podfile:
```ruby
github "rastaman111/VerticalFlowLayout"
```

### Manually
If you prefer not to use any of dependency managers, you can integrate manually. Put `Sources/VerticalFlowLayout` folder in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

## Usage
To use `VerticalFlowLayout` inside your `UIViewController`:

```swift
import VerticalFlowLayout

class ViewController: UIViewController, VerticalCollectionViewDelegate, VerticalCollectionViewDataSource {
    
    @IBOutlet var verticalView: VerticalView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verticalView.delegate = self
        verticalView.datasource = self
        
        // register cell
        verticalView.register(nib: UINib(nibName: "ExampleCell", bundle: nil), forCellWithReuseIdentifier: "ExampleCell")
    }
    
    func cellForItemIn(verticalCollectionView: VerticalCollectionView, cellForItemAt indexPath: Int) -> UICollectionViewCell {
        let cell = verticalCollectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as! ExampleCell
       
        return cell
    }
    
     func numberOfItemsIn(verticalCollectionView: VerticalCollectionView) -> Int {
        return 20
    }
    
    func didSelectCell(verticalCollectionView: VerticalCollectionView, indexPath: Int) {
        // Called when the user clicks on a cell.
    }
}
```

## License
VerticalFlowLayout is available under the MIT license. See the LICENSE file for more info.

## Donation
<a href="https://www.buymeacoffee.com/SoundBar" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
