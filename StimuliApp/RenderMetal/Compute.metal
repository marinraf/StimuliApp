//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#include <metal_stdlib>
#include "Functions.h"
#import "LokiHeader.metal"
using namespace metal;

constant ushort MAX_OBJECTS = 20;


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

struct ObjectPos {
    float x[MAX_OBJECTS];
    float y[MAX_OBJECTS];
};

struct Layers1 {
    float layer;
};

struct Layers2 {
    float layer[2];
};

struct Layers3 {
    float layer[3];
};



//get color
float4 getColor(int position,
                float4 color0,
                texture2d<float, access::read> input,
                constant ObjectPos &objectPos,
                ushort2 id)
{

    float2 newId = float2(id.x - objectPos.x[position], id.y - objectPos.y[position]);

    if (newId.x < 0 || newId.y < 0 || newId.x >= input.get_width() || newId.y >= input.get_height()) {
            return color0;
        }

    float4 color1 = input.read(ushort2(newId));

    float3 color = mix(color0.xyz, color1.xyz, color1.w);

    return float4(color, 1);
}



//compute 1 layer
kernel void compute1Layer(texture2d<float, access::write> output [[texture(0)]],
                          const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                          constant Data &data [[buffer(0)]],
                          constant ObjectPos &objectPos [[buffer(1)]],
                          device Layers1 *layers [[buffer(2)]],
                          ushort2 id [[thread_position_in_grid]],
                          ushort2 groupId [[threadgroup_position_in_grid]],
                          ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }

    float4 color = float4(data.backgroundRed, data.backgroundGreen, data.backgroundBlue, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

//compute 1 layer more colors
kernel void compute1LayerContinuous(texture2d<float, access::write> output [[texture(0)]],
                                    const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                                    constant Data &data [[buffer(0)]],
                                    constant ObjectPos &objectPos [[buffer(1)]],
                                    device Layers1 *layers [[buffer(2)]],
                                    ushort2 id [[thread_position_in_grid]],
                                    ushort2 groupId [[threadgroup_position_in_grid]],
                                    ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }
    
    float3 color0 = float3(data.backgroundRed, data.backgroundGreen, data.backgroundBlue);
    float2 point = float2(id);
    color0 = moreColors(data, color0, point);
    float4 color = float4(color0, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

//compute 2 layers
kernel void compute2Layers(texture2d<float, access::write> output [[texture(0)]],
                           const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                           constant Data &data [[buffer(0)]],
                           constant ObjectPos &objectPos [[buffer(1)]],
                           device Layers2 *layers [[buffer(2)]],
                           ushort2 id [[thread_position_in_grid]],
                           ushort2 groupId [[threadgroup_position_in_grid]],
                           ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }
    
    float4 color = float4(data.backgroundRed, data.backgroundGreen, data.backgroundBlue, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer[0] + 0.5);
    int objectNumber1 = int(layers[group].layer[1] + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }
    if (objectNumber1 < MAX_OBJECTS) {
        color = getColor(objectNumber1, color, input[objectNumber1], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

//compute 2 layers more colors
kernel void compute2LayersContinuous(texture2d<float, access::write> output [[texture(0)]],
                                     const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                                     constant Data &data [[buffer(0)]],
                                     constant ObjectPos &objectPos [[buffer(1)]],
                                     device Layers2 *layers [[buffer(2)]],
                                     ushort2 id [[thread_position_in_grid]],
                                     ushort2 groupId [[threadgroup_position_in_grid]],
                                     ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }
    
    float3 color0 = float3(data.backgroundRed, data.backgroundGreen, data.backgroundBlue);
    float2 point = float2(id);
    color0 = moreColors(data, color0, point);
    float4 color = float4(color0, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer[0] + 0.5);
    int objectNumber1 = int(layers[group].layer[1] + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }
    if (objectNumber1 < MAX_OBJECTS) {
        color = getColor(objectNumber1, color, input[objectNumber1], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

//compute 3 layers
kernel void compute3Layers(texture2d<float, access::write> output [[texture(0)]],
                           const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                           constant Data &data [[buffer(0)]],
                           constant ObjectPos &objectPos [[buffer(1)]],
                           device Layers3 *layers [[buffer(2)]],
                           ushort2 id [[thread_position_in_grid]],
                           ushort2 groupId [[threadgroup_position_in_grid]],
                           ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }

    float4 color = float4(data.backgroundRed, data.backgroundGreen, data.backgroundBlue, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer[0] + 0.5);
    int objectNumber1 = int(layers[group].layer[1] + 0.5);
    int objectNumber2 = int(layers[group].layer[2] + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }
    if (objectNumber1 < MAX_OBJECTS) {
        color = getColor(objectNumber1, color, input[objectNumber1], objectPos, id);
    }
    if (objectNumber2 < MAX_OBJECTS) {
        color = getColor(objectNumber2, color, input[objectNumber2], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

//compute 3 layers more colors
kernel void compute3LayersContinuous(texture2d<float, access::write> output [[texture(0)]],
                                     const array<texture2d<float, access::read>, MAX_OBJECTS> input [[texture(1)]],
                                     constant Data &data [[buffer(0)]],
                                     constant ObjectPos &objectPos [[buffer(1)]],
                                     device Layers3 *layers [[buffer(2)]],
                                     ushort2 id [[thread_position_in_grid]],
                                     ushort2 groupId [[threadgroup_position_in_grid]],
                                     ushort2 numberOfGroups [[threadgroups_per_grid]])
{
    float2 sizeDisp = float2(output.get_width(), output.get_height());
    if (id.x >= sizeDisp.x || id.y >= sizeDisp.y) {
        return;
    }
    
    float3 color0 = float3(data.backgroundRed, data.backgroundGreen, data.backgroundBlue);
    float2 point = float2(id);
    color0 = moreColors(data, color0, point);
    float4 color = float4(color0, 1);

    ushort group = groupId.y * numberOfGroups.x + groupId.x;

    int objectNumber0 = int(layers[group].layer[0] + 0.5);
    int objectNumber1 = int(layers[group].layer[1] + 0.5);
    int objectNumber2 = int(layers[group].layer[2] + 0.5);

    if (objectNumber0 < MAX_OBJECTS) {
        color = getColor(objectNumber0, color, input[objectNumber0], objectPos, id);
    }
    if (objectNumber1 < MAX_OBJECTS) {
        color = getColor(objectNumber1, color, input[objectNumber1], objectPos, id);
    }
    if (objectNumber2 < MAX_OBJECTS) {
        color = getColor(objectNumber2, color, input[objectNumber2], objectPos, id);
    }

    float3 newColor = pow(color.xyz, data.inversGammaCorrection);

    output.write(float4(newColor, 1), id);
}

