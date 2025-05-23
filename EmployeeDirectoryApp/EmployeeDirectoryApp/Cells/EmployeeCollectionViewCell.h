//
//  EmployeeCollectionViewCell.h
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import <UIKit/UIKit.h>
#import <EmployeeNetworking/Employee.h>

NS_ASSUME_NONNULL_BEGIN

// Define a reuse identifier for the cell as a public constant
extern NSString *const EmployeeCollectionViewCellReuseIdentifier;

@interface EmployeeCollectionViewCell : UICollectionViewCell

/**
 * @brief Configures the cell with employee data.
 * @param employee The Employee object containing data to display.
 */
- (void)configureWithEmployee:(Employee *)employee;

@end

NS_ASSUME_NONNULL_END
