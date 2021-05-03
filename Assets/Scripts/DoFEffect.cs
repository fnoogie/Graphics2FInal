using UnityEngine;
using System;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class DoFEffect : MonoBehaviour
{
	[Range(0.1f, 20f)]
	public float focusDist = 10f;
	[Range(0.1f, 20f)]
	public float focusRange = 3f;
	[Range(1,15)]
	public int bokehStrength = 4;

	const int circleOfConfusionPass = 0;
	const int preFilterPass = 1;
	const int bokehPass = 2;
	const int postFilterPass = 3;
	const int combinePass = 4;

	[HideInInspector]
	public Shader dofShader;

	[NonSerialized]
	Material dofMat;

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (dofMat == null)
		{
			dofMat = new Material(dofShader);
			dofMat.hideFlags = HideFlags.HideAndDontSave;
		}

		dofMat.SetFloat("_FocusDist", focusDist);
		dofMat.SetFloat("_FocusRange", focusRange);
		dofMat.SetFloat("_BokehStrength", bokehStrength);

		int width = source.width / 2;
		int height = source.height / 2;
		RenderTextureFormat format = source.format;
		RenderTexture tex1 = RenderTexture.GetTemporary(width, height, 0, format);
		RenderTexture tex2 = RenderTexture.GetTemporary(width, height, 0, format);
		RenderTexture confuse = RenderTexture.GetTemporary(width, height, 0, format);

		dofMat.SetTexture("_CoCTex", confuse);
		dofMat.SetTexture("_DoFTex", tex1);
		
		//copy texture From, To, with Material, and Pass Number
		Graphics.Blit(source, confuse, dofMat, circleOfConfusionPass);
		Graphics.Blit(source, tex1, dofMat, preFilterPass);
		Graphics.Blit(tex1, tex2, dofMat, bokehPass);
		Graphics.Blit(tex2, tex1, dofMat, postFilterPass);
		Graphics.Blit(source, destination, dofMat, combinePass);


		RenderTexture.ReleaseTemporary(confuse);
		RenderTexture.ReleaseTemporary(tex1);
		RenderTexture.ReleaseTemporary(tex2);
	}
}
