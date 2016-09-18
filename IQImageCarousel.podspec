Pod::Spec.new do |s|
s.name = 'IQImageCarousel'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'An Image Carsoule view on iOS.'
s.homepage = 'https://github.com/DevGuan/IQImageCarousel'
s.authors = { 'DevGuan' => '975081801@qq.com' }
s.source = { :git => 'https://github.com/DevGuan/IQImageCarousel.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'IQImageCarousel/*.{h,m}'
end
