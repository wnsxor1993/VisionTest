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
    private var textRecognitionRequest: VNRecognizeTextRequest?
    
    private lazy var textObserver: ((String) -> Void) = { [weak self] newText in
        guard let self else { return }
        
        DispatchQueue.main.async {
            self.textView.text = newText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureVision()
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
        self.configureVNCamera()
        self.configureVNTextRequest()
    }
    
    func configureVNCamera() {
        self.vnCameraVC.delegate = self
        self.vnCameraVC.modalPresentationStyle = .fullScreen
    }
    
    func configureVNTextRequest() {
        self.textRecognitionRequest = .init { [weak self] (request, error) in
            guard let self, let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            if let error {
                print("TextRequestError: \(error.localizedDescription)")
                
                return
            }
            
            let observedText = observations.compactMap {
                $0.topCandidates(1).first?.string
            }
                .map {
                    if $0.last == "." || $0.last == "\"" {
                        let newChar: String = $0 + " "
                        return newChar
                    }
                    
                    return $0
                }
                .joined()
            
            let completedText = observedText.replacingOccurrences(of: ".", with: ".\n")
            self.textObserver(completedText)
        }
    }
}
