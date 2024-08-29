import Cocoa
import FlutterMacOS
import AVFoundation

@NSApplicationMain
class AppDelegate: FlutterAppDelegate, AVCapturePhotoCaptureDelegate {

    private let channelName = "com.quest.screenshot"
    var captureSession: AVCaptureSession?
    @available(macOS 10.15, *)
    var photoOutput: AVCapturePhotoOutput?

    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
        let screenshotChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.engine.binaryMessenger)

        screenshotChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "captureScreenshot":
                self?.captureScreenshot(result: result)
            case "capturePicture":
                if #available(macOS 10.15, *) {
                    self?.capturePicture(result: result)
                } else {
                    result(FlutterError(code: "UNSUPPORTED_VERSION", message: "macOS 10.15 or newer is required", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        super.applicationDidFinishLaunching(notification)
    }

    func captureScreenshot(result: @escaping FlutterResult) {
        let window = NSApp.keyWindow
        let rect = window?.frame ?? NSRect.zero

        if let image = CGWindowListCreateImage(rect, .optionOnScreenBelowWindow, CGWindowID(window?.windowNumber ?? 0), [.bestResolution]) {
            let bitmapRep = NSBitmapImageRep(cgImage: image)
            if let data = bitmapRep.representation(using: .png, properties: [:]) {
                let filename = getDocumentsDirectory().appendingPathComponent("screenshot.png")
                try? data.write(to: filename)
                result(filename.path)
            } else {
                result(FlutterError(code: "ERROR", message: "Failed to create PNG data", details: nil))
            }
        } else {
            result(FlutterError(code: "ERROR", message: "Failed to capture screenshot", details: nil))
        }
    }

    @available(macOS 10.15, *)
    func capturePicture(result: @escaping FlutterResult) {
        captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            result(FlutterError(code: "UNAVAILABLE", message: "No camera available", details: nil))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession?.addInput(input)
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput {
                captureSession?.addOutput(photoOutput)
                captureSession?.startRunning()

                let settings = AVCapturePhotoSettings()
                photoOutput.capturePhoto(with: settings, delegate: self)
            }
        } catch {
            result(FlutterError(code: "ERROR", message: "Failed to initialize camera: \(error.localizedDescription)", details: nil))
        }
    }

    @available(macOS 10.15, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        if let imageData = photo.fileDataRepresentation(),
           let image = NSImage(data: imageData) {
            let filename = getDocumentsDirectory().appendingPathComponent("picture.png")
            let data = image.tiffRepresentation

            if let pngData = NSBitmapImageRep(data: data!)?.representation(using: .png, properties: [:]) {
                try? pngData.write(to: filename)
             
                let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
                let screenshotChannel = FlutterMethodChannel(name: channelName,
                                                             binaryMessenger: controller.engine.binaryMessenger)
                screenshotChannel.invokeMethod("pictureCaptured", arguments: filename.path)
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

