Shader "Custom/DoF" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
	}

CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex, _CameraDepthTexture, _CoCTex, _DoFTex;
	float4 _MainTex_TexelSize;

	//from camera's component
	float _FocusDist, _FocusRange, _BokehStrength;

	struct VertexData {
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct Interpolators {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	Interpolators VertexProgram(VertexData v) {
		Interpolators i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.uv = v.uv;
		return i;
	}

	ENDCG

	SubShader
	{
		Cull Off
		ZTest Always
		ZWrite Off
			
		//Circle of Confusion
		Pass 
		{ 
			CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				half FragmentProgram(Interpolators i) : SV_Target 
				{
					half depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
					depth = LinearEyeDepth(depth);
						
					float CoC = (depth - _FocusDist) / _FocusRange;
					CoC = clamp(CoC, -1, 1) * _BokehStrength;
					return CoC;
				}
			ENDCG
		}

		//Prefilter pass
		Pass
		{
			CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				half4 FragmentProgram(Interpolators i) : SV_Target {
					float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
					half coc0 = tex2D(_CoCTex, i.uv + o.xy).r;
					half coc1 = tex2D(_CoCTex, i.uv + o.zy).r;
					half coc2 = tex2D(_CoCTex, i.uv + o.xw).r;
					half coc3 = tex2D(_CoCTex, i.uv + o.zw).r;

					half cocMin = min(min(min(coc0, coc1), coc2), coc3);
					half cocMax = max(max(max(coc0, coc1), coc2), coc3);
					half coc = max(cocMax, abs(cocMin));

					return half4(tex2D(_MainTex, i.uv).rgb, coc);
				}
			ENDCG
		}

		//Bokeh
		Pass
		{
			CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				//Consts used for Bokeh
				//From https://github.com/Unity-Technologies/PostProcessing/blob/v2/PostProcessing/Shaders/Builtins/DiskKernels.hlsl
				static const int kernelSampleCount = 16;
				static const float2 kernel[kernelSampleCount] = 
				{
					float2(0, 0),
					float2(0.54545456, 0),
					float2(0.16855472, 0.5187581),
					float2(-0.44128203, 0.3206101),
					float2(-0.44128197, -0.3206102),
					float2(0.1685548, -0.5187581),
					float2(1, 0),
					float2(0.809017, 0.58778524),
					float2(0.30901697, 0.95105654),
					float2(-0.30901703, 0.9510565),
					float2(-0.80901706, 0.5877852),
					float2(-1, 0),
					float2(-0.80901694, -0.58778536),
					float2(-0.30901664, -0.9510566),
					float2(0.30901712, -0.9510565),
					float2(0.80901694, -0.5877853),
				};

				//psudo IF statement coc >= radius
				half Weigh(half coc, half radius) {
					return saturate((coc - radius + 2) / 2);
				}

				half4 FragmentProgram(Interpolators i) : SV_Target
				{
					half coc = tex2D(_MainTex, i.uv).a;
					half3 bgColor = 0, fgColor = 0;
					half bgWeight = 0, fgWeight = 0;
					for (int k = 0; k < kernelSampleCount; k++) {
						float2 o = kernel[k] * _BokehStrength;			//0 = both elements of kernel[k] * Bokeh Strength
						half radius = length(o);						//radius = 2 * bokeh strength
						o *= _MainTex_TexelSize.xy;						//multiply by texel size
						half4 s = tex2D(_MainTex, i.uv + o);			//RGBA of texture at position o

						half bgw = Weigh(max(0, s.a), radius);			//if s.a >= radius, add it to background
						bgColor += s.rgb * bgw;							//add color if true, or add 0 if false
						bgWeight += bgw;								//increment counter if true

						half fgw = Weigh(-s.a, radius);					//if -s.a >= 0, add it to foreground
						fgColor += s.rgb * fgw;							//add color if true, or add 0 if false
						fgWeight += fgw;								//increment counter if true
					}
					half bgW = Weigh(bgWeight, 1);						//compare bgWeight to 1, if >= return 1 and
					half fgW = Weigh(fgWeight, 1);						//dont need to add 1 to average to avoid div by 0
					bgColor /= (bgWeight + (1 - bgW));					//average bg and fg colors
					fgColor /= (fgWeight + (1 - fgW));	

					half bgfg = min(1, fgWeight * 3.14159265 
						/ kernelSampleCount);
					half3 color = lerp(bgColor, fgColor, bgfg);
					return half4(color, bgfg);

				}
				ENDCG
		}

		//post bokeh blur
		Pass
		{
			CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				half4 FragmentProgram(Interpolators i) : SV_Target 
				{
					float4 o = _MainTex_TexelSize.xyxy * float2(-0.5, 0.5).xxyy;
					half4 s =
						tex2D(_MainTex, i.uv + o.xy) +
						tex2D(_MainTex, i.uv + o.zy) +
						tex2D(_MainTex, i.uv + o.xw) +
						tex2D(_MainTex, i.uv + o.zw);
					return s * 0.25;
				}
			ENDCG
		}

		//combine pass
		Pass
		{
			CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				half4 FragmentProgram(Interpolators i) : SV_Target 
				{
					half4 source = tex2D(_MainTex, i.uv);
					half coc = tex2D(_CoCTex, i.uv).r;
					half4 dof = tex2D(_DoFTex, i.uv);

					half lerpVal = smoothstep(0.1, 1, abs(coc));
					half3 color = lerp(source.rgb, dof.rgb, lerpVal);
					return half4(color, source.a);
				}
			ENDCG
		}
	}
}