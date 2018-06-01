//
//  ViewController.swift
//  BeautyDemo
//
//  Created by iOS on 2018/5/31.
//  Copyright © 2018年 weiman. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

class ViewController: UIViewController {
    
    /// 视频源
    private var videoCamera = GPUImageVideoCamera()
    /// 磨皮滤镜
    private var bilateralFilter = GPUImageBilateralFilter()
    /// 美白滤镜
    private var brightnessFilter = GPUImageBrightnessFilter()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    private func setup() {
        
        //1. 创建视频源
        // SessionPreset:屏幕分辨率，AVCaptureSessionPresetHigh会自适应高分辨率
        // cameraPosition:摄像头方向
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
        videoCamera.outputImageOrientation = .portrait
        
        //2.创建最终预览的View
        let captureVideoPreview = GPUImageView(frame: view.bounds)
        view.insertSubview(captureVideoPreview, at: 0)
        
        //3.创建滤镜： 磨皮，美白，组合滤镜
        let groupFilter = GPUImageFilterGroup()
        
        // 3.1 磨皮滤镜
        groupFilter.addTarget(bilateralFilter)
        
        // 3.2 美白滤镜
        groupFilter.addTarget(brightnessFilter)
        
        // 3.3 设置滤镜组链
        bilateralFilter.addTarget(brightnessFilter)
        groupFilter.initialFilters = [bilateralFilter]
        groupFilter.terminalFilter = brightnessFilter
        
        // 4. 设置GPUImage响应链，从数据源-》滤镜-〉最终界面效果
        videoCamera.addTarget(groupFilter)
        groupFilter.addTarget(captureVideoPreview)
        
        // 5.必须调用brightnessFilter，底层才会把采集到的视频源，渲染到
        // GPUImageView中，就能显示了
        // 开始采集视频
        videoCamera.startCapture()
    }
    
}

extension ViewController {
   
    @IBAction func mopiAction(_ sender: UIButton) {
        // 值越小，磨皮效果越好
        bilateralFilter.distanceNormalizationFactor = 0.5
    }
    
    @IBAction func meibaiAction(_ sender: UIButton) {
        brightnessFilter.brightness = 0.3
    }
    
    @IBAction func recoverAction(_ sender: UIButton) {
        brightnessFilter.brightness = 0
        bilateralFilter.distanceNormalizationFactor = 10
    }
    /// 磨皮
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let maxvalue: Float = 5
        bilateralFilter.distanceNormalizationFactor = CGFloat(maxvalue - sender.value)
        print(bilateralFilter.distanceNormalizationFactor)
    }
    /// 美白
    @IBAction func meibaiSliderValueChange(_ sender: UISlider) {
        brightnessFilter.brightness = CGFloat(sender.value)
    }
    
    /// 下一页
    @IBAction func nextPage(_ sender: UIButton) {
        let vc = SecondViewController.instance()
        present(vc, animated: true, completion: nil)
    }
    
}










