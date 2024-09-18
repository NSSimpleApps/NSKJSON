Pod::Spec.new do |s|
    s.name         = "NSKJSON"
    s.version      = "1.2"
    s.summary      = "NSKJSON is a swift library for parsing plain-json format and json5 format."
    s.homepage     = "https://github.com/NSSimpleApps/NSKJSON"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { 'NSSimpleApps, Sergey Poluyanov' => 'ns.simple.apps@gmail.com' }
    s.source       = { :git => "https://github.com/NSSimpleApps/NSKJSON.git", :tag => s.version.to_s }
    s.requires_arc = true
    s.swift_version = '6.0'


    s.platform                  = :ios, '12.4', :osx, '10.15'

    s.osx.deployment_target = "10.15"
    s.ios.deployment_target = "12.4"

    s.source_files = "Source/Swift/*.swift"

end

