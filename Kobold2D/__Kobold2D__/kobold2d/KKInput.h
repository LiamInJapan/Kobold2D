/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

/** @file KKInput.h */

/** Direction bits for the swipe gesture relative are relative to the current device orientation. */
typedef enum
{
	KKSwipeGestureDirectionRight	= 1 << 0, /**< */
	KKSwipeGestureDirectionLeft		= 1 << 1, /**< */
	KKSwipeGestureDirectionUp		= 1 << 2, /**< */
	KKSwipeGestureDirectionDown		= 1 << 3, /**< */
} KKSwipeGestureDirection;

/** A touch can have just began, it can be moving, or it can be ended this frame. The kKKTouchPhaseAny can be used if want to include all three phases in a touch test.
 The KKTouchPhase enum values are equal to those in the UITouchPhase enum, that means they can be used interchangeably. */
typedef enum
{
	KKTouchPhaseBegan, /**< touch began this frame */
	KKTouchPhaseMoved, /**< touch has moved this frame */
	KKTouchPhaseStationary, /**< touch didn't move this frame */
	KKTouchPhaseEnded, /**< touch ended this frame */
	KKTouchPhaseCancelled, /**< touch was cancelled (ie incoming call, incoming SMS, etc) this frame */
	
	KKTouchPhaseAny, /**< used for certain tests to disregard the phase of the touch */
	
	KKTouchPhaseLifted,  /**< a touch is "lifted" if it is no longer associated with a finger on the screen */
} KKTouchPhase;


/** The modifier flags (bits) for special keyboard keys, like Shift, Control, Option, Command, Function, Help, etc. */
typedef enum {
    KKModifierAlphaShiftKeyMask         = 1 << 16, /**< Caps Lock */
    KKModifierShiftKeyMask              = 1 << 17, /**< */
    KKModifierControlKeyMask            = 1 << 18, /**< */
    KKModifierAlternateKeyMask          = 1 << 19, /**< Option */
    KKModifierCommandKeyMask            = 1 << 20, /**< */
    KKModifierNumericPadKeyMask         = 1 << 21, /**< Set if a numeric keypad key is pressed */
    KKModifierHelpKeyMask               = 1 << 22, /**< */
    KKModifierFunctionKeyMask           = 1 << 23, /**< Set if any function key (F1, F2, etc) is pressed */
    KKDeviceIndependentModifierFlagsMask    = 0xffff0000UL, /**< Keyboard modifier keys are bits 16 to 23. Sometimes other bits (0-15) may be set as well, depending on the device. According to Apple: "Used to retrieve only the device-independent modifier flags, allowing applications to mask off the device-dependent modifier flags, including event coalescing information."
															 Use the following code to mask out the device-dependent flags:
															 
															 UInt32 flags = eventModifierFlags & kKKDeviceIndependentModifierFlagsMask;
															 */
} KKModifierFlag;

