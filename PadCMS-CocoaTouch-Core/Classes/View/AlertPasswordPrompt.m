
#import "AlertPasswordPrompt.h"


@implementation AlertPasswordPrompt

@synthesize textField, passwordField;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
	
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {

        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 140.0, 250.0, 34.0)]; 
		theTextField.font = [UIFont systemFontOfSize:18];
		theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [theTextField setBackgroundColor:[UIColor clearColor]]; 
		theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		theTextField.borderStyle = UITextBorderStyleRoundedRect;

		theTextField.placeholder = @"User name";
		theTextField.delegate = self;
        [self addSubview:theTextField];
		self.textField = theTextField;
		theTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
		[theTextField release];
		
        theTextField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 180.0, 250.0, 34.0)]; 
		theTextField.font = [UIFont systemFontOfSize:18];
		theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [theTextField setBackgroundColor:[UIColor clearColor]]; 
		theTextField.delegate = self;
		theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		theTextField.borderStyle = UITextBorderStyleRoundedRect;
		theTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
		theTextField.secureTextEntry = YES;
		theTextField.placeholder = @"Password";		
        [self addSubview:theTextField];
		self.passwordField = theTextField;
		[theTextField release];

        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 40.0); 
        [self setTransform:translate];
    }
    return self;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	
	[self dismissWithClickedButtonIndex:1 animated:YES];
	return YES;
}

- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return textField.text;
}

- (NSString*) enteredPassword {

	return passwordField.text;
}

- (void)dealloc
{
    [textField release];
    [super dealloc];
}
@end
