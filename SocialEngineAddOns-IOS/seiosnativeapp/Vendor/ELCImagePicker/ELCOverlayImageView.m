//
//  ELCOverlayImageView.m
//  ELCImagePickerDemo
//
//  Created by Seamus on 14-7-11.
//  Copyright (c) 2014年 ELC Technologies. All rights reserved.
//

#import "ELCOverlayImageView.h"
#import "ELCConsole.h"
#import "seiosnativeapp-Swift.h"
@implementation ELCOverlayImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setIndex:(int)_index
{
    self.labIndex.text = [NSString stringWithFormat:@"%d",_index];
}

- (void)dealloc
{
    self.labIndex = nil;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
       // UIImageView *img = [[UIImageView alloc] initWithImage:image];
        UIImageView *img = [[UIImageView alloc] initWithFrame:self.frame];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.image = image;
        //img.frame = self.frame;
        //[img contentMode:UIView.ContentModeScaleAspectFill];
        [self addSubview:img];
        
        self.layer.borderWidth = 4.0;
        //self.layer.borderColor = UIColor.redColor.CGColor;
        self.layer.borderColor = [FXFormCustomization fxButtonColorCgcolor];
        
        if ([[ELCConsole mainConsole] onOrder]) {
            self.labIndex = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 20, 20)];
            self.labIndex.backgroundColor = [FXFormCustomization fxbuttonColor];
            self.labIndex.clipsToBounds = YES;
            self.labIndex.textAlignment = NSTextAlignmentCenter;
            self.labIndex.textColor = [UIColor whiteColor];
            self.labIndex.layer.cornerRadius = 0;
            self.labIndex.layer.shouldRasterize = YES;
            //        self.labIndex.layer.borderWidth = 1;
            //        self.labIndex.layer.borderColor = [UIColor greenColor].CGColor;
            self.labIndex.font = [UIFont boldSystemFontOfSize:13];
            [self addSubview:self.labIndex];
        }
    }
    return self;
}




@end
