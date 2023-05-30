//
//  ViewController.swift
//  VisionTest
//
//  Created by Zeto on 2023/05/30.
//

import UIKit
import VisionKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    private var vnTextRequest: VNRecognizeTextRequest?
    private var vnRequestHandlers: [VNImageRequestHandler] = []
    
    private var textImages: [CGImage] = []
    private var convertedTexts: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureVision()
    }
    
    @IBAction func executeVisionOCR(_ sender: UIButton) {
        do {
            guard let vnTextRequest else { return }
            
            try self.vnRequestHandlers.forEach {
                try $0.perform([vnTextRequest])
            }
            
        } catch {
            print("Execute Error: \(error.localizedDescription)")
        }
    }
}

private extension ViewController {
    
    func configureVision() {
        self.configureTextImages()
        self.configureVisionRequest()
        self.configureVisionSetting()
    }
    
    func configureTextImages() {
        for num in 1...5 {
            let image: UIImage? = .init(named: "\(num)")
            
            guard let image,  let cgImage: CGImage = image.cgImage else { continue }
            
            self.textImages.append(cgImage)
        }
    }
    
    func configureVisionRequest() {
        guard !(textImages.isEmpty) else { return }
        
        textImages.forEach {
            let vnRequestHandler: VNImageRequestHandler = .init(cgImage: $0)
            self.vnRequestHandlers.append(vnRequestHandler)
        }
        
        let request: VNRecognizeTextRequest = .init { [weak self] request, error in
            guard let self, let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            if let error {
                print("Request Error: \(error.localizedDescription)")
                
                return
            }
            
            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if convertedTexts.isEmpty {
                self.convertedTexts = text
            } else {
                self.convertedTexts += "\n\n\(text)"
            }
        }
        
        self.vnTextRequest = request
    }
    
    func configureVisionSetting() {
        if #available(iOS 16.0, *) {
            let revision3: Int = VNRecognizeTextRequestRevision3
            self.vnTextRequest?.revision = revision3
        }
        
        self.vnTextRequest?.recognitionLevel = .accurate
        self.vnTextRequest?.recognitionLanguages = ["ko-KR"]
        self.vnTextRequest?.usesLanguageCorrection = true
    }
}
