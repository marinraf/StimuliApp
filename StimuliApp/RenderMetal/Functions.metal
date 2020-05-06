//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

#include <metal_stdlib>
#import "LokiHeader.metal"
using namespace metal;

//constant float PHI = 1.61803398874989484820459 * 00000.1; // Golden Ratio
//constant float PI  = 3.14159265358979323846264 * 00000.1; // PI
//constant float SQ2 = 1.41421356237309504880169 * 10000.0; // Square Root of Two

constant float CONSTANT = 0.003922; // 1/255

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

struct Particle {
    float type;
    float duration;
    float positionX;
    float positionY;
};

//get random
float getRandom(float2 p, float seed) {
    return fract(6791.0 * sin(47.0 * p.x + 9973.0 * p.y + seed));
}

//old version, think the randomness is better but produces artifacts and it is slower
//float getRandom(float2 p, float seed) {
//    return fract(tan(distance(p * (seed + PHI), float2(PHI, PI))) * SQ2);
//}


//normalise angle (0, 2pi)
float normaliseAngle(float angle)
{
    float x = angle - int(angle / (2 * M_PI_F)) * (2 * M_PI_F);
    if (x < 0) {
        x += (2 * M_PI_F);
    }
    return x;
}

//get angle
float getAngle(float2 point)
{
    float angle = atan2(point.y, point.x);

    return normaliseAngle(angle);
}

//rotate
float2 rotate(float2 point, float rotation)
{
    float finalPointX = point.x * cos(rotation) + point.y * sin(rotation);
    float finalPointY = -point.x * sin(rotation) + point.y * cos(rotation);
    
    return float2(finalPointX, finalPointY);
}

//calculate position
//from ushort2 with center: left, up and directions: right, bottom
//to float2 with center: center, center and directions: right, top
float2 calculatePosition(ushort2 id, float2 center, float rotation, float2 size)
{
    float2 point = float2(id.x - size.x / 2 - center.x, -id.y + size.y / 2 - center.y);
    float2 finalPoint = rotate(point, rotation);
    return finalPoint;
}

//calculate position image
//from float2 with center: center, center and directions: right, top
//to int2 with center: left, up and directions: right, bottom
int2 calculatePositionImage(float2 point, float2 center, float rotation, float2 size)
{
    float2 newPoint = rotate(point, rotation);
    float2 finalPoint = float2(newPoint.x + size.x / 2 - center.x, -newPoint.y + size.y / 2 + center.y);
    return int2(finalPoint + float2(0.5, 0.5));
}

//change position
//from float2 with center: center, center and directions: right, top
//to float2 with center: center, center and directions: right, top
float2 changePosition(float2 point, float2 displacement, float rotation)
{
    float2 newPoint = point - displacement;
    float2 finalPoint = rotate(newPoint, rotation);
    return finalPoint;
}


//rectangle
ushort rectangle(Object object, float2 point)
{
    float xSize1 = object.xSize / 2;
    float xSize2 = xSize1 + object.borderDistance;
    float xSize3 = xSize2 + object.borderThickness;
    
    float ySize1 = object.ySize / 2;
    float ySize2 = ySize1 + object.borderDistance;
    float ySize3 = ySize2 + object.borderThickness;
    
    bool inside1 = abs(point.x) < xSize1 && abs(point.y) < ySize1;
    bool inside2 = abs(point.x) < xSize2 && abs(point.y) < ySize2;
    bool inside3 = abs(point.x) < xSize3 && abs(point.y) < ySize3;
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
}

//ellipse
ushort ellipse(Object object, float2 point)
{
    float xRadius1 = object.xSize / 2;
    float xRadius2 = xRadius1 + object.borderDistance;
    float xRadius3 = xRadius2 + object.borderThickness;
    
    float yRadius1 = object.ySize / 2;
    float yRadius2 = yRadius1 + object.borderDistance;
    float yRadius3 = yRadius2 + object.borderThickness;
    
    bool inside1 = pow(point.x, 2) / pow(xRadius1, 2) + pow(point.y, 2) / pow(yRadius1, 2) < 1;
    bool inside2 = pow(point.x, 2) / pow(xRadius2, 2) + pow(point.y, 2) / pow(yRadius2, 2) < 1;
    bool inside3 = pow(point.x, 2) / pow(xRadius3, 2) + pow(point.y, 2) / pow(yRadius3, 2) < 1;
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
}

