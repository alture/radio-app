//
//  RadioAddViewController.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol RadioAddViewControllerDelegate {
  func radioAdded()
}

final class RadioAddViewController: BaseTableViewController, UINavigationControllerDelegate {
  
  // MARK: Properties
  
  var presenter: RadioAddPresentation?
  var delegate: RadioAddViewControllerDelegate?
  @IBOutlet weak var nameRadioTextField: RoundedTextField! {
    didSet {
      nameRadioTextField.tag = 1
      nameRadioTextField.delegate = self
      nameRadioTextField.addTarget(self,
                                   action: #selector(textFieldDidChange),
                                   for: .editingChanged)
    }
  }
  
  @IBOutlet weak var nameUrlTextField: RoundedTextField! {
    didSet {
      nameUrlTextField.tag = 2
      nameUrlTextField.delegate = self
      nameUrlTextField.addTarget(self,
                                 action: #selector(textFieldDidChange),
                                 for: .editingChanged)
    }
  }
  @IBOutlet weak var imageView: UIImageView!
  private var uploadImage: UIImage?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
    setupNavigationBar()
  }
  
  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "badge.plus.radiowaves.right"), style: .plain, target: self, action: #selector(didTapAddButton))
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.prefersLargeTitles = false
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    navigationItem.rightBarButtonItem?.isEnabled = false
  }
  
  @objc private func didTapAddButton() {
    guard
      let name = nameRadioTextField.text,
      let url = nameUrlTextField.text,
      name != "",
      url != ""
    else {
      return
    }
    
    presenter?.didTapAddRadioButton(with: uploadImage, name, url)
  }
  
  @objc private func textFieldDidChange() {
    guard
      let name = nameRadioTextField.text,
      let url = nameUrlTextField.text,
      name != "",
      url != ""
    else {
      navigationItem.rightBarButtonItem?.isEnabled = false
      return
    }
    
    navigationItem.rightBarButtonItem?.isEnabled = true
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      
      let photoSourceRequestController = UIAlertController(title: "", message: "Добавить изображение", preferredStyle: .actionSheet)
      
      let cameraAction = UIAlertAction(title: "Камера", style: .default, handler: { (action) in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          let imagePicker = UIImagePickerController()
          imagePicker.allowsEditing = false
          imagePicker.sourceType = .camera
          imagePicker.delegate = self
          self.present(imagePicker, animated: true, completion: nil)
        }
      })
      
      let photoLibraryAction = UIAlertAction(title: "Библиотека", style: .default, handler: { (action) in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
          let imagePicker = UIImagePickerController()
          imagePicker.allowsEditing = false
          imagePicker.sourceType = .photoLibrary
          imagePicker.delegate = self
          self.present(imagePicker, animated: true, completion: nil)
        }
      })
      
      let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
      
      photoSourceRequestController.addAction(cameraAction)
      photoSourceRequestController.addAction(photoLibraryAction)
      photoSourceRequestController.addAction(cancelAction)
      
      present(photoSourceRequestController, animated: true, completion: nil)
      
    }
  }
  
}

extension RadioAddViewController: RadioAddView {
  func dismiss() {
    dismiss(animated: true) {
      self.delegate?.radioAdded()
    }
  }
}

extension RadioAddViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if let nextTextField = view.viewWithTag(textField.tag + 1) {
          textField.resignFirstResponder()
          nextTextField.becomeFirstResponder()
      }

      return true
  }
}

extension RadioAddViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      uploadImage = selectedImage
      imageView.image = selectedImage
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
    }
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    dismiss(animated: true, completion: nil)
  }
}
