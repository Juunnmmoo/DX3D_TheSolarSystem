#pragma once
#include "CRenderComponent.h"

class CDecal :
    public CRenderComponent
{
private:
    Ptr<CTexture>   m_DecalTex;
    bool m_bDeferred;
    bool m_bEmissive;

public:
    void SetDeferredDecal(bool _bDeferred);
    void ActivateEmissive(bool _bActivate) { m_bEmissive = _bActivate; }

public:
    virtual void finaltick() override;
    virtual void render() override;

    CLONE(CDecal);
public:
    CDecal();
    ~CDecal();
};

