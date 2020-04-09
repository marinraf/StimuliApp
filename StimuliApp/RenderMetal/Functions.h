//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#ifndef Functions_h
#define Functions_h

typedef struct Data Data;
typedef struct Object Object;
float2 calculatePosition(ushort2 id, float2 center, float rotation, float2 size);
int2 calculatePositionImage(float2 point, float2 center, float rotation, float2 size);
float2 changePosition(float2 point, float2 displacement, float rotation);
float2 rotate(float2 point, float rotation);
ushort getInside(Object object, float2 point, ushort shape);
float getAngle(float2 point);
float normaliseAngle(float angle);
float4 finalColor(Object object, Data data, float4 color0, float2 point);
float4 finalColor(Object object, Data data, float3 color0, float2 point);
float3 moreColors(Data data, float3 color0, float2 point);

#endif
