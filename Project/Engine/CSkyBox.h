#pragma once

#include "CRenderComponent.h"

enum class SKYBOX_TYPE
{
	SPHERE,
	CUBE,
};

class CSkyBox : public CRenderComponent
{
public:
	CSkyBox();
	~CSkyBox();

	virtual void finaltick() override;
	virtual void render() override;

	CLONE(CSkyBox);
public:
	void SetSkyBoxType(SKYBOX_TYPE _Type);
	void SetSkyBoxTexture(Ptr<CTexture> _Tex);

private:
	SKYBOX_TYPE m_Type;
	Ptr<CTexture> m_SkyBoxTex;
};

