#import <Foundation/Foundation.h>

@interface AlertPasswordPrompt : UIAlertView <UITextFieldDelegate>
{
    UITextField *textField;
	UITextField* passwordField;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UITextField * passwordField;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
- (NSString *)enteredText;
- (NSString*) enteredPassword;

@end