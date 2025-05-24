//
//  EmployeeDetailViewController.h
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 24/05/2025.
//

#import <UIKit/UIKit.h>
#import "EmployeeDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmployeeDetailViewController : UIViewController

// Input ViewModel property (will be set by the presenting ViewController)
@property (nonatomic, strong) EmployeeDetailViewModel *viewModel;

// MARK: - IBOutlets for Storyboard Connection

// Photo Section
@property (nonatomic, weak) IBOutlet UIImageView *employeePhotoImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *photoActivityIndicator;

// Details Section
@property (nonatomic, weak) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *employeeTypeLabel;

@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;

// Biography
@property (nonatomic, weak) IBOutlet UILabel *biographyLabel;

// Stack view holding "Phone:" and actual phone number label
@property (nonatomic, weak) IBOutlet UIStackView *phoneStackView;
// Stack view holding "Email:" and actual email address label
@property (nonatomic, weak) IBOutlet UIStackView *emailStackView;
// Stack view holding "Biography:" and actual bio label
@property (nonatomic, weak) IBOutlet UIStackView *biographyStackView;

// Main Stack View to hold all detail labels,This will contain all the labels below the photo
@property (nonatomic, weak) IBOutlet UIStackView *detailsStackView;

@end

NS_ASSUME_NONNULL_END
