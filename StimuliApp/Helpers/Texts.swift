//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct Texts {

    // MARK: - Other
    #if targetEnvironment(macCatalyst)
    static let version = "StimuliApp beta " + String(format:"%.1f", Constants.version)
    #else
    static let version = "StimuliApp " + String(format:"%.1f", Constants.version)
    #endif

    static let versionInfo = "StimuliApp version"
    
    static let firstLaunch = """
Welcome to \(version)!!

We have included some demos in the Tests menu to show you some of the StimuliApp features.
You can duplicate, edit or delete them.
You'll always find a copy of them available to download on our website (www.stimuliapp.com).
"""

    static let frameRateWeb = "https://www.stimuliapp.com/steady-frame-rate/"

    static let resultName = """
A name to identify this result.
"""

    static let longFrames = """
It is possible that the calculations needed to render a new image last longer than the expected frame duration. In \
that case, the previous image will be on the screen for a longer time, until all the calculations are made and a \
new image can appear. We call the frames that last more than expected long frames.
"""

    static let export = """
The test will be saved in a .stimulitest file containing a .jsondescription of all its parameters.
You can email the file and save it as a backup or share it with other devices.

To import a test from a previous saved file, first open the file on your device and the select the option \
"Copy to StimuliApp".
StimuliApp will launch and the new imported test will appear in the Tests menu.
"""

    // MARK: - Edit
    static let optionalElements = """
Use the edit button in the top of the screen if you want to delete or move this item.
"""

    static let optionalAndDuplicatingElements = """
Use the edit button in the top of the screen if you want to delete or move this item.

A long press will allow you to make a copy of the item.
"""

    static let deleteTest = """
Are you sure you want to delete this test and all of its contents?
"""

    static let deleteMedia = """
Are you sure you want to delete this media from the device?
"""

    static let deleteResult = """
Are you sure you want to delete this result?
"""

    static let deleteStimulus = """
Are you sure you want to delete this stimulus?

The following objects are referencing the stimulus and they will also be deleted:
"""

    static let deleteSection = """
Are you sure you want to delete this section and all its contents?
"""

    static let deleteScene = """
Are you sure you want to delete this scene and all its contents?
"""

    static let deleteCondition = """
Are you sure you want to delete this condition?
"""

    static let deleteObject = """
Are you sure you want to delete this object?
"""

    static let deleteList = """
Are you sure you want to delete this list?

The following variables are referencing this list and their values will also be deleted:
"""

    // MARK: - Settings
    static let name = """
A name to identify this device.
"""

    static let email = """
The default email address that will be used to send the results.
"""

    static let description = """
The description of the device in use.

If the device is not correctly identified correctly, an alphaNumeric code preceded by the word "unknown" is displayed.
"""

    static let system = """
The OS system of the device.
"""

    static let rampTime = """
The transition time in seconds that any change in volume requires.
\(Constants.rampTime) seconds is the recommended value to avoid pops and clicks that can occur when \
changes in volumes occur very quickly.
From the startTime of a sound stimulus to startTime + rampTime, the volume changes from \
zero to the corresponding value.
From startTime + duration - rampTime to startTime + duration the volume changes from the \
corresponding value to zero.
"""

    static var ppi: String {
        var text = """
        The pixel density per inch of the screen.
        This value is provided directly when the device is identified.
        If the device is not correctly identified, you can provide a value manually.
        This value is only necessary if you plan to work in centimeters, inches or visual degrees instead of pixels.
        """
        #if targetEnvironment(macCatalyst)
        text =  """
        The pixel density per inch of the screen.
        It is important that you calculate this value yourself, if you plan to work in centimeters, inches \
        or visual degrees.
        Do not use the value provided by apple or the manufacturer of your screen, because the value of your current \
        ppi can depend on some system settings.
        The only way to be sure that you are using the right value for the ppi is to measure it yourself.
        To do that, first measure the size of the test window in pixels and then the length of the diagonal of the \
        test window in inches.
        With these values you can easily get your ppi, for example using:

        https://www.pxcalc.com

        Always verify that the ppi value is correct by drawing a rectangle of a certain size in cm or inches and \
        measuring the actual size.
        """
        #endif
        return text
    }

    static let maximumFrameRate = """
The maximum frame rate of the screen. This value can be 60 or 120 Hz depending on the device.
"""

    static let maximumBrightness = """
The maximum luminance of the device in cd/m².

StimuliApp identifies most of the devices and sets as a default value for maximumLuminance the value included in \
the specifications by Apple. The nominal maximum luminance values were retrieved from apple.com and might slightly \
differ from the displayed values due to variations across series or the time in use of the displays.

You can also manually specify maximumLuminance if you have measured the maximum luminance using a photometer.

StimuliApp uses the maximumLuminance parameter, so you can directly read the luminance of your tests and \
stimuli directly in cd/m².
"""

    static let audioRate = """
The sampling frequency at which sounds are played.
It is usually a value from 44100 to 48000 Hz, depending on the device.
"""

    static let delayAudio60 = """
Delay correction (negative or positive) to apply for the audiovisual synchronization on tests where \
the screen frame rate is 60Hz.

When the user specifies that the auditory and visual signals should be presented at the same, \
some small audiovisual delays occur. The average delay is around -10 to 10 ms depending on the device.
It is possible to correct this average delay.

You need to present several times an audiovisual signal specified to be presented at the same time and \
calculate the average delay measuring the signals with an oscilloscope.
Then, you should include the average delay in the delayAudio60 variable using a positive sign if you want \
that the correction delays the auditory signal presentation and a negative sign if you want that the correction \
delays the visual signal presentation.

The variability of the delay across presentations (precision) is less than 1 millisecond \
(standard deviation) and cannot be corrected.
"""

    static let delayAudio120 = """
Delay correction to apply for the audiovisual synchronization on tests where the screen frame rate is 120 Hz.

This delay correction is necessary because the average delay is different when the device is working at 60 or 120 Hz.
"""

    static var resolution: String {
        var text = """
        Screen resolution in landscape mode.
        """
        #if targetEnvironment(macCatalyst)
        text =  """
        Tests are always run and previewed with StimuliApp in fullscreen mode.

        When a test is run, a test window is created with the size indicated in this property.

        Depending on your computer's CPU and GPU model, you may find that running tests \
        using a large window results in a drop in performance and unstable frame rate.

        If that is the case, you can try reducing the size of the window.

        You can change the position of the window in the screen with the testWindowPosition properties.
        """
        #endif
        return text
    }

    static let testWindowPositionX = """
The x position of the test window, from the upper left corner of the screen.
"""

    static let testWindowPositionY = """
The y position of the test window, from the upper left corner of the screen.
"""

    // MARK: - Test
    static let firstMessageTest = """
Remember to disable Notifications while performing the test.

For stimuliApp to display luminance properly:

- Disable TrueTone and Night Shift in your device (Settings -> Display & Brightness).

- Disable Auto-Brightness (Settings -> Accessibility, Display & Text Size).
"""

    static let needToSync = """
Screen needs to re-sync. Press OK to continue.
"""

    static let testName = """
A name to identify this test.
"""

    static let frameRate = """
On this device, the refresh rate of the screen can be 60 or 120 HZ.
Select the desired frame rate of the screen.
"""

    static let frameRate2 = """
On this device, the refresh rate of the screen is always 60 HZ.
"""

    static let brightness = """
You can control the luminance of the screen with this parameter.

The perceived brightness is approximately proportional to the logarithm of the luminance that you set \
with this parameter.

The new luminance will only be effective once the test begins.

There are a few preferences on iOS and iPadOS that can automatically change the brightness and color temperature \
settings of the device:

Auto-Brightness can be found in your device Settings, Accessibility, Display & Text Size.

TrueTone and Night Shift options can be found in your device Settings, Display & Brightness.

Remember to disable these options to avoid unwanted changes of brightness when running a test.

Even with the Auto-Brightness adjustment disabled, the brightness of the device can be slightly increased \
automatically if you are under a bright light (outside).
"""

    static let gamma = """
Establish how the luminance raises with the input value.
"""

    static let gammaValue = """
Numeric value of gamma.
"""

    static let viewingDistance = """
Viewing distance from the participant to the screen.

This value is used to calculate the actual pixel size of any property that is measured in visual degrees.
"""

    static let distanceValue = """
Distance value.
"""

    static let distanceDefault = """
Distance value by default, used when previewing.
"""

    static let XButton = """
The position on the screen of the button that is used to cancel test in progress.
"""

    static let randomness = """
How random numbers are generated.
"""

    static let firstSection = """
The first section of the test.
"""

    static let linear = """
The gamma is transformed to make the luminance linear, assuming the screen has a gamma value of 2.2, \
which is the gamma used in iOS and iPadOs devices.
The correction is simply to raise the luminance to the power of 1/2.2
"""

    static let normal = """
No transformation is made. The values are not in a linear space.
This option is a good choice if you are drawing images.
"""

    static let calibrated = """
If you are using stimuliApp on a computer or with an external monitor, you may want to calibrate it with a \
photometer and manually enter the correction value for gamma.
The correction is simply to raise the luminance to the power of 1/gamma.
"""

    static let constant = """
The distance from the participant to the screen is a constant value.
"""

    static let dependent = """
Each time you run the test, you are asked to enter the distance from the participant to the screen.
"""

    static let automaticRandomness = """
The random numbers are generated automatically each time you run the test.
"""
    static let withSeedsRandomness = """
Each time you run the test, you are asked for numeric seeds to generate the random numbers.
"""

    // MARK: - Stimulus
    static let stimulusName = """
A name to identify this stimulus.
"""

    static let type = """
Stimulus type.
"""

    static let shape = """
Stimulus shape.
"""

    static let activated = """
Boolean variable that establishes whether the stimulus is active or not.
Useful when you have stimuli that should be presented in some trials and not presented in other trials.
Use this variable to control the presence of the stimulus rather than using contrast = 0 or volume = 0 \
or other workarounds.
Making the stimulus inactive is the only way to make sure neither CPU or GPU cycles are used to compute the stimulus.
"""

    static let start = """
Time at which the stimulus begins, measured from the start of the scene.
"""

    static let duration = """
Duration of the stimulus. By default is set to 1000 seconds.
"""

    static let originCoordinates = """
By default, the origin of coordinates is placed in the center of the screen, \
but it is possible to place it in another point of the screen.
"""

    static let position = """
Position of the center of the stimulus relative to the origin of coordinates.
X increases from left to right and Y increases from bottom to top.
The angles are measured counterclockwise from the x axis.
"""

    static let rotation = """
The angle of rotation of the stimulus (both the shape and its content).
Measured counterclockwise.
"""

    static let border = """
Border around the stimulus.
"""

    static let borderDistance = """
Distance from the interior limit of the border to the exterior limit of the stimulus.
The distance can be positive or negative to create the border in the exterior or interior of the stimulus.
"""

    static let borderThickness = """
The size of the border.
"""

    static let borderColor = """
The color of the border.
"""

    static let noise = """
Noise applied to the stimulus.
"""

    static let noiseDeviation = """
The value of the standard deviation of the normal distribution that adds noise to the stimulus.
"""

    static let noiseIntensity = """
Intensity of Perlin noise that is added to the stimulus.
"""

    static let noiseSmoothness = """
The smoothness value of the Perlin noise implementation.
"""

    static let noiseTimePeriod = """
The duration of each different noise calculation. If you set this value to 1 frame the noise will change each frame.
If you want a static noise, you can make this value longer than the duration of the stimulus.
"""

    static let noiseSize = """
The size of the blocks with same noise. From 1 pixel to the size of the stimulus.
"""

    static let noisePosition = """
The position of the origin of the noise. Making this parameter dependent on time you can move the noise in a \
certain direction.
"""

    static let noiseRotation = """
The rotation of the noise.
"""

    static let contrast = """
Contrast of the stimulus.
"""

    static let contrastValue = """
Numeric value of the contrast.
"""

    static let contrastValue2 = """
Maximum value of the contrast in the center of the stimulus.
"""

    static let contrastGaussianDeviation = """
The standard deviation of the gaussian function of the contrast.
"""

    static let contrastCosineValue = """
The stimulus is masked with a circular shape of diameter equal to the maximum size of the stimulus.
In the exterior part of the shape, the contrast decay from contrastValue to zero following a cosine function.
ContrastCosineValue is the proportion of the shape that is not affected by the cosine decay.
"""

    static let modulator = """
Modulator of the contrast of the stimulus.
"""

    static let modulatorAmplitude = """
The amplitude of the sine modulator of the contrast.
"""

    static let modulatorPeriod = """
The size period of the sine modulator of the contrast.
"""

    static let modulatorPhase = """
The phase of the sine modulator of the contrast.
"""

    static let modulatorRotation = """
The rotation of the sine modulator of the contrast.
"""

    static let borderNone = """
No border.
"""

    static let borderNormal = """
The border has the same contrast, noise and modulation as the stimulus.
"""
    static let borderOpaque = """
The border has always contrast = 1 and zero noise and modulation, independently of the stimulus values.
"""

    static let noiseNone = """
No noise.
"""

    static let gaussian = """
Gaussian noise. Adding a noise RGB value (x;x;x) to the color.
The x value is a random value calculated from a normal distribution with mean = 0 and  \
standard deviation = noiseDeviation.
"""

    static let perlin = """
Simple Perlin noise implementation with a parameter for the intensity of noise, and another parameter for smoothness.
"""

    static let contrastUniform = """
The contrast is uniform.
"""

    static let contrastGaussian = """
The contrast is fitted by a 2d gaussian function centered in the center of the shape.
"""

    static let contrastCosine = """
The contrast is fitted by a 2d raised cosine function centered in the center of the shape.
"""

      static let modulatorNone = """
No modulator of contrast.
"""

    static let modulatorSinusoidal = """
The contrast is modulated by a sinusoidal function.
"""

    static let origin2dCenter = """
The origin of coordinates is the center of the screen.
"""

    static let origin2dCartesian = """
Two independent cartesian variables.
"""
    static let origin2dPolar = """
Two independent polar variables.
"""

    static let position2dVector = """
One only variable with 2 components (horizontal;vertical).
"""

    static let position2dCartesian = """
2 independent cartesian variables.
"""

    static let position2dPolar = """
2 independent polar variables.
"""

    static let size2dVector = """
One only variable with 2 components (horizontal;vertical).
"""

    static let size2dCartesian = """
2 independent cartesian variables.
"""

    static let size2dXy = """
One only variable to measure size making sizeX = sizeY.
"""

    static let colorVector = """
One only variable with 3 components (r;g;b).
"""

    static let colorRgb = """
3 independent variables, one for each color: red, green or blue.
"""

    static let colorLuminance = """
One only variable (r=g=b) for grayscale colors.
"""

    static let both = """
Both audio channels.
"""

    static let left = """
Left audio channel.
"""

    static let right = """
Right audio channels.
"""

    static let pureTone = """
Pure tone sound (tone with a simple sinusoidal waveform).
"""

    static let whiteNoise = """
White noise sound (random signal having equal intensity at different frequencies).
"""

    static let random = """
The direction of movement of the dots is random.
"""

    static let fixed = """
The dots move in a fixed direction.
"""

    static let center = """
The dots move towards the stimulus center.
"""

    static let outCenter = """
The dots move away from the the stimulus center.
"""

    static let clockwise = """
The dots move clockwise.
"""

    static let counterclockwise = """
The dots move clockwise.
"""

    static let directionAngle = """
The angle of the direction of movement.
"""

    static let distanceDots = """
Total distance dots travel during their life.
"""

    static let distanceAngle = """
Total angular distance dots travel during their life.
"""

    static let same = """
The dot is always the same type (type1 or type2) during all its life.
"""

    static let different = """
Each frame a dot can change from type1 to type2 or viceversa.
"""

