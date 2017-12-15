Pod::Spec.new do |s|
  s.name             = 'Semver'
  s.version          = '0.1.2'
  s.summary          = 'Swift Semantic Versioning library.'
  s.homepage         = 'https://github.com/ddddxxx/Semver'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xander Deng' => 'dengxiang2010@gmail.com' }
  s.source           = { :git => 'https://github.com/ddddxxx/Semver.git', :tag => "v#{s.version.to_s}" }

  s.source_files = 'Sources/Semver/*.swift'

  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
end