/** The virtual key codes for all keyboard keys, including modifier keys like Control, Command, Shift, etc. */
typedef enum {
	KKKeyCode_A                    = 0x00, /**< */
	KKKeyCode_B                    = 0x0B, /**< */
	KKKeyCode_C                    = 0x08, /**< */
	KKKeyCode_D                    = 0x02, /**< */
	KKKeyCode_E                    = 0x0E, /**< */
	KKKeyCode_F                    = 0x03, /**< */
	KKKeyCode_G                    = 0x05, /**< */
	KKKeyCode_H                    = 0x04, /**< */
	KKKeyCode_I                    = 0x22, /**< */
	KKKeyCode_J                    = 0x26, /**< */
	KKKeyCode_K                    = 0x28, /**< */
	KKKeyCode_L                    = 0x25, /**< */
	KKKeyCode_M                    = 0x2E, /**< */
	KKKeyCode_N                    = 0x2D, /**< */
	KKKeyCode_O                    = 0x1F, /**< */
	KKKeyCode_P                    = 0x23, /**< */
	KKKeyCode_Q                    = 0x0C, /**< */
	KKKeyCode_R                    = 0x0F, /**< */
	KKKeyCode_S                    = 0x01, /**< */
	KKKeyCode_T                    = 0x11, /**< */
	KKKeyCode_U                    = 0x20, /**< */
	KKKeyCode_V                    = 0x09, /**< */
	KKKeyCode_W                    = 0x0D, /**< */
	KKKeyCode_X                    = 0x07, /**< */
	KKKeyCode_Y                    = 0x10, /**< */
	KKKeyCode_Z                    = 0x06, /**< */
	
	KKKeyCode_1                    = 0x12, /**< */
	KKKeyCode_2                    = 0x13, /**< */
	KKKeyCode_3                    = 0x14, /**< */
	KKKeyCode_4                    = 0x15, /**< */
	KKKeyCode_5                    = 0x17, /**< */
	KKKeyCode_6                    = 0x16, /**< */
	KKKeyCode_7                    = 0x1A, /**< */
	KKKeyCode_8                    = 0x1C, /**< */
	KKKeyCode_9                    = 0x19, /**< */
	KKKeyCode_0                    = 0x1D, /**< */
	
	KKKeyCode_KeypadDecimal        = 0x41, /**< */
	KKKeyCode_KeypadMultiply       = 0x43, /**< */
	KKKeyCode_KeypadPlus           = 0x45, /**< */
	KKKeyCode_KeypadClear          = 0x47, /**< */
	KKKeyCode_KeypadDivide         = 0x4B, /**< */
	KKKeyCode_KeypadEnter          = 0x4C, /**< */
	KKKeyCode_KeypadMinus          = 0x4E, /**< */
	KKKeyCode_KeypadEquals         = 0x51, /**< */
	KKKeyCode_Keypad0              = 0x52, /**< */
	KKKeyCode_Keypad1              = 0x53, /**< */
	KKKeyCode_Keypad2              = 0x54, /**< */
	KKKeyCode_Keypad3              = 0x55, /**< */
	KKKeyCode_Keypad4              = 0x56, /**< */
	KKKeyCode_Keypad5              = 0x57, /**< */
	KKKeyCode_Keypad6              = 0x58, /**< */
	KKKeyCode_Keypad7              = 0x59, /**< */
	KKKeyCode_Keypad8              = 0x5B, /**< */
	KKKeyCode_Keypad9              = 0x5C, /**< */

	KKKeyCode_RightBracket         = 0x1E, /**< */
	KKKeyCode_LeftBracket          = 0x21, /**< */
	KKKeyCode_Equal                = 0x18, /**< */
	KKKeyCode_Minus                = 0x1B, /**< */
	KKKeyCode_Quote                = 0x27, /**< */
	KKKeyCode_Grave                = 0x32, /**< */
	KKKeyCode_Semicolon            = 0x29, /**< */
	KKKeyCode_Comma                = 0x2B, /**< */
	KKKeyCode_Period               = 0x2F, /**< */
	KKKeyCode_Slash                = 0x2C, /**< */
	KKKeyCode_Backslash            = 0x2A, /**< */
	
	/* keycodes for keys that are independent of keyboard layout*/
	KKKeyCode_Escape                    = 0x35, /**< */
	KKKeyCode_Tab                       = 0x30, /**< */
	KKKeyCode_Space                     = 0x31, /**< */
	KKKeyCode_Return                    = 0x24, /**< */
	KKKeyCode_Help                      = 0x72, /**< */
	KKKeyCode_Home                      = 0x73, /**< */
	KKKeyCode_Delete                    = 0x33, /**< */
	KKKeyCode_End                       = 0x77, /**< */
	KKKeyCode_PageUp                    = 0x74, /**< */
	KKKeyCode_PageDown                  = 0x79, /**< */
	KKKeyCode_ForwardDelete             = 0x75, /**< */
	KKKeyCode_LeftArrow                 = 0x7B, /**< */
	KKKeyCode_RightArrow                = 0x7C, /**< */
	KKKeyCode_DownArrow                 = 0x7D, /**< */
	KKKeyCode_UpArrow                   = 0x7E, /**< */
	KKKeyCode_VolumeUp                  = 0x48, /**< */
	KKKeyCode_VolumeDown                = 0x49, /**< */
	KKKeyCode_Mute                      = 0x4A, /**< */

	KKKeyCode_F1                        = 0x7A, /**< */
	KKKeyCode_F2                        = 0x78, /**< */
	KKKeyCode_F3                        = 0x63, /**< */
	KKKeyCode_F4                        = 0x76, /**< */
	KKKeyCode_F5                        = 0x60, /**< */
	KKKeyCode_F6                        = 0x61, /**< */
	KKKeyCode_F7                        = 0x62, /**< */
	KKKeyCode_F8                        = 0x64, /**< */
	KKKeyCode_F9                        = 0x65, /**< */
	KKKeyCode_F10                       = 0x6D, /**< */
	KKKeyCode_F11                       = 0x67, /**< */
	KKKeyCode_F12                       = 0x6F, /**< */
	KKKeyCode_F13                       = 0x69, /**< */
	KKKeyCode_F14                       = 0x6B, /**< */
	KKKeyCode_F15                       = 0x71, /**< */
	KKKeyCode_F16                       = 0x6A, /**< */
	KKKeyCode_F17                       = 0x40, /**< */
	KKKeyCode_F18                       = 0x4F, /**< */
	KKKeyCode_F19                       = 0x50, /**< */
	KKKeyCode_F20                       = 0x5A, /**< */

	KKKeyCode_Command                   = 0x37, /**< */
	KKKeyCode_Shift                     = 0x38, /**< */
	KKKeyCode_CapsLock                  = 0x39, /**< */
	KKKeyCode_Option                    = 0x3A, /**< */
	KKKeyCode_Control                   = 0x3B, /**< */
	KKKeyCode_RightShift                = 0x3C, /**< */
	KKKeyCode_RightOption               = 0x3D, /**< */
	KKKeyCode_RightControl              = 0x3E, /**< */
	KKKeyCode_Function                  = 0x3F, /**< */

	/* ISO keyboards only*/
	KKKeyCode_ISO_Section               = 0x0A, /**< ISO keyboards only */
	
	/* JIS keyboards only*/
	KKKeyCode_JIS_Yen                   = 0x5D, /**< JIS keyboards only (this one and following) */
	KKKeyCode_JIS_Underscore            = 0x5E, /**< */
	KKKeyCode_JIS_KeypadComma           = 0x5F, /**< */
	KKKeyCode_JIS_Eisu                  = 0x66, /**< */
	KKKeyCode_JIS_Kana                  = 0x68, /**< */
	
} KKKeyCode;

