import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var barcodeValue = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new capture session
        captureSession = AVCaptureSession()
        
        // Get the back camera as the input device
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        // Add the input device to the capture session
        captureSession.addInput(input)
        
        // Create a new metadata output object
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        // Add the metadata output object to the capture session
        captureSession.addOutput(captureMetadataOutput)
        
        // Set the delegate for the metadata output object
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Set the metadata object types to scan for (in this case, just barcodes)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.code128]
        
        // Create a new video preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // Configure the preview layer's video gravity and frame
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        
        // Add the preview layer to the view's layer
        view.layer.addSublayer(previewLayer)
        
        // Start the capture session
        captureSession.startRunning()
    }
    
    // AVCaptureMetadataOutputObjectsDelegate method that gets called when a metadata object is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadata objects array contains at least one object
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        // Check if the detected object is a barcode
        if let barcodeObject = previewLayer.transformedMetadataObject(for: metadataObj) as? AVMetadataMachineReadableCodeObject,
           barcodeObject.type == AVMetadataObject.ObjectType.ean13 || barcodeObject.type == AVMetadataObject.ObjectType.code128 {
            // Print the barcode string to the console
            
            
            barcodeValue = metadataObj.stringValue ?? "No barcode found"
            captureSession.stopRunning()
            // print(barcodeValue)
            
        }
        self.performSegue(withIdentifier: "barcodePassedSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "barcodePassedSegue" {
            let destinationVC = segue.destination as! IngredientsViewController
            destinationVC.barcode = barcodeValue
        }
    }
}
