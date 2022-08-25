
Pod::Spec.new do |spec|

  spec.name         = "SuneelTDKit"
  spec.version      = "1.0.3"
  spec.summary      = "first framework ever developed by suneel"

  spec.description  = "Description is more definately... why your thinking about the description... you may dont want the description"

  spec.homepage     = "https://github.com/suneelreddymunagala/ATDKit"

  spec.license      = "MIT"
  spec.author       = { "Suneel Apprikart" => "developer@apprikart.com" }
  
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/suneelreddymunagala/ATDKit.git", :tag => spec.version.to_s }

  spec.source_files  = "SuneelTDKit/**/*.{swift}"
 # s.resources = "SuneelTDKit/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  spec.resources = "SuneelTDKit/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,lproj}"
spec.resource_bundles = "SuneelTDKit/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,lproj}"
  
  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
 spec.dependency "DropDown"
spec.dependency "LTSupportAutomotive", "~> 1.0"
spec.swift_versions = "5.0"
spec.swift_version = "5.0"

end