/** The "virtual keyCodes" for mouse buttons. These are left, right and other. The "other" buttons may include multiple keys which,
 if supported by the hardware and driver, you can identify with kKKMouseButtonOther and an optional offset, eg "kKKMouseButtonOther + 2" for
 a fifth mouse button. Note that any of the "other" mouse buttons are non-standard and typically require non-Apple mice to work. You can not
 rely on any of the "other" buttons being available at all.
 
 Mouse double-clicks are an offset (kKKMouseButtonDoubleClickOffset) to the button codes. Double-clicks are treated as separate buttons by
 KKInput for your convenience, ie you don't have to test for two consecutive mouse button presses.
 */
typedef enum {
	KKMouseButtonLeft, /**< */
	KKMouseButtonRight, /**< */
	KKMouseButtonOther, /**< Third mouse button, and other mouse buttons by adding offset: kKKMouseButtonOther + n */
	
	KKMouseButtonDoubleClickOffset = 0x1F, /**< Mouse button double clicks are treated as seperate key codes with this offset: kKKMouseButtonLeft + kKKMouseButtonDoubleClickOffset == kKKMouseButtonDoubleClickLeft */
	KKMouseButtonDoubleClickLeft = KKMouseButtonDoubleClickOffset, /**< */
	KKMouseButtonDoubleClickRight, /**< */
	KKMouseButtonDoubleClickOther, /**< */
} KKMouseButtonCode;


#import "KKAcceleration.h"
#import "KKRotationRate.h"
#import "KKDeviceMotion.h"
#import "KKTouches.h"
#import "KKInputGesture.h"

@class KKInputKeyboard;
@class KKInputMouse;
@class KKInputMotion;
@class KKInputTouch;
@class KKInputGesture;

/** Kobold2D User Input handler that gives you both a polling API (eg isKeyDown) and an event-driven API configurable via config.lua.
 KKInput supports all input methods: keyboard, mouse, touch, motion (accelerometer and gyroscope) and gestures.
 
 The design of the KKInput API is meant to be as simple as possible, giving you many convenience functions. For example, mouse button
 double-clicks are treated as if they were separate buttons so you don't have to write your own code to test for double-clicks. You
 can also easily test mouse button states in combination with keyboard modifierFlags to detect Control-Clicks and the like.
 
 It is legal (no compile error) to call keyboard & mouse methods on iOS, as is calling touch, motion and gesture methods on Mac OS. 
 Of course you won't get meaningful results/values, the real benefit is that you can write #ifdef-less code.
 
 Note: all "ThisFrame" methods are only useful if you poll the state every frame (eg scheduled update method without an interval),
 otherwise you might "miss" the event because the state will only remain true for one frame.
 */
