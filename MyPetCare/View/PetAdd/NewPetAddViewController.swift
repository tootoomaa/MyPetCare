//
//  NewPetAddViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/08.
//

import Foundation
import UIKit
import ReactorKit

class NewPetAddViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    let mainView = NewPetAddView()
    
    lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
        $0.allowsEditing = true
        $0.modalPresentationStyle = .overFullScreen
    }
    
    let addNaviButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    let closeNanviButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    // MARK: - Life Cycle
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
    func bind(reactor: MainViewControllerReactor) {
        
        Observable.just(["몸무게","혈액형","BSC"])
            .bind(to: mainView.tableView.rx.items(cellIdentifier: HealthDataCell.identifier,
                                                  cellType: HealthDataCell.self)) { row, data, cell in
                
                cell.titleLabel.text = data
                
            }.disposed(by: disposeBag)
        
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

// MARK: - HealthDataCell
class HealthDataCell: UITableViewCell {
    
    static let identifier = "HealthDataCell"
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .lightBlue

        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        
        [titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            $0.centerY.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
}


