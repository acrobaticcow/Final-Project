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
			Blend SrcAlpha OneMinusSrcAlpha

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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, float2(_Health, i.uv.y));
				bool healthBarMask = i.uv.x < _Health;
				bool isPulsate = _Health < _PulsingThreshold;
				float pulse = cos(_Time.y * _PulseSpeed) * _Amp + 1;
				col *= healthBarMask;

				return float4(col.rgb * (isPulsate ? pulse : 1), 1);
			}
			ENDCG
		}
	}
}
