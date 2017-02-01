Pod::Spec.new do |s|
  s.name             = "Swipeable"
  s.version          = "0.0.1"
  s.summary          = "A short description of Swipeable."
  s.license          = 'MIT'
  s.author           = { "Hubert Drąg" => "hubert.drag@gmail.com" }
  s.source           = { :git => "git@github.com:bercik0291/Swipeable.git", :tag => s.version.to_s }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.source_files     = 'Swiper/Classes/*.swift'
  s.homepage         = 'https://www.appunite.com'
end
