Shader "Custom/Geometry/Extrude"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Factor ("Factor", Range(0., 2.)) = 0.2
		_Scale("Scale", float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
 
            #include "UnityCG.cginc"
 
            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
				float3 screenUp : TEXCOORD1;
				float3 screenRight : TEXCOORD2;

            };
 
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
           
            v2g vert (appdata_base v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = v.normal;

				o.screenUp = mul((float3x3)unity_CameraToWorld, float3(0, 1, 0));
				o.screenRight = mul((float3x3)unity_CameraToWorld, float3(1, 0, 0));

				o.screenUp = mul((float3x3)unity_WorldToObject, o.screenUp);
				o.screenRight = mul((float3x3)unity_WorldToObject, o.screenRight);

				o.screenUp = normalize(o.screenUp);
				o.screenRight = normalize(o.screenRight);

                return o;
            }
 
            float _Factor;
			float _Scale;

            [maxvertexcount(6)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
            {
                g2f o;

				float3 up = IN[0].screenUp*_Scale*0.01;
				float3 rt = IN[0].screenRight*_Scale*0.01;
				float4 color = tex2Dlod(_MainTex, float4(IN[0].uv, 0, 1));

                o.pos = UnityObjectToClipPos(IN[0].vertex);
                o.uv = IN[0].uv;
				o.col = color;
                tristream.Append(o);
					
				o.pos = UnityObjectToClipPos(IN[0].vertex + rt);
				o.uv = IN[0].uv;
				o.col = color;
				tristream.Append(o);

				o.pos = UnityObjectToClipPos(IN[0].vertex + up);
				o.uv = IN[0].uv;
				o.col = color;
				tristream.Append(o);
 
				tristream.RestartStrip();





				o.pos = UnityObjectToClipPos(IN[0].vertex + rt + up);
				o.uv = IN[0].uv;
				o.col = color;
				tristream.Append(o);

				o.pos = UnityObjectToClipPos(IN[0].vertex + rt);
				o.uv = IN[0].uv;
				o.col = color;
				tristream.Append(o);

				o.pos = UnityObjectToClipPos(IN[0].vertex + up);
				o.uv = IN[0].uv;
				o.col = color;
				tristream.Append(o);

				tristream.RestartStrip();
            }
           
            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.col;
                return col;
            }
            ENDCG
        }
    }
}