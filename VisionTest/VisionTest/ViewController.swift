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
    
    private var textImages: [CGImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension ViewController {
    
    func configureTextImages() {
        for num in 1...5 {
            let image: UIImage? = .init(named: "\(num)")
            
            guard let image,  let cgImage: CGImage = image.cgImage else { continue }
            
            self.textImages.append(cgImage)
        }
    }
    
    func configureVision() {
        guard !(textImages.isEmpty) else { return }
    }
}
