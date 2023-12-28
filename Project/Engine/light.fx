#ifndef _LIGHT
#define _LIGHT

#include "value.fx"
#include "func.fx"

struct VS_IN
{
    float3 vPos : POSITION;
};

struct VS_OUT
{
    float4 vPosition : SV_Position;
};

struct PS_OUT
{
    float4 vDiffuse : SV_Target0;
    float4 vSpecular : SV_Target1;
};

#define NormalTargetTex     g_tex_0
#define PoisitionTargetTex  g_tex_1
#define LightIdx            g_int_0

// =======================
// DirLightShader
// MRT                  :   LIGHT
// Mesh                 :   RectMesh
// Rasterizer            :   CULL_BACK
// DepthStencil        :   NO_TEST_NO_WRITE
// Blend                 :   ONE_ONE

VS_OUT VS_DirLightShader(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    // Directional Light는 RectMesh이기 때문에 LocalPos * 2.f 를 해주면 전체화면을 가리키도록 설정가능
    // w값은 1.f로 해줘야함. (Rasterizer에서 나눠주기 때문에 똑같이 2.f를 곱해주면 원상복구된다.)
    output.vPosition = float4(_in.vPos.xyz * 2.f, 1.f);
    
    return output;
}

PS_OUT PS_DirLightShader(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
    
    float2 vScreenUV = _in.vPosition.xy / g_Resolution.xy;
    
    float3 vViewNormal = NormalTargetTex.Sample(g_sam_0, vScreenUV).xyz;
    float3 vViewPos = PoisitionTargetTex.Sample(g_sam_0, vScreenUV).xyz;

    if (vViewPos.x == 0 && vViewPos.y == 0 && vViewPos.z == 0)
    {
        //output.vDiffuse = float4(0.2f, 1.f, 0.2f, 1.f);
        //output.vSpecular = float4(0.2f, 1.f, 0.2f, 1.f);
        //return output;        
        discard;
    }
    
    tLightColor LightColor = (tLightColor) 0.f;
    float fSpecPow = 0.f;
    
    CalcLight3D(vViewPos, vViewNormal, LightIdx, LightColor, fSpecPow);
    
    output.vDiffuse = LightColor.vDiffuse + LightColor.vAmbient;
    output.vSpecular = g_Light3DBuffer[LightIdx].Color.vDiffuse * fSpecPow;
    
    output.vDiffuse.a = 1.f;
    output.vSpecular.a = 1.f;
    
    return output;
}


// =====================================
// MergeShader
// MRT              : SwapChain
// Domain           : DOMAIN_LIGHT
// Mesh             : RectMesh
// Rasterizer       : CULL_BACK
// DepthStencil     : NO_TEST_NO_WRITE
// Blend            : Default
//========================================

// Parameter
#define ColorTargetTex    g_tex_0
#define DiffuseTargetTex  g_tex_1
#define SpecularTargetTex g_tex_2
#define EmissiveTargetTex g_tex_3

VS_OUT VS_MergeShader(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vPosition = float4(_in.vPos.xyz * 2.f, 1.f);
    
    return output;
}

float4 PS_MergeShader(VS_OUT _in) : SV_Target
{
    float4 vOutColor = (float4) 0.f;
 
    float2 vScreenUV = _in.vPosition.xy / g_Resolution.xy;
    
    float4 vColor = ColorTargetTex.Sample(g_sam_0, vScreenUV);
    float4 vDiffuse = DiffuseTargetTex.Sample(g_sam_0, vScreenUV);
    float4 vSpecular = SpecularTargetTex.Sample(g_sam_0, vScreenUV);
    float4 vEmissive = EmissiveTargetTex.Sample(g_sam_0, vScreenUV);
    
    vOutColor.xyz = vColor.xyz * vDiffuse.xyz + (vSpecular.xyz * vColor.a) + vEmissive.xyz;
    vOutColor.a = 1.f;
    
    return vOutColor;    
}


// =====================================
// PointLightShader
// MRT              : LIGHT
// Mesh             : SphereMesh
// Rasterizer       : CULL_FRONT
// DepthStencil     : NO_TEST_NO_WRITE
// Blend            : ONE_ONE

// Parameter
//#define NormalTargetTex     g_tex_0
//#define PoisitionTargetTex  g_tex_1
//#define LightIdx            g_int_0
// =====================================

VS_OUT VS_PointLightShader(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;

    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    
    return output;
}

PS_OUT PS_PointLightShader(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
 
    float2 vScreenUV = _in.vPosition.xy / g_Resolution.xy;
    float3 vViewNormal = NormalTargetTex.Sample(g_sam_0, vScreenUV);
    float3 vViewPos = PoisitionTargetTex.Sample(g_sam_0, vScreenUV);
    
    if(vViewPos.x == 0.f && vViewPos.y == 0.f && vViewPos.z == 0.f)
    {
        discard;
    }
    
    float3 vWorldPos = mul(float4(vViewPos, 1.f), g_matViewInv);
    float3 vLocalPos = mul(float4(vWorldPos, 1.f), g_matWorldInv);
    float fDist = length(vLocalPos.xyz);
    
    if(0.5f < fDist)
    {
        discard;
    }
    
    tLightColor LightColor = (tLightColor) 0.f;
    float fSpecPow = 0.f;
    
    CalcLight3D(vViewPos, vViewNormal, LightIdx, LightColor, fSpecPow);
    
    output.vDiffuse = LightColor.vDiffuse + LightColor.vAmbient;
    output.vSpecular = g_Light3DBuffer[LightIdx].Color.vDiffuse * fSpecPow;
    
    output.vDiffuse.a = 1.f;
    output.vSpecular.a = 1.f;
    
    return output;
}

#endif