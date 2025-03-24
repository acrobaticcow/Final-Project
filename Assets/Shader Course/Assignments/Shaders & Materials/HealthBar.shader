Shader "Unlit/HealthBar"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Health ("_Health", Range(0.0, 1.0)) = 0.0
		_StartColor ("Start Color", Color) = (1, 0, 0, 1)
		_EndColor ("End Color", Color) = (0, 1, 0, 1)
		_MinHealthThreshold ("Min Health Threshold", Range(0.0, 1.0)) = 0.2
		_MaxHealthThreshold ("Max Health Threshold", Range(0.0, 1.0)) = 0.8
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

			float4 _StartColor;
			float4 _EndColor;
			float _Health;
			float _MinHealthThreshold;
			float _MaxHealthThreshold;

			struct MeshData
			{
				float4 vertex : POSITION;
				float3 normals : NORMAL;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			// sampler2D _MainTex;
			// float4 _MainTex_ST;

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float InvLerp(float a, float b, float x)
			{
				return (x - a) / (b - a);
			}


			fixed4 frag(Interpolators i) : SV_Target
			{
				float t = saturate(InvLerp(_MinHealthThreshold, _MaxHealthThreshold, _Health));
				float4 col = lerp(_StartColor, _EndColor, t) * (_Health == 0 || i.uv.x < _Health);
				clip(col.a - 0.1);
				return col;
			}
			ENDCG
		}
	}
}