//cross
ushort cross(Object object, float2 point)
{
    float size1 = object.xSize / 2;
    float size2 = size1 + object.borderDistance;
    float size3 = size2 + object.borderThickness;
    
    float thickness1 = object.ySize / 2;
    float thickness2 = thickness1 + object.borderDistance;
    float thickness3 = thickness2 + object.borderThickness;
    
    bool inside1a = abs(point.x) < size1 && abs(point.y) < thickness1;
    bool inside1b = abs(point.y) < size1 && abs(point.x) < thickness1;
    bool inside2a = abs(point.x) < size2 && abs(point.y) < thickness2;
    bool inside2b = abs(point.y) < size2 && abs(point.x) < thickness2;
    bool inside3a = abs(point.x) < size3 && abs(point.y) < thickness3;
    bool inside3b = abs(point.y) < size3 && abs(point.x) < thickness3;
    
    bool inside1 = inside1a || inside1b;
    bool inside2 = inside2a || inside2b;
    bool inside3 = inside3a || inside3b;
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
}

//inside polygon
bool insidePolygon(float radius, float radiusCircle, float apothem, int sides, float2 point)
{
    if (radius < radiusCircle * apothem) {
        return true;
    }
    int result = 1;
    int positive = 0;
    int negative = 0;
    float cosine = 0;
    float sine = 1;
    float cosine2 = 0;
    float sine2 = 1;
    
    for(int i = 0; i < sides; i++) {
        int i2 = (i < sides - 1) ? i + 1 : 0;
        
        cosine = cosine2;
        sine = sine2;
        
        cosine2 = cos(2 * M_PI_F * i2 / sides + M_PI_F / 2);
        sine2 = sin(2 * M_PI_F * i2 / sides + M_PI_F / 2);
        
        float x1 = radiusCircle * cosine;
        float y1 = radiusCircle * sine;
        
        float x2 = radiusCircle * cosine2;
        float y2 = radiusCircle * sine2;
        
        float d = (point.x - x1) * (y2 - y1) - (point.y - y1) * (x2 - x1);
        
        if (d > 0) positive++;
        if (d < 0) negative++;
        
        if (positive > 0 && negative > 0) {
            result = 0;
            return false;
        }
    }
    return (result == 1) ? true: false;
}

//polygon
ushort polygon(Object object, float2 point)
{
    float radius1 = object.xSize / 2;
    float radius2 = radius1 + object.borderDistance;
    float radius3 = radius2 + object.borderThickness;
    int sides = int(object.ySize + 0.5);
    float radius = length(point);
    float apothem = cos(M_PI_F / sides);
    
    if (sides < 3 || sides > 10) {
        return 2;
    }
    
    bool inside1 = insidePolygon(radius, radius1, apothem, sides, point);
    bool inside2 = insidePolygon(radius, radius2, apothem, sides, point);
    bool inside3 = insidePolygon(radius, radius3, apothem, sides, point);
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
}

//ring
ushort ring(Object object, float2 point)
{
    float radius = length(point);
    
    float radiusExt1 = object.xSize / 2;
    float radiusExt2 = radiusExt1 + object.borderDistance;
    float radiusExt3 = radiusExt2 + object.borderThickness;
    
    float radiusInt1 = object.ySize / 2;
    float radiusInt2 = radiusInt1 + object.borderDistance;
    float radiusInt3 = radiusInt2 + object.borderThickness;
    
    bool inside1 = radius < radiusExt1 && radius > radiusInt1;
    bool inside2 = radius < radiusExt2 && radius > radiusInt2;
    bool inside3 = radius < radiusExt3 && radius > radiusInt3;
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
    
}

//wedge
ushort wedge(Object object, float2 point)
{
    float radius = length(point);
    float angle = getAngle(point);
    
    float angleSize = object.ySize;
    
    if (angle >= angleSize) {
        return 2;
    }
    
    float radius1 = object.xSize / 2;
    float radius2 = radius1 + object.borderDistance;
    float radius3 = radius2 + object.borderThickness;
    
    bool inside1 = radius < radius1;
    bool inside2 = radius < radius2;
    bool inside3 = radius < radius3;
    
    if (inside3 && !inside2) {
        return 1;
    } else if (inside1) {
        return 0;
    } else {
        return 2;
    }
}

