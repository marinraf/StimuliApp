//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#include <metal_stdlib>
#include "Functions.h"
#import "LokiHeader.metal"
using namespace metal;



struct Data {
    float inversGammaCorrection;
    float backgroundRed;
    float backgroundGreen;
    float backgroundBlue;
    float timeInFrames;
    float frameRate;
    float randomSeed;
    float randomSeedInitial;
    float screenWidth;
    float screenHeight;
    float gammaCorrection;
    float moreColors;
    float status;
};


struct Object {
    float type; //0
    float variable0; //1...20
    float variable1; //1...20
    float variable2; //1...20
    float variable3; //1...20
    float variable4; //1...20
    float variable5; //1...20
    float variable6; //1...20
    float variable7; //1...20
    float variable8; //1...20
    float variable9; //1...20
    float variable10; //1...20
    float variable11; //1...20
    float variable12; //1...20
    float variable13; //1...20
    float variable14; //1...20
    float variable15; //1...20
    float variable16; //1...20
    float variable17; //1...20
    float variable18; //1...20
    float variable19; //1...20
    float shape; //21
    float xSize; //22
    float ySize; //23
    float startNotUseful; //24 not used
    float durationNotUseful; //25 not used
    float xOriginNotUseful; //26 not used
    float yOriginNotUseful; //27 not used
    float xPositionNotUseful; //28 not used
    float yPositionNotUseful; //29 not used
    float xCenter; //30
    float yCenter; //31
    float rotation; //32
    float borderType; //33
    float borderDistance; //34
    float borderThickness; //35
    float borderColorRed; //36
    float borderColorGreen; //37
    float borderColorBlue; //38
    float contrastType; //39
    float contrastValue; //40
    float contrastEnvelope; //41
    float noiseType; //42
    float noiseValue; //43
    float noiseTimePeriod; //44
    float noisePosX; //45
    float noisePosY; //46
    float noiseRotation; //47
    float noiseSizeX; //48
    float noiseSizeY; //49
    float modulatorType; //50
    float modulatorAmplitude; //51
    float modulatorPeriod; //52
    float modulatorPhase; //53
    float modulatorRotation; //54
};




//PATCH
kernel void patch(texture2d<float, access::write> output [[texture(0)]],
                  constant Data &data [[buffer(0)]],
                  constant Object &object [[buffer(1)]],
                  ushort2 id [[thread_position_in_grid]])
{
    //GENERAL
    //position
    float2 maxSize = float2(output.get_width(), output.get_height());
    if (id.x >= maxSize.x || id.y >= maxSize.y) {
        return;
    }
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);
    float2 point = calculatePosition(id, center, rotation, maxSize);
    //shape
    int shape = int(object.shape + 0.5);
    ushort inside = getInside(object, point, shape);
    //color
    if (inside == 2) {
        float4 color = float4(0);
        output.write(color, id);
        return;
    } else if (inside == 1 && object.borderType > 1.5) {
        float3 color0 = float3(object.borderColorRed, object.borderColorGreen, object.borderColorBlue);
        float4 color = float4(moreColors(data, color0, point), 1);
        output.write(color, id);
        return;
    } else if (inside == 1) {
        float4 color0 = float4(object.borderColorRed, object.borderColorGreen, object.borderColorBlue, 1);
        float4 color = finalColor(object, data, color0, point);
        output.write(color, id);
        return;
    }
    
    //SPECIFIC
    float3 color0 = float3(object.variable0, object.variable1, object.variable2);
    float4 color = finalColor(object, data, color0, point);
    output.write(color, id);
}