@interface KKInput : NSObject
{
@private
	KKInputKeyboard* keyboard;
	KKInputMouse* mouse;
	KKInputMotion* motion;
	KKInputTouch* touch;
	KKInputGesture* gesture;
}

/** returns the singleton instance */
+(KKInput*) sharedInput;

/** Resets the entire KKInput system, meaning all current touches, keypresses, etc. will be removed and state
 variables are reset. However gesture recognizers will remain enabled and so are other "enabled" states.
 Note: This method is called automatically when changing scenes (replaceScene, pushScene, popScene). */
-(void) resetInputStates;

#pragma mark General Input Helpers

/** Enable or disable user interaction events for the Cocos2D glView entirely. */
@property (nonatomic) BOOL userInteractionEnabled;

#pragma mark Keyboard Facade

/** returns true if any keyboard key is down */
@property (nonatomic, readonly) BOOL isAnyKeyDown;
/** returns true if any keyboard key changed from keyUp to keyDown state in the current frame */
@property (nonatomic, readonly) BOOL isAnyKeyDownThisFrame;
/** returns true if any keyboard key changed from keyDown to keyUp state in the current frame */
@property (nonatomic, readonly) BOOL isAnyKeyUpThisFrame;

/** returns true if the key with the given virtual keyCode is down */
-(BOOL) isKeyDown:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode and the given modifierFlags are down */
-(BOOL) isKeyDown:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the key with the given virtual keyCode just changed from keyUp to keyDown state in the current frame */
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode just changed from keyUp to keyDown state in the current frame, with modifiers. The modifiers must already be down, eg pressing modifier(s) followed by key will return true but pressing key first and modifier(s) second won't. */
-(BOOL) isKeyDownThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;

/** returns true if the key with the given virtual keyCode is up */
-(BOOL) isKeyUp:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode and the given modifierFlags are up */
-(BOOL) isKeyUp:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the key with the given virtual keyCode just changed from keyDown to keyUp state in the current frame */
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode;
/** returns true if the key with the given virtual keyCode just changed from keyDown to keyUp state in the current frame, with modifiers. The modifiers must already be down when the key is released. */
-(BOOL) isKeyUpThisFrame:(KKKeyCode)keyCode modifierFlags:(KKModifierFlag)modifierFlags;


#pragma mark Mouse Facade

/** returns true if any mouse button is down */
@property (nonatomic, readonly) BOOL isAnyMouseButtonDown;
/** returns true if any mouse button changed from up to down state in the current frame */
@property (nonatomic, readonly) BOOL isAnyMouseButtonDownThisFrame;
/** returns true if any mouse button changed from down to up state in the current frame */
@property (nonatomic, readonly) BOOL isAnyMouseButtonUpThisFrame;

/** returns true if the mouse button with the given button code is down */
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code and the given modifierFlags are down */
-(BOOL) isMouseButtonDown:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags;
/** returns true if the mouse button with the given button code just changed from up to down state in the current frame */
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code just changed from up to down state in the current frame, with modifiers. The modifiers must already be down, eg pressing modifier(s) followed by mouse button will return true but pressing mouse button first and modifier(s) second won't. */
-(BOOL) isMouseButtonDownThisFrame:(KKMouseButtonCode)buttonCode modifierFlags:(KKModifierFlag)modifierFlags;

/** returns true if the mouse button with the given button code is up */
-(BOOL) isMouseButtonUp:(KKMouseButtonCode)buttonCode;
/** returns true if the mouse button with the given button code just changed from down to up state in the current frame */
-(BOOL) isMouseButtonUpThisFrame:(KKMouseButtonCode)buttonCode;

