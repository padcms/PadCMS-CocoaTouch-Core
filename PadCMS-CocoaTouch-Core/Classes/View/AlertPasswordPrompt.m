//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

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
