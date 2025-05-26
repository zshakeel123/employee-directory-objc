//
//  EmployeeDetailViewController.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 24/05/2025.
//

#import "EmployeeDetailViewController.h"
#import "EmployeeDirectoryApp-Swift.h"

@interface EmployeeDetailViewController ()
// No additional private properties needed here, as all UI elements are IBOutlets
@end

@implementation EmployeeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Employee Details";
    self.view.backgroundColor = [UIColor systemBackgroundColor]; // Adapts to dark/light mode
    
    [self setupInitialUIState];

    [self configureUI];
}

#pragma mark - UI Configuration

// Initial setup of UI (e.g., placeholders, default states)
- (void)setupInitialUIState {
    // Apply basic styling/placeholders that don't depend on ViewModel data
    self.employeePhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.employeePhotoImageView.clipsToBounds = YES;
    self.employeePhotoImageView.layer.cornerRadius = (self.employeePhotoImageView.bounds.size.width / 2.0); // Will adjust in configureUI after constraints
    self.employeePhotoImageView.backgroundColor = [UIColor systemGray5Color]; // Placeholder background
    self.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"]; // Default SF Symbols placeholder
    self.employeePhotoImageView.tintColor = [UIColor systemGrayColor];

    // Hide activity indicator initially
    [self.photoActivityIndicator stopAnimating];

    // Basic label styling
    self.fullNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    self.fullNameLabel.textColor = [UIColor labelColor];
    self.fullNameLabel.textAlignment = NSTextAlignmentCenter;

    self.teamLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.teamLabel.textColor = [UIColor secondaryLabelColor];
    self.teamLabel.textAlignment = NSTextAlignmentCenter;

    self.employeeTypeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.employeeTypeLabel.textColor = [UIColor tertiaryLabelColor];
    self.employeeTypeLabel.textAlignment = NSTextAlignmentCenter;

    // Detail labels
    self.phoneLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.phoneLabel.textColor = [UIColor labelColor];
    self.phoneLabel.textAlignment = NSTextAlignmentLeft;
    
    self.emailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.emailLabel.textColor = [UIColor labelColor];
    self.emailLabel.textAlignment = NSTextAlignmentLeft;
    
    self.biographyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.biographyLabel.textColor = [UIColor labelColor];
    self.biographyLabel.textAlignment = NSTextAlignmentLeft;
    self.biographyLabel.numberOfLines = 0; // Allow multiple lines for biography
}

- (void)configureUI {
    if (!self.viewModel) {
        NSLog(@"Error: EmployeeDetailViewModel not set for EmployeeDetailViewController.");
        return;
    }

    // Populate labels
    self.fullNameLabel.text = self.viewModel.fullName;
    self.teamLabel.text = self.viewModel.team;
    self.employeeTypeLabel.text = self.viewModel.employeeType;

    // Handle optional fields: hide parent stack view if data is missing
    self.phoneLabel.text = self.viewModel.phoneNumber;
    self.phoneStackView.hidden = (self.viewModel.phoneNumber == nil || self.viewModel.phoneNumber.length == 0);

    self.emailLabel.text = self.viewModel.emailAddress;
    self.emailStackView.hidden = (self.viewModel.emailAddress == nil || self.viewModel.emailAddress.length == 0);

    self.biographyLabel.text = self.viewModel.biography;
    self.biographyStackView.hidden = (self.viewModel.biography == nil || self.viewModel.biography.length == 0);
    
    // load the image
    if(self.viewModel.photoURLLarge){
        [KingfisherWrapper setImageOn:self.employeePhotoImageView
                             urlString:self.viewModel.photoURLLarge
                    activityIndicator:self.photoActivityIndicator];
    }
}

// Ensure the photo image view is circular after its size is determined by Auto Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.employeePhotoImageView.layer.cornerRadius = self.employeePhotoImageView.bounds.size.width / 2.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
