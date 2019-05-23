Pod::Spec.new do |s|

  s.name                = "GridView.iOS"
  s.version             = "0.1.0"
  s.summary             = "A grid view for iOS, based on NSGridView for macOS."
  s.homepage            = "https://github.com/roblokhorst/GridView"
  s.license             = "MIT"
  s.author              = "Rob Lokhorst"
  s.social_media_url    = "http://twitter.com/roblokhorst"
  s.platform            = :ios, "9.0"
  s.source              = { :git => "https://github.com/roblokhorst/GridView.git", :tag => s.version.to_s }
  s.source_files        = "GridView", "GridView/**/*.{h,m,swift}"
  s.module_name         = "GridView"
  s.swift_version   = "5.0"

end
