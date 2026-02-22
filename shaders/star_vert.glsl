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

// sRGB to linear conversion (inverse of the passthrough_frag's to_srgb)
vec3 srgb_to_linear(vec3 c)
{
    vec3 low = c / 12.92;
    vec3 high = pow((c + 0.055) / 1.055, vec3(2.4));
    return mix(low, high, step(vec3(0.04045), c));
}

void main(void)
{
    float br0 = pow(10.0, 0.4 * in_PointSize) * exposure;

    // in_Color arrives as sRGB because Color class stores 8-bit sRGB values.
    // We must convert to linear so that:
    //   1. The discriminator compares correct physical brightness
    //   2. The fragment output is linear, matching passthrough_frag's to_srgb()
    vec3 raw_color = srgb_to_linear(in_Color.rgb);

    // Normalize so that max component = 1.0
    vec3 color = raw_color / max(raw_color.r, max(raw_color.g, raw_color.b));

    // Apply saturation correction
    float delta = color_saturation_limit - min(color.r, min(color.g, color.b));
    if (delta > 0.0)
    {
        vec3 diff = vec3(1.0) - color;
        color += diff * diff * delta;
    }

    vec3 scaled_color = color * br0;

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
