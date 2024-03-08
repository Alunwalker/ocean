using System;
using System.Linq.Expressions;
using Godot;
public class Perlin
{

    const int n_bits = 5;
    const int n_size = (1 << (n_bits - 1)); //16
    const int n_size_m1 = (n_size - 1); //15
    const int n_size_sq = (n_size * n_size); //256
    const int n_size_sq_m1 = (n_size_sq - 1);
    const int n_packsize = 4;
    const int np_bits = (n_bits + n_packsize - 1);
    const int np_size = (1 << (np_bits - 1)); //128
    const int np_size_m1 = (np_size - 1);
    const int np_size_sq = (np_size * np_size);
    const int np_size_sq_m1 = (np_size_sq - 1);
    const int n_dec_bits = 12;
    const int n_dec_magn = 4096;
    const int n_dec_magn_m1 = 4095;
    const int max_octaves = 32;
    const int noise_frames = 256;
    const int noise_frames_m1 = (noise_frames - 1);
    const int noise_decimalbits = 15;
    const int noise_magnitude = (1 << (noise_decimalbits - 1));
    const int scale_decimalbits = 15;
    const int scale_magnitude = (1 << (scale_decimalbits - 1));

    int[] noise = new int[n_size_sq * noise_frames];
    int[] o_noise = new int[n_size_sq * max_octaves];
    int[] p_noise = new int[np_size_sq * (max_octaves >> (n_packsize - 1))];
    int[] r_noise;
    float magnitude = n_dec_magn * 0.085f;

    public bool _def_PackedNoise { get; set; } = true;

    public struct PerlinOptions
    {
        public int Octaves { get; set; }
        public float Falloff { get; set; }
        public float Timemulti { get; set; }

        public float Scale { get; set; }



    }

    public PerlinOptions mOptions { get; set; }

    public void _initNoise()
    {
        // Create noise (uniform)
        float[] tempnoise = new float[n_size_sq * noise_frames];
        float temp;

        int i, frame, v, u,
            v0, v1, v2, u0, u1, u2, f;
        var random = new Random();
        for (i = 0; i < (n_size_sq * noise_frames); i++)
        {

            temp = random.Next(32767) / 32767.0f;
            tempnoise[i] = 4 * (temp - 0.5f);
        }

        for (frame = 0; frame < noise_frames; frame++)
        {
            for (v = 0; v < n_size; v++)
            {
                for (u = 0; u < n_size; u++)
                {
                    v0 = ((v - 1) & n_size_m1) * n_size;
                    v1 = v * n_size;
                    v2 = ((v + 1) & n_size_m1) * n_size;
                    u0 = ((u - 1) & n_size_m1);
                    u1 = u;
                    u2 = ((u + 1) & n_size_m1);
                    f = frame * n_size_sq;

                    temp = (1.0f / 14.0f) *
                       (tempnoise[f + v0 + u0] + tempnoise[f + v0 + u1] + tempnoise[f + v0 + u2] +
                        tempnoise[f + v1 + u0] + 6.0f * tempnoise[f + v1 + u1] + tempnoise[f + v1 + u2] +
                        tempnoise[f + v2 + u0] + tempnoise[f + v2 + u1] + tempnoise[f + v2 + u2]);

                    noise[frame * n_size_sq + v * n_size + u] = (int)(noise_magnitude * temp);
                }
            }
        }
    }

    float time;
    public void _calculeNoise(float timeFromLastFrame)
    {
        time += timeFromLastFrame;
        int i, o, v, u;
        int[] multitable = new int[max_octaves];
        int[] amount = new int[3];

        int iImage;

        uint[] image = new uint[3];

        float sum = 0.0f;
        float[] f_multitable = new float[max_octaves];


        double dImage, fraction;

        // calculate the strength of each octave
        for (i = 0; i < mOptions.Octaves; i++)
        {
            f_multitable[i] = Mathf.Pow(mOptions.Falloff, 1.0f * i);
            sum += f_multitable[i];
        }

        for (i = 0; i < mOptions.Octaves; i++)
        {
            f_multitable[i] /= sum;
        }

        for (i = 0; i < mOptions.Octaves; i++)
        {
            multitable[i] = (int)(scale_magnitude * f_multitable[i]);
        }

        double r_timemulti = 1.0;
        const float PI_3 = Mathf.Pi / 3;

        for (o = 0; o < mOptions.Octaves; o++)
        {
            dImage = Mathf.Floor(time * r_timemulti);
            fraction = time * r_timemulti - dImage;
            iImage = (int)dImage;

            amount[0] = (int)(scale_magnitude * f_multitable[o] * (Math.Pow(Math.Sin((fraction + 2) * PI_3), 2) / 1.5));
            amount[1] = (int)(scale_magnitude * f_multitable[o] * (Math.Pow(Math.Sin((fraction + 1) * PI_3), 2) / 1.5));
            amount[2] = (int)(scale_magnitude * f_multitable[o] * (Math.Pow(Math.Sin((fraction) * PI_3), 2) / 1.5));

            image[0] = (uint)((iImage) & noise_frames_m1);
            image[1] = (uint)((iImage + 1) & noise_frames_m1);
            image[2] = (uint)((iImage + 2) & noise_frames_m1);

            for (i = 0; i < n_size_sq; i++) //256
            {
                o_noise[i + n_size_sq * o] = (
                   ((amount[0] * noise[i + n_size_sq * image[0]]) >> scale_decimalbits) +
                   ((amount[1] * noise[i + n_size_sq * image[1]]) >> scale_decimalbits) +
                   ((amount[2] * noise[i + n_size_sq * image[2]]) >> scale_decimalbits));
            }

            r_timemulti *= mOptions.Timemulti;
        }

        if (_def_PackedNoise)
        {
            int octavepack = 0;
            for (o = 0; o < mOptions.Octaves; o += n_packsize)
            {
                for (v = 0; v < np_size; v++)  //128
                {
                    for (u = 0; u < np_size; u++)
                    {
                        p_noise[v * np_size + u + octavepack * np_size_sq] = o_noise[(o + 3) * n_size_sq + (v & n_size_m1) * n_size + (u & n_size_m1)];
                        p_noise[v * np_size + u + octavepack * np_size_sq] += _mapSample(u, v, 3, o);
                        p_noise[v * np_size + u + octavepack * np_size_sq] += _mapSample(u, v, 2, o + 1);
                        p_noise[v * np_size + u + octavepack * np_size_sq] += _mapSample(u, v, 1, o + 2);
                    }
                }

                octavepack++;
            }
        }
    }

