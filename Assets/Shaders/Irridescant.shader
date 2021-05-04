Shader "Custom/Irridescant"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Alpha("Alpha", Range(0,1)) = 1

        [Space(20)][Header(ColorMap)][Space(20)]
        _ColorMap("ColorMap", 2D) = "color" {}
        _ColorBlend("BlendStrength", Range(0.1,1)) = 0.1


        [Space(20)][Header(BumpMap and BumpPower)][Space(20)]
        _BumpMap("BumpMap", 2D) = "bump" {}
        _BumpPower("BumpPower",Range(0.001,1)) = 0.1

        [Space(20)][Header(DistortionMap and Power)][Space(20)]
        _DistMap("DistortionMap", 2D) = "dist" {}
        _DistPower("DistortionPower", Range(0.1, 10)) = 1

        _Animate("Animate", Range(0,1)) = 0
        

    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        //ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front

        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:fade vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _ColorMap;
        sampler2D _BumpMap;
        sampler2D _DistMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_ColorMap;
            float2 uv_BumpMap;
            float2 uv_DistMap;
            float3 viewDir;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        float _ColorBlend;
        float _BumpPower;
        float _DistPower;
        fixed4 _Color;
        float _Alpha;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			float4x4 rotation;
		float _Animate;
			void vert(inout appdata_full v)
		{
			rotation = float4x4(1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, -_SinTime.x * _Animate, 0.f, 0.f, 1.f, 0.f, 0.f, _SinTime.x * _Animate, 0, 1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, 0.f, 0.f, 0.f, 1.f);
			v.vertex = mul(v.vertex, rotation);
		}
            ///the main function
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // IN.viewDir.rgb;

            // Albedo comes from a texture tinted by color            

            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            float distMap = tex2D(_DistMap, IN.uv_DistMap);
            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            normal.z /= _BumpPower;
            o.Normal = normalize(normal);

            float4 rim4 = dot(normalize(IN.viewDir.rgb),o.Normal);
            float2 distortion = distMap * _DistPower;
            float2 rim2 = 1.0 - saturate(dot(normalize(IN.viewDir.rgb), o.Normal));

            fixed3 colorMap = tex2D(_ColorMap, (rim4.xy * IN.uv_ColorMap.xy + rim2) * distortion);

            //o.Albedo = ((c.rgb + colorMap.rgb + IN.viewDir)/3) * _ColorBlend;
            o.Albedo = lerp(c, colorMap, _ColorBlend);
            //o.Albedo = c.rgb * normal.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
