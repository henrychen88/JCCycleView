Pod::Spec.new do |s|
s.name = 'JCCycleView'
s.version = '1.0.1'
s.license = 'MIT'
s.summary = 'A cycle display view'
s.homepage = 'https://github.com/henrychen88/JCCycleView'
s.authors = { 'henrychen88' => '24129114@qq.com' }
s.source = { :git => "https://github.com/henrychen88/JCCycleView.git", :tag => "1.0.1"}
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = 'JCCycleView/*.{h,m}'
end
