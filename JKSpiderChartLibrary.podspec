Pod::Spec.new do |s|
  s.name             = "JKSpiderChartLibrary"
  s.version          = "0.3"
  s.summary          = "A chart library to draw graph in the form of spider chart"  
  s.homepage         = "https://github.com/jayesh15111988/JKSpiderChartLibrary"
  s.license          = 'MIT'
  s.author           = { "Jayesh Kawli" => "j.kawli@gmail.com" }
  s.source           = { :git => "https://github.com/jayesh15111988/JKSpiderChartLibrary.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/JayeshKawli'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'JKSpiderChartLibrary/Classes/*.{swift}'
  s.dependency 'BlocksKit', '~> 2.2'
end
