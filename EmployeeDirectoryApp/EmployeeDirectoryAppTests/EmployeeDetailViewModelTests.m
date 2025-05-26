//
//  EmployeeDetailViewModelTests.m
//  EmployeeDirectoryAppTests
//
//  Created by Zeeshan Shakeel on 26/05/2025.
//

#import <XCTest/XCTest.h>
#import "EmployeeDetailViewModel.h"
#import <EmployeeNetworking/Employee.h>

@interface EmployeeDetailViewModelTests : XCTestCase

@end

@implementation EmployeeDetailViewModelTests

#pragma mark - Helper Method for Test Data

- (Employee *)createEmployeeWithUUID:(NSString *)uuid
                                name:(NSString *)name
                       email:(NSString *)email
                       phoneNumber:(nullable NSString *)phoneNumber
                         biography:(nullable NSString *)biography
                              team:(NSString *)team
                      employeeType:(EmployeeType)employeeType
                     photoUrlSmall:(nullable NSString *)photoUrlSmall
                     photoUrlLarge:(nullable NSString *)photoUrlLarge {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"uuid"] = uuid;
    dictionary[@"full_name"] = name;
    dictionary[@"email_address"] = email;
    dictionary[@"team"] = team;

    // Convert EmployeeType enum to string for the dictionary
    NSString *typeString;
    switch (employeeType) {
        case EmployeeTypeFullTime:
            typeString = @"FULL_TIME";
            break;
        case EmployeeTypePartTime:
            typeString = @"PART_TIME";
            break;
        case EmployeeTypeContractor:
            typeString = @"CONTRACTOR";
            break;
        default:
            typeString = @"UNKNOWN"; // Should not happen with valid EmployeeType
            break;
    }
    dictionary[@"employee_type"] = typeString;

    if (phoneNumber) {
        dictionary[@"phone_number"] = phoneNumber;
    }
    if (biography) {
        dictionary[@"biography"] = biography;
    }
    if (photoUrlSmall) {
        dictionary[@"photo_url_small"] = photoUrlSmall;
    }
    if (photoUrlLarge) {
        dictionary[@"photo_url_large"] = photoUrlLarge;
    }

    return [[Employee alloc] initWithDictionary:dictionary];
}

#pragma mark - Test Cases

- (void)testViewModel_InitializationWithValidEmployee {
    // Arrange
    Employee *employee = [self createEmployeeWithUUID:@"123"
                                                 name:@"John Doe"
                                                email:@"john.doe@example.com"
                                          phoneNumber:@"1234567890"
                                            biography:@"A dedicated software engineer."
                                                 team:@"Engineering"
                                         employeeType:EmployeeTypeFullTime
                                        photoUrlSmall:@"https://example.com/small.jpg"
                                        photoUrlLarge:@"https://example.com/large.jpg"];

    // Act
    EmployeeDetailViewModel *viewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:employee];

    // Assert
    XCTAssertNotNil(viewModel, @"ViewModel should be initialized.");
    XCTAssertEqualObjects(viewModel.fullName, @"John Doe", @"Full name should match.");
    XCTAssertEqualObjects(viewModel.emailAddress, @"john.doe@example.com", @"Email address should match.");
    XCTAssertEqualObjects(viewModel.phoneNumber, @"(123) 456-7890", @"Phone number should be formatted.");
    XCTAssertEqualObjects(viewModel.biography, @"A dedicated software engineer.", @"Biography should match.");
    XCTAssertEqualObjects(viewModel.team, @"Engineering", @"Team should match.");
    XCTAssertEqualObjects(viewModel.employeeType, @"Full Time", @"Employee type should be 'Full Time'.");
    XCTAssertEqualObjects(viewModel.photoURLSmall.absoluteString, @"https://example.com/small.jpg", @"Small photo URL should match.");
    XCTAssertEqualObjects(viewModel.photoURLLarge.absoluteString, @"https://example.com/large.jpg", @"Large photo URL should match.");
}

- (void)testViewModel_PhoneNumberFormatting_InvalidFormat {
    // Arrange: Employee with a phone number that cannot be formatted
    Employee *employee = [self createEmployeeWithUUID:@"789"
                                                 name:@"Bob Johnson"
                                                email:@"bob@example.com"
                                          phoneNumber:@"123" // Not 10 digits
                                            biography:nil
                                                 team:@"HR"
                                         employeeType:EmployeeTypeContractor
                                        photoUrlSmall:nil
                                        photoUrlLarge:nil];

    // Act
    EmployeeDetailViewModel *viewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:employee];

    // Assert
    XCTAssertNotNil(viewModel, @"ViewModel should be initialized.");
    XCTAssertEqualObjects(viewModel.phoneNumber, @"123", @"Phone number should return original if format is not 10 digits.");
}

