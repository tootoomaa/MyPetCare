//
//  PetModelInputValidator.swift
//  MyPetCareTests
//
//  Created by 김광수 on 2021/02/06.
//

import XCTest
@testable import MyPetCare

class PetInputValidatorTests: XCTestCase {

    var sut: PetInputValidator!
    
    override func setUpWithError() throws {
        sut = PetInputValidator()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testPetInputValidator_WhenNameProvided_ShouldReturnTrue() {
        
        let isNameValid = sut.isNameValid(name: "댕댕이")
        
        XCTAssertTrue(isNameValid, "The isNameValid should return true when name is String Type")
    }
    // pet name
    func testPetInputValidator_WhenEmptyNameProvided_ShouldReturnFalse() {
        
        let isNameValid = sut.isNameValid(name: "")

        XCTAssertFalse(isNameValid, "The isNameValid should return false when name is empty")
    }
    // pet age
    func testPetInputValidator_WhenAgeOneDayBeforeNowProvided_ShoudReturnTrue() {
        
        let testDate = Date().addingTimeInterval(TimeInterval(-60*60*24))
        let isAgeValid = sut.isAgeValid(date: testDate)
        
        XCTAssertTrue(isAgeValid, "The isAgeValid should return false when Age is Date Type")
    }
    
    func testPetInputValidator_WhenAgeOneDatAfterNowProvided_ShoudReturnFalse() {
        
        let testDate = Date().addingTimeInterval(TimeInterval(60*60*24))
        let isAgeValid = sut.isAgeValid(date: testDate)
        
        XCTAssertFalse(isAgeValid, "The isAgeValid shoud return false when Date is more then current time")
    }
    
    func testPetInputValidator_WhenAgeCurrnetDayProvided_ShouldReturnTrue() {
        
        let testDate = Date()
        let isAgeValud = sut.isAgeValid(date: testDate)
        
        XCTAssertTrue(isAgeValud, "The isAgeValid shoud return false When Date is Current time")
    }
    
    func testPetInputValidator_WhenMaleTypeProvided_ShouldReturnTrue() {
        
        let isBoyMaleValid = sut.isMaleValid(type: .boy)
        let isGirlMaleValid = sut.isMaleValid(type: .girl)
        XCTAssertTrue(isBoyMaleValid, "The isMaleValid should return true When Mail is EnumType .boy")
        XCTAssertTrue(isGirlMaleValid, "The isMaleValid should return true When Mail is EnumType .girl")
    }
    
    func testPetInputValidator_WhenProfileImageDataProvided_ShouldReturnTrue() {
        
        let data = UIImage(named: "cat")?.pngData()
        let isImageData = sut.isProfileImage(imageData: data!)
        
        XCTAssertTrue(isImageData, "The isImageData should return true When Image Data is correct")
        
    }
    
    func testPetInputValidator_WhenNotProfileImageDataProvided_ShouldReturnFalse() {
        let data = UIImage(named: "itisnotImage")?.pngData() ?? Data()
        
        let isImageData = sut.isProfileImage(imageData: data)
        
        XCTAssertFalse(isImageData, "The isImageData Should return false When there is not a Image Data")
    }
}
