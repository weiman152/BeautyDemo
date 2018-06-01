//
//  SecondViewController.swift
//  BeautyDemo
//
//  Created by iOS on 2018/5/31.
//  Copyright © 2018年 weiman. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    private var videoCamera = GPUImageVideoCamera()
    private var captureVideoPreview = GPUImageView()
    let bilateralFilter = GPUImageBilateralFilter()
    let brightnessFilter = GPUImageBrightnessFilter()
    let saturationFilter = GPUImageSaturationFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }

    private func setup() {
        
        //1. 创建视频源
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
        videoCamera.outputImageOrientation = .portrait
        
        //2.创建预览的view
        captureVideoPreview = GPUImageView(frame: view.bounds)
        view.insertSubview(captureVideoPreview, at: 0)
        
        //3.设置处理链
        videoCamera.addTarget(captureVideoPreview)
        
        //4.开始
        videoCamera.startCapture()
        
    }
    
    /// 切换美颜
    @IBAction func switchChange(_ sender: UISwitch) {
        //切换美颜效果原理：一出之前所有处理链，重新设置处理链
        if sender.isOn {
            // 一处之前所有处理链
            videoCamera.removeAllTargets()
            
            //创建滤镜： 磨皮，美白，组合滤镜
            let groupFilter = GPUImageFilterGroup()
            
            // 3.1 磨皮滤镜
            groupFilter.addTarget(bilateralFilter)
            
            // 3.2 美白滤镜
            groupFilter.addTarget(brightnessFilter)
            
            // 3.3 饱和度
            groupFilter.addTarget(saturationFilter)
            
            // 3.3 设置滤镜组链
            bilateralFilter.addTarget(brightnessFilter)
            brightnessFilter.addTarget(saturationFilter)
            groupFilter.initialFilters = [bilateralFilter]
            groupFilter.terminalFilter = saturationFilter
            
            // 4. 设置GPUImage响应链，从数据源-》滤镜-〉最终界面效果
            videoCamera.addTarget(groupFilter)
            groupFilter.addTarget(captureVideoPreview)
            
            // 5.必须调用brightnessFilter，底层才会把采集到的视频源，渲染到
            // GPUImageView中，就能显示了
            // 开始采集视频
            videoCamera.startCapture()
            
        } else {
            // 移除之前所有处理链
            videoCamera.removeAllTargets()
            videoCamera.addTarget(captureVideoPreview)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    class func instance() -> SecondViewController {
        let storyB = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyB.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        return vc
    }
    
}