- (void)testViewModel_PhoneNumberFormatting_NonNumericCharacters {
    // Arrange: Phone number with non-numeric characters
    Employee *employee = [self createEmployeeWithUUID:@"101"
                                                 name:@"Alice Brown"
                                                email:@"alice@example.com"
                                          phoneNumber:@"555-123-4567"
                                            biography:nil
                                                 team:@"Sales"
                                         employeeType:EmployeeTypeFullTime
                                        photoUrlSmall:nil
                                        photoUrlLarge:nil];
    // Act
    EmployeeDetailViewModel *viewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:employee];

    // Assert
    // The internal logic extracts only numeric parts, so it should still format if 10 digits result
    XCTAssertEqualObjects(viewModel.phoneNumber, @"(555) 123-4567", @"Phone number should be formatted properly.");
}


- (void)testViewModel_EmployeeTypeMapping {
    // Test Full Time
    Employee *fullTimeEmployee = [self createEmployeeWithUUID:@"F1" name:@"FT Guy" email:@"ft@ex.com" phoneNumber:nil biography:nil team:@"Ops" employeeType:EmployeeTypeFullTime photoUrlSmall:nil photoUrlLarge:nil];
    EmployeeDetailViewModel *ftViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:fullTimeEmployee];
    XCTAssertEqualObjects(ftViewModel.employeeType, @"Full Time", @"Employee type should map to 'Full Time'.");

    // Test Part Time
    Employee *partTimeEmployee = [self createEmployeeWithUUID:@"P1" name:@"PT Gal" email:@"pt@ex.com" phoneNumber:nil biography:nil team:@"Support" employeeType:EmployeeTypePartTime photoUrlSmall:nil photoUrlLarge:nil];
    EmployeeDetailViewModel *ptViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:partTimeEmployee];
    XCTAssertEqualObjects(ptViewModel.employeeType, @"Part Time", @"Employee type should map to 'Part Time'.");

    // Test Contractor
    Employee *contractorEmployee = [self createEmployeeWithUUID:@"C1" name:@"Contractor" email:@"co@ex.com" phoneNumber:nil biography:nil team:@"Consulting" employeeType:EmployeeTypeContractor photoUrlSmall:nil photoUrlLarge:nil];
    EmployeeDetailViewModel *coViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:contractorEmployee];
    XCTAssertEqualObjects(coViewModel.employeeType, @"Contractor", @"Employee type should map to 'Contractor'.");

    // Test Unknown/Default as EmployeeType
    Employee *unknownTypeEmployee = [self createEmployeeWithUUID:@"U1" name:@"Unknown Type" email:@"ut@ex.com" phoneNumber:nil biography:nil team:@"Misc" employeeType:(EmployeeType)999 photoUrlSmall:nil photoUrlLarge:nil]; // Cast to simulate unknown enum
    EmployeeDetailViewModel *utViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:unknownTypeEmployee];
    XCTAssertEqualObjects(utViewModel.employeeType, @"Unknown", @"Employee type should map to 'Unknown' for unrecognized types.");
}

- (void)testViewModel_InitializationWithNilEmployee {
    // Arrange & Act
    // Attempt to initialize ViewModel with a nil Employee
    EmployeeDetailViewModel *nilEmployeeViewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:nil];
    
    // Create a nil employee (or just pass nil directly)
    Employee *nilEmployee = nil;
    
    // We expect the initializer to proceed, but with nil values for properties
    EmployeeDetailViewModel *viewModel = [[EmployeeDetailViewModel alloc] initWithEmployee:nilEmployee];
    
    XCTAssertNotNil(viewModel, @"ViewModel should still be initialized even with a nil employee if it doesn't return nil.");
    XCTAssertEqualObjects(viewModel.fullName, @"N/A", @"Full name should be 'N/A' for nil employee.");
    XCTAssertNil(viewModel.emailAddress, @"Email address should be nil for nil employee.");
    XCTAssertNil(viewModel.biography, @"Biography should be nil for nil employee.");
    XCTAssertEqualObjects(viewModel.team, @"N/A", @"Team should be 'N/A' for nil employee.");
    XCTAssertNil(viewModel.phoneNumber, @"Phone number should be nil for nil employee.");
    XCTAssertNil(viewModel.photoURLSmall, @"Small photo URL should be nil for nil employee.");
    XCTAssertNil(viewModel.photoURLLarge, @"Large photo URL should be nil for nil employee.");
}


@end
