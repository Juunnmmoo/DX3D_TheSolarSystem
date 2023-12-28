#ifndef _DECAL
#define _DECAL

#include "value.fx"
#include "func.fx"

// ================================
// DecalShader
// MRT                  : SwapChain
// DOMAIN               : DOMAIN_DECAL
// Mesh                 : CubeMesh
// Rasterizer           : CULL_FRONT
// DepthStencil State   : No_Test_No_Write
// Blend State          : Default
    
// Parameter
#define PositionTargetTex  g_tex_0
#define OutputTex          g_tex_1
#define IsOutputTex        g_btex_1
// ================================

struct VS_DECAL_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
};

struct VS_DECAL_OUT
{
    float4 vPosition : SV_Position;
    float3 vLocalPos : POSITION;
    float2 vUV : TEXCOORD;
};

VS_DECAL_OUT VS_Decal(VS_DECAL_IN _in)
{
    VS_DECAL_OUT output = (VS_DECAL_OUT) 0.f;
    
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    output.vLocalPos = _in.vPos;
    
    return output;
}

float4 PS_Decal(VS_DECAL_OUT _in) : SV_Target
{
    float4 vOutColor = (float4) 0.f;
    
    float2 vScreenUV = _in.vPosition.xy / g_Resolution;
    float3 vViewPos = PositionTargetTex.Sample(g_sam_0, vScreenUV).xyz;
    float3 vWorldPos = mul(float4(vViewPos, 1.f), g_matViewInv).xyz;
    float3 vLocal = mul(float4(vWorldPos, 1.f), g_matWorldInv).xyz;
    
    if (abs(vLocal.x) < 0.5f && abs(vLocal.y) < 0.5f && abs(vLocal.z) < 0.5f)
    {
        float2 vUV = vLocal.xz;
        vUV.x = vUV.x + 0.5f;
        vUV.y = (1.f - vUV.y) - 0.5f;
        
        if (IsOutputTex)
        {
            vOutColor = OutputTex.Sample(g_sam_0, vUV);
        }
        else
        {
            discard;
        }

    }
    else
    {
        discard;
    }
    
    
        return vOutColor;
}

// Deferred DecalShader
// MRT                  : Deferred Decal (ColorTarget, EmissiveTarget)
// DOMAIN               : DOMAIN_DECAL
// Mesh                 : CubeMesh
// Rasterizer           : CULL_FRONT
// DepthStencil State   : No_Test_No_Write
// Blend State          : DeferredDecalBlend

// Parameter
#define PositionTargetTex g_tex_0
#define OutputTex          g_tex_1
#define IsOutputTex        g_btex_1
#define IsEmissive           g_int_0
// ==========================

VS_DECAL_OUT VS_DeferredDecal(VS_DECAL_IN _in)
{
    VS_DECAL_OUT output = (VS_DECAL_OUT) 0.f;
    
    output.vLocalPos = _in.vPos;
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    
    return output;
}

struct PS_DECAL_OUT
{
    float4 vColor : SV_Target0;
    float4 vEmissive : SV_Target1;
};

PS_DECAL_OUT PS_DeferredDecal(VS_DECAL_OUT _in)
{
    PS_DECAL_OUT output = (PS_DECAL_OUT) 0.f;
    
    float2 vScreenUV = _in.vPosition.xy / g_Resolution.xy;
    float3 vViewPos = PositionTargetTex.Sample(g_sam_0, vScreenUV).xyz;
    float3 vWorldPos = mul(float4(vViewPos, 1.f), g_matViewInv).xyz;
    float3 vLocalPos = mul(float4(vWorldPos, 1.f), g_matWorldInv).xyz;
    
    if (abs(vLocalPos.x) < 0.5f && abs(vLocalPos.y) < 0.5f && abs(vLocalPos.z) <0.5f)
    {
        if (IsOutputTex)
        {
            float2 vUV = vLocalPos.xz;
            vUV.x = vUV.x + 0.5f;
            vUV.y = (1.f - vUV.y) - 0.5f;
            
            output.vColor = OutputTex.Sample(g_sam_0, vUV);
            
            if (IsEmissive)
            {
                output.vEmissive = output.vColor * output.vColor.a;
            }

        }
        else
        {
            discard;
        }
    }
    else
    {
        discard;
    }
    
    return output;
}


#endif
