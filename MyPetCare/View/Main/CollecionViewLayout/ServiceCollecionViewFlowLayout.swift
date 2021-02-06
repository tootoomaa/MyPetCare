//
//  ServiceCollecionViewFlowLayout.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//
import Foundation
import UIKit

class ServiceCollecionViewFlowLayout:NSObject, UICollectionViewDelegateFlowLayout {
    
    struct BaseLayout {
        static var lineNumber: CGFloat = 2
        static var miniMumItemSpacing: CGFloat = 10
        static var miniMumLineSpacing: CGFloat = 10
        static var edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static var collectionViewHeight: CGFloat = 100
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return BaseLayout.miniMumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return BaseLayout.miniMumItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return BaseLayout.edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - BaseLayout.edgeInsets.left - BaseLayout.edgeInsets.right - BaseLayout.miniMumLineSpacing*(BaseLayout.lineNumber-1))/BaseLayout.lineNumber
        
        return CGSize(width: width, height: BaseLayout.collectionViewHeight)
    }
}
