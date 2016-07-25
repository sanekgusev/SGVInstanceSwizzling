Pod::Spec.new do |s|
  s.name             = "SGVInstanceSwizzling"
  s.version          = "1.0.0"
  s.cocoapods_version = '>= 1.0.0'
  s.summary          = "Override dynamically-dispatched methods on any Objective-C or Swift object with access to original implementation."
  s.description      = <<-DESC
                       An optional longer description of SGVInstanceSwizzling

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/sanekgusev/SGVInstanceSwizzling"
  s.license          = 'MIT'
  s.author           = { "Aleksandr Gusev" => "sanekgusev@gmail.com" }
  s.source           = { :git => "https://github.com/sanekgusev/SGVInstanceSwizzling.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sanekgusev'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.subspec 'Objective-C' do |ss|
    ss.source_files = 'Pod/Sources/Objective-C/**/*.{h,m}'
    ss.public_header_files = 'Pod/Sources/Objective-C/SGVInstanceSwizzling.h'
    ss.dependency 'SGVSuperMessagingProxy/Objective-C', '~> 2.0'

    ss.ios.deployment_target = '7.0'
    ss.osx.deployment_target = '10.8'
    ss.watchos.deployment_target = '1.0'
    ss.tvos.deployment_target = '9.0'
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'Pod/Sources/Swift/**/*.swift'
    ss.dependency 'SGVSuperMessagingProxy/Swift', '~> 2.0'

    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.9'
    ss.watchos.deployment_target = '2.0'
    ss.tvos.deployment_target = '9.0'
  end

end
