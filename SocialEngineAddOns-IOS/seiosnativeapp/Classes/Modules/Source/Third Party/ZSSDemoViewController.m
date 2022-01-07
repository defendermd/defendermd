//
//  ZSSDemoViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/29/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoViewController.h"
#import "ZSSDemoPickerViewController.h"


@interface ZSSDemoViewController ()

@end

@implementation ZSSDemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"EditorTitle"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(texttypecheck:)
                                                 name:@"texttypecheck"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(texttypecheckzero:)
                                                 name:@"texttypecheckzero"
                                               object:nil];
    

    
    if (value != nil && ![value  isEqual: @""]) {
        
        self.title = value;
    }
    else {
        self.title = @"Description";
    }
    
    self.alwaysShowToolbar = YES;
    self.receiveEditorDidChangeEvents = NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spinner"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(popViewControllerAnimated)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Export HTML
    
    NSString *valueedit = [[NSUserDefaults standardUserDefaults] stringForKey:@"EditValue"];
    if (valueedit != nil && ![valueedit  isEqual: @""]) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    }
    else {
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"forumcheckkey"];
        
        if (value != nil && ![value  isEqual: @""] ){
            
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
        else {
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
    }
     NSString *valueblog = [[NSUserDefaults standardUserDefaults] stringForKey:@"blogandclassified"];
    if (valueblog != nil && ![valueblog  isEqual: @""]) {
        
        
        self.navigationItem.rightBarButtonItem.enabled = false;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = true;
    }
    

    
}

- (void) texttypecheck:(NSNotification *) notification
{
    NSString *valueedit = [[NSUserDefaults standardUserDefaults] stringForKey:@"EditValue"];
    if (valueedit != nil && ![valueedit  isEqual: @""]) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    }
    else {
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"forumcheckkey"];
        
        if (value != nil && ![value  isEqual: @""] ){
            
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
        else {
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
    }

    self.navigationItem.rightBarButtonItem.enabled = true;
    
}

- (void) texttypecheckzero:(NSNotification *) notification
{
    NSString *valueedit = [[NSUserDefaults standardUserDefaults] stringForKey:@"EditValue"];
    if (valueedit != nil && ![valueedit  isEqual: @""]) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    }
    else {
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"forumcheckkey"];
        
        if (value != nil && ![value  isEqual: @""] ){
            
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
        else {
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
        }
    }
    self.navigationItem.rightBarButtonItem.enabled = false;
    //}
    
}


- (void) viewDidAppear:(BOOL)animated{
    NSString *html = @"";
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferenceName"];
    
    if (value != nil && ![value  isEqual: @""]) {
        
        html = value;
    }
    
    
    // Set the base URL if you would like to use relative links, such as to images.
    self.baseURL = [NSURL URLWithString:@""];
    self.shouldShowKeyboard = YES;
    
    // Set the HTML contents of the editor
    // [self setPlaceholder:@"This is a placeholder that will show when there is no content(html)"];
    [self setHTML:html];
    
    
}

-  (void) popViewControllerAnimated{
    // [self.navigationController popViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spinner"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)showInsertURLAlternatePicker {
    
    [self dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)showInsertImageAlternatePicker {
    
    [self dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    picker.isInsertImagePicker = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)exportHTML
{
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"forumcheckkey"];
    if (value != nil && ![value  isEqual: @""] ){
        //NSString *valueToSave = (@"%@", [self getHTML]);
        [self getHTML:^(NSString *result, NSError * _Nullable error) {
            NSLog(@"%@", result);
            [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"preferenceName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
      //  NSString *valueToSave =  [self getHTML];
       
    }
    else
    {

        NSString *spinnervalue = @"spinner";
        [[NSUserDefaults standardUserDefaults] setObject:spinnervalue forKey:@"spinner"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //NSString *valueToSave = (@"%@", [self getHTML]);
        [self getHTML:^(NSString *result, NSError * _Nullable error) {
            NSLog(@"%@", result);
            [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"preferenceName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        
        // [self ScrollingactionBlog];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ScrollingactionBlog"
         object:self];
        
    }
    
    
    
}
- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html {
    
    NSLog(@"Text Has Changed: %@", text);
    
    NSLog(@"HTML Has Changed: %@", html);
    
}

- (void)hashtagRecognizedWithWord:(NSString *)word {
    
    NSLog(@"Hashtag has been recognized: %@", word);
    
}

- (void)mentionRecognizedWithWord:(NSString *)word {
    
    NSLog(@"Mention has been recognized: %@", word);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
