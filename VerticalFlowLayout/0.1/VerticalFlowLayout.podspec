Pod::Spec.new do |s|

  s.name         = "VerticalFlowLayout"
  s.version      = "0.1"
  s.summary      = "This implementation is built using a UICollectionView and a custom flowLayout in Swift."
  s.homepage     = "https://github.com/rastaman111/VerticalFlowLayout"
  s.source       = { :git => "https://github.com/rastaman111/VerticalFlowLayout.git", :tag => s.version }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { 'Alexander' => "rastaman.alex007@gmail.com" }

  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'

  s.source_files  = 'Sources/VerticalFlowLayout/**/*.swift'

end
