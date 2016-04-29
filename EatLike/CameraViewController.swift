//
//  CameraViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/29.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import AVFoundation
class CameraViewController: UIViewController {
    let captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var stillImageOutput = AVCaptureStillImageOutput()
    var stillImage: UIImage?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as!
            [AVCaptureDevice]
        for device in devices {
            if device.position == .Back {
                backFacingCamera = device
            } else if device.position == .Front {
                frontFacingCamera = device
            }
        }
        // by default, back is the first started
        currentDevice = backFacingCamera
        do {
            let captrueDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
            captureSession.addInput(captrueDeviceInput)
            captureSession.addOutput(stillImageOutput)
        } catch {
            print(error)
        }
        // configure the still image to use JPEG encoder
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer.frame = view.layer.frame

        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(cancelButton)
        captureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func capture(sender: UIButton) {
        let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)

        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
            (imageDataSampleBuffer, error) in
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            self.stillImage = UIImage(data: imageData)
            self.performSegueWithIdentifier("ShowCaptureImage", sender: self)
        }
    }

    @IBAction func swipeSwitchCameraGesture(sender: UISwipeGestureRecognizer) {
        captureSession.beginConfiguration()
        let newDevice = currentDevice?.position == .Back ? frontFacingCamera : backFacingCamera
        // remove all inputs
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }

        guard let cameraInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }

        currentDevice = newDevice
        captureSession.commitConfiguration()
    }


    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    func configureZoom(isOut: Bool) {
        guard let zoomFactor = currentDevice?.videoZoomFactor else { return }
        let newZoomFactor: CGFloat
        if isOut {
            newZoomFactor = max(zoomFactor - 0.4, 1.0)
        } else {
            newZoomFactor = min(zoomFactor + 0.4, 4.0)
        }

        do {
            try currentDevice?.lockForConfiguration()
            currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 0.4)
            currentDevice?.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCaptureImage" {
            let captureNC = segue.destinationViewController as! UINavigationController
            let captureVC = captureNC.topViewController as! CapturePhotoViewController
            captureVC.image = stillImage
        }
    }

}
