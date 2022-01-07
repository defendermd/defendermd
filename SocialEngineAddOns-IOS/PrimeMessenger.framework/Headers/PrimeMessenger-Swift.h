// Generated by Apple Swift version 4.2.1 (swiftlang-1000.11.42 clang-1000.11.45.1)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import CoreGraphics;
@import Foundation;
@import ObjectiveC;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="PrimeMessenger",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class NSCoder;
@class UIImage;

SWIFT_CLASS("_TtC14PrimeMessenger15AvatarImageView")
@interface AvatarImageView : UIImageView
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithImage:(UIImage * _Nullable)image SWIFT_UNAVAILABLE;
- (void)layoutSubviews;
- (nonnull instancetype)initWithImage:(UIImage * _Nullable)image highlightedImage:(UIImage * _Nullable)highlightedImage SWIFT_UNAVAILABLE;
@end

@class UIColor;

SWIFT_CLASS("_TtC14PrimeMessenger10BadgeSwift")
@interface BadgeSwift : UILabel
/// Background color of the badge
@property (nonatomic, strong) UIColor * _Nonnull badgeColor;
/// Width of the badge border
@property (nonatomic) CGFloat borderWidth;
/// Color of the bardge border
@property (nonatomic, strong) UIColor * _Nonnull borderColor;
/// Badge insets that describe the margin between text and the edge of the badge.
@property (nonatomic) CGSize insets;
/// Opacity of the badge shadow
@property (nonatomic) CGFloat shadowOpacityBadge;
/// Size of the badge shadow
@property (nonatomic) CGFloat shadowRadiusBadge;
/// Color of the badge shadow
@property (nonatomic, strong) UIColor * _Nonnull shadowColorBadge;
/// Offset of the badge shadow
@property (nonatomic) CGSize shadowOffsetBadge;
/// Corner radius of the badge. -1 if unspecified. When unspecified, the corner is fully rounded. Default: -1.
@property (nonatomic) CGFloat cornerRadius;
/// Initialize the badge view
- (nonnull instancetype)init;
/// Initialize the badge view
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
/// Initialize the badge view
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
/// Add custom insets around the text
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines SWIFT_WARN_UNUSED_RESULT;
/// Draws the label with insets
- (void)drawTextInRect:(CGRect)rect;
/// Draw the background of the badge
- (void)drawRect:(CGRect)rect;
/// Draw the stars in interface builder
- (void)prepareForInterfaceBuilder SWIFT_AVAILABILITY(ios,introduced=8.0);
@end

@class NSAttributedString;

