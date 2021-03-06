//
//  Popup.m
//  AH Plaza
//
//  Created by Casper Eekhof on 08-08-13.
//  Copyright (c) 2013 Redlake. All rights reserved.
//

#import "RLPopup.h"
#import <QuartzCore/QuartzCore.h>

@implementation RLPopup

/**
 * Inits the basic components needed for the RLPopup.
 */
- (id)init
{
    self = [super init];
    if (self) {
        CGRect popupFrame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        popupFrame.size.height = screenRect.size.height;
        popupFrame.size.width = screenRect.size.width;
        popupFrame.origin.x = 0;
        popupFrame.origin.y = 0;
        
        CGRect backgroundFrame = screenRect;
        
        CGRect dialogFrame;
        dialogFrame.size.height = 90;
        dialogFrame.size.width = 280;
        dialogFrame.origin.x = (backgroundFrame.size.width / 2) - (dialogFrame.size.width / 2); // center the view
        dialogFrame.origin.y = (backgroundFrame.size.height / 2) - (dialogFrame.size.height / 2);
        
        background = [[UIView alloc] initWithFrame: backgroundFrame];
        dialog = [[UIView alloc] initWithFrame: dialogFrame];
        popUpView = [[UIView alloc] initWithFrame: popupFrame];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        // These frames should be made when the decision is made to use 1 or either 2 of the buttons or an activity indicator.
        button1 = [[UIButton alloc] init];
        button2 = [[UIButton alloc] init];
        dialogLabel = [[UILabel alloc] init];
        [dialogLabel setNumberOfLines: 0];
        [dialogLabel setTextAlignment: NSTextAlignmentCenter];
        
        [background setBackgroundColor: [UIColor blackColor]];
        
        backgroundAlpha = 0.6;
        background.alpha = backgroundAlpha;
        dialog.layer.cornerRadius = 10;
        dialog.layer.masksToBounds = YES;
        [dialog setBackgroundColor: [UIColor whiteColor]];
        
        [popUpView addSubview: background];
        [popUpView addSubview: dialog];
        [popUpView setAlpha: 0.0f];
        [popUpView setHidden: YES];
    }
    return self;
}

/**
 * Hides the dialog in a specified amount of time.
 * @param duration of the hide animation.
 * @param completion block that is excuted after the animation.
 */
- (void) hidePopupWithAnimationDuration:(float) duration onCompletion:(onCompletion) completion {
    [UIView animateWithDuration: duration animations:^{
        [popUpView setAlpha: 0.0f];
    } completion:^(BOOL finished) {
        [popUpView setHidden: YES];
        completion(finished);
    }];
}

/**
 * Shows a popup with text.
 * @param duration of the show animation.
 * @param completion block that is excuted after the animation.
 */
- (void) showPopupWithAnimationDuration:(float)duration onCompletion:(onCompletion) completion {
    if(![[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]) {
        double delayInSeconds = .001;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showPopupWithAnimationDuration:duration onCompletion:completion];
        });
        return;
    };
    [[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] addSubview: popUpView];
    
    [popUpView setHidden: NO];
    
    [UIView animateWithDuration: duration animations:^{
        [popUpView setAlpha: 1.0f];
    } completion: completion];
}

/**
 * Builds and shows a popup with text.
 * @param duration of the show animation.
 * @param text the text to display.
 * @param completion block that is excuted after the animation.
 */
- (void) showPopupWithAnimationDuration:(float) duration withText: (NSString*) text onCompletion:(onCompletion) completion {
    [self removeDialogComponents];
    
    CGRect dialogFrame;
    dialogFrame.size.height = 90;
    dialogFrame.size.width = 280;
    dialogFrame.origin.x = (background.frame.size.width / 2) - (dialogFrame.size.width / 2); // center the view
    dialogFrame.origin.y = (background.frame.size.height / 2) - (dialogFrame.size.height / 2);
    [dialog setFrame: dialogFrame];
    
    CGRect labelFrame;
    int paddingLeftRight = 10;
    int paddingTopBottom = 10;
    labelFrame.origin.x = paddingLeftRight/2;
    labelFrame.origin.y = paddingTopBottom/2;
    labelFrame.size.height = [dialog frame].size.height - paddingTopBottom;
    labelFrame.size.width = [dialog frame].size.width - paddingLeftRight;
    [dialogLabel setFrame: labelFrame];
    [dialogLabel setTextColor: [UIColor blackColor]];
    [dialogLabel setBackgroundColor:[UIColor clearColor]];
    
    [dialogLabel setText: text];
    [dialog addSubview: dialogLabel];
    
    [self showPopupWithAnimationDuration: duration onCompletion: completion];
}

