Shader "Unlit/LightingTest"
{
	Properties
	{
		/*
		 * Gloss is a exponent so leaving it as a free range float will make the tuning of this parameter not linear, limit it to this range then transform the value into something that can be use as a exponent somewhere else. Probably should do this in C# for better performance
		*/
		_Gloss ("Gloss", range(0.0, 1.0)) = 1
		_MainTex ("Texture", 2D) = "white" { }
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
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct MeshData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Interpolators
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Gloss;

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(Interpolators i) : SV_Target
			{
				/*
				 * The gloss are set within a range of  0 -> 1 clearly not usable to be a exponent. Transform it into something usable. This is clearly just a preferences. Better do it in C# end for more performance 
				*/
				float specularExponent = exp2(_Gloss * 11) + 2;
				// diffuse lighting (lambert lighting)
				float3 N = normalize(i.normal); // * Since this is a interpolated value, we need to do the normalization our self
				float3 L = _WorldSpaceLightPos0.xyz;
				float3 lambert = saturate(dot(N, L));


				// specular lighting (phong)
				float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
				float3 R = reflect(-L, N);
				/*
				 * this is to resolve the edge case where we get the reflection on the wrong side of the object like in the back for example.
				 * We multiply it with the lambert condition because the lambert is negative when the fragment is behind light vector 
				*/
				float3 specularLighting = saturate(dot(V, R)) * (lambert > 0);
				specularLighting = pow(specularLighting, specularExponent); // specular exponent

				// specular lighting (blinn-phong i think)
				float3 H = normalize(V + L); // Half vector
				float3 specularLighting2 = saturate(dot(H, N)) * (lambert > 0);
				specularLighting2 = pow(specularLighting2, specularExponent);

				return float4((specularLighting2.xxx + lambert) * _LightColor0.xyz, 1);
			}
			ENDCG
		}
	}
}