/** Determines if mouse moved events are accepted or not. Unless you need to track all mouse movements it is recommended to set this to NO. This is the same setting as: AcceptsMouseMovedEvents in config.lua. */
@property (nonatomic) BOOL acceptsMouseMovedEvents;
/** returns the mouse cursor location in window coordinates. If you want to track ALL mouse movements you'll have to turn on trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua). */
@property (nonatomic, readonly) CGPoint mouseLocation;
/** returns the previous mouse cursor location in window coordinates. With trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua) turned OFF (NO) the previous location will be the location of the previous mouse down, mouse up, or mouse dragged event and could be quite far away from the current mouseLocation. If you need to track previous locations accurately you need to turn on trackMouseMovedEvents. */
@property (nonatomic, readonly) CGPoint previousMouseLocation;
/** returns the delta of the current and previous mouse cursor location in window coordinates. With trackMouseMovedEvents (AcceptsMouseMovedEvents in config.lua) turned OFF (NO) the delta location will be the location of the previous mouse down, mouse up, or mouse dragged event and could be quite far away from the current mouseLocation. If you need to track delta locations accurately you need to turn on trackMouseMovedEvents. */
@property (nonatomic, readonly) CGPoint mouseLocationDelta;

/** returns the current scroll wheel delta position. Will be (0,0) if the user hasn't scrolled the wheel in the current frame. */
@property (nonatomic, readonly) CGPoint scrollWheelDelta;


#pragma mark MotionInput Facade

/** Set to YES to enable accelerometer input. When enabled, the acceleration values are updated every frame. On devices that support it (running iOS 4.0) the CMMotionManager is used to obtain acceleration data, otherwise UIAcceleration is used. If deviceMotion is set to YES, acceleration will be taken from userAcceleration property of the <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> class. */
@property (nonatomic) BOOL accelerometerActive;
/** Is YES if the current device has an accelerometer, and accelerometer input can be activated and used. */
@property (nonatomic, readonly) BOOL accelerometerAvailable;
/** Returns the KKAcceleration object used by KKInput internally. The acceleration object is valid during the entire lifetime of your application and its acceleration values will continue to be updated (depending on the accelerometerActive property). */
@property (nonatomic, readonly) KKAcceleration* acceleration;

/** Set to YES to enable gyroscope input. When enabled, the gyro values are updated every frame. Only available on devices that have a gyroscope (4th generation, iPad 2, and newer). Use gyroAvailable property to check for gyroscope availability on the current device. If deviceMotion is set to YES, rotationRate will be taken from rotationRate property of the <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> class. */
@property (nonatomic) BOOL gyroActive;
/** Is YES if the current device has a gyroscope, and gyroscope input can be activated and used. */
@property (nonatomic, readonly) BOOL gyroAvailable;
/** Returns the KKRotationRate object used by KKInput internally. The rotationRate object is valid during the entire lifetime of your application and its rotation values will continue to be updated (depending on the gyroActive property). */
@property (nonatomic, readonly) KKRotationRate* rotationRate;

/** Set to YES to enable device motion input (combined accelerometer & gyroscope -> attitude). DeviceMotion relies on the CoreMotion.framework which is only available on devices running iOS 4.0 and later, and only available on devices that have both accelerometer and gyroscope (4th generation devices and iPad 2). Use deviceMotionAvailable property to check for availability on the current device. You can get acceleration, rotation plus attitude and gravity via the deviceMotion property (KKDeviceMotion). The rotationRate and acceleration can also be obtained via the regular rotationRate and acceleration properties. */
@property (nonatomic) BOOL deviceMotionActive;
/** Is YES if the current device has both a gyroscope and accelerometer, and device motion (sensor fusion) input can be activated and used. */
@property (nonatomic, readonly) BOOL deviceMotionAvailable;
/** Returns the KKDeviceMotion object used by KKInput internally. The deviceMotion object is valid during the entire lifetime of your application and its properties will continue to be updated (depending on the deviceMotionActive property). Gives you access to acceleration, rotationRate, gravity and attitude as <a href="http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/c_ref/CMDeviceMotion">CMDeviceMotion</a> object. */
@property (nonatomic, readonly) KKDeviceMotion* deviceMotion;


#pragma mark TouchInput Facade

/** Returns a CCArray of five KKTouch objects. Each object either represents a finger currently touching the screen, or it is set to be invalid.
 Note: do not rely on the array indexes for tracking individual touches/fingers. Compare the KKTouch touchID property if you need to track specific fingers. */
