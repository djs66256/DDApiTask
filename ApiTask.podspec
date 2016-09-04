Pod::Spec.new do |s|

  s.name         = "ApiTask"
  s.version      = "0.0.2"
  s.summary      = "A networking framework base on Alamofire."

  s.description  = <<-DESC
  A networking framework base on Alamofire, with json to model
                   DESC

  s.homepage     = "https://github.com/djs66256/DDApiTask"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Daniel" => "djs66256@163.com" }
  # Or just: s.author    = "Daniel"
  # s.authors            = { "Daniel" => "djs66256@163.com" }
  # s.social_media_url   = "http://twitter.com/Daniel"

  # s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  s.source       = { :git => "https://github.com/djs66256/DDApiTask.git", :tag => "0.0.2" }

  s.source_files  = "Class", "Class/**/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "Foundation"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true

  #s.xcconfig = { "SWIFT_OBJC_BRIDGING_HEADER" => "$(POD_ROOT)/ApiTask/ApiTask-Bridging-Header.h" }
  s.dependency "Alamofire", '~> 3.4'
  s.dependency "YYModel", '~>1.0.4'
  s.dependency "SwiftyJSON", '~>2.3.2'
  s.dependency "DDFileCache"

end
