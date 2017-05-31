//
//  PersionalInfoViewController.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 5/30/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//

import UIKit

class PersionalInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set persional info
        let persionalInfo = PersonalInfo(name: "Pham Thanh Hung", email: "hungpt.0506@gmail.com")
        nameLabel.text = persionalInfo.name
        emailLabel.text = persionalInfo.email
        
        //Custom image view to circle
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor(hexString: "#0F85D1").cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        showAnimate()
        
        if UserDefaults.standard.object(forKey: "avatar") != nil {
            
            if let image = UserDefaults.standard.object(forKey: "avatar") as? Data {
                avatarImageView.image = UIImage(data: image)!

            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        removeAnimate()
    }
    
    @IBAction func updateLoadImageTapped(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImageView.image = image
            
            let defaults = UserDefaults.standard
            defaults.set(UIImageJPEGRepresentation(avatarImageView.image!, 100), forKey: "avatar")
            
            defaults.synchronize()
        } else {
            print("error")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }
}
