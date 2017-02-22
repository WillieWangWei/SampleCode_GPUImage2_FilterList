//
//  FilterModel.swift
//  SampleCode_GPUImage2_FilterList
//
//  Created by 王炜 on 2017/2/12.
//  Copyright © 2017年 Willie. All rights reserved.
//

import UIKit
import GPUImage

typealias InitCallback = () -> (AnyObject)
typealias ValueChangedCallback = (AnyObject, Float) -> ()
typealias CustomCallback = (PictureInput, AnyObject, RenderView) -> ()

let flowerImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "Flower", ofType: "jpg")!)!
let MaYuImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "MaYu", ofType: "jpg")!)!

enum FilterType {
    case imageGenerators
    case basicOperation
    case operationGroup
    case custom
    case blend
}

class FilterModel: NSObject {
    
    var name: String!
    var filterType: FilterType!
    var range: (Float, Float, Float)?
    var initCallback: InitCallback!
    var valueChangedCallback: ValueChangedCallback?
    var customCallback: CustomCallback?
    
    init(name: String, filterType: FilterType, range: (Float, Float, Float)? = (0.0, 1.0, 0.0), initCallback: @escaping InitCallback, valueChangedCallback: ValueChangedCallback? = nil, customCallback: CustomCallback? = nil) {
        
        self.name = name
        self.filterType = filterType
        self.range = range
        self.initCallback = initCallback
        self.valueChangedCallback = valueChangedCallback
        self.customCallback = customCallback
    }
}

extension FilterModel {
    
    class func filterModels() -> [String: [FilterModel]] {
        
