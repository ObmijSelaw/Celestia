const float degree_per_px = 0.01;
// empirical constants
const float a = 0.123;
const float k = 0.0016;
const float exposure = 1.0;

// py: max_square_size = 512 # px
const float max_square_size = 256.0;
// py: max_br = (degree_per_px * max_square_size / algorithms.a)**2 / (2*np.pi)
const float max_br = pow((degree_per_px * max_square_size / a), 2.0) / (2.0 * 3.141592653);

varying vec3 v_color;
varying float max_theta;
varying float pointSize;
varying float br;

attribute vec4 in_Position;
attribute vec3 in_Color;
attribute float in_PointSize;

const float color_saturation_limit = 0.1; // the ratio of the minimum color component to the maximum

//! Normalizes the color by its green value and corrects extreme saturation
vec3 green_normalization(vec3 color)
{
    // color /= max(color.r, max(color.g, color.b)); // we do this in XYZRGBConverter::convertUnnormalized()
    float delta = color_saturation_limit - min(color.r, min(color.g, color.b));

    if (delta > 0)
    {
        vec3 diff = vec3(1.0) - color;
        color += diff * diff * delta; // desaturating to the saturation limit
    }
    return color / color.g;
}

void main(void)
{
    float br0 = pow(10.0, 0.4 * in_PointSize) * exposure;
    
    // Normalize color so that max component = 1.0 (matching Python behavior)
    // NOT green_normalization, which forces g=1.0
    vec3 color = in_Color / max(in_Color.r, max(in_Color.g, in_Color.b));
    
    // Apply saturation correction if needed
    float delta = color_saturation_limit - min(color.r, min(color.g, color.b));
    if (delta > 0.0)
    {
        vec3 diff = vec3(1.0) - color;
        color += diff * diff * delta;
    }
    // DO NOT divide by color.g here!
    
    vec3 scaled_color = color * br0;
    
    // Now max(scaled_color) = br0, so this is equivalent to checking br0 < 1.0
    // But per-channel check also accounts for color, matching the Python exactly
    if (all(lessThan(scaled_color, vec3(1.0))))
    {
        // Dim star (3×3 px box mode)
        max_theta = -1.0;
        pointSize = 3.0;
        v_color = scaled_color;
    }
    else
    {
        // Bright star (glow mode)
        br = atan(br0 / max_br) * max_br;
        max_theta = a * sqrt(br);
        float half_sq = max_theta / degree_per_px;
        pointSize = 2.0 * half_sq - 1.0;
        v_color = color;
    }
    
    gl_PointSize = pointSize;
    set_vp(in_Position);
}
