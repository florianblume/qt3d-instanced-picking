#version 150 core

// copy of phong.frag from qt3d extras

uniform vec4 id_color;
flat in uint id;

out vec4 fragColor;

#pragma include light.inc.frag

void main()
{
    // Mask the respective components and shift it to the right to make the values take on numbers between 0 and 255
    // Then divide by 255.f to make the numbers be between 0 and 1 because that's what the shader expects as output
    fragColor = vec4(((id & uint(0xFF000000)) >> 24) / 255.f, ((id & uint(0xFF0000)) >> 16) / 255.f, ((id & uint(0xFF00)) >> 8) / 255.f, (id & uint(0xFF)) / 255.f);
}
