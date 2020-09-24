//
//  ViewController.swift
//  KLGetMediaDemo
//
//  Created by WKL on 2020/9/22.
//  Copyright © 2020 ray. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    fileprivate   lazy var rSession : AVCaptureSession = AVCaptureSession()
    
    var rVodeoOutput : AVCaptureVideoDataOutput?
    
    var rPreLayer : AVCaptureVideoPreviewLayer?
    
    var rVideoInput : AVCaptureDeviceInput?
    
    var  rVideoOutFile : AVCaptureMovieFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        view.backgroundColor = .gray
        
        
        setupVideoInputOutPut()
        setupAudioInputOutPut()
        
        
        setUpMoiveOutFile()
        
        
    }
    
    
    
    @IBAction func pvt_start(_ sender: UIButton) {
        
        
        
        print("开始采集")
        self.rSession.startRunning()
        
        setUpPrevierLayer()
        
        
        rVideoOutFile?.startRecording(to: (rVideoOutFile?.outputFileURL)!, recordingDelegate: self)
        
        
        
    }
    
    
    @IBAction func pvt_pause(_ sender: UIButton) {
        
        print("切换")
        
        guard let videoInput = rVideoInput else {return}
        let position : AVCaptureDevice.Position  =  videoInput.device.position == .back ? .front : .back
        
        
        //创建视频输入
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices(for: .video)
        
        guard let devi = devices.filter({$0.position == position}).first   else { return  }
        guard  let input = try? AVCaptureDeviceInput.init(device: devi)else {return}
        
        rSession.beginConfiguration()
        
        rSession.removeInput(videoInput)
        
        if rSession.canAddInput(input){
            rSession.addInput(input)
        }
        
        rSession.commitConfiguration()
        
        rVideoInput = input
        
    }
    
    
    @IBAction func pvt_stop(_ sender: UIButton) {
        
        rSession.stopRunning()
        
        
        rVideoOutFile?.stopRecording()
        print("停止采集")
        
        rPreLayer?.removeFromSuperlayer()
        
    }
    @IBAction func pvt_play(_ sender: UIButton) {
        
        print("播放")
        
    }
}






extension ViewController{
    
    
    func setupVideoInputOutPut ()  {
        
        //创建视频输入
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices(for: .video)
        
        guard let devi = devices.filter({$0.position == .front}).first   else { return  }
        
        guard  let input = try? AVCaptureDeviceInput.init(device: devi)else {return}
        rVideoInput = input
        
        //创建视频输出
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        
        
        addInputOutputToSession(input, output)
        
        rVodeoOutput = output
        
        
    }
    
    
    func  setupAudioInputOutPut ()  {
        
        
        guard  let device = AVCaptureDevice.default(for: .audio) else {return}
        
        guard  let input = try? AVCaptureDeviceInput.init(device: device)else {return }
        
        
        
        //创建视频输出
        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        
        //设置方向
        let connection = output .connection(with: .video)
        connection?.videoOrientation = .portrait
        
        
        addInputOutputToSession(input, output)
        
    }
    
    func  setUpPrevierLayer ()  {
        //创建预览图层
        let preLayer =  AVCaptureVideoPreviewLayer()
        preLayer.session = self.rSession
        
        preLayer.frame = view.bounds
        
        preLayer.backgroundColor = UIColor.purple.cgColor
        
        view.layer.insertSublayer(preLayer, at: 0)
        
        rPreLayer = preLayer
    }
    
    
    func setUpMoiveOutFile ()  {
        
        //创建文件输出
        let fileOutput = AVCaptureMovieFileOutput()
        
        
        let connection =  fileOutput.connection(with: .video)
        connection?.automaticallyAdjustsVideoMirroring = true
        
        if rSession.canAddOutput(fileOutput){
            rSession.addOutput(fileOutput)
        }
        
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "abc.mp4"
        
        let fileUrl = URL(fileURLWithPath: filePath)
        
        fileOutput.startRecording(to: fileUrl, recordingDelegate: self)
        
        
        rVideoOutFile = fileOutput
        
    }
    
    func addInputOutputToSession(_ input: AVCaptureDeviceInput, _ output: AVCaptureOutput) {
        
        
        //添加输入&输出
        rSession.beginConfiguration()
        
        if rSession.canAddInput(input){
            rSession.addInput(input)
        }
        
        if rSession.canAddOutput(output){
            rSession.addOutput(output)
        }
        
        
        rSession.commitConfiguration()
        
    }
    
    
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        if connection == rVodeoOutput?.connection(with: .video) {
            
            print("已采集视频画面")
            
        }else {
            
            print("已采集音频")
            
        }
        
    }
    
    
}


extension ViewController : AVCaptureFileOutputRecordingDelegate {
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]){
        
        print("开始写入文件")
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        print("结束写入文件")
        
    }
    
    
}





