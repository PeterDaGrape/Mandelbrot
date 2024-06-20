//
//  Shaders.metal
//  MetalStart
//
//  Created by Peter Vine on 05/06/2024.
//

#include <metal_stdlib>
using namespace metal;


#include "definitions.h"

struct Fragment {
    
    float4 position [[position]];
    float4 colour;
    float2 complexPosition;
};

vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], unsigned int vid [[vertex_id]]) {
    
    Vertex input = vertexArray[vid];
    
    Fragment output;
    
    output.position = float4(input.position.x, input.position.y, 0, 1);

    
    output.complexPosition = input.complexPosition;
    return output;
}
fragment float4 fragmentShader(Fragment input [[stage_in]]) {
 
    float complexX = input.complexPosition.x;
    float complexY = input.complexPosition.y;

    uint16_t iterMax = 1000;
    
    float xn = 0;
    float yn = 0;

    int iteration = 0;

    for (; iteration < iterMax; iteration++){

        float nextxn = xn * xn - yn * yn + complexX;
        float nextyn = (2. * xn * yn) + complexY;

        xn = nextxn;
        yn = nextyn;



        if (xn*xn + yn*yn > 4.) {
            break;
        };
    };
    
    float r = 0;
    float g = 0;
    float b = 0;

    if (iteration < iterMax) {
    
        r = float(iteration * 20 % 255) / 255;
        g = float(iteration * 40 % 255) / 255;
        b = float(iteration * 60 % 255) / 255;

    }

    float4 colour = {r, g, b, 1};
    
    return colour;
}
