//
//  MGCameraUtils.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/4/20.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class MGCameraUtils {

    private var captureSession: AVCaptureSession?

    private var frontCameraDevice: AVCaptureDevice?
    private var backCameraDevice: AVCaptureDevice?

    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var backCameraInput: AVCaptureDeviceInput?

    var photoOutput: AVCaptureStillImageOutput?

    var previewLayer: AVCaptureVideoPreviewLayer?

    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }

    public enum CameraPosition {
        case front
        case back
    }


    //準備開始預覽相機, 這是一個異步方法, 返回時若有錯誤, 則無法預覽, 做唔, 則可以開始預覽
    public func prepare(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }


    //將預覽畫面投放到view上
    public func displayPreview(_ onView: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait

        onView.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = onView.bounds
    }


}

extension MGCameraUtils {

    //創建與相機溝通的session
    private func createCaptureSession() {
        captureSession = AVCaptureSession()
    }

    //得到相機裝置, 通常分成前置/後置
    private func configureCaptureDevices() throws {
        //        let availableCameraDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)

        let devices = AVCaptureDevice.devices(for: .video)

        //        let devices = availableCameraDevice.devices

        guard !devices.isEmpty else {
            throw CameraControllerError.noCamerasAvailable
        }

        try devices.forEach {

            switch $0.position {
            case .front: //前置鏡頭
                frontCameraDevice = $0
                break
            case .back: //後置鏡頭
                backCameraDevice = $0

                try $0.lockForConfiguration()
                $0.focusMode = .continuousAutoFocus
                $0.unlockForConfiguration()
                break
            case .unspecified: //未知
                break
            }

        }
    }

    /*
     1. 這行先簡單地確認captureSession是否存在，若不存在就會出現錯誤訊息。
     2. 這些if流程主要是要建立所需的 Capture Device Input 來支援相片擷取。
     AVFoundation每一次 Capture Session 僅能允許一台相機的輸入。
     由於裝置的初始設定通常是後相機，所以我們會先嘗試用後相機建立 Input，再加到 Capture Session；如出現錯誤，就會轉成前相機；若還是有問題，就會出現錯誤訊息。
     */
    private func configureDeviceInputs() throws {
        //1
        guard let captureSession = self.captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }

        //2
        if let backCameraDevice = self.backCameraDevice {
            self.backCameraInput = try AVCaptureDeviceInput(device: backCameraDevice)

            if captureSession.canAddInput(self.backCameraInput!) {
                captureSession.addInput(self.backCameraInput!)
            }

            self.currentCameraPosition = .back

        } else if let frontCameraDevice = self.frontCameraDevice {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)

            if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
            else { throw CameraControllerError.inputsAreInvalid }

            self.currentCameraPosition = .front
        }

        else { throw CameraControllerError.noCamerasAvailable }
    }


    //為當前的capturesession設定影像輸出端口
    private func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

        self.photoOutput = AVCaptureStillImageOutput()
        self.photoOutput!.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]

        if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }

        captureSession.startRunning()
    }

}







