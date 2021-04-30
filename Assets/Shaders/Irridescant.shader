Shader "Custom/Irridescant"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [Space(20)][Header(ColorMap)][Space(20)]
        _ColorMap("Colormap", 2D) = "color" {}
        _ColorBlend("BlendStrength", Range(0.1,1)) = 0.1


        [Space(20)][Header(BumpMap and BumpPower)][Space(20)]
        _BumpMap("Bumpmap", 2D) = "bump" {}
        _BumpPower("BumpPower",Range(0.1,1)) = 0.1
            
        [Space(20)][Header(Snells Law)][Space(20)]
        _N1("N1", Range(0.1,2)) = 1
        _N2("N2", Range(0.1,2)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _ColorMap;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_ColorMap;
            float2 uv_BumpMap;
            float3 viewDir;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        float _ColorBlend;
        float _BumpPower;
        fixed4 _Color;
        float _N1;
        float _N2;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

            ///the main function
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // IN.viewDir.rgb;

            // Albedo comes from a texture tinted by color

            /*
            * one of these is Snell's Law
            * conflicting sources
            float critical = asin((_N2 / _N1) * sin(IN.viewDir));*/
            float critical = (_N1 / _N2) * sin(IN.viewDir);
            

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            fixed3 colorMap = (tex2D(_ColorMap, IN.uv_ColorMap));
            normal.z /= _BumpPower;
            o.Normal = normalize(normal);
            o.Albedo = lerp(c, colorMap, _ColorBlend * critical);
            //o.Albedo = c.rgb * normal.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
