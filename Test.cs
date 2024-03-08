using Godot;
using System;

// [Tool]
public class Test : Spatial
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.

    ShaderMaterial mtl;
    OpenSimplexNoise noise;

    Perlin perlin = new Perlin();
    public override void _Ready()
    {
        var meshins = GetNode<MeshInstance>("MeshInstance");

        mtl = (ShaderMaterial)meshins.GetSurfaceMaterial(0);



        var mOptions = new Perlin.PerlinOptions
        {
            Octaves = 8,
            Falloff = 0.490f,
            Timemulti = 1.27f,
            Scale = 0.085f
        };
        perlin.mOptions = mOptions;
        perlin._initNoise();
        // perlin._calculeNoise(timeFromLastFrame);
        // float f = 2.25f;
        // var window = World.Instance.DefaultCamera.GetViewport().Size;

        // var array = ((ArrayMesh)(Ocean.Mesh)).SurfaceGetArrays(0);
        // var vertexCom = array[0];
        // int NX = (int)(f * window.x / resolution);
        // int NY = (int)(f * window.y / resolution);
        // Vector3[] vertexs = new Vector3[NX * NY]
        // perlin._calculeNoise(DateTime.Now.Ticks);
        // var noise = perlin.GetTexture();
        // oceanMaterial.SetShaderParam("noiseSampler", noise);

        var noise3D = perlin.gen3DNoiseImage();
        mtl.SetShaderParam("noiseSampler3D", noise3D);

    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        // noise.Seed = (int)OS.GetTicksMsec();
        // var image = noise.GetSeamlessImage(256);
        // ImageTexture texture = new ImageTexture();
        // texture.CreateFromImage(image);
        // mtl.SetShaderParam("noise", texture);


    }
}
