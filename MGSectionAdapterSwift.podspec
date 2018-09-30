Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "MGSectionAdapterSwift"
  s.version      = "1.0.0"
  s.summary      = "All item in table/collect can be a section."

  s.description  = <<-DESC
                   All item in table/collect can be a section.
                   DESC

  s.homepage     = "https://github.com/MagicalWater/MGSectionAdapterSwift"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "water" => "crazydennies@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/MagicalWater/MGSectionAdapterSwift.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "MGSectionAdapterSwift/MGSectionAdapterSwift/Classes/**/*"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.framework  = "UIKit"
  s.frameworks = "UIKit", "Foundation"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency 'MGUtilsSwift'
  s.dependency 'MGViewsSwift'
  s.dependency 'MGExtensionSwift'

end
