Shader "Custom/WireframeShader"
{

	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_WireColor("Edges Color", Color) = (0,0,0,1)
		_WireThickness("Thickness", RANGE(0,500)) = 100
		_Animate("Animate", Range(0,1)) = 0
	}

		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Pass
		{
		CGPROGRAM
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "UnityCG.cginc"

		#pragma vertex vert
		#pragma fragment frag
		#pragma geometry geom

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Animate;
		struct Input
		{
			float2 uv_MainTex;
		};

		fixed4 _WireColor;
		uniform float _WireThickness;

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2g
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		struct g2f
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 dist : TEXCOORD1;
		};

		float4x4 rotation;

		v2g vert(appdata v)
		{
			v2g o;
			rotation = float4x4(1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, -_SinTime.x * _Animate, 0.f, 0.f, 1.f, 0.f, 0.f, _SinTime.x * _Animate, 0, 1 * (1 - _Animate) + _CosTime.x * _Animate, 0.f, 0.f, 0.f, 0.f, 1.f);
			v.vertex = mul(v.vertex, rotation);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		[maxvertexcount(3)]
		void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
		{
			float2 p0 = i[0].pos.xy / i[0].pos.w;
			float2 p1 = i[1].pos.xy / i[1].pos.w;
			float2 p2 = i[2].pos.xy / i[2].pos.w;

			float2 edge0 = p2 - p1;
			float2 edge1 = p2 - p0;
			float2 edge2 = p1 - p0;

			float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
			float wireThickness = 800 - _WireThickness;

			g2f o;

			o.uv = i[0].uv;
			o.pos = i[0].pos;
			o.dist.xyz = float3((area / length(edge0)), 0.0, 0.0) * o.pos.w * wireThickness;
			o.dist.w = 1.0 / o.pos.w;
			triangleStream.Append(o);

			o.uv = i[1].uv;
			o.pos = i[1].pos;
			o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0) * o.pos.w * wireThickness;
			o.dist.w = 1.0 / o.pos.w;
			triangleStream.Append(o);

			o.uv = i[2].uv;
			o.pos = i[2].pos;
			o.dist.xyz = float3(0.0, 0.0, (area / length(edge2))) * o.pos.w * wireThickness;
			o.dist.w = 1.0 / o.pos.w;
			triangleStream.Append(o);
		}

		fixed4 frag(g2f i) : SV_Target
		{
			float minDistanceToEdge = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.dist[3];

			float4 baseColor = tex2D(_MainTex, i.uv);

			// Early out if we know we are not on a line segment.
			if (minDistanceToEdge > 0.9)
			{
				return fixed4(baseColor.rgb,0);
			}

			return _WireColor;
		}
		ENDCG
	}
	}
		FallBack "Diffuse"
}
