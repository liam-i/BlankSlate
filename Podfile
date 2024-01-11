source 'https://cdn.cocoapods.org/'

install! 'cocoapods',
  :disable_input_output_paths => true,
  :generate_multiple_pod_projects => true

platform :ios, '11.0'
#use_frameworks!
use_frameworks! :linkage => :static

target 'EmptyDataSet_Example' do
  pod 'LPEmptyDataSet', :path => './'
  pod 'LPHUD'

  target 'EmptyDataSet_Tests' do
    inherit! :search_paths
    
  end
end
