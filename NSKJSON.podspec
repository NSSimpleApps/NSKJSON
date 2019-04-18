Pod::Spec.new do |s|
    s.name         = "NSKJSON"
    s.version      = "0.8.3"
    s.summary      = "NSKJSON is a swift library for parsing plain-json format and json5 format."
    s.homepage     = "https://github.com/NSSimpleApps/NSKJSON"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { 'NSSimpleApps, Sergey Poluyanov' => 'ns.simple.apps@gmail.com' }
    s.source       = { :git => "https://github.com/NSSimpleApps/NSKJSON.git", :tag => s.version.to_s }
    s.requires_arc = true
    s.swift_version = '5.0'


    s.platform                  = :ios, '8.0', :watchos, '2.0', :tvos, '9.0', :osx, '10.10'

    s.osx.deployment_target = "10.10"
    s.ios.deployment_target = "8.0"
    s.watchos.deployment_target = "2.0"
    s.tvos.deployment_target = "9.0"

    s.source_files = "Source/Swift/*.swift"

end