// MARK: - Section
    static let sceneOrder = """
All the scenes in this menu will be presented consecutively, one after the other, in the order they are in.

The presentation of all the scenes of a section is called a trial.
"""

    static let newScene = """
To create a new scene.

All the scenes in this menu will be presented consecutively, one after the other, in the order they are in.

The presentation of all the scenes of a section is called a trial.
"""

    static let variablesInSection = """
Variables of all the objects in any scene in the section.

We call variables the properties of an object that are not kept constant across trials, but vary from trial to trial.

Select any of the variables to manage what their possible values are and how they are chosen in each trial.
"""

    static let repetitionsBlock = """
One of the variables is managed by blocks. In this case repetitions is always = 1. The number of different trials \
is the same as the total number of trials and it is automatically managed by the list of blocks.
"""

    static let repetitions = """
The number of repetitions of all the different trials.
"""

    static let differentTrials = """
The total number of different ways in which the variable values can be assigned.
"""

    static let totalNumberOfTrials = """
numberOfDifferentTrials * repetitions.
"""

    static let trialValueVariable = """
 It is possible to associate a different value for each trial in the section.
To do this, it is necessary to select the variable that will be used to calculate the value of each trial.
If no variable is selected, the value of each trial will always be considered zero.
"""

    static let trialValueSame = """
The value of the trial is equal to the value of the variable that we have selected.
It can be a numeric value or a position vector.
"""

    static let trialValueOther = """
The value of the trial is equal to a numeric value set for each of the possible values of the variable \
that we have selected.
"""

    static let responseValueParameter = """
It is possible to select one of the parameters of any response to be the responseValue of the section.
The responseValue can be a numeric value or a position vector.
"""

    static let marginError = """
We compare responseValue with trialValue and calculate their difference.

If they are numeric values: difference = abs(responseValue - trialValue).
If they are vectors, the difference is the distance between the points they represent on the screen.

If distance < marginError the trial is considered correct, otherwise it is considered incorrect.

The variable used to calculate the trialValue and the response parameter used to calculate the responseValue \
must have the same units for the comparison to be fair.

For example, if the trialValue is determined by the anglePosition of certain stimulus and the responseValue is \
determined by the anglePosition of the touch on the screen, both angle positions must be measured \
in radians or both must be measured in degrees.
"""

    static let newCondition = """
Create a new condition that will be evaluated after each trial.

The order of the conditions in the menu is the order in which they are evaluated.

If a condition is true, the action associated with that condition will be performed and the following conditions \
will not be evaluated.

The possible actions that can be performed are to go to another section or to end the test.

If neither condition is true, a new trial in the same section is performed.
"""

    static let condition = """
The order of the conditions in the menu is the order in which they are evaluated.

If a condition is true, the action associated with that condition will be performed and the following conditions \
will not be evaluated.

The possible actions that can be performed are to go to another section or to end the test.

If neither condition is true, a new trial in the same section is performed.
"""

    static let allTrials = """
The order of the conditions in the menu is the order in which they are evaluated.

If a condition is true, the action associated with that condition will be performed and the following conditions \
will not be evaluated.

The possible actions that can be performed are to go to another section or to end the test.

If neither condition is true, a new trial in the same section is performed.
"""

    // MARK: - Scene
    static let sceneName = """
A name to identify this scene
"""

    static let sceneDuration = """
The maximum duration of the scene if no response is given.
"""

    static let durationValue = """
The duration of the scene.
"""

    static let sceneResponse = """
To select one of the possible types of responses for the scene.

Each time a response is given the scene ends even if the time has not reached the duration of the scene.
"""

    static let numberOfLayers =  """
The number of layers in the scene.
By default, all objects are drawn on the same layer, which is drawn on top of the background.
If you want to draw one object on top of another, you must increase the number of layers.
(This does not apply to video or text objects that are rendered differently, always on top of everything).

When drawing objects, a preassigned space is saved for each one of them.
This space is slightly larger than the object itself.
If two objects are too close to each other, their respective preassigned spaces can interfere, \
creating an unwanted empty space between the objects.
To avoid this, you should increase the number of layers (or separate the objects a bit if possible).

Increasing the number of layers is computationally costly, so try to use as few layers as possible, \
especially when working at 120Hz.
"""

    static let continuousResolution = """
When using stimuliApp, images are displayed in an sRGB space with 256 possible values for each channel of the RGB color.
If you are working only with luminances: R = G = B, there are 256 luminance levels.

Sometimes this limitation on the number of different luminance intensities displayable can be an issue.
By making the continuosResolution property true, the noisy-bit method is implemented.
This method consists of adding a small amount of random noise.
The method is described in Allard, R., Faubert, J., 2008. The Noisy-Bit method for digital displays: \
Converting a 256 luminance resolution into a continuous resolution. Behav. Res. Methods 40, 735–743.

The noisy-bit method, combined with the 256 luminance levels, is perceptually equivalent to an analog display \
with a continuous luminance intensity resolution when the spatiotemporal resolution is high enough that \
the noise becomes negligible.
"""

    static let backgroundColor = """
Background object that sets the color of the screen.
"""

    static let newObject = """
To create a new object from an existing stimulus.
"""

    static let object = """
Objects are drawn on the screen in the same order as they are in this menu, except for video or text objects that \
are always rendered above everything else.
You can change the order of the objects by clicking the Edit button and moving them in the menu.
"""

}
