#pragma once
#include "CComponent.h"

#include "CMesh.h"
#include "CMaterial.h"

class CLight3D : public CComponent
{
public:
	virtual void finaltick()override;
	void render();
	
	virtual void SaveToLevelFile(FILE* _File) override;
	virtual void LoadFromLevelFile(FILE* _File)override;

public:
	CLight3D();
	~CLight3D();

	CLONE(CLight3D);
public:
	void SetLightColor(Vec3 _vColor) { m_LightInfo.Color.vDiffuse = _vColor; }
	void SetLightAmbient(Vec3 _vAmb) { m_LightInfo.Color.vAmbient = _vAmb; }
	void SetLightType(LIGHT_TYPE _Type);
	void SetRadius(float _fRadius);
	void SetAngle(float _fAngle) { m_LightInfo.Angle = _fAngle; }

	Vec3 GetLightColor() { return m_LightInfo.Color.vDiffuse; }
	Vec3 GetLightAmbient() { return m_LightInfo.Color.vAmbient; }
	LIGHT_TYPE GetLightType() { return (LIGHT_TYPE)m_LightInfo.LightType; }
	float GetRadius() { return m_LightInfo.Radius; }
	float GetAngle() { return m_LightInfo.Angle; }

	void ShowRange(bool _bSet) { m_bShowRange = _bSet; }

private:
	tLightInfo m_LightInfo;

	Ptr<CMesh>		m_Mesh;
	Ptr<CMaterial>		m_Material;
	
	UINT            m_LightIdx;

	bool            m_bShowRange;
};

