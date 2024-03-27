Pod::Spec.new do |s|
  s.name             = 'BlankSlate'
  s.version          = '0.6.3'
  s.summary          = 'A drop-in UIView extension for showing empty datasets whenever the view has no content to display.'

s.description      = <<-DESC
It will work automatically, by just conforming to BlankSlateDataSource, and returning the data you want to show. The reloadData() call will be observed so the empty dataset will be configured whenever needed.
                       DESC

  s.homepage         = 'https://github.com/liam-i/BlankSlate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Liam' => 'liam_i@163.com' }
  s.source           = { :git => 'https://github.com/liam-i/BlankSlate.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*'
end