@property (nonatomic, readonly) CCArray* touches;
/** Returns YES if there are touches available this frame, ie if the uiTouches array contains UITouch objects. NO if uiTouches is currently empty. */
@property (nonatomic, readonly) BOOL touchesAvailable;
/** Set to YES to allow multi touch events. If NO, only the first touch will be tracked. Same as config.lua setting EnableMultiTouch. */
@property (nonatomic) BOOL multipleTouchEnabled;

/** Returns YES if any touch began this frame. */
@property (nonatomic, readonly) BOOL anyTouchBeganThisFrame;
/** Returns YES if any touch ended this frame. */
@property (nonatomic, readonly) BOOL anyTouchEndedThisFrame;
/** Returns the location of any touch, or CGPointZero if there's no touch. Useful mostly when not using multi touch and you just want to get the touch location easily. */
@property (nonatomic, readonly) CGPoint anyTouchLocation;
/** Returns the location (in cocos2d coordinates) of any touch in the given phase. If there is no finger touching the screen, CGPointZero is returned. */
-(CGPoint) locationOfAnyTouchInPhase:(KKTouchPhase)touchPhase;
/** Tests if a touch in the given touchPhase was on a node. The test is correct even if the node was rotated and/or scaled. */
-(BOOL) isAnyTouchOnNode:(CCNode*)node touchPhase:(KKTouchPhase)touchPhase;

#pragma mark GestureInput Facade

/** Returns YES if gesture recognizers are available. Gesture Recognizers are available on devices running iOS 3.2 or newer. */
@property (nonatomic, readonly) BOOL gesturesAvailable;

/** Enables the (one finger) tap gesture recognizer. Note that the tap recognition may be delayed if double-tap is also active. 
 See the explanation in gestureDoubleTapEnabled. */
@property (nonatomic) BOOL gestureTapEnabled;
/** Is YES if a tap gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureTapRecognizedThisFrame;
/** The location of the last tap. Is updated every time a tap gesture is recognized. */
@property (nonatomic, readonly) CGPoint gestureTapLocation;

/** Enables the (one finger) double tap gesture recognizer. Note that single tap gesture will be delayed if it is active.
 This is because the single tap gesture recognizer has to wait for the double-tap recognizer to fail before it is being recognized.
 See this question for a more detailed explanation: http://stackoverflow.com/questions/3081215/ipad-gesture-recognizer-delayed-response
 */
@property (nonatomic) BOOL gestureDoubleTapEnabled;
/** Is YES if a double-tap gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureDoubleTapRecognizedThisFrame;
/** The location of the last double-tap. Is updated every time a double-tap gesture is recognized. */
@property (nonatomic, readonly) CGPoint gestureDoubleTapLocation;

/** Enables the (one finger) long-press gesture recognizer. A long-press occurs when the finger stays almost stationary (default: 10 pixels)
 on the screen for a minimum time period (0.5 seconds). If these conditions are true, the long-press gesture remains active until the finger is lifted.
 That means you have to long-press an object, and when the long-press gesture is recognized the user can move the finger freely. This makes long-press
 gestures ideal for initiating a drag & drop operation. */
@property (nonatomic) BOOL gestureLongPressEnabled;
/** Is YES when the long-press gesture has began and stays true until the finger moves too far or is lifted. */
@property (nonatomic, readonly) BOOL gestureLongPressBegan;
/** Returns the location of the long-press gesture. */
@property (nonatomic, readonly) CGPoint gestureLongPressLocation;

/** Enables the (one finger) swipe gesture recognizer. A swipe occurs when moving the finger mostly in one direction. 
 The swipe can be slow over a short distance or fast over a long distance. Since the pan gesture is similar to the swipe
 gesture, both will be recognized simulataneously if swipe and pan gestures are enabled at the same time. */
@property (nonatomic) BOOL gestureSwipeEnabled;
/** Is YES if a swipe gesture was recognized in this frame. */
@property (nonatomic, readonly) BOOL gestureSwipeRecognizedThisFrame;
/** The start location of the swipe. Use locationOfAnyTouchInPhase method with phase of KKTouchPhaseCancelled to get the end location of the swipe. */
@property (nonatomic, readonly) CGPoint gestureSwipeLocation;
/** The direction of the swipe. The direction is already converted to the current device orientation, so that left/right/up/down are relative
 to how the user is holding the device and up is always up, left is always to the left, and so on. */
