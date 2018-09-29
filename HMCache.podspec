Pod::Spec.new do |s|
  s.name             = "HMCache"
  s.version          = "0.2.3"
  s.summary          = "An automatic NSCoding library used on iOS/MacOS."
  s.description      = <<-DESC
                       It is an automatic NSCoding library used on iOS/MacOS which also offers a mechanism for data structure migration.
                       DESC
  s.homepage         = "https://github.com/lxian1988/HMCache"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "lxian1988" => "lxian1988@gmail.com" }
  s.source           = { :git => "https://github.com/lxian1988/HMCache.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'

  # s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'HMCache/*.{h,m}', 'HMCache/HMObject/*.{h,m}', 'HMCache/HMCacheManager/*.{h,m}', 'HMCache/HMMigrationData/*.{h,m}'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation'

end