//get inside
ushort getInside(Object object, float2 point, ushort shape)
{
    if (shape == 0) {
        return rectangle(object, point);
    } else if (shape == 1) {
        return ellipse(object, point);
    } else if (shape == 2) {
        return cross(object, point);
    } else if (shape == 3) {
        return polygon(object, point);
    } else if (shape == 4) {
        return ring(object, point);
    } else if (shape == 5) {
        return wedge(object, point);
    } else {
        return 2;
    }
}

//perlin noise
float perlinNoise(float2 p, float sharp, float seed)
{
    float2 i = floor(p * sharp);
    float2 f = fract(p * sharp);

    float a = getRandom(i, seed);
    float b = getRandom(i + float2(1.0, 0.0), seed);
    float c = getRandom(i + float2(0.0, 1.0), seed);
    float d = getRandom(i + float2(1.0, 1.0), seed);
    
    float2 u  = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) +
    (c - a)* u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

//calculate noise
float3 calculateNoise(Object object, Data data, float3 color0, float2 point)
{
    float3 color;
    int noiseType = int(object.noiseType + 0.5);
    float noiseValue = object.noiseValue;
    float noiseTimePeriod = object.noiseTimePeriod;
    float noisePosX = object.noisePosX;
    float noisePosY = object.noisePosY;
    float rotation = object.noiseRotation;
    float noiseSizeX = object.noiseSizeX;
    float noiseSizeY = object.noiseSizeY;
    
    if (noiseType == 0) {
        color = color0;

    } else if (noiseType == 1) { //gaussian noise

        float2 displacement = float2(noisePosX, noisePosY);
        float2 position = changePosition(point, displacement, rotation);
        
        int valuex = position.x > 0 ? 1 : 0;
        int valuey = position.y > 0 ? 1 : 0;
        int x = int(position.x / noiseSizeX + valuex);
        int y = int(position.y / noiseSizeY + valuey);
        int z = (int(data.timeInFrames / data.frameRate / noiseTimePeriod) + 1) * data.randomSeedInitial;
        
        Loki rng = Loki(x, y, z);
        float random1 = rng.rand();
        float random2 = rng.rand();
        
        float randomValue = sqrt(-2 * log(random1)) * cos(2 * M_PI_F * random2) * noiseValue;
        
        color = color0 + float3(randomValue);

    } else if (noiseType == 2) { //perlin noise
        
        float2 displacement = float2(noisePosX, noisePosY);
        float2 position = changePosition(point, displacement, rotation);
        
        float z = (int(data.timeInFrames / data.frameRate / noiseTimePeriod) + 1) * data.randomSeedInitial / 10000;
        
        float sharp = (1 - noiseSizeX) * 30;

        float maxSize = max(object.xSize, object.ySize);
        
        float2 uv = float2(position) / float2(maxSize);
        
        float randomValue = (perlinNoise(uv, sharp, z) - 0.5) * noiseValue;;
        
        color = color0 + float3(randomValue);

    } else {
        color = color0;

    }
    return saturate(color);
}

//more colors option
float3 moreColors(Data data, float3 color0, float2 point)
{
    if (data.moreColors > 0.5) {
        float x = abs(point.x);
        float y = abs(point.y);
        float z = data.randomSeed;
        Loki rng = Loki(x, y, z);
        float random = rng.rand() * 2.0 - 1.0;

        color0 = float3(color0 + random * CONSTANT);
    }

    return color0;
}

//final color
float4 finalColor(Object object, Data data, float4 color0, float2 point)
{
    float3 newColor = calculateNoise(object, data, color0.xyz, point);
    int contrastType = int(object.contrastType + 0.5);
    int modulatorType = int(object.modulatorType + 0.5);
    float maximumRadius = object.xSize / 2;
    
    float alpha = color0.w * object.contrastValue;


    newColor = moreColors(data, newColor, point);

    
    // the contrast gaussian envelope or cosine envelope
    if (contrastType == 1) {
        alpha *= exp(-(pow(length(point), 2)) / (2 * pow(object.contrastEnvelope, 2)));
        
    } else if (contrastType == 2) {
        float radius = length(point);
        float minimumRadius = maximumRadius * object.contrastEnvelope;
        if (radius > maximumRadius) {
            alpha = 0;
        } else if (radius > minimumRadius) {
            alpha *= cos(M_PI_F / 2 * (radius - minimumRadius) / (maximumRadius - minimumRadius));
        }
    }
    
    // the sinusoidal contrast modulator
    if (modulatorType == 1) {
        float2 position = rotate(point, object.modulatorRotation);
        alpha *= 0.5 + object.modulatorAmplitude / 2 *
        sin((2 * M_PI_F / object.modulatorPeriod * position.x) - object.modulatorPhase);
    }
    
    return float4(newColor, alpha);
}