/**
 * Builds and shows a popup with a loading indicator and text.
 * @param duration of the show animation.
 * @param text the text to display.
 * @param completion block that is excuted after the animation.
 */
- (void) showPopupWithAnimationDuration:(float) duration withActivityIndicatorAndText: (NSString*) text onCompletion:(onCompletion) completion {
    [self removeDialogComponents];
    // The amount of taken space seen from the top of the dialog
    
    CGRect dialogFrame;
    dialogFrame.size.height = 90;
    dialogFrame.size.width = 280;
    dialogFrame.origin.x = (background.frame.size.width / 2) - (dialogFrame.size.width / 2); // center the view
    dialogFrame.origin.y = (background.frame.size.height / 2) - (dialogFrame.size.height / 2);
    [dialog setFrame: dialogFrame];
    
    int spaceTakenFromTop = 0;
    
    CGRect aiFrame;
    int paddingTop = 15;
    aiFrame.size.height = 20;
    aiFrame.size.width = 20;
    aiFrame.origin.x = [dialog frame].size.width/2 - aiFrame.size.width/2;
    aiFrame.origin.y = paddingTop;
    [activityIndicator setFrame: aiFrame];
    [activityIndicator startAnimating];
    spaceTakenFromTop += activityIndicator.frame.origin.y + (aiFrame.size.height/2);
    
    CGRect labelFrame;
    int paddingLeftRight = 20;
    int paddingTopBottom = 10;
    labelFrame.origin.x = paddingLeftRight/2;
    labelFrame.origin.y = paddingTopBottom/2 + spaceTakenFromTop * 1.5;
    labelFrame.size.height = [dialog frame].size.height - paddingTopBottom - spaceTakenFromTop*2;
    labelFrame.size.width = [dialog frame].size.width - paddingLeftRight;
    [dialogLabel setFrame: labelFrame];
    [dialogLabel setTextColor: [UIColor blackColor]];
    [dialogLabel setBackgroundColor:[UIColor clearColor]];
    
    [dialogLabel setText: text];
    [dialog addSubview: dialogLabel];
    [dialog addSubview: activityIndicator];
    
    [self showPopupWithAnimationDuration: duration onCompletion: completion];
}

/**
 * Builds and shows a popup with a confirm message and text.
 * @param duration of the show animation.
 * @param text the text to display.
 * @param buttonText the text on the button
 * @param result a block returing a value indicating a button is pressed.
 * @param completion block that is excuted after the animation.
 */
