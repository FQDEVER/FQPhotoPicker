Pod::Spec.new do |s|

    s.name                       = 'FQPhotoPicker'

    s.version                    = '0.0.2'

    s.summary                    = '非常简单易用的轻量级相册框架。'

    s.homepage              = 'https://github.com/FQDEVER/FQPhotoPicker'

    s.license                    = { :type => 'MIT', :file => 'LICENSE' }

    s.author                     = { 'FQDEVER' => '814383466@qq.com' }

    s.source                     = { :git => 'https://github.com/FQDEVER/FQPhotoPicker.git', :tag => s.version }

    s.source_files               = 'FQPhotoPicker/FQPhotoPicker/FQImagePickerVC/*.{h,m}'
    s.resource_bundle            = { 'FQImagePicker' => ['FQPhotoPicker/**/*.xcassets']}

    s.platform                   = :ios

    s.ios.deployment_target      = '9.0'

    s.dependency                 'Masonry'
    s.dependency                 'YYKit'
    s.dependency                 'MBProgressHUD'

end
