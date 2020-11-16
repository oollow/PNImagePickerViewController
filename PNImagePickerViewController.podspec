#
# Be sure to run `pod lib lint PNImagePickerViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PNImagePickerViewController"
  s.version          = "1.1.1"
  s.summary          = "PNImagePickerViewController is a fork of jacobsieradzki/JSImagePickerController with iOS8+ PhotoKit support."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
# s.description      = <<-DESC DESC

  s.homepage         = "https://github.com/oollow/PNImagePickerViewController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "oolloow" => "noreply@oolloow.com" }
  s.source           = { :git => "https://github.com/oollow/PNImagePickerViewController.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '13.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Photos', 'PhotosUI'
  # s.dependency 'PureLayout'
  s.dependency 'DGActivityIndicatorView'
  s.dependency 'CLImageEditor/AllTools'
end