//final color
float4 finalColor(Object object, Data data, float3 color0, float2 point)
{
    float3 newColor = calculateNoise(object, data, color0, point);
    int contrastType = int(object.contrastType + 0.5);
    int modulatorType = int(object.modulatorType + 0.5);
    float maximumRadius = object.xSize / 2;

    float alpha = object.contrastValue;


    newColor = moreColors(data, newColor, point);


    // the contrast gaussian envelope or cosine envelope
    if (contrastType == 1) {
        alpha *= exp(-(pow(length(point), 2)) / (2 * pow(object.contrastEnvelope, 2)));

    } else if (contrastType == 2) {
        float radius = length(point);
        float minimumRadius = maximumRadius * object.contrastEnvelope;
        if (radius > maximumRadius) {
            alpha = 0;
        } else if (radius > minimumRadius) {
            alpha *= cos(M_PI_F / 2 * (radius - minimumRadius) / (maximumRadius - minimumRadius));
        }
    }

    // the sinusoidal contrast modulator
    if (modulatorType == 1) {
        float2 position = rotate(point, object.modulatorRotation);
        alpha *= 0.5 + object.modulatorAmplitude / 2 *
        sin((2 * M_PI_F / object.modulatorPeriod * position.x) - object.modulatorPhase);
    }

    return float4(newColor, alpha);
}




//IMAGE
kernel void image(texture2d<float, access::write> output [[texture(0)]],
                  texture2d<float, access::read> input [[texture(1)]],
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
    float2 imageCenter = float2(object.variable1, object.variable2);
    float imageRotation = object.variable3;
    float2 imageSize = float2(input.get_width(), input.get_height());

    int2 point2 = calculatePositionImage(point, imageCenter, imageRotation, imageSize);

    float4 color = float4(0);

    if (point2.x >= 0 && point2.y >= 0 && point.x <= imageSize.x && point.y <= imageSize.y) {
        float4 color0 = input.read(ushort2(point2));
        color = finalColor(object, data, color0, point);
    }
    output.write(color, id);
}




//CLEAN (used before dots)
kernel void clean(texture2d<float, access::write> output [[texture(0)]],
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
    float4 color = float4(0);
    output.write(color, id);
}




