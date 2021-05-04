Shader "Custom/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OutlineColor ("OutLineColor", color) = (0,0,0,1)
		_OutlineSize("OutlineThickness", Range(1,2)) = 1.1
		_Animate("Animate", Range(0,1)) = 0
    }
    SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 15

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _Animate;
				float4x4 rotation;

				v2f vert(appdata v)
				{
					v2f o;
					rotation = float4x4(1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, -_SinTime.x * _Animate, 0.f,   0.f, 1.f, 0.f, 0.f,   _SinTime.x * _Animate, 0, 1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f,   0.f, 0.f, 0.f, 1.f);
					v.vertex = mul(v.vertex, rotation);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					return col;
				}
				ENDCG
			}
			Pass
			{
				Cull Front
				CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _OutlineColor;
				float _OutlineSize;
				float _Animate;
				float4x4 scale;
				float4x4 rotation;

				struct appdata
				{
					float4 vertex:POSITION;
					float2 uv:TEXCOORD0;
				};

				struct v2f
				{
					float4 pos:SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				v2f vert(appdata v)
				{
					v2f o;
					rotation = float4x4(1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, -_SinTime.x * _Animate, 0.f, 0.f, 1.f, 0.f, 0.f, _SinTime.x * _Animate, 0, 1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, 0.f, 0.f, 0.f, 1.f);
					_OutlineSize = _OutlineSize * (1 - _Animate) + (_SinTime.w * 0.25f + .99f) * _Animate;
					scale = float4x4(_OutlineSize, 0.f, 0.f, 0.f,   0.f, _OutlineSize, 0.f, 0.f,   0.f, 0.f, _OutlineSize, 0.f,   0.f, 0.f, 0.f, 1.f);
					v.vertex = mul(v.vertex, scale);
					v.vertex = mul(v.vertex, rotation);
					o.pos = UnityObjectToClipPos(v.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = _OutlineColor;
					return col;
				}
				ENDCG
			}
		}
}