//GRADIENT
kernel void gradient(texture2d<float, access::write> output [[texture(0)]],
                     constant Data &data [[buffer(0)]],
                     constant Object &object [[buffer(1)]],
                     ushort2 id [[thread_position_in_grid]])
{
    //GENERAL
    //position
    float2 maxSize = float2(output.get_width(), output.get_height());
    if (id.x >= maxSize.x || id.y >= maxSize.y) {
        return;
    }
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);
    float2 point = calculatePosition(id, center, rotation, maxSize);
    //shape
    int shape = int(object.shape + 0.5);
    ushort inside = getInside(object, point, shape);
    //color
    if (inside == 2) {
        float4 color = float4(0);
        output.write(color, id);
        return;
    } else if (inside == 1 && object.borderType > 1.5) {
        float3 color0 = float3(object.borderColorRed, object.borderColorGreen, object.borderColorBlue);
        float4 color = float4(moreColors(data, color0, point), 1);
        output.write(color, id);
        return;
    } else if (inside == 1) {
        float4 color0 = float4(object.borderColorRed, object.borderColorGreen, object.borderColorBlue, 1);
        float4 color = finalColor(object, data, color0, point);
        output.write(color, id);
        return;
    }
    
    //SPECIFIC
    float gradientSize = object.variable0;
    float3 color1 = float3(object.variable1, object.variable2, object.variable3);
    float3 color2 = float3(object.variable4, object.variable5, object.variable6);
    float displacementAxis = object.variable7;
    float gradientRotation = object.variable8;
    
    float2 displacement = float2(displacementAxis * cos(gradientRotation), displacementAxis * sin(gradientRotation));
    float2 position = changePosition(point, displacement, gradientRotation);
    
    float3 color0;
    if (point.x < -gradientSize / 2) {
        color0 = color1;
    } else if (point.x > gradientSize / 2) {
        color0 = color2;
    } else {
        color0 = color1 * (0.5 - position.x / gradientSize) + color2 * (0.5 + position.x / gradientSize);
    }
    float4 color = finalColor(object, data, color0, point);
    output.write(color, id);
}




//GRATING
kernel void grating(texture2d<float, access::write> output [[texture(0)]],
                    constant Data &data [[buffer(0)]],
                    constant Object &object [[buffer(1)]],
                    ushort2 id [[thread_position_in_grid]])
{
    //GENERAL
    //position
    float2 maxSize = float2(output.get_width(), output.get_height());
    if (id.x >= maxSize.x || id.y >= maxSize.y) {
        return;
    }
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);
    float2 point = calculatePosition(id, center, rotation, maxSize);
    //shape
    int shape = int(object.shape + 0.5);
    ushort inside = getInside(object, point, shape);
    //color
    if (inside == 2) {
        float4 color = float4(0);
        output.write(color, id);
        return;
    } else if (inside == 1 && object.borderType > 1.5) {
        float3 color0 = float3(object.borderColorRed, object.borderColorGreen, object.borderColorBlue);
        float4 color = float4(moreColors(data, color0, point), 1);
        output.write(color, id);
        return;
    } else if (inside == 1) {
        float4 color0 = float4(object.borderColorRed, object.borderColorGreen, object.borderColorBlue, 1);
        float4 color = finalColor(object, data, color0, point);
        output.write(color, id);
        return;
    }
    
    //SPECIFIC
    float period = object.variable0;
    float3 color1 = float3(object.variable1, object.variable2, object.variable3);
    float3 color2 = float3(object.variable4, object.variable5, object.variable6);
    float phase = object.variable7;
    float gratingRotation = object.variable8;
    
    float2 displacement = float2(0, 0);
    float2 position = changePosition(point, displacement, gratingRotation);
    
    float sinusoidal = sin((2 * M_PI_F / period * position.x) - phase);
    
    float3 colorCentral = (color1 + color2) / 2;
    float3 colorVariation = (color2 - color1) / 2;
    float3 color0 = colorCentral + colorVariation * sinusoidal;
    float4 color = finalColor(object, data, color0, point);
    output.write(color, id);
}




