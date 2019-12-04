Shader "MaxMaskPattern"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			CGINCLUDE
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			ENDCG

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

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex); //均一な座標でオブジェクト空間からカメラのクリップ空間にポイントを変換します。
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}
					fixed4 frag(v2f i) : SV_Target
				{
					half3 centerColor = 0;

					for (int k = -2; k < 3; k++) {
						for (int l = -2; l < 3; l++) {
							float diffU = _MainTex_TexelSize.x * k;
							float diffV = _MainTex_TexelSize.y * l;
							half3 coller = tex2D(_MainTex, i.uv + half2(diffU, diffV));
							centerColor += coller;
						}
					}
					centerColor = centerColor / 25;
					return half4(centerColor, 1);
				}
				ENDCG
			}
		}
}