    int _mapSample(int u, int v, int upsamplepower, int octave)
    {
        int magnitude = 1 << upsamplepower,

            pu = u >> upsamplepower,
            pv = v >> upsamplepower,

            fu = u & (magnitude - 1),
            fv = v & (magnitude - 1),

            fu_m = magnitude - fu,
            fv_m = magnitude - fv,

            o = fu_m * fv_m * o_noise[octave * n_size_sq + ((pv) & n_size_m1) * n_size + ((pu) & n_size_m1)] +
                fu * fv_m * o_noise[octave * n_size_sq + ((pv) & n_size_m1) * n_size + ((pu + 1) & n_size_m1)] +
                fu_m * fv * o_noise[octave * n_size_sq + ((pv + 1) & n_size_m1) * n_size + ((pu) & n_size_m1)] +
                fu * fv * o_noise[octave * n_size_sq + ((pv + 1) & n_size_m1) * n_size + ((pu + 1) & n_size_m1)];

        return o >> (upsamplepower + upsamplepower);
    }

    int _readTexelLinearDual(int u, int v, int o)
    {
        int iu, iup, iv, ivp, fu, fv,
            ut01, ut23, ut;

        iu = (u >> n_dec_bits) & np_size_m1;
        iv = ((v >> n_dec_bits) & np_size_m1) * np_size;

        iup = ((u >> n_dec_bits) + 1) & np_size_m1;
        ivp = (((v >> n_dec_bits) + 1) & np_size_m1) * np_size;

        fu = u & n_dec_magn_m1;
        fv = v & n_dec_magn_m1;

        ut01 = ((n_dec_magn - fu) * r_noise[octave + iv + iu] + fu * r_noise[octave + iv + iup]) >> n_dec_bits;
        ut23 = ((n_dec_magn - fu) * r_noise[octave + ivp + iu] + fu * r_noise[octave + ivp + iup]) >> n_dec_bits;
        ut = ((n_dec_magn - fv) * ut01 + fv * ut23) >> n_dec_bits;

        return ut;
    }

    int octave = 0;
    float _getHeigthDual(float u, float v)
    {
        // Pointer to the current noise source octave	
        r_noise = p_noise;
        octave = 0;
        int ui = (int)(u * magnitude),
            vi = (int)(v * magnitude),
            i,
            value = 0,
            hoct = mOptions.Octaves / n_packsize;

        for (i = 0; i < hoct; i++)
        {
            value += _readTexelLinearDual(ui, vi, 0);
            ui = ui << n_packsize;
            vi = vi << n_packsize;
            octave += np_size_sq;
        }

        return (float)value / (float)noise_magnitude;
    }
    public float GetValue(float x, float y)
    {
        return _getHeigthDual(x, y);
    }

    public void genNoiseImage()
    {
        Image image = new Image();
        image.Create((int)np_size, (int)np_size, false, Image.Format.Rgbaf);
        image.Lock();
        for (int i = 0; i < np_size; i++)
        {
            for (int j = 0; j < np_size; j++)
            {
                // image.SetPixel(j, i, new Color(p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f));
                var v = _getHeigthDual(j, i);
                image.SetPixel(j, i, new Color(v, v, v));
            }
        }
        image.Unlock();
        image.SavePng("noise.png");
        // image.SavePng($"inscatterImage/inscatter{d}.png");
    }

    public Texture3D gen3DNoiseImage()
    {
       int count = 0;
       Texture3D texture = new Texture3D();
       texture.Create(np_size, np_size, 600, Image.Format.Rgbaf, 7);
        while (true)
        {
            _calculeNoise(0.016f);
            Image image = new Image();
            image.Create((int)np_size, (int)np_size, false, Image.Format.Rgbaf);
            image.Lock();
            for (int i = 0; i < np_size; i++)
            {
                for (int j = 0; j < np_size; j++)
                {
                    // image.SetPixel(j, i, new Color(p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f));
                    var v = GetValue(j, i);
                    image.SetPixel(j, i, new Color(v, v, v));
                }
            }
            image.Unlock();
            // image.SavePng("noise" + count + ".png");
            texture.SetLayerData(image, count);
            texture.SetLayerData(image, 599 - count);
            count++;
            if(count >= 300)
            {
                break;
            }
        }
        return texture;
    }

    public Texture GetTexture()
    {

        Image image = new Image();
        image.Create((int)np_size, (int)np_size, false, Image.Format.Rgbaf);
        image.Lock();
        for (int i = 0; i < np_size; i++)
        {
            for (int j = 0; j < np_size; j++)
            {
                // image.SetPixel(j, i, new Color(p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f, p_noise[np_size * i + j] / 255.0f));
                var v = _getHeigthDual(j, i);
                image.SetPixel(j, i, new Color(v, v, v));
            }
        }
        image.Unlock();
        ImageTexture noiseTex = new ImageTexture();
        noiseTex.CreateFromImage(image);
        return noiseTex;
    }
}