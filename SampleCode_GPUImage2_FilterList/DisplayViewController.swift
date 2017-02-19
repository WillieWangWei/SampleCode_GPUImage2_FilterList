//
//  DisplayViewController.swift
//  SampleCode_GPUImage2_FilterList
//
//  Created by 王炜 on 2017/2/12.
//  Copyright © 2017年 Willie. All rights reserved.
//

import UIKit
import GPUImage

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH_Float = Float(UIScreen.main.bounds.width)
let SCREEN_HEIGHT_Float = Float(UIScreen.main.bounds.height)
let SCREEN_SIZE = Size(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float)

class DisplayViewController: UIViewController {
    
    var pictureInput: PictureInput!
    var filterModel: FilterModel!
    var filter: AnyObject!
    
    var renderView: RenderView = {
        
        let renderView = RenderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        renderView.fillMode = .preserveAspectRatio
        renderView.backgroundRenderColor = .white
        return renderView
    }()
    
    var slider: UISlider = {
        
        let slider = UISlider(frame: CGRect(x: 8, y: SCREEN_HEIGHT - 30, width: SCREEN_WIDTH - 18, height: 20))
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        view.addSubview(renderView)
        view.addSubview(slider)
        title = filterModel.name
        self.setupFilterChain()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pictureInput.removeAllTargets()
        
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("deinit")
    }
    
    func setupFilterChain() {
        
        pictureInput = PictureInput(image: MaYuImage)
        slider.minimumValue = filterModel.range?.0 ?? 0
        slider.maximumValue = filterModel.range?.1 ?? 0
        slider.value = filterModel.range?.2 ?? 0
        filter = filterModel.initCallback()
        
        switch filterModel.filterType! {
            
        case .imageGenerators:
            filter as! ImageSource --> renderView
            
        case .basicOperation:
            if let actualFilter = filter as? BasicOperation {
                pictureInput --> actualFilter --> renderView
                pictureInput.processImage()
            }
            
        case .operationGroup:
            if let actualFilter = filter as? OperationGroup {
                pictureInput --> actualFilter --> renderView
            }
        case .custom:
            filterModel.customCallback!(pictureInput, filter, renderView)
        }
        
        self.sliderValueChanged(slider: slider)
    }
    
    func sliderValueChanged(slider: UISlider) {
        
        print("slider value: \(slider.value)")
        if let actualCallback = filterModel.valueChangedCallback {
            actualCallback(filter, slider.value)
        } else {
            slider.isHidden = true
        }
        
        switch filterModel.filterType! {
        case .imageGenerators: break
        case .basicOperation: pictureInput.processImage()
        case .operationGroup: pictureInput.processImage()
        case .custom: pictureInput.processImage()
        }
    }
}

