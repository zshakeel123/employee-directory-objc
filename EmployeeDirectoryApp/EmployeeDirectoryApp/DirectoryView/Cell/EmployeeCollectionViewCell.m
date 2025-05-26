//
//  EmployeeCollectionViewCell.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import "EmployeeCollectionViewCell.h"
#import "EmployeeDirectoryApp-Swift.h"

// Define the reuse identifier's value
NSString *const EmployeeCollectionViewCellReuseIdentifier = @"EmployeeCell";

@interface EmployeeCollectionViewCell ()

@property (nonatomic, strong) UIImageView *employeePhotoImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *teamLabel;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UIActivityIndicatorView *photoActivityIndicator;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *currentImageTask;

@end

@implementation EmployeeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupConstraints];
        
        // Basic cell styling
        self.contentView.backgroundColor = [UIColor systemBackgroundColor]; // A light background for the cell
        self.contentView.layer.cornerRadius = 8.0;
        self.contentView.layer.masksToBounds = YES; // Ensures content respects cornerRadius
        self.contentView.layer.borderColor = [UIColor systemGray5Color].CGColor;
        self.contentView.layer.borderWidth = 1.0;
        
        // Add a subtle shadow to the cell's layer for better visual separation
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 5.0;
        self.layer.masksToBounds = NO; // Important for shadows to be visible outside bounds
        self.layer.shouldRasterize = YES; // Performance optimization for shadows
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}

// Called by the collection view when a cell is reused
- (void)prepareForReuse {
    [super prepareForReuse];
    // Reset content to avoid displaying stale data
    self.employeePhotoImageView.image = nil;
    self.nameLabel.text = nil;
    self.teamLabel.text = nil;

    // Cancel any ongoing image loading task for the previous cell's content
    [self.currentImageTask cancel];
    self.currentImageTask = nil;
    [self.photoActivityIndicator stopAnimating];
}

- (void)setupViews {
    // 1. Employee Photo Image View
    self.employeePhotoImageView = [[UIImageView alloc] init];
    self.employeePhotoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.employeePhotoImageView.contentMode = UIViewContentModeScaleAspectFill; // Scale to fill, crop if necessary
    self.employeePhotoImageView.clipsToBounds = YES; // Ensure content stays within bounds and respects cornerRadius
    self.employeePhotoImageView.layer.cornerRadius = 40.0; // Half of 80x80 to make it circular
    self.employeePhotoImageView.backgroundColor = [UIColor systemGray5Color]; // Background before image loads
    self.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.circle.fill"]; // Default SF Symbols placeholder
    self.employeePhotoImageView.tintColor = [UIColor systemGrayColor]; // Tint for SF Symbols

    // 2. Activity Indicator for Photo Loading
    self.photoActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.photoActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoActivityIndicator.hidesWhenStopped = YES; // Automatically hide when not animating
    [self.employeePhotoImageView addSubview:self.photoActivityIndicator]; // Add on top of image view

    // 3. Name Label
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.nameLabel.textColor = [UIColor labelColor]; // Adaptable to dark/light mode
    self.nameLabel.numberOfLines = 1; // Usually names fit on one line, can be 0 if wrapping is desired
    self.nameLabel.adjustsFontSizeToFitWidth = YES; // Shrink font if needed
    self.nameLabel.minimumScaleFactor = 0.8;

    // 4. Team Label
    self.teamLabel = [[UILabel alloc] init];
    self.teamLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.teamLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.teamLabel.textColor = [UIColor secondaryLabelColor]; // Adaptable to dark/light mode
    self.teamLabel.numberOfLines = 1; // Team names usually fit on one line
    self.teamLabel.adjustsFontSizeToFitWidth = YES;
    self.teamLabel.minimumScaleFactor = 0.8;

    // 5. Vertical Stack View for Text Labels (Name and Team)
    UIStackView *textStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.nameLabel, self.teamLabel]];
    textStackView.translatesAutoresizingMaskIntoConstraints = NO;
    textStackView.axis = UILayoutConstraintAxisVertical;
    textStackView.distribution = UIStackViewDistributionFill;
    textStackView.alignment = UIStackViewAlignmentCenter;
    //textStackView.spacing = 2.0; // Small space between name and team

    // 6. Main Horizontal Stack View for entire cell content (Image + Text Stack)
    self.mainStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.employeePhotoImageView, textStackView]];
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.distribution = UIStackViewDistributionFill;
    self.mainStackView.alignment = UIStackViewAlignmentCenter; // Vertically center the image and text stack
    self.mainStackView.spacing = 12.0; // Space between image and text
    self.mainStackView.layoutMarginsRelativeArrangement = YES; // Enable layout margins
    self.mainStackView.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(20, 12, 12, 12); // Padding inside the stack view

    // Add the main stack view to the cell's content view
    [self.contentView addSubview:self.mainStackView];
}

- (void)setupConstraints {
    // Constraints for the employee photo image view (fixed size)
    [NSLayoutConstraint activateConstraints:@[
        [self.employeePhotoImageView.widthAnchor constraintEqualToConstant:80],
        [self.employeePhotoImageView.heightAnchor constraintEqualToConstant:80],
        // Center the activity indicator within the photo image view
        [self.photoActivityIndicator.centerXAnchor constraintEqualToAnchor:self.employeePhotoImageView.centerXAnchor],
        [self.photoActivityIndicator.centerYAnchor constraintEqualToAnchor:self.employeePhotoImageView.centerYAnchor]
    ]];

    // Constraints for the main stack view to fill the content view with margins
    [NSLayoutConstraint activateConstraints:@[
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor]
    ]];
}

- (void)configureWithEmployee:(Employee *)employee {
    self.nameLabel.text = employee.fullName;
    self.teamLabel.text = employee.team;

    // Reset to default placeholder and start indicator before loading a new image
    self.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.circle.fill"];
    self.employeePhotoImageView.tintColor = [UIColor systemGrayColor];
    
    // load the image
    if(employee.photoUrlSmall){
        [KingfisherWrapper setImageOn:self.employeePhotoImageView
                             urlString:employee.photoUrlSmall
                    activityIndicator:self.photoActivityIndicator];
    }
}

@end
