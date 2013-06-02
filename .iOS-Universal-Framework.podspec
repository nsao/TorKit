Pod::Spec.new do |s|
    s.name = 'iOS-Universal-Framework'
    s.version = "0.1.1"
    s.summary = 'BLa'
    s.source = { :git => 'https://github.com/kstenerud/iOS-Universal-Framework.git' }
    s.platform = :ios, '5.0'
    s.pre_install do |pod, target_definition|
	unless File.exists?('/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec') && File.exists?('/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec')
		puts "\a[!] Installing #{s.name} requires ".yellow + "root".red + " access!".yellow
        	Dir.chdir(pod.root)
        	Dir.chdir('Real Framework'){ system 'sudo sh install.sh' }
	end
    end
end

