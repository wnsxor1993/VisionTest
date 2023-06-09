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
    
    private var vnCameraVC: VNDocumentCameraViewController?
    private var textRecognitionRequest: VNRecognizeTextRequest?
    
    private var vnCGImage: CGImage?
    
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
    
    // VNCamera를 새로 생성하지 않으면 이전 촬영 이미지들이 그대로 남아있음
    @IBAction func takePicture(_ sender: UIButton) {
        self.initializeVNCamera()
        
        guard let vnCameraVC else { return }
        
        self.present(vnCameraVC, animated: true)
    }
}

extension CameraOCRViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for pageNumber in 0..<scan.pageCount {
            let image: UIImage = scan.imageOfPage(at: pageNumber)
            self.convertToCGImage(from: image)
        }

        controller.dismiss(animated: true) {
            self.vnCameraVC = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.executeOCR()
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("CameraDocumentError: \(error.localizedDescription)")
        
        controller.dismiss(animated: true) {
            self.vnCameraVC = nil
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true) {
            self.vnCameraVC = nil
        }
    }
}

private extension CameraOCRViewController {
    
    func initializeVNCamera() {
        self.vnCameraVC = .init()
        self.vnCameraVC?.delegate = self
        self.vnCameraVC?.modalPresentationStyle = .fullScreen
    }
    
    func convertToCGImage(from image: UIImage) {
        guard let cgImage: CGImage = image.cgImage else { return }
        
        self.vnCGImage = cgImage
    }
    
    func executeOCR() {
        guard let vnCGImage, let textRecognitionRequest else { return }
        
        let requestHandler: VNImageRequestHandler = .init(cgImage: vnCGImage)
        
        DispatchQueue.global(qos: .background).async {
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                print("RequestHandlerError: \(error.localizedDescription)")
            }
        }
    }
}

private extension CameraOCRViewController {
    
    func configureVision() {
        self.configureVNTextRequest()
        self.configureRequestSetting()
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
    
    // textRecognitionRequest 설정이 없으면 영어가 기본으로 잡혀서 인식이 안 됨
    func configureRequestSetting() {
        if #available(iOS 16.0, *) {
            // 최신 Vision으로 할당
            let revision3: Int = VNRecognizeTextRequestRevision3
            self.textRecognitionRequest?.revision = revision3
        }
        
        // 속도와 정확도 중에서 선택 가능
        self.textRecognitionRequest?.recognitionLevel = .accurate
        self.textRecognitionRequest?.recognitionLanguages = ["ko-KR"]
        self.textRecognitionRequest?.usesLanguageCorrection = true
    }
}
