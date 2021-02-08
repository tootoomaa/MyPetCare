//
//  PetAddViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/07.
//

import Foundation
import UIKit
import ReactorKit


class PetAddViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    let mainView = PetAddView()
    
    lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
        $0.allowsEditing = true
        $0.modalPresentationStyle = .overFullScreen
    }
    
    let isEditingMode: Bool
    
    let addNaviButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    let closeNanviButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    
    // MARK: - Life cycle
    init(_ isEditingMode: Bool) {
        self.isEditingMode = isEditingMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = self.mainView
        mainView.frame = view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainViewButtonBinding()
        
        configureNavigationBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func mainViewButtonBinding() {
        // done버튼 터치시 키보드 내리기
        mainView.nameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [unowned self] in
                mainView.endEditing(true)
            }).disposed(by: disposeBag)
        
        
        let petImageSelectTapGuesture =  UITapGestureRecognizer(target: nil, action: nil)
        mainView.petImage.addGestureRecognizer(petImageSelectTapGuesture)
        petImageSelectTapGuesture.rx.event
            .subscribe(onNext: { [unowned self] _ in
                
                let alertC = UIAlertController(title: "사진 선택", message: "사진을 가져올 곳을 선택해주세요",
                                               preferredStyle: .actionSheet)
                
                let photo = UIAlertAction(title: "사진첩", style: .default) { _ in
                    openLibrary()
                }
                
                let camera = UIAlertAction(title: "사진찍기", style: .default) { _ in
                    openCamera()
                }
                
                let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                    dismiss(animated: true, completion: nil)
                }
                
                alertC.addAction(photo)
                alertC.addAction(camera)
                alertC.addAction(cancel)
                
                self.present(alertC, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        self.navigationController?.configureNavigationBarAppearance(.lightBlue)
        self.navigationItem.title = "펫 등록"
        
        self.navigationItem.leftBarButtonItem = closeNanviButton
        self.navigationItem.rightBarButtonItem = addNaviButton
        self.navigationController?.navigationBar.backgroundColor = .lightDeepBlue
            
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - Reactor Binder
    func bind(reactor: MainViewControllerReactor) {
        
    }
}

extension PetAddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            newImage = image
        }
        
        self.mainView.petImage.image = newImage
        
        print(info)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func openLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
        
    }
    
    private func openCamera() {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: false, completion: nil)
    }
    
}
