Shader "Unlit/HealthBarWithTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Health ("_Health", Range(0.0, 1.0)) = 0.0
		_Amp ("_Amp", Float) = 0.1
		_PulseSpeed ("Pulse Speed", Float) = 1.0
		_PulsingThreshold ("Pulsing Threshold", Range(0.0, 1.0)) = 0.2
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#define PI 3.14159265358979323846
			#define TAU 2 * PI

			float _Health;
			float _Amp;
			float _PulseSpeed;
			float _PulsingThreshold;

			struct MeshData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct Interpolators
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			Interpolators vert(MeshData
			v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				// o.uv = v.uv * 2 - 1;
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(Interpolators i) : SV_Target
			{
				/*
				 * The y axis are scale down 0.125 so we scale the X axis up in proportion. This help un-stretch the coords
				 * We doing the scaling here instead of the vertex shader even though it is less performant because we want to have a high precision coords. Doing it in the vertex shader would result in interpolated value. 
				*/
				float2 coords = i.uv;
				coords.x *= 8;


				float2 pointOnLengthSegment = float2(clamp(coords.x, 0.5, 7.5), 0.5); // * A line that stay in the middle of the quad, distanced from the edge by 0.5 in both side

				/*
				 * This is personal pref. We multiply the distance by 2 to make the distance in the range of [0,1]. 
				 Then we minus the radius which is standard sdf operations. This is to make everything outside of the radius positive and vice versa
				*/
				float sdf = distance(coords, pointOnLengthSegment) * 2 - 1 ;
				clip(-sdf);

				float borderSdf = sdf + 0.2;
				float pd = fwidth(borderSdf); // partial derivative
				float borderMask = 1 - saturate(borderSdf / pd); // anti-alias

				float4 col = tex2D(_MainTex, float2(_Health, i.uv.y));
				bool healthBarMask = (i.uv.x < _Health);
				bool isPulsate = _Health < _PulsingThreshold;
				float pulse = cos(_Time.y * _PulseSpeed) * _Amp + 1;
				col *= healthBarMask;

				return float4(col.rgb * borderMask * (isPulsate ? pulse : 1), 1);
			}
			ENDCG
		}
	}
}
