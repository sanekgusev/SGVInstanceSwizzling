#
# Be sure to run `pod lib lint SGVInstanceSwizzling.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SGVInstanceSwizzling"
  s.version          = "1.0.0"
  s.summary          = "A short description of SGVInstanceSwizzling."
  s.description      = <<-DESC
                       An optional longer description of SGVInstanceSwizzling

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/sanekgusev/SGVInstanceSwizzling"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Alexander Gusev" => "sanekgusev@gmail.com" }
  s.source           = { :git => "https://github.com/sanekgusev/SGVInstanceSwizzling.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sanekgusev'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/SGVInstanceSwizzling.h'
  s.dependency 'SGVSuperMessagingProxy', '~> 1.0'
end