SWIFT_CLASS("_TtC14PrimeMessenger19BottomSeparatorCell")
@interface BottomSeparatorCell : UICollectionViewCell
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)setTextOnLabel:(NSAttributedString * _Nonnull)text :(NSTextAlignment)alignment SWIFT_DEPRECATED_OBJC("Swift method 'BottomSeparatorCell.setTextOnLabel(_:_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)layoutSubviews;
@end

@class UIFont;

SWIFT_CLASS("_TtC14PrimeMessenger22ConversationHeaderView")
@interface ConversationHeaderView : UIStackView
@property (nonatomic, strong) NSAttributedString * _Nullable attributedTitle SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.attributedTitle' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) NSAttributedString * _Nullable attributedSubtitle SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.attributedSubtitle' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIImage * _Nullable avatarImage SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.avatarImage' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIFont * _Nonnull titlePrimaryFont SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.titlePrimaryFont' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIFont * _Nonnull titleSecondaryFont SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.titleSecondaryFont' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIFont * _Nonnull subtitleFont SWIFT_DEPRECATED_OBJC("Swift property 'ConversationHeaderView.subtitleFont' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)initWithTitle:(NSString * _Nonnull)title OBJC_DESIGNATED_INITIALIZER SWIFT_DEPRECATED_OBJC("Swift initializer 'ConversationHeaderView.init(title:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) CGSize intrinsicContentSize;
- (void)updateImageWithImageUrl:(NSString * _Nullable)imageUrl with:(NSString * _Nonnull)name SWIFT_DEPRECATED_OBJC("Swift method 'ConversationHeaderView.updateImage(imageUrl:with:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end

@class UIActivityIndicatorView;
@class UIButton;

SWIFT_CLASS("_TtC14PrimeMessenger17DefaultStatusView")
@interface DefaultStatusView : UIView
@property (nonatomic, readonly, strong) UIView * _Nonnull view SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.view' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UILabel * _Nonnull titleLabel SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.titleLabel' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UILabel * _Nonnull descriptionLabel SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.descriptionLabel' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIActivityIndicatorView * _Nonnull activityIndicatorView SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.activityIndicatorView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIImageView * _Nonnull imageView SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.imageView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIButton * _Nonnull actionButton SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.actionButton' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIStackView * _Nonnull verticalStackView SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.verticalStackView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIStackView * _Nonnull horizontalStackView SWIFT_DEPRECATED_OBJC("Swift property 'DefaultStatusView.horizontalStackView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@property (nonatomic, strong) UIColor * _Null_unspecified tintColor;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC14PrimeMessenger8Emoticon")
@interface Emoticon : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC14PrimeMessenger13EmoticonGroup")
@interface EmoticonGroup : NSObject
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
@end


SWIFT_CLASS("_TtC14PrimeMessenger17EmoticonInputView")
@interface EmoticonInputView : UIView
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIScrollView;

@interface EmoticonInputView (SWIFT_EXTENSION(PrimeMessenger)) <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView * _Nonnull)scrollView;
@end





@class UICollectionView;

@interface EmoticonInputView (SWIFT_EXTENSION(PrimeMessenger)) <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView * _Nonnull)collectionView numberOfItemsInSection:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (void)collectionView:(UICollectionView * _Nonnull)collectionView didSelectItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
@end

@class UICollectionViewLayout;

@interface EmoticonInputView (SWIFT_EXTENSION(PrimeMessenger)) <UICollectionViewDelegateFlowLayout>
- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
@end



@class UIAlertController;
@class UIAlertAction;

