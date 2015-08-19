Pod:: Spec.new do |spec|
  spec.platform     = 'ios', '7.0'
  spec.name         = 'ResponsiveLabel'
  spec.version      = '1.0.4'
  spec.summary      = 'A UILabel subclass which responds to touch on specified patterns and allows to set custom truncation token'
  spec.author = {
    'Susmita Horrow' => 'susmita.horrow@gmail.com'
  }
  spec.license          = 'MIT'
  spec.homepage         = 'https://github.com/hsusmita/ResponsiveLabel'
  spec.source = {
    :git => 'https://github.com/hsusmita/ResponsiveLabel.git',
    :tag => '1.0.4'
  }
  spec.ios.deployment_target = '7.0'
  spec.source_files = 'ResponsiveLabel/ResponsiveLabel/Source/*'
  spec.requires_arc = true
end