//DOTS
kernel void dots(texture2d<float, access::write> output [[texture(0)]],
                 constant Data &data [[buffer(0)]],
                 constant Object &object [[buffer(1)]],
                 device Particle *particles [[buffer(2)]],
                 uint idDot [[thread_position_in_grid]])
{
    Particle particle = particles[idDot];

    float screenMaxSize = max(data.screenWidth, data.screenHeight);

    float type = particle.type;
    float initialDuration = particle.duration;
    float duration = particle.duration;
    float2 position = float2(particle.positionX, particle.positionY);

    uint number = uint(object.variable0 + 0.5);
    float coherence = object.variable1;

    float dotsLife1 = max(object.variable2 * data.frameRate, 1.0);
    float radius1 = object.variable3 / 2;
    int directionType1 = int(object.variable4 +0.5);
    float distance1 = object.variable5;
    float direction1 = object.variable6;
    float3 color1 = float3(object.variable7, object.variable8, object.variable9);

    float dotsLife2 = max(object.variable10 * data.frameRate, 1.0);
    float radius2 = object.variable11 / 2;
    int directionType2 = int(object.variable12 +0.5);
    float distance2 = object.variable13;
    float direction2 = object.variable14;
    float3 color2 = float3(object.variable15, object.variable16, object.variable17);

    float radius;
    float directionType;
    float direction;
    float speedX;
    float speedY;
    float speedAngular;
    float3 color0;
    float dotsLife;

    int2 pos = int2(position.x * screenMaxSize, position.y * screenMaxSize);

    if (idDot >= number) {
        return;
    }

    Loki rng = Loki(idDot, data.randomSeed, 0);
    float random1 = rng.rand();
    float random2 = rng.rand();

    Loki rng2 = Loki(idDot, 1, 0);
    float random3 = rng2.rand() * 2 - 1;
    float random4 = rng2.rand() * 2 - 1;

    if (type < coherence) {
        dotsLife = dotsLife1;
        radius = radius1;
        directionType = directionType1;
        direction = direction1;
        speedAngular = data.status * distance1 / dotsLife;
        speedX = data.status * distance1 / screenMaxSize / dotsLife;
        speedY = data.status * distance1 / screenMaxSize / dotsLife;
        color0 = color1;
    } else {
        dotsLife = dotsLife2;
        radius = radius2;
        directionType = directionType2;
        direction = direction2;
        speedAngular = data.status * distance2 / dotsLife;
        speedX = data.status * distance2 / screenMaxSize / dotsLife;
        speedY = data.status * distance2 / screenMaxSize / dotsLife;
        color0 = color2;
    }

    duration = fmod(data.timeInFrames + (initialDuration * dotsLife), dotsLife) / dotsLife;

    if (duration < (1 / dotsLife)) {
        position.x = random1;
        position.y = random2;
    }

    if (directionType == 0) { //random
        position.x += random3 * speedX;
        position.y += random4 * speedY;
    } else if (directionType == 1) { //fixed
        position.x += cos(direction) * speedX;
        position.y += -sin(direction) * speedY;
    } else if (directionType == 2) { //center
        float2 point = float2(float(pos.x) - screenMaxSize / 2, float(pos.y) - screenMaxSize / 2);
        float directionPoint = getAngle(point);
        float directionPoint2 = normaliseAngle(directionPoint + M_PI_F);
        position.x += cos(directionPoint2) * speedX;
        position.y += sin(directionPoint2) * speedY;
    } else if (directionType == 3) { //away from the center
        float2 point = float2(float(pos.x) - screenMaxSize / 2, float(pos.y) - screenMaxSize / 2);
        float directionPoint = getAngle(point);
        float directionPoint2 = normaliseAngle(directionPoint);
        position.x += cos(directionPoint2) * speedX;
        position.y += sin(directionPoint2) * speedY;
    } else if (directionType == 4) { //clockwise
        float2 point = float2(position.x - 0.5, position.y - 0.5);
        float radius = length(point);
        float angle = getAngle(point);
        float newAngle = normaliseAngle(angle + speedAngular);
        position.x = cos(newAngle) * radius + 0.5;
        position.y = sin(newAngle) * radius + 0.5;
    } else if (directionType == 5) { //counterclockwise
        float2 point = float2(position.x - 0.5, position.y - 0.5);
        float radius = length(point);
        float angle = getAngle(point);
        float newAngle = normaliseAngle(angle - speedAngular);
        position.x = cos(newAngle) * radius + 0.5;
        position.y = sin(newAngle) * radius + 0.5;
    }

    if (position.x < 0 || position.x > 1) {
        position.x = random1;
    }

    if (position.y < 0 || position.y > 1) {
        position.y = random2;
    }

    particle.positionX = position.x;
    particle.positionY = position.y;
    particles[idDot] = particle;

    float2 maxSize = float2(output.get_width(), output.get_height());
    float2 center = float2(object.xCenter, object.yCenter);
    float rotation = float(object.rotation);

    float displacementX = float(((screenMaxSize - maxSize.x) / 2) - center.x);
    float displacementY = float(((screenMaxSize - maxSize.y) / 2) + center.y);

    float2 pos2;
    pos2 = float2(position.x - 0.5, position.y -0.5);
    pos2 = rotate(pos2, rotation);
    pos2 = float2(pos2.x + 0.5, pos2.y + 0.5);
    pos2 = float2(pos2.x * screenMaxSize - displacementX, pos2.y * screenMaxSize - displacementY);

    for(int i = -radius; i <= radius; i++) {
        for(int j = -radius; j <= radius; j++) {
            int2 newPos = int2(i, j);
            int2 point = int2(pos2) + newPos;

            if (length(float2(newPos)) < radius) {
                ushort2 id = ushort2(point);

                //position
                float2 point = calculatePosition(id, center, rotation, maxSize);
                //shape
                int shape = int(object.shape + 0.5);
                ushort inside = getInside(object, point, shape);
                //color
                if (inside > 0.5) {
                    float4 color = float4(0);
                    output.write(color, id);
                } else {
                    float4 color = finalColor(object, data, color0, point);
                    output.write(color, id);
                }
            }
        }
    }
}