- (void) showPopupWithAnimationDuration:(float) duration withText: (NSString*) text withButtonText: (NSString*) buttonText withResult: (RLPopupResult) result onCompletion:(onCompletion) completion {
    [self removeDialogComponents];
    
    resultCallback = result;
    
    CGRect dialogFrame;
    dialogFrame.size.height = 150;
    dialogFrame.size.width = 280;
    dialogFrame.origin.x = (background.frame.size.width / 2) - (dialogFrame.size.width / 2); // center the view
    dialogFrame.origin.y = (background.frame.size.height / 2) - (dialogFrame.size.height / 2);
    [dialog setFrame: dialogFrame];
    
    
    // The amount of taken space seen from the top of the dialog
    int spaceTaken = 0;
    
    
    CGRect labelFrame;
    int paddingLeftRight = 20;
    int paddingTopBottom = 10;
    labelFrame.origin.x = paddingLeftRight/2;
    labelFrame.origin.y = paddingTopBottom/2 + spaceTaken * 1.5;
    labelFrame.size.height = [dialog frame].size.height/(double)(1.5) - paddingTopBottom;
    labelFrame.size.width = [dialog frame].size.width - paddingLeftRight;
    [dialogLabel setFrame: labelFrame];
    [dialogLabel setTextColor: [UIColor blackColor]];
    [dialogLabel setBackgroundColor:[UIColor clearColor]];
    [dialogLabel setText: text];
    spaceTaken += paddingTopBottom + dialogLabel.frame.size.height;
    
    CGRect button1Frame;
    button1Frame.size.height = 35;
    button1Frame.size.width = [dialog frame].size.width - paddingLeftRight;
    button1Frame.origin.x = [dialog frame].size.width/2 - button1Frame.size.width/2; // center the view
    button1Frame.origin.y = spaceTaken;
    [button1 setFrame: button1Frame];
    [button1 setBackgroundColor: [UIColor colorWithRed:200/255.f green:30/255.f blue:30/255.f alpha:1.0f]];
    [button1 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button1 setTitleColor: [UIColor grayColor] forState: UIControlStateHighlighted];
    
    [button1 setTitle: buttonText forState: UIControlStateNormal];
    [button1 setTitle: buttonText forState: UIControlStateHighlighted];
    button1.layer.cornerRadius = 10;
    button1.layer.masksToBounds = YES;
    
    [button1 addTarget: self action:@selector(button1Tapped) forControlEvents: UIControlEventTouchUpInside];
    
    [dialog addSubview: dialogLabel];
    [dialog addSubview: button1];
    
    
    [self showPopupWithAnimationDuration: duration onCompletion: completion];
}

/**
 * Builds and shows a popup with a YES/NO message and text.
 * @param duration of the show animation.
 * @param text the text to display.
 * @param button1Text the text on the left button
 * @param button2Text the text on the right button
 * @param result a block returing a value indicating a button is pressed.
 * @param completion block that is excuted after the animation.
 */
