// Author: NhatLinh
// github: https://github.com/concat1911
// This shader use for setting single color of image or sprite
// Usecase example: color of avatar item/charactere... when is not unlocked yet.

Shader"VeryDisco/Sprite2D/SingleColorReplace"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _ReplaceColor( "Replace Color", COLOR) = (0, 0, 0, 1)
        _FadeAlpha("Fade Alpha", Range(0, 1)) = 1.0

        // required for using on UI
        [HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector]_ColorMask("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent" 
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "CanUseSpriteAtlas"="True" 
        }

        ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off

        // required for using on UI
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            struct appdata_t{
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
            };

            sampler2D _MainTex;
            float _FadeAlpha;
            float4 _ReplaceColor;

            v2f vert(appdata_t i)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                o.texcoord = i.texcoord;
                o.color = i.color;
                return o;
            }


            float4 UniColor(float4 txt, float4 color)
            {
                txt.rgb = lerp(txt.rgb, color.rgb, color.a);
                return txt;
            }

            float4 frag (v2f i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.texcoord);

                col.rgb = lerp(col.rgb, _ReplaceColor.rgb, _ReplaceColor.a);

                float4 finalCol = col;
                finalCol.rgb *= i.color.rgb;
                finalCol.a = finalCol.a * _FadeAlpha * i.color.a;
                return finalCol;
            }

            ENDCG
            }
        }
        Fallback "Sprites/Default"
    }