@property (nonatomic, readonly) KKSwipeGestureDirection gestureSwipeDirection;

/** Enables the (one finger) pan gesture recognizer. A pan occurs when the finger touches the screen and starts moving within a short amount
 of time (otherwise it may be recognized as a long press gesture instead). Since the pan gesture is similar to the swipe gesture, the swipe and pan gestures
 will be recognized simultaneously if both are enabled at the same time. */
@property (nonatomic) BOOL gesturePanEnabled;
/** Is YES when the pan gesture has began and stays true until the finger is lifted. */
@property (nonatomic, readonly) BOOL gesturePanBegan;
/** Returns the location of the pan gesture. */
@property (nonatomic, readonly) CGPoint gesturePanLocation;
/** Returns the translation of the pan gesture, ie how far (in points) the finger has moved from the point where the pan gesture began. For example,
 if translation is -50, 20 then the finger has moved 50 points to the left and 20 points upwards from its initial position.
 You can set the translation at any time, for example to reset it to (0,0). Note that setting the translation resets the gesturePanVelocity. */
@property (nonatomic) CGPoint gesturePanTranslation;
/** Returns the velocity of the pan gesture in points per frame. If you need points per second (like UIPanGestureRecognizer returns), 
 simply multiply the x and y coordinates with the MaxFrameRate setting (ie 60). */
@property (nonatomic, readonly) CGPoint gesturePanVelocity;

/** Enables the (two finger) rotation gesture recognizer. A rotation occurs when two fingers touch the screen and the fingers move in opposing directions in a circular motion.
 The rotation gesture ends when both fingers are lifted. Can be used simultaneously with the pinch gesture recognizer for a rotate & scale action.
 
 It is recommended to not enable the pan or long press gestures simultaneously with the rotation gesture,
 since the pan and long press gestures will make it difficult for the user to correctly initiate the rotation gesture. 
 If the pan gesture is enabled with rotation, the user must place both fingers on the screen before moving either one more than 10 pixels. This is tricky to achieve.
 If the long press gesture is enabled, the user must place both fingers on the screen within the time it takes to initiate a long press (0.5 seconds). 
 This is feasible but can still be confusing. */
@property (nonatomic) BOOL gestureRotationEnabled;
/** Is YES when the rotation gesture has began and stays true until both fingers are lifted. */
@property (nonatomic, readonly) BOOL gestureRotationBegan;
/** Returns the location of the rotation gesture, which is the middle point between the two fingers. */
@property (nonatomic, readonly) CGPoint gestureRotationLocation;
/** Returns the rotation angle in Cocos2D direction values (an angle in the range 0 to 360 degrees). 
 If you change the rotation angle the rotation velocity will be reset. */
@property (nonatomic) float gestureRotationAngle;
/** Returns the velocity of the rotation gesture in degrees per frame. */
@property (nonatomic, readonly) float gestureRotationVelocity;

/** Enables the (two finger) pinch gesture recognizer. A pinch occurs when two fingers touch the screen and move either towards or away from each other.
 The rotation gesture ends when both fingers are lifted. Can be used simultaneously with the rotation gesture recognizer for a rotate & scale action.
 
 It is recommended to not enable the pan or long press gestures simultaneously with the pinch gesture,
 since the pan and long press gestures will make it difficult for the user to correctly initiate the pinch gesture. 
 If the pan gesture is enabled, the user must place both fingers on the screen before moving either one more than 10 pixels. This is tricky to achieve.
 If the long press gesture is enabled, the user must place both fingers on the screen within the time it takes to initiate a long press (0.5 seconds). 
 This is feasible but can still be confusing. */
@property (nonatomic) BOOL gesturePinchEnabled;
/** Is YES when the pinch gesture has began and stays true until both fingers are lifted. */
@property (nonatomic, readonly) BOOL gesturePinchBegan;
/** Returns the location of the pinch gesture, which is the middle point between the two fingers. */
@property (nonatomic, readonly) CGPoint gesturePinchLocation;
/** Returns the scale factor relative to the two fingers. 
 If you change the scale factor the pinch velocity will be reset. */
@property (nonatomic) float gesturePinchScale;
/** Returns the velocity of the pinch gesture in scale factor per frame. */
@property (nonatomic, readonly) float gesturePinchVelocity;


@end
