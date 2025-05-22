//
//  EmployeeNetworkingConstants.h
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Top-level response key
extern NSString *const EmployeeListResponseEmployeesKey;

// Employee object keys
extern NSString *const EmployeeUUIDKey;
extern NSString *const EmployeeFullNameKey;
extern NSString *const EmployeePhoneNumberKey;
extern NSString *const EmployeeEmailAddressKey;
extern NSString *const EmployeeBiographyKey;
extern NSString *const EmployeePhotoURLSmallKey;
extern NSString *const EmployeePhotoURLLargeKey;
extern NSString *const EmployeeTeamKey;
extern NSString *const EmployeeTypeKey;

// Employee type string values for enum mapping
extern NSString *const EmployeeTypeFullTimeString;
extern NSString *const EmployeeTypePartTimeString;
extern NSString *const EmployeeTypeContractorString;

NS_ASSUME_NONNULL_END