- (void) showPopupWithAnimationDuration:(float) duration withText: (NSString*) text withButton1Text: (NSString*) button1Text withButton2Text: (NSString*) button2Text withResult: (RLPopupResult) result onCompletion:(onCompletion) completion {
    [self removeDialogComponents];
    
    resultCallback = result;
    
    CGRect dialogFrame;
    dialogFrame.size.height = 150;
    dialogFrame.size.width = 280;
    dialogFrame.origin.x = (background.frame.size.width / 2) - (dialogFrame.size.width / 2); // center the view
    dialogFrame.origin.y = (background.frame.size.height / 2) - (dialogFrame.size.height / 2);
    [dialog setFrame: dialogFrame];
    
    
    // The amount of taken space seen from the top of the dialog
    int spaceTaken = 0;
    
    
    CGRect labelFrame;
    int paddingLeftRight = 20;
    int paddingTopBottom = 10;
    labelFrame.origin.x = paddingLeftRight/2;
    labelFrame.origin.y = paddingTopBottom/2 + spaceTaken * 1.5;
    labelFrame.size.height = [dialog frame].size.height/(double)(1.5) - paddingTopBottom;
    labelFrame.size.width = [dialog frame].size.width - paddingLeftRight;
    [dialogLabel setFrame: labelFrame];
    [dialogLabel setTextColor: [UIColor blackColor]];
    [dialogLabel setBackgroundColor:[UIColor clearColor]];
    [dialogLabel setText: text];
    spaceTaken += paddingTopBottom + dialogLabel.frame.size.height;
    
    CGRect button1Frame;
    button1Frame.size.height = 35;
    button1Frame.size.width = [dialog frame].size.width/2 - paddingLeftRight;
    button1Frame.origin.x = [dialog frame].size.width/4 - button1Frame.size.width/2; // center the view
    button1Frame.origin.y = spaceTaken;
    [button1 setFrame: button1Frame];
    [button1 setBackgroundColor: [UIColor colorWithRed:200/255.f green:30/255.f blue:30/255.f alpha:1.0f]];
    [button1 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button1 setTitleColor: [UIColor grayColor] forState: UIControlStateHighlighted];
    
    [button1 setTitle: button1Text forState: UIControlStateNormal];
    [button1 setTitle: button1Text forState: UIControlStateHighlighted];
    button1.layer.cornerRadius = 10;
    button1.layer.masksToBounds = YES;
    
    CGRect button2Frame;
    button2Frame.size.height = 35;
    button2Frame.size.width = [dialog frame].size.width/2 - paddingLeftRight;
    button2Frame.origin.x = ([dialog frame].size.width/4)*3 - button2Frame.size.width/2; // center the view
    button2Frame.origin.y = button1.frame.origin.y;
    [button2 setFrame: button2Frame];
    [button2 setBackgroundColor: [UIColor colorWithRed:200/255.f green:30/255.f blue:30/255.f alpha:1.0f]];
    [button2 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [button2 setTitleColor: [UIColor grayColor] forState: UIControlStateHighlighted];
    
    [button2 setTitle: button2Text forState: UIControlStateNormal];
    [button2 setTitle: button2Text forState: UIControlStateHighlighted];
    button2.layer.cornerRadius = 10;
    button2.layer.masksToBounds = YES;
    
    
    [button1 addTarget: self action:@selector(button1Tapped) forControlEvents: UIControlEventTouchUpInside];
    [button2 addTarget: self action:@selector(button2Tapped) forControlEvents: UIControlEventTouchUpInside];
    
    [dialog addSubview: dialogLabel];
    [dialog addSubview: button1];
    [dialog addSubview: button2];
    
    [self showPopupWithAnimationDuration: duration onCompletion: completion];
}

/**
 * Removes all subviews from dialog
 */
-(void) removeDialogComponents {
    [[dialog subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

/**
 * Handle button 1 click event by calling the callback.
 */
- (void) button1Tapped {
    [self hidePopupWithAnimationDuration: 0.5 onCompletion:^(BOOL finished) {}];
    if(resultCallback)
        resultCallback(OKAY);
    else
        NSLog(@"No callback provided for RLPopup");
}

/**
 * Handle button 2 click event by calling the callback.
 */
- (void) button2Tapped {
    [self hidePopupWithAnimationDuration: 0.5 onCompletion:^(BOOL finished) {}];
    if(resultCallback)
        resultCallback(CANCELED);
    else
        NSLog(@"No callback provided for RLPopup");
}

/**
 *************************************************
 *Customize methods. Used to customize the dialog*
 *************************************************
 */

/**
 * Sets the background image for the most left button.
 * @param color to set.
 * @param controlState of the button with the image.
 */
- (void) setButton1BackgroundColor: (UIColor*) color {
    [button1 setBackgroundColor:color];
}
/**
 * Sets the background image for the most right button.
 * @param color to set.
 * @param controlState of the button with the image.
 */
- (void) setButton2BackgroundColor: (UIColor*) color {
    [button2 setBackgroundColor:color];
}

/**
 * Sets the font of the dialog
 * @param the font name to set.
 */
- (void) setFont:(NSString*) fontName {
    UIFont * newFont = [UIFont fontWithName: fontName size: 17.0];
    [dialogLabel setFont: newFont];
    [[button1 titleLabel] setFont: newFont];
    [[button2 titleLabel] setFont: newFont];
}

/**
 * Sets the background image for the most left button.
 * @param image to set.
 * @param controlState of the button with the image.
 */
- (void) setButton1BackgroundImage: (UIImage*) image forState:(UIControlState) controlState {
    [button1 setBackgroundImage: image forState: controlState];
}

/**
 * Sets the background image for the most right button.
 * @param image to set.
 * @param controlState of the button with the image.
 */
- (void) setButton2BackgroundImage: (UIImage*) image forState:(UIControlState) controlState {
    [button2 setBackgroundImage:image forState: controlState];
}

/** 
 * Sets the color of the message.
 * @param color to set to the text.
 */
- (void) setTextColor:(UIColor*) color {
    [dialogLabel setTextColor: color];
}

@end
