Shader "Custom/DissolveShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		[Normal] _Normal ("Normal", 2D) = "bump"{}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0 
		_Occlusion("Occlusion", 2D) = "white"{}

		[Header(Edge)]
		_Width ("Edge width", Float) = 0.1 
		_EdgeColor ("Edge color", Color) = (1,1,1,1)
		_Sharpness ("Edge sharpness", Range(0,12)) = 1
		_Offset ("Offset", Float) = 0 

		[Header(Noise)]
		_Noise ("Noise influence", Range(0,1)) = 0 
		_NoiseTex ("Noise texture", 2D) = "black" {}
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull mode", int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull [_CullMode]
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0


		struct Input 
		{
			float2 uv_Normal;
			float2 uv_Occlusion;
            float3 worldPos;
			float4 screenPos;
			float depth;
        };

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.depth = -UnityObjectToViewPos(float3(0, 0, 0)).z;
		}

		fixed4 _Color;
		sampler2D _Normal;
		half _Glossiness;
		half _Metallic;
		sampler2D _Occlusion;

		sampler2D _NoiseTex;
		float4 _NoiseTex_ST;
		float3 _PlanePoint;
		float3 _PlaneNormal;
		float _Width;
		float _Noise;
		float _Sharpness;
		float _Offset;
		fixed4 _EdgeColor;

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END
		
		float signedPointPlaneDistance(float3 planePoint, float3 planeNormal, float3 objectPoint)
		{
			return dot((objectPoint - planePoint), normalize(planeNormal));
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w * IN.depth * _NoiseTex_ST.xy;
			fixed4 noise = tex2D(_NoiseTex, screenUV + _NoiseTex_ST.zw) * _Noise;
			float distance = -signedPointPlaneDistance(_PlanePoint, _PlaneNormal, IN.worldPos);
			float edge = (distance + _Offset - noise) / _Width;
			clip(edge);
			o.Emission = pow(1 - saturate(edge), _Sharpness + 0.001) * _EdgeColor;
			o.Albedo = _Color.rgb;
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Occlusion = tex2D(_Occlusion, IN.uv_Occlusion);
			o.Alpha = _Color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