//CHECKERBOARD
kernel void checkerboard(texture2d<float, access::write> output [[texture(0)]],
                         constant Data &data [[buffer(0)]],
                         constant Object &object [[buffer(1)]],
                         ushort2 id [[thread_position_in_grid]])
{
    //GENERAL
    //position
    float2 maxSize = float2(output.get_width(), output.get_height());
    if (id.x >= maxSize.x || id.y >= maxSize.y) {
        return;
    }
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);
    float2 point = calculatePosition(id, center, rotation, maxSize);
    //shape
    int shape = int(object.shape + 0.5);
    ushort inside = getInside(object, point, shape);
    //color
    if (inside == 2) {
        float4 color = float4(0);
        output.write(color, id);
        return;
    } else if (inside == 1 && object.borderType > 1.5) {
        float3 color0 = float3(object.borderColorRed, object.borderColorGreen, object.borderColorBlue);
        float4 color = float4(moreColors(data, color0, point), 1);
        output.write(color, id);
        return;
    } else if (inside == 1) {
        float4 color0 = float4(object.borderColorRed, object.borderColorGreen, object.borderColorBlue, 1);
        float4 color = finalColor(object, data, color0, point);
        output.write(color, id);
        return;
    }
    
    //SPECIFIC
    float boxSizeX = object.variable0;
    float boxSizeY = object.variable1;
    float3 color1 = float3(object.variable2, object.variable3, object.variable4);
    float3 color2 = float3(object.variable5, object.variable6, object.variable7);
    float boxPositionX = object.variable8;
    float boxPositionY = object.variable9;
    float checkerboardRotation = object.variable10;
    
    float2 displacement = float2(boxPositionX, boxPositionY);
    float2 position = changePosition(point, displacement, checkerboardRotation);
    
    bool condition1 = (position.x < 0 && position.y > 0 )|| (position.x > 0 && position.y < 0);
    
    bool condition2 = (int(position.x / boxSizeX) % 2 + int(position.y / boxSizeY) % 2) % 2 == 0;
    
    bool condition = condition1 == condition2;
    
    float3 color0 = condition ? color1 : color2;
    float4 color = finalColor(object, data, color0, point);
    output.write(color, id);
}




//RADIAL CHECKERBOARD
kernel void radialCheckerboard(texture2d<float, access::write> output [[texture(0)]],
                               constant Data &data [[buffer(0)]],
                               constant Object &object [[buffer(1)]],
                               ushort2 id [[thread_position_in_grid]])
{
    //GENERAL
    //position
    float2 maxSize = float2(output.get_width(), output.get_height());
    if (id.x >= maxSize.x || id.y >= maxSize.y) {
        return;
    }
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);
    float2 point = calculatePosition(id, center, rotation, maxSize);
    //shape
    int shape = int(object.shape + 0.5);
    ushort inside = getInside(object, point, shape);
    //color
    if (inside == 2) {
        float4 color = float4(0);
        output.write(color, id);
        return;
    } else if (inside == 1 && object.borderType > 1.5) {
        float3 color0 = float3(object.borderColorRed, object.borderColorGreen, object.borderColorBlue);
        float4 color = float4(moreColors(data, color0, point), 1);
        output.write(color, id);
        return;
    } else if (inside == 1) {
        float4 color0 = float4(object.borderColorRed, object.borderColorGreen, object.borderColorBlue, 1);
        float4 color = finalColor(object, data, color0, point);
        output.write(color, id);
        return;
    }
    
    //SPECIFIC
    float boxAngleSize = object.variable0;
    float3 color1 = float3(object.variable1, object.variable2, object.variable3);
    float3 color2 = float3(object.variable4, object.variable5, object.variable6);
    float radialCheckerboardRotation = object.variable7;
    
    float diameter[10] = { object.variable8, object.variable9, object.variable10,
        object.variable11, object.variable12, object.variable13, object.variable14,
        object.variable15, object.variable16,
        object.variable17 };
    
    float2 displacement = float2(0, 0);
    float2 position = changePosition(point, displacement, radialCheckerboardRotation);
    
    float radius = length(position);
    float angle = getAngle(position);
    
    bool condition1 = false;
    for(int i = 0; i < 10; i++) {
        if (radius > diameter[i] / 2) {
            condition1 = !condition1;
        }
    }    
    bool condition2 = int(angle / boxAngleSize) % 2 == 0;
    
    bool condition = condition1 == condition2;
    
    float3 color0 = condition ? color1 : color2;
    float4 color = finalColor(object, data, color0, point);
    output.write(color, id);
}
