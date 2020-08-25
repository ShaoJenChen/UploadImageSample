//
//  ViewController.swift
//  UploadImageSample
//
//  Created by ShaoJen Chen on 2020/5/19.
//  Copyright © 2020 ShaoJen Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func pickImage(_ sender: UIButton) {
        
        let controller = UIImagePickerController()

        controller.sourceType = .photoLibrary

        controller.delegate = self

        self.present(controller, animated: true, completion: nil)
        
    }
}

extension ViewController {

    internal func createBody(with image: UIImage, parameters: [String: String], boundary: String) -> Data? {
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        let fileName = "picture.jpg"
        let keyName = "file"
        
        let mimeType = "application/octet-stream"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; "
            + "name=\"\(keyName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        return body
    }
    
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let parameters = [
            "file": "xxx.com",
        ]
        
        guard let url = URL(string: "http://192.168.0.131:9090/uploadMore") else { picker.dismiss(animated: true, completion: nil); return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBody(with: image, parameters: parameters, boundary: boundary)
                
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        let uploadTask = session.dataTask(with: request) { (data, response, error) in
            
            //上傳完畢後
            if error != nil{
                print(error!)
            }else{
                let str = String(data: data!, encoding: String.Encoding.utf8)
                print("--- 上傳完畢 ---\(str!)")
            }
            
        }
        
        uploadTask.resume()
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

extension ViewController: URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64, totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let written = (Float)(totalBytesSent)
        let total = (Float)(totalBytesExpectedToSend)
        let pro = written/total
        print("進度：\(pro)")
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
