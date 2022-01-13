Pod::Spec.new do |s|
  s.name             = 'LPEmptyDataSet'
  s.version          = '0.2.0'
  s.summary          = 'A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display.'

s.description      = <<-DESC
It will work automatically, by just conforming to DZNEmptyDataSetSource, and returning the data you want to show. The -reloadData call will be observed so the empty dataset will be configured whenever needed.
                       DESC

  s.homepage         = 'https://github.com/liam-i/EmptyDataSet'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Liam' => 'liam_i@163.com' }
  s.source           = { :git => 'https://github.com/liam-i/EmptyDataSet.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.1', '5.2', '5.3']

  s.source_files = 'Sources/Classes/**/*'
end
