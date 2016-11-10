# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'belis-app' do
pod 'ObjectMapper', :head
pod 'MGSwipeTableCell', :head
pod 'SwiftForms', :head
pod 'JGProgressHUD'
pod 'AFImageHelper', '~> 3.2'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
end

target 'belis-appTests' do
pod 'ObjectMapper', :head
pod 'MGSwipeTableCell', :head
pod 'SwiftForms', :head
pod 'JGProgressHUD'
pod 'AFImageHelper', '~> 3.2'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

end
