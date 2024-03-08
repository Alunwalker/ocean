using Godot;
using System;

public class ColorRectTex : ColorRect
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.

    float start = 0.0f;
    float time = 0f;
    public override void _Ready()
    {

    }
    Vector3 evolution = new Vector3(0, 0, 0);

    float fixedDeltaTime = 0.002f;
    float evolutionSpeed = 1.1f;
    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        start += delta;
        ShaderMaterial shaderMaterial = (ShaderMaterial)Material;
        // shaderMaterial.SetShaderParam("v1", start );
        // shaderMaterial.SetShaderParam("v1", start * 2.0f);
        // shaderMaterial.SetShaderParam("v1", start * 3.0f);

        time += delta;
        if (time % 3 < 1) {
            evolution.x += delta * evolutionSpeed * 1.0f;
            evolution.y += delta * evolutionSpeed * 0.75f;
            evolution.z += delta * evolutionSpeed * 0.5f;
        }
        else if (time % 3 < 2) {
            evolution.x += delta * evolutionSpeed * 0.75f;
            evolution.y += delta * evolutionSpeed * 1.0f;
            evolution.z += delta * evolutionSpeed * 0.5f;
        }
        else {
            evolution.x += delta * evolutionSpeed * 1.0f;
            evolution.y += delta * evolutionSpeed * 0.5f;
            evolution.z += delta * evolutionSpeed * 0.75f;
        }
        shaderMaterial.SetShaderParam("_Evolution", evolution);
        shaderMaterial.SetShaderParam("_RandomSeed", delta);

    }
}
