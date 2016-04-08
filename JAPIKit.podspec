#
# Be sure to run `pod lib lint JAPIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JAPIKit"
  s.version          = "1.0.0"
  s.summary          = "An iOS developer tools which are awesome!"


  s.description      = <<-DESC
  This is an iOS developer tools which will help you making apps quickly, now it is simply gives you an API request base.
                       DESC

  s.homepage         = "https://github.com/jjjjjeffrey/JAPIKit"
  s.license          = 'MIT'
  s.author           = { "zengdaqian" => "jjjjjeffreyzeng@gmail.com" }
  s.source           = { :git => "https://github.com/jjjjjeffrey/JAPIKit.git", :tag => s.version.to_s }
  

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JAPIKit' => ['Pod/Assets/*.png']
  }

  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'SwiftyJSON', '~> 2.0'

end