SWIFT_CLASS("_TtC14PrimeMessenger17PMAlertController")
@interface PMAlertController : NSObject
+ (UIAlertController * _Nonnull)alert:(NSString * _Nonnull)title SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.alert(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (UIAlertController * _Nonnull)alert:(NSString * _Nonnull)title message:(NSString * _Nonnull)message SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.alert(_:message:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (UIAlertController * _Nonnull)alert:(NSString * _Nonnull)title message:(NSString * _Nonnull)message acceptMessage:(NSString * _Nonnull)acceptMessage acceptBlock:(void (^ _Nonnull)(void))acceptBlock SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.alert(_:message:acceptMessage:acceptBlock:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (UIAlertController * _Nonnull)alert:(NSString * _Nonnull)title message:(NSString * _Nonnull)message buttons:(NSArray<NSString *> * _Nonnull)buttons tapBlock:(void (^ _Nullable)(UIAlertAction * _Nonnull, NSInteger))tapBlock SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.alert(_:message:buttons:tapBlock:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (UIAlertController * _Nonnull)actionSheet:(NSString * _Nonnull)title message:(NSString * _Nonnull)message sourceView:(UIView * _Nonnull)sourceView actions:(NSArray<UIAlertAction *> * _Nonnull)actions SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.actionSheet(_:message:sourceView:actions:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (UIAlertController * _Nonnull)actionSheet:(NSString * _Nonnull)title message:(NSString * _Nonnull)message sourceView:(UIView * _Nonnull)sourceView buttons:(NSArray<NSString *> * _Nonnull)buttons tapBlock:(void (^ _Nullable)(UIAlertAction * _Nonnull, NSInteger))tapBlock SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.actionSheet(_:message:sourceView:buttons:tapBlock:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (void)showGroupActionsWithView:(UIView * _Nonnull)view SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.showGroupActions(view:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
+ (void)showUserActionsWithView:(UIView * _Nonnull)view SWIFT_DEPRECATED_OBJC("Swift method 'PMAlertController.showUserActions(view:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

enum PopoverType : NSInteger;
@class UIBlurEffect;
@class UIControl;
@class UINavigationController;

SWIFT_CLASS("_TtC14PrimeMessenger7Popover")
@interface Popover : UIView
@property (nonatomic) CGSize arrowSize SWIFT_DEPRECATED_OBJC("Swift property 'Popover.arrowSize' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) NSTimeInterval animationIn SWIFT_DEPRECATED_OBJC("Swift property 'Popover.animationIn' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) NSTimeInterval animationOut SWIFT_DEPRECATED_OBJC("Swift property 'Popover.animationOut' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat cornerRadius SWIFT_DEPRECATED_OBJC("Swift property 'Popover.cornerRadius' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat sideEdge SWIFT_DEPRECATED_OBJC("Swift property 'Popover.sideEdge' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) enum PopoverType popoverType SWIFT_DEPRECATED_OBJC("Swift property 'Popover.popoverType' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIColor * _Nonnull blackOverlayColor SWIFT_DEPRECATED_OBJC("Swift property 'Popover.blackOverlayColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIBlurEffect * _Nullable overlayBlur SWIFT_DEPRECATED_OBJC("Swift property 'Popover.overlayBlur' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIColor * _Nonnull popoverColor SWIFT_DEPRECATED_OBJC("Swift property 'Popover.popoverColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL dismissOnBlackOverlayTap SWIFT_DEPRECATED_OBJC("Swift property 'Popover.dismissOnBlackOverlayTap' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL showBlackOverlay SWIFT_DEPRECATED_OBJC("Swift property 'Popover.showBlackOverlay' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL highlightFromView SWIFT_DEPRECATED_OBJC("Swift property 'Popover.highlightFromView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat highlightCornerRadius SWIFT_DEPRECATED_OBJC("Swift property 'Popover.highlightCornerRadius' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat springDamping SWIFT_DEPRECATED_OBJC("Swift property 'Popover.springDamping' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat initialSpringVelocity SWIFT_DEPRECATED_OBJC("Swift property 'Popover.initialSpringVelocity' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, copy) void (^ _Nullable willShowHandler)(void) SWIFT_DEPRECATED_OBJC("Swift property 'Popover.willShowHandler' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, copy) void (^ _Nullable willDismissHandler)(void) SWIFT_DEPRECATED_OBJC("Swift property 'Popover.willDismissHandler' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, copy) void (^ _Nullable didShowHandler)(void) SWIFT_DEPRECATED_OBJC("Swift property 'Popover.didShowHandler' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, copy) void (^ _Nullable didDismissHandler)(void) SWIFT_DEPRECATED_OBJC("Swift property 'Popover.didDismissHandler' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIControl * _Nonnull blackOverlay SWIFT_DEPRECATED_OBJC("Swift property 'Popover.blackOverlay' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
- (void)showAsDialog:(UIView * _Nonnull)contentView SWIFT_DEPRECATED_OBJC("Swift method 'Popover.showAsDialog(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)showAsDialog:(UIView * _Nonnull)contentView inView:(UIView * _Nonnull)inView SWIFT_DEPRECATED_OBJC("Swift method 'Popover.showAsDialog(_:inView:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)show:(UINavigationController * _Nonnull)nc fromView:(UIView * _Nonnull)fromView SWIFT_DEPRECATED_OBJC("Swift method 'Popover.show(_:fromView:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)show:(UIView * _Nonnull)contentView fromView:(UIView * _Nonnull)fromView inView:(UIView * _Nonnull)inView SWIFT_DEPRECATED_OBJC("Swift method 'Popover.show(_:fromView:inView:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)show:(UIView * _Nonnull)contentView point:(CGPoint)point SWIFT_DEPRECATED_OBJC("Swift method 'Popover.show(_:point:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)show:(UIView * _Nonnull)contentView point:(CGPoint)point inView:(UIView * _Nonnull)inView SWIFT_DEPRECATED_OBJC("Swift method 'Popover.show(_:point:inView:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (BOOL)accessibilityPerformEscape SWIFT_WARN_UNUSED_RESULT;
- (void)dismiss;
- (void)drawRect:(CGRect)rect;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@end

@class UITableView;

@interface Popover (SWIFT_EXTENSION(PrimeMessenger)) <UITableViewDelegate>
- (void)tableView:(UITableView * _Nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
@end

@class UITableViewCell;

@interface Popover (SWIFT_EXTENSION(PrimeMessenger)) <UITableViewDataSource>
- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
@end



typedef SWIFT_ENUM(NSInteger, PopoverType, closed) {
  PopoverTypeUp = 0,
  PopoverTypeDown = 1,
  PopoverTypeAuto = 2,
};


SWIFT_CLASS("_TtC14PrimeMessenger9QuoteView")
@interface QuoteView : UIView
@property (nonatomic, strong) UIView * _Nonnull containerView SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.containerView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UILabel * _Nonnull nameView SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.nameView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UILabel * _Nonnull messageView SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.messageView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIImageView * _Nonnull imageView SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.imageView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIView * _Nonnull indicatorView SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.indicatorView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIButton * _Nonnull cancelButton SWIFT_DEPRECATED_OBJC("Swift property 'QuoteView.cancelButton' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)setup SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.setup()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)setupContainerView SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.setupContainerView()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)setupView SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.setupView()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)createConstraints SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.createConstraints()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)addShadow SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.addShadow()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)setIndicatorColor:(UIColor * _Nonnull)color SWIFT_DEPRECATED_OBJC("Swift method 'QuoteView.setIndicatorColor(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end

@class UITouch;
@class UIEvent;

SWIFT_CLASS("_TtC14PrimeMessenger26SimpleFloatingActionButton")
@interface SimpleFloatingActionButton : UIButton
@property (nonatomic) float ripplePercent SWIFT_DEPRECATED_OBJC("Swift property 'SimpleFloatingActionButton.ripplePercent' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIColor * _Nonnull rippleColor SWIFT_DEPRECATED_OBJC("Swift property 'SimpleFloatingActionButton.rippleColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIColor * _Nonnull rippleBackgroundColor SWIFT_DEPRECATED_OBJC("Swift property 'SimpleFloatingActionButton.rippleBackgroundColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL rippleOverBounds;
@property (nonatomic) float shadowRippleRadius;
@property (nonatomic) BOOL shadowRippleEnable;
@property (nonatomic) BOOL trackTouchLocation;
@property (nonatomic, strong) UIColor * _Nonnull buttonBackgroundColor;
@property (nonatomic, strong) BadgeSwift * _Nonnull badge SWIFT_DEPRECATED_OBJC("Swift property 'SimpleFloatingActionButton.badge' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
- (void)layoutSubviews;
- (void)updateBadgeCount SWIFT_DEPRECATED_OBJC("Swift method 'SimpleFloatingActionButton.updateBadgeCount()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)removeBadgeCount SWIFT_DEPRECATED_OBJC("Swift method 'SimpleFloatingActionButton.removeBadgeCount()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)updateHeightWithIsOpen:(BOOL)isOpen SWIFT_DEPRECATED_OBJC("Swift method 'SimpleFloatingActionButton.updateHeight(isOpen:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)drawRect:(CGRect)rect;
- (BOOL)beginTrackingWithTouch:(UITouch * _Nonnull)touch withEvent:(UIEvent * _Nullable)event SWIFT_WARN_UNUSED_RESULT;
- (void)cancelTrackingWithEvent:(UIEvent * _Nullable)event;
- (void)endTrackingWithTouch:(UITouch * _Nullable)touch withEvent:(UIEvent * _Nullable)event;
@end








@interface UIImageView (SWIFT_EXTENSION(PrimeMessenger))
- (void)setImageForNameWithString:(NSString * _Nonnull)string backgroundColor:(UIColor * _Nullable)backgroundColor circular:(BOOL)circular textAttributes:(NSDictionary<NSAttributedStringKey, id> * _Nullable)textAttributes gradient:(BOOL)gradient SWIFT_DEPRECATED_OBJC("Swift method 'UIImageView.setImageForName(string:backgroundColor:circular:textAttributes:gradient:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end


@interface UISearchBar (SWIFT_EXTENSION(PrimeMessenger))
- (void)setTextColor:(UIColor * _Nonnull)color SWIFT_DEPRECATED_OBJC("Swift method 'UISearchBar.setTextColor(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)setPlaceholderWithColor:(NSString * _Nonnull)placeholderText SWIFT_DEPRECATED_OBJC("Swift method 'UISearchBar.setPlaceholderWithColor(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)updateSearchBar:(NSString * _Nonnull)placeholderText SWIFT_DEPRECATED_OBJC("Swift method 'UISearchBar.updateSearchBar(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end


@interface UITabBar (SWIFT_EXTENSION(PrimeMessenger))
- (CGSize)sizeThatFits:(CGSize)size SWIFT_WARN_UNUSED_RESULT;
@end










@interface UIView (SWIFT_EXTENSION(PrimeMessenger))
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) NSInteger StatusViewTag SWIFT_DEPRECATED_OBJC("Swift property 'UIView.StatusViewTag' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");)
+ (NSInteger)StatusViewTag SWIFT_WARN_UNUSED_RESULT SWIFT_DEPRECATED_OBJC("Swift property 'UIView.StatusViewTag' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, strong) UIView * _Nullable statusContainerView SWIFT_DEPRECATED_OBJC("Swift property 'UIView.statusContainerView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end

@class UITapGestureRecognizer;
@class NSTimer;

@interface UIView (SWIFT_EXTENSION(PrimeMessenger))
/// Creates and presents a new toast view with a message and displays it with the
/// default duration and position. Styled using the shared style.
/// @param message The message to be displayed
- (void)makeToastPM:(NSString * _Nonnull)message SWIFT_DEPRECATED_OBJC("Swift method 'UIView.makeToastPM(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Creates and presents a new toast view with a message. Duration and position
/// can be set explicitly. Styled using the shared style.
/// @param message The message to be displayed
/// @param duration The toast duration
/// @param position The toast’s center point
- (void)makeToastPM:(NSString * _Nonnull)message duration:(NSTimeInterval)duration position:(CGPoint)position SWIFT_DEPRECATED_OBJC("Swift method 'UIView.makeToastPM(_:duration:position:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Displays any view as toast using the default duration and position.
/// @param toast The view to be displayed as toast
- (void)showPMToast:(UIView * _Nonnull)toast SWIFT_DEPRECATED_OBJC("Swift method 'UIView.showPMToast(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Displays any view as toast at a provided position and duration. The completion closure
/// executes when the toast view completes. <code>didTap</code> will be <code>true</code> if the toast view was
/// dismissed from a tap.
/// @param toast The view to be displayed as toast
/// @param duration The notification duration
/// @param position The toast’s center point
/// @param completion The completion block, executed after the toast view disappears.
/// didTap will be <code>true</code> if the toast view was dismissed from a tap.
- (void)showPMToast:(UIView * _Nonnull)toast duration:(NSTimeInterval)duration position:(CGPoint)position completion:(void (^ _Nullable)(BOOL))completion SWIFT_DEPRECATED_OBJC("Swift method 'UIView.showPMToast(_:duration:position:completion:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Creates and displays a new toast activity indicator view at a specified position.
/// @warning Only one toast activity indicator view can be presented per superview. Subsequent
/// calls to <code>makeToastPMActivity(position:)</code> will be ignored until <code>hidePMToastActivity()</code> is called.
/// @warning <code>makeToastPMActivity(position:)</code> works independently of the <code>showPMToast</code> methods. Toast
/// activity views can be presented and dismissed while toast views are being displayed.
/// <code>makeToastPMActivity(position:)</code> has no effect on the queueing behavior of the <code>showPMToast</code> methods.
/// @param position The toast’s center point
- (void)makeToastPMActivity:(CGPoint)position SWIFT_DEPRECATED_OBJC("Swift method 'UIView.makeToastPMActivity(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Dismisses the active toast activity indicator view.
- (void)hidePMToastActivity SWIFT_DEPRECATED_OBJC("Swift method 'UIView.hidePMToastActivity()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)hideLoader SWIFT_DEPRECATED_OBJC("Swift method 'UIView.hideLoader()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)handlePMToastTapped:(UITapGestureRecognizer * _Nonnull)recognizer;
- (void)toastTimerDidFinish:(NSTimer * _Nonnull)timer;
@end







#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
