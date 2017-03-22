//
//  ViewController.swift
//  liubai
//
//  Created by 李江波 on 2017/2/25.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var photos: UIImagePickerController = {
        let photos = UIImagePickerController()
        photos.sourceType = .photoLibrary
        photos.delegate = self
        return photos
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }

    @IBAction func openCameraAction(_ sender: Any) {
        
        let openCameraVC = CameraController()
        present(openCameraVC, animated: true, completion: nil)
    }
    
    @IBAction func openPhotosAction(_ sender: Any) {
        
//        let photosVc = PhotosController()
//        present(photosVc, animated: true, completion: nil)
        present(photos, animated: true, completion: nil)
        
    }
}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        let photosVC = PhotosController()
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        photosVC.chooseImage = img.imgScale(width: SCREENW)
        present(photosVC, animated: true, completion: nil)
    }
    
   

}













