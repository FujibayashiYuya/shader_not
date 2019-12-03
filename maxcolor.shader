Shader "MaskPattern"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_OutlineThick("Outline Thick", float) = 1.0
		_OutlineThreshold("Outline Threshold", float) = 0.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

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
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _MainTex_TexelSize;
				float _OutlineThick;
				float _OutlineThreshold;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// 近隣のテクスチャ色をサンプリング
					float diffU = _MainTex_TexelSize.x + 1; //*_OutlineThick
					float diffV = _MainTex_TexelSize.y + 1;
					half3 col00 = tex2D(_MainTex, i.uv + half2(-diffU, -diffV));
					half3 col01 = tex2D(_MainTex, i.uv + half2(-diffU, 0.0));
					half3 col02 = tex2D(_MainTex, i.uv + half2(-diffU, diffV));
					half3 col10 = tex2D(_MainTex, i.uv + half2(0.0, -diffV));
					half3 col11 = tex2D(_MainTex, i.uv);
					half3 col12 = tex2D(_MainTex, i.uv + half2(0.0, diffV));
					half3 col20 = tex2D(_MainTex, i.uv + half2(diffU, -diffV));
					half3 col21 = tex2D(_MainTex, i.uv + half2(diffU, 0.0));
					half3 col22 = tex2D(_MainTex, i.uv + half2(diffU, diffV));


					//3*3の平滑化フィルタ
					half3 centerColor = col11 / 9;
					centerColor += col00 / 9;
					centerColor += col01 / 9;
					centerColor += col02 / 9;
					centerColor += col10 / 9;
					centerColor += col12 / 9;
					centerColor += col20 / 9;
					centerColor += col21 / 9;
					centerColor += col22 / 9;

					//最大値検出
					half3 maxColor = max(centerColor, 0.2);

					if (centerColor.r < 0.9 || centerColor.g < 0.9 || centerColor.b < 0.9) {
						centerColor = 0;
					}
					return half4(centerColor, 1);
				}
				ENDCG
			}

			//1パス目（平滑化）の描写結果をテクスチャとして渡す
			GrabPass{}

			//2パス目で一番明るい場所の検出
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;
			float4 _GrabTexture_ST;
			float4 _GrabTexture_TexelSize;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _GrabTexture);
				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float diffu = _GrabTexture_TexelSize.x;
				float diffv = _GrabTexture_TexelSize.y;
				half3 col = tex2D(_GrabTexture, i.uv);
				half3 col2 = tex2D(_GrabTexture, i.uv + half2(diffu, diffv));
				float scalarcol = sqrt(col.r * col.r + col.g * col.g + col.b * col.b);
				float scalarcol2 = sqrt(col2.r * col2.r + col2.g * col2.g + col2.b * col2.b);
				half3 maxcol;
				if (scalarcol < scalarcol2) {
					col = 0;
					maxcol = col2;
				}
				else {
					col2 = 0;
					maxcol = col;
				}
				return half4(maxcol, 1);
			}
				ENDCG
			}
		}
}