using Godot;
using System;

public class ColorRectTex : ColorRect
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.

    float start = 0.0f;
    public override void _Ready()
    {

    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        start += delta;
        ShaderMaterial shaderMaterial = (ShaderMaterial)Material;
        shaderMaterial.SetShaderParam("v1", start );
        shaderMaterial.SetShaderParam("v1", start * 2.0f);
        shaderMaterial.SetShaderParam("v1", start * 3.0f);
    }
}