        return [
            "Image generators 图像生成": [
                FilterModel(name: "LineGenerator 生成直线",
                            filterType: .imageGenerators,
                            initCallback: {LineGenerator(size: .init(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float))},
                            valueChangedCallback: { (filter, value) in
                                let lineGenerator = filter as! LineGenerator
                                lineGenerator.lineColor = .green
                                lineGenerator.lineWidth = 2
                                lineGenerator.renderLines([.segment(p1: .init(value, value), p2: .center), .infinite(slope: value, intercept: value)])
                }),
                FilterModel(name: "SolidColorGenerator 生成纯色",
                            filterType: .imageGenerators,
                            initCallback: {SolidColorGenerator(size: .init(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float))},
                            valueChangedCallback: { (filter, value) in
                                (filter as! SolidColorGenerator).renderColor(.init(red: 1, green: value * 2, blue: value))
                }),
                FilterModel(name: "CircleGenerator 生成圆",
                            filterType: .imageGenerators,
                            initCallback: {CircleGenerator(size: .init(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float))},
                            valueChangedCallback: { (filter, value) in
                                (filter as! CircleGenerator).renderCircleOfRadius(value * 0.5, center: .center, circleColor: .green, backgroundColor: .red)
                }),
                FilterModel(name: "CrosshairGenerator 生成十字线",
                            filterType: .imageGenerators,
                            initCallback: {CrosshairGenerator(size: .init(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float))},
                            valueChangedCallback: { (filter, value) in
                                let crosshairGenerator = filter as! CrosshairGenerator
                                crosshairGenerator.crosshairWidth = 20
                                crosshairGenerator.crosshairColor = .green
                                crosshairGenerator.renderCrosshairs([.init(value, value), .init(value * 0.5, value), .init(value, value * 0.5)])
                })
            ],
            "Color adjustments 颜色调校": [
                // BasicOperation
                FilterModel(name: "BrightnessAdjustment 亮度",
                            filterType: .basicOperation,
                            range: (-1.0, 1.0, 0.0),
                            initCallback: {BrightnessAdjustment()},
                            valueChangedCallback: { (filter, value) in
                                (filter as! BrightnessAdjustment).brightness = value
                }),
                FilterModel(name: "ExposureAdjustment 曝光",
                            filterType: .basicOperation,
                            range: (-10, 10, 0.0),
                            initCallback: {ExposureAdjustment()},
                            valueChangedCallback: { (filter, value) in
                                (filter as! ExposureAdjustment).exposure = value
                }),
                FilterModel(name: "ContrastAdjustment 对比度",
                            filterType: .basicOperation,
                            range: (0.0, 4.0, 1.0),
                            initCallback: {ContrastAdjustment()},
                            valueChangedCallback: { (filter, value) in
                                (filter as! ContrastAdjustment).contrast = value
                }),
                FilterModel(name: "SaturationAdjustment 饱和度",
                            filterType: .basicOperation,
                            range: (0.0, 2.0, 1.0),
                            initCallback: {SaturationAdjustment()},
                            valueChangedCallback: { (filter, value) in
                                (filter as! SaturationAdjustment).saturation = value
                }),
                FilterModel(name: "GammaAdjustment 灰度",
                            filterType: .basicOperation,
                            range: (0.0, 3.0, 1.0),
                            initCallback: { GammaAdjustment() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! GammaAdjustment).gamma = value
                }),
                FilterModel(name: "LevelsAdjustment 色阶",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { LevelsAdjustment() },
                            valueChangedCallback: { (filter, value) in
                                let levelsAdjustment = filter as! LevelsAdjustment
                                let color = Color(red: value, green: 0, blue: 0)
                                levelsAdjustment.minimum = color
                                levelsAdjustment.minOutput = color
                }),
                FilterModel(name: "ColorMatrixFilter 矩阵转换",
                            filterType: .basicOperation,
                            range: (0.0, 2.0, 1.0),
                            initCallback: { ColorMatrixFilter() },
                            valueChangedCallback: { (filter, value) in
                                let colorMatrixFilter = filter as! ColorMatrixFilter
                                colorMatrixFilter.intensity = value
                                colorMatrixFilter.colorMatrix = .init(rowMajorValues:[0.2, 0.3, 0.5, 0.0,
                                                                                      0.1, 0.4, 0.5, 0.0,
                                                                                      0.3, 0.7, 0.9 ,0.0,
                                                                                      0.0, 0.0, 0.0, 1.0])
                }),
                FilterModel(name: "RGBAdjustment RGB调整",
                            filterType: .basicOperation,
                            range: (0.0, 10.0, 1.0),
                            initCallback: { RGBAdjustment() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! RGBAdjustment).green = value
                }),
                FilterModel(name: "HueAdjustment 色调",
                            filterType: .basicOperation,
                            range: (0.0, 180.0, 90.0),
                            initCallback: { HueAdjustment() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! HueAdjustment).hue = value
                }),
                FilterModel(name: "WhiteBalance 白平衡",
                            filterType: .basicOperation,
                            range: (-1.5, 1.5, 0),
                            initCallback: { WhiteBalance() },
                            valueChangedCallback: { (filter, value) in
                                let whiteBalance = filter as! WhiteBalance
                                whiteBalance.temperature = (value + 5.5) * 1000
                                whiteBalance.tint = value
                }),
                FilterModel(name: "HighlightsAndShadows 高光和阴影",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { HighlightsAndShadows() },
                            valueChangedCallback: { (filter, value) in
                                let highlightsAndShadows = filter as! HighlightsAndShadows
                                highlightsAndShadows.shadows = value
                                highlightsAndShadows.highlights = 1 - value
                }),
                FilterModel(name: "LookupFilter Lookup",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { LookupFilter() },
                            valueChangedCallback: { (filter, value) in
                                let lookupFilter = filter as! LookupFilter
                                lookupFilter.lookupImage = PictureInput(imageName:"lookup.png")
                                lookupFilter.intensity = value
                }),
                FilterModel(name: "AmatorkaFilter Amatorka",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { AmatorkaFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! AmatorkaFilter).intensity = value
                }),
                FilterModel(name: "MissEtikateFilter MissEtikate",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { MissEtikateFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! MissEtikateFilter).intensity = value
                }),
                FilterModel(name: "ColorInversion 反色",
                            filterType: .basicOperation,
                            initCallback: { ColorInversion() }),
                FilterModel(name: "MonochromeFilter 单色",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { MonochromeFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! MonochromeFilter).intensity = value
                }),
                FilterModel(name: "FalseColor 颜色混合",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { FalseColor() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! FalseColor).secondColor = .init(red: value, green: value, blue: value)
                }),
                FilterModel(name: "Haze 雾度",
                            filterType: .basicOperation,
                            range: (-0.3, 0.3, 0.0),
                            initCallback: { Haze() },
                            valueChangedCallback: { (filter, value) in
                                let haze = filter as! Haze
                                haze.distance = value
                                haze.slope = value
                }),
                FilterModel(name: "SepiaToneFilter 棕褐色滤镜",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { SepiaToneFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SepiaToneFilter).intensity = value
                }),
                FilterModel(name: "OpacityAdjustment alpha通道",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { OpacityAdjustment() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! OpacityAdjustment).opacity = value
                }),
                FilterModel(name: "LuminanceThreshold 亮度阈值",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { LuminanceThreshold() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! LuminanceThreshold).threshold = value
                }),
                FilterModel(name: "AverageColorExtractor 平均颜色",
                            filterType: .basicOperation,
                            initCallback: { AverageColorExtractor() }),
                FilterModel(name: "AverageLuminanceExtractor 平均亮度",
                            filterType: .basicOperation,
                            initCallback: { AverageLuminanceExtractor() }),
                FilterModel(name: "ChromaKeying 色度控制",
                            filterType: .custom,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { ChromaKeying() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ChromaKeying).smoothing = value
                },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let chromaKeying = basicOperation as! ChromaKeying
                                
                                let alphaBlend = AlphaBlend()
                                alphaBlend.mix = 1.0
                                
                                let inputImage = PictureInput(image: flowerImage)
                                inputImage --> alphaBlend
                                pictureInput --> chromaKeying --> alphaBlend --> renderView
                                inputImage.processImage()
                }),
                FilterModel(name: "Vibrance 动态",
                            filterType: .basicOperation,
                            range: (-1.2, 1.2, 0),
                            initCallback: { Vibrance() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Vibrance).vibrance = value
                }),
                FilterModel(name: "HighlightAndShadowTint 高光阴影着色",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { HighlightAndShadowTint() },
                            valueChangedCallback: { (filter, value) in
                                let highlightAndShadowTint = filter as! HighlightAndShadowTint
                                highlightAndShadowTint.shadowTintIntensity = value
                                highlightAndShadowTint.highlightTintIntensity = value
                }),
                // OperationGroup
                FilterModel(name: "SoftElegance SoftElegance",
                            filterType: .operationGroup,
                            initCallback: { SoftElegance() }),
                FilterModel(name: "AdaptiveThreshold 自适应阈值",
                            filterType: .operationGroup,
                            initCallback: { AdaptiveThreshold() }),
                FilterModel(name: "AverageLuminanceThreshold 平均亮度阈值",
                            filterType: .operationGroup,
                            initCallback: { AverageLuminanceThreshold() }),
            ],
            "Image processing 图像处理": [
                // BasicOperation
                FilterModel(name: "TransformOperation 2-D或3-D变换",
                            filterType: .basicOperation,
                            range: (0.0, Float(M_PI), 0.0),
                            initCallback: { TransformOperation() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! TransformOperation).transform = Matrix4x4(CGAffineTransform(rotationAngle:CGFloat(value)))
                }),
                FilterModel(name: "Crop 裁剪",
                            filterType: .basicOperation,
                            range: (0.1, 1.0, 1.0),
                            initCallback: { Crop() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Crop).cropSizeInPixels = Size(width: 674.0, height: 1200.0 * value)
                }),
                FilterModel(name: "LanczosResampling Lanczos重采样",
                            filterType: .basicOperation,
                            initCallback: { LanczosResampling() }),
                FilterModel(name: "Sharpen 锐化",
                            filterType: .basicOperation,
                            range: (-4.0, 4.0, 0.0),
                            initCallback: { Sharpen() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Sharpen).sharpness = value
                }),
                FilterModel(name: "Histogram 直方图",
                            filterType: .custom,
                            range: (1.0, 32.0, 16.0),
                            initCallback: { Histogram(type:.rgb) },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Histogram).downsamplingFactor = UInt(round(value))
                },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let histogram = basicOperation as! Histogram
                                let histogramGraph = HistogramDisplay()
                                histogramGraph.overriddenOutputSize = Size(width:SCREEN_WIDTH_Float, height:SCREEN_HEIGHT_Float)
                                let alphaBlend = AlphaBlend()
                                alphaBlend.mix = 0.5
                                pictureInput --> alphaBlend
                                pictureInput --> histogram --> histogramGraph --> alphaBlend --> renderView
                }),
                FilterModel(name: "HistogramDisplay 直方图显示",
                            filterType: .basicOperation,
                            initCallback: { HistogramDisplay() }),
                FilterModel(name: "MotionBlur 运动模糊",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { MotionBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! MotionBlur).blurSize = value
                }),
                FilterModel(name: "ZoomBlur 运动模糊",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { ZoomBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ZoomBlur).blurSize = value
                }),
                // TwoStageOperation
                FilterModel(name: "GaussianBlur 高斯模糊",
                            filterType: .basicOperation,
                            range: (0.0, 5.0, 0.0),
                            initCallback: { GaussianBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! GaussianBlur).blurRadiusInPixels = value
                }),
                FilterModel(name: "BoxBlur Box模糊",
                            filterType: .basicOperation,
                            range: (0.0, 5.0, 0.0),
                            initCallback: { BoxBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! BoxBlur).blurRadiusInPixels = value
                }),
                FilterModel(name: "SingleComponentGaussianBlur 单一分量模糊",
                            filterType: .basicOperation,
                            range: (0.5, 5.0, 0.5),
                            initCallback: { SingleComponentGaussianBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SingleComponentGaussianBlur).blurRadiusInPixels = value
                }),
                FilterModel(name: "BilateralBlur 双边模糊",
                            filterType: .custom,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { BilateralBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! BilateralBlur).distanceNormalizationFactor = value
                }),
                FilterModel(name: "Dilation 扩张",
                            filterType: .basicOperation,
                            initCallback: { Dilation() }),
                FilterModel(name: "Erosion 侵蚀",
                            filterType: .basicOperation,
                            initCallback: { Erosion() }),
                // TextureSamplingOperation
                FilterModel(name: "MedianFilter 三色中值",
                            filterType: .basicOperation,
                            initCallback: { MedianFilter() }),
                FilterModel(name: "Convolution3x3 Convolution3x3",
                            filterType: .basicOperation,
                            initCallback: { Convolution3x3() },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let convolution3x3 = basicOperation as! Convolution3x3
                                convolution3x3.convolutionKernel = Matrix3x3(rowMajorValues:[
                                    -1.0, 0.0, 1.0,
                                    -2.0, 0.0, 2.0,
                                    -1.0, 0.0, 1.0])
                                pictureInput --> convolution3x3 --> renderView
                }),
                FilterModel(name: "SobelEdgeDetection Sobel边缘检测",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { SobelEdgeDetection() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SobelEdgeDetection).edgeStrength = value
                }),
                FilterModel(name: "PrewittEdgeDetection Prewitt边缘检测",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { PrewittEdgeDetection() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! PrewittEdgeDetection).edgeStrength = value
                }),
                FilterModel(name: "ThresholdSobelEdgeDetection Sobel边缘检测",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { ThresholdSobelEdgeDetection() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ThresholdSobelEdgeDetection).edgeStrength = value
                }),
                FilterModel(name: "LocalBinaryPattern LocalBinaryPattern",
                            filterType: .basicOperation,
                            initCallback: { LocalBinaryPattern() }),
                FilterModel(name: "ColorLocalBinaryPattern ColorLocalBinaryPattern",
                            filterType: .basicOperation,
                            initCallback: { ColorLocalBinaryPattern() }),
                // OperationGroup
                FilterModel(name: "UnsharpMask 反锐化",
                            filterType: .operationGroup,
                            range: (0.0, 10.0, 0.0),
                            initCallback: { UnsharpMask() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! UnsharpMask).intensity = value
                }),
                FilterModel(name: "iOSBlur iOS模糊",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { iOSBlur() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! iOSBlur).blurRadiusInPixels = value * 100
                }),
                FilterModel(name: "TiltShift TiltShift",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { TiltShift() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! TiltShift).blurRadiusInPixels = value * 10
                }),
                FilterModel(name: "HistogramEqualization 直方图补偿",
                            filterType: .operationGroup,
                            initCallback: { HistogramEqualization(type:.rgb) }),
                FilterModel(name: "CannyEdgeDetection Canny边缘检测",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { CannyEdgeDetection() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! CannyEdgeDetection).blurRadiusInPixels = value * 10
                }),
                FilterModel(name: "HarrisCornerDetector 哈里斯角点检测",
                            filterType: .custom,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { HarrisCornerDetector() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! HarrisCornerDetector).threshold = value
                },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let harrisCornerDetector = basicOperation as! HarrisCornerDetector
                                let crosshairGenerator = CrosshairGenerator(size:Size(width:SCREEN_WIDTH_Float, height:SCREEN_HEIGHT_Float))
                                crosshairGenerator.crosshairWidth = 15.0
                                crosshairGenerator.crosshairColor = .red
                                
                                harrisCornerDetector.cornersDetectedCallback = { corners in
                                    crosshairGenerator.renderCrosshairs(corners)
                                }
                                
                                pictureInput --> harrisCornerDetector
                                
                                let blendFilter = AlphaBlend()
                                pictureInput --> blendFilter --> renderView
                                crosshairGenerator --> blendFilter
                }),
                FilterModel(name: "NobleCornerDetector Noble哈里斯角点检测",
                            filterType: .custom,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { NobleCornerDetector() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! NobleCornerDetector).threshold = value
                },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let harrisCornerDetector = basicOperation as! NobleCornerDetector
                                let crosshairGenerator = CrosshairGenerator(size:Size(width:SCREEN_WIDTH_Float, height:SCREEN_HEIGHT_Float))
                                crosshairGenerator.crosshairWidth = 15.0
                                crosshairGenerator.crosshairColor = .red
                                
                                harrisCornerDetector.cornersDetectedCallback = { corners in
                                    crosshairGenerator.renderCrosshairs(corners)
                                }
                                
                                pictureInput --> harrisCornerDetector
                                
                                let blendFilter = AlphaBlend()
                                pictureInput --> blendFilter --> renderView
                                crosshairGenerator --> blendFilter
                }),
                FilterModel(name: "ShiTomasiFeatureDetector ShiTomasi检测",
                            filterType: .custom,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { ShiTomasiFeatureDetector() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ShiTomasiFeatureDetector).threshold = value
                },
                            customCallback: { (pictureInput, basicOperation, renderView) in
                                let harrisCornerDetector = basicOperation as! ShiTomasiFeatureDetector
                                let crosshairGenerator = CrosshairGenerator(size:Size(width:SCREEN_WIDTH_Float, height:SCREEN_HEIGHT_Float))
                                crosshairGenerator.crosshairWidth = 15.0
                                crosshairGenerator.crosshairColor = .red
                                
                                harrisCornerDetector.cornersDetectedCallback = { corners in
                                    crosshairGenerator.renderCrosshairs(corners)
                                }
                                
                                pictureInput --> harrisCornerDetector
                                
                                let blendFilter = AlphaBlend()
                                pictureInput --> blendFilter --> renderView
                                crosshairGenerator --> blendFilter
                }),
                FilterModel(name: "OpeningFilter 颜色侵蚀",
                            filterType: .operationGroup,
                            initCallback: { OpeningFilter() }),
                FilterModel(name: "ClosingFilter 颜色扩张",
                            filterType: .operationGroup,
                            initCallback: { ClosingFilter() }),
                FilterModel(name: "LowPassFilter 低通滤镜",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { LowPassFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! LowPassFilter).strength = value
                }),
                FilterModel(name: "HighPassFilter 高通滤镜",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { HighPassFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! HighPassFilter).strength = value
                }),
                FilterModel(name: "MotionDetector 运动检测",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { MotionDetector() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! MotionDetector).lowPassStrength = value
                }),
                FilterModel(name: "ColourFASTFeatureDetection ColourFAST特征描述符",
                            filterType: .operationGroup,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { ColourFASTFeatureDetection() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ColourFASTFeatureDetection).blurRadiusInPixels = value
                })
            ],
            "Blending modes 混合模式": [
                // BasicOperation
                FilterModel(name: "ChromaKeyBlend 颜色替换",
                            filterType: .blend,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { ChromaKeyBlend() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ChromaKeyBlend).thresholdSensitivity = value
                }),
                FilterModel(name: "DissolveBlend 消失混合",
                            filterType: .blend,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { DissolveBlend() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! DissolveBlend).mix = value
                }),
                FilterModel(name: "MultiplyBlend 乘法混合",
                            filterType: .blend,
                            initCallback: { DissolveBlend() }),
                FilterModel(name: "AddBlend 加法混合",
                            filterType: .blend,
                            initCallback: { AddBlend() }),
                FilterModel(name: "SubtractBlend 减法混合",
                            filterType: .blend,
                            initCallback: { SubtractBlend() }),
                FilterModel(name: "DivideBlend 分割混合",
                            filterType: .blend,
                            initCallback: { DivideBlend() }),
                FilterModel(name: "OverlayBlend 重叠混合",
                            filterType: .blend,
                            initCallback: { OverlayBlend() }),
                FilterModel(name: "DarkenBlend 颜色分量最小值混合",
                            filterType: .blend,
                            initCallback: { DarkenBlend() }),
                FilterModel(name: "LightenBlend 颜色分量最大值混合",
                            filterType: .blend,
                            initCallback: { LightenBlend() }),
                FilterModel(name: "ColorBurnBlend 颜色加深混合",
                            filterType: .blend,
                            initCallback: { ColorBurnBlend() }),
                FilterModel(name: "ColorDodgeBlend 颜色加亮混合",
                            filterType: .blend,
                            initCallback: { ColorDodgeBlend() }),
                FilterModel(name: "ScreenBlend 滤色混合",
                            filterType: .blend,
                            initCallback: { ScreenBlend() }),
                FilterModel(name: "ExclusionBlend 排除混合",
                            filterType: .blend,
                            initCallback: { ExclusionBlend() }),
                FilterModel(name: "DifferenceBlend 差异混合",
                            filterType: .blend,
                            initCallback: { DifferenceBlend() }),
                FilterModel(name: "HardLightBlend 强光混合",
                            filterType: .blend,
                            initCallback: { HardLightBlend() }),
                FilterModel(name: "SoftLightBlend 柔光混合",
                            filterType: .blend,
                            initCallback: { SoftLightBlend() }),
                FilterModel(name: "AlphaBlend Alpha混合",
                            filterType: .blend,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { AlphaBlend() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! AlphaBlend).mix = value
                }),
                FilterModel(name: "SourceOverBlend 图像源混合",
                            filterType: .blend,
                            initCallback: { SourceOverBlend() }),
                FilterModel(name: "NormalBlend 普通混合",
                            filterType: .blend,
                            initCallback: { NormalBlend() }),
                FilterModel(name: "ColorBlend 颜色混合",
                            filterType: .blend,
                            initCallback: { ColorBlend() }),
                FilterModel(name: "HueBlend 色调混合",
                            filterType: .blend,
                            initCallback: { HueBlend() }),
                FilterModel(name: "SaturationBlend 饱和度混合",
                            filterType: .blend,
                            initCallback: { SaturationBlend() }),
                FilterModel(name: "LuminosityBlend 亮度混合",
                            filterType: .blend,
                            initCallback: { LuminosityBlend() }),
                FilterModel(name: "LinearBurnBlend 线性加深混合",
                            filterType: .blend,
                            initCallback: { LinearBurnBlend() }),
            ],
            "Visual effects 视觉特效": [
                FilterModel(name: "Pixellate 像素化",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { Pixellate() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Pixellate).fractionalWidthOfAPixel = value
                }),
                FilterModel(name: "PolarPixellate 基于极坐标的像素化",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { PolarPixellate() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! PolarPixellate).center = Position(value, value)
                }),
                FilterModel(name: "PolkaDot 彩色点",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { PolkaDot() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! PolkaDot).fractionalWidthOfAPixel = value
                }),
                FilterModel(name: "Halftone 半色调",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { Halftone() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Halftone).fractionalWidthOfAPixel = value
                }),
                FilterModel(name: "Crosshatch 交叉排线",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.5),
                            initCallback: { Crosshatch() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Crosshatch).crossHatchSpacing = value
                }),
                FilterModel(name: "SketchFilter 素描滤镜",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { SketchFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SketchFilter).edgeStrength = value
                }),
                FilterModel(name: "ThresholdSketchFilter 阈值素描滤镜",
                               filterType: .basicOperation,
                               range: (0.0, 1.0, 1.0),
                               initCallback: { ThresholdSketchFilter() },
                               valueChangedCallback: { (filter, value) in
                                (filter as! ThresholdSketchFilter).edgeStrength = value
                }),
                FilterModel(name: "ToonFilter 黑色描边",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 1.0),
                            initCallback: { ToonFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! ToonFilter).threshold = value
                }),
                FilterModel(name: "SmoothToonFilter 平滑黑色描边",
                            filterType: .basicOperation,
                            range: (0.0, 10.0, 1.0),
                            initCallback: { SmoothToonFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SmoothToonFilter).blurRadiusInPixels = value
                }),
                FilterModel(name: "EmbossFilter 浮雕滤镜",
                            filterType: .basicOperation,
                            range: (0.0, 4.0, 0.0),
                            initCallback: { EmbossFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! EmbossFilter).intensity = value
                }),
                FilterModel(name: "Posterize 色调分离",
                            filterType: .basicOperation,
                            range: (1.0, 256.0, 1.0),
                            initCallback: { Posterize() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Posterize).colorLevels = value
                }),
                FilterModel(name: "SwirlDistortion 旋涡扭曲",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { SwirlDistortion() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SwirlDistortion).radius = value
                }),
                FilterModel(name: "BulgeDistortion 凸起扭曲",
                            filterType: .basicOperation,
                            range: (-1.0, 1.0, 0.0),
                            initCallback: { BulgeDistortion() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! BulgeDistortion).scale = value
                }),
                FilterModel(name: "PinchDistortion 捏合扭曲",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { PinchDistortion() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! PinchDistortion).center = Position(value, value)
                                (filter as! PinchDistortion).scale = -2
                                (filter as! PinchDistortion).radius = 0.2
                }),
                FilterModel(name: "StretchDistortion 拉伸扭曲",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { StretchDistortion() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! StretchDistortion).center = Position(value, value)
                }),
                FilterModel(name: "SphereRefraction 球体折射",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { SphereRefraction() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! SphereRefraction).refractiveIndex = value
                }),
                FilterModel(name: "GlassSphereRefraction 正像球体折射",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { GlassSphereRefraction() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! GlassSphereRefraction).refractiveIndex = value
                }),
                FilterModel(name: "Vignette 渐晕",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { Vignette() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Vignette).color = Color(red: value, green: value, blue: 0)
                }),
                FilterModel(name: "KuwaharaFilter Kuwahara滤镜",
                            filterType: .basicOperation,
                            range: (0.0, 10.0, 0.0),
                            initCallback: { KuwaharaFilter() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! KuwaharaFilter).radius = Int(value)
                }),
                FilterModel(name: "KuwaharaRadius3Filter KuwaharaRadius3滤镜",
                            filterType: .basicOperation,
                            initCallback: { KuwaharaRadius3Filter() }),
                FilterModel(name: "CGAColorspaceFilter CGA颜色空间",
                            filterType: .basicOperation,
                            initCallback: { CGAColorspaceFilter() }),
                FilterModel(name: "Solarize 过度曝光",
                            filterType: .basicOperation,
                            range: (0.0, 1.0, 0.0),
                            initCallback: { Solarize() },
                            valueChangedCallback: { (filter, value) in
                                (filter as! Solarize).threshold = value
                }),
            ]
        ];
    }
}
