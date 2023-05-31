//
//  CameraOCRViewController.swift
//  VisionTest
//
//  Created by Zeto on 2023/05/31.
//

import UIKit
import VisionKit
import Vision

final class CameraOCRViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    private let vnCameraVC: VNDocumentCameraViewController = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        self.present(vnCameraVC, animated: true)
    }
}

extension CameraOCRViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
        }

        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("CameraDocumentError: \(error.localizedDescription)")
        
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

private extension CameraOCRViewController {
    
    func configureVision() {
        self.vnCameraVC.delegate = self
        self.vnCameraVC.modalPresentationStyle = .fullScreen
    }
}
