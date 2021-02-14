//
//  PetProfileCollecionViewFlowLayout.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit

class PetProfileCollecionViewFlowLayout:NSObject, UICollectionViewDelegateFlowLayout {
    
    struct BaseLayout {
        static var lineNumber: CGFloat = 3.5
        static var miniMumItemSpacing: CGFloat = 0
        static var miniMumLineSpacing: CGFloat = 10
        static var egdeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        static var height: CGFloat = 60
        static var collectionViewCellHeight: CGFloat {
            let layout = PetProfileCollecionViewFlowLayout.BaseLayout.self
            return layout.height - layout.egdeInsets.top - layout.egdeInsets.bottom
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return BaseLayout.miniMumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return BaseLayout.miniMumItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return BaseLayout.egdeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = PetProfileCollecionViewFlowLayout.BaseLayout.collectionViewCellHeight
        return CGSize(width: size, height: size)
    }
}
