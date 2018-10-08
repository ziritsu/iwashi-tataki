// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "GUI/Text Shader Iws_fail_edge_bleed2" {
	Properties {
		_MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Text Color", Color) = (1,1,1,1)
		_DimLevel ("Dim level", Range(0,1)) = 1
		// _BlurWeight("Blur Weight", Range(0, 0.5)) = 0
	}

	SubShader {

		Tags {
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}
		Lighting Off Cull Off ZTest Always ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed4 _Color;

			float4 _MainTex_TexelSize;
			float _DimLevel;
			// float _BlurWeight;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color * _Color;
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag (v2f v) : SV_Target
			{
				// Unity original:
				// fixed4 col = v.color;
				// col.a *= tex2D(_MainTex, v.texcoord).a;
				
				float4 texelsz = _MainTex_TexelSize;
				float2 resolution = texelsz.zw;
			        float2 range = pow(resolution, _DimLevel);
				
				float2 texcoord = v.texcoord;
				if (_DimLevel < 1) {
					texcoord = floor(texcoord * range) / range;
				}

				fixed a = tex2D(_MainTex, texcoord).a;
				
				// float blur = _BlurWeight;
				// fixed a = tex2D(_MainTex, texcoord).a * (1.0 - blur);
				// a += tex2D(_MainTex, texcoord + float2(+texelsz.x, +texelsz.y)).a * blur / 4;
				// a += tex2D(_MainTex, texcoord + float2(+texelsz.x, -texelsz.y)).a * blur / 4;
				// a += tex2D(_MainTex, texcoord + float2(-texelsz.x, -texelsz.y)).a * blur / 4;
				// a += tex2D(_MainTex, texcoord + float2(-texelsz.x, +texelsz.y)).a * blur / 4;

				fixed4 col = v.color;
				col.a *= a;
				return col;
			}
			ENDCG
		}
	}
}
