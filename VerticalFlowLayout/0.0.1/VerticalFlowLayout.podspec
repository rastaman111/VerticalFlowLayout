Pod::Spec.new do |spec|

  spec.name         = "VerticalFlowLayout"
  spec.version      = "0.0.1"
  spec.summary      = "Tinder UI built with UICollectionView in Swift."
  spec.homepage     = "https://github.com/rastaman111/VerticalFlowLayout"
  spec.source       = { :git => "https://github.com/rastaman111/VerticalFlowLayout.git", :tag => spec.version }
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author       = { 'Alexander' => "rastaman.alex007@gmail.com" }

  spec.swift_version = '5.1'
  spec.ios.deployment_target = '11.0'

  spec.source_files  = 'Sources/**/*.swift'
end
