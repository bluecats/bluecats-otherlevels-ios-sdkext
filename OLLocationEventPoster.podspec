Pod::Spec.new do |s|
  s.name     = 'OLLocationEventPoster'
  s.version  = '0.0.6'
  s.summary  = 'Post BlueCats zone events to OtherLevels location event endpoint.'
  s.homepage = 'http://www.bluecats.com'
  s.license      = { :type => 'MIT' }
  s.author       = { "BlueCats" => "support@bluecats.com" }
  s.source   = { :git => 'https://github.com/bluecats/bluecats-otherlevels-ios-sdkext', :tag => s.version }
  s.platform = :ios, '7.0'
  s.source_files = 'OLLocationEventPoster.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'

  s.xcconfig  =  { 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Headers/Public/BlueCatsSDK/BlueCatsSDK"' }
end
