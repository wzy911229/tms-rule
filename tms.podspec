Pod::Spec.new do |s|
  s.name                = "tms"
  s.version             = "0.0.7"
  s.summary             = "tms"
  s.description         = <<-DESC
                            tms lib for ios.
                         DESC
  s.homepage            = "http://www.terminus.io"
  s.license             = "ISC"
  s.author              = "wuzhiyu"
  s.requires_arc        = true
  s.platform            = :ios, "9.0"
  s.source              = { :git => "https://github.com/wzy911229/tms-rule.git"}
  s.static_framework = true

  s.source_files  =  "ios/**/*.{h,m}"

end
