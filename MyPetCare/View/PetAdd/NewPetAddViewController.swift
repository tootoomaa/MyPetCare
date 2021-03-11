//
//  NewPetAddViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/08.
//

import Foundation
import UIKit
import RxCocoa
import ReactorKit

class NewPetAddViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    let mainView = NewPetAddView()
    
    lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
        $0.allowsEditing = true
        $0.modalPresentationStyle = .overFullScreen
    }
    
    let addNaviButton: UIBarButtonItem
    let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    
    // MARK: - Life Cycle
    
    init(isEditMode: Bool) {
        self.addNaviButton = isEditMode == true
            ? UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
            : UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = addNaviButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        mainViewButtonBinding()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.nameTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mainView.endEditing(true)
    }
    
    private func configureNavigationBar() {
        self.navigationController?.configureNavigation(.extraLightPink, largeTitle: false)
        self.navigationItem.leftBarButtonItem = closeNanviButton
        self.navigationController?.navigationBar.backgroundColor = .extraGray
        
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - MainView Button Binding
    private func mainViewButtonBinding() {
        // done버튼 터치시 키보드 내리기
        mainView.nameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [unowned self] in
                mainView.endEditing(true)
            }).disposed(by: disposeBag)
        
        let petImageSelectTapGuesture =  UITapGestureRecognizer(target: nil, action: nil)
        mainView.petImageView.addGestureRecognizer(petImageSelectTapGuesture)
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

    // MARK: - Reactor Binder
    func bind(reactor: PetAddViewReactor) {
        // state
        reactor.state.map{$0.isEditMode}
            .map{$0 == true ? "펫 수정" : "펫 등록"}
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.petName}
            .distinctUntilChanged()
            .compactMap{$0}
            .bind(to: mainView.nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.male}
            .compactMap{Male(rawValue: $0)}
            .compactMap{Male.allCases.firstIndex(of: $0)}
            .bind(to: mainView.maleSegmentController.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.species}
            .compactMap{SpeciesType(rawValue: $0)}
            .compactMap{SpeciesType.allCases.firstIndex(of: $0)}
            .bind(to: mainView.sepicesSegmentController.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.birthDay}
            .distinctUntilChanged()
            .compactMap{$0}
            .bind(to: mainView.datePicker.rx.date)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.petImageData}
            .distinctUntilChanged()
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                let image = UIImage(data: data) ?? UIImage(systemName: "photo")
                owner.mainView.petImageView.layer.cornerRadius = (owner.mainView.viewWidthMinusPadding/2*0.8)/2
                owner.mainView.petImageView.clipsToBounds = true
                owner.mainView.petImageView.image = image
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isComplete}
            .observe(on: MainScheduler.asyncInstance)
            .filter{$0 == true}
            .subscribe(onNext: { _ in
                
                self.dismiss(animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.isEnableSaveButton}
            .bind(to: addNaviButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Action
        mainView.nameTextField.rx.value.changed
            .compactMap{$0}
            .map{Reactor.Action.inputPetName($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        mainView.datePicker.rx.value.changed
            .compactMap{$0}
            .map{Reactor.Action.inputBirthDay($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.maleSegmentController.rx.controlEvent(.valueChanged)
            .map{self.mainView.maleSegmentController.selectedSegmentIndex}
            .compactMap{Male.allCases[$0].rawValue}
            .map{Reactor.Action.inputMale($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.sepicesSegmentController.rx.controlEvent(.valueChanged)
            .map{self.mainView.sepicesSegmentController.selectedSegmentIndex}
            .compactMap{SpeciesType.allCases[$0].rawValue}
            .map{Reactor.Action.inputSpecies($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addNaviButton.rx.tap
            .map{Reactor.Action.savePet}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        imagePicker.rx.viewDidDisappear
            .map{ _ in self.mainView.petImageView.image?.pngData()}
            .compactMap{$0}
            .map{Reactor.Action.inputPetImage($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension NewPetAddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
        
        self.mainView.petImageView.image = newImage
        self.mainView.petImageView.layer.cornerRadius = self.mainView.petImageView.frame.width/2
        self.mainView.petImageView.clipsToBounds = true
        
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

extension Reactive where Base: NewPetAddViewController {
    var tapPetAddButton: ControlEvent<Void> {
        let source = base.addNaviButton.rx.tap.debug()
        return ControlEvent(events: source)
    }
}
