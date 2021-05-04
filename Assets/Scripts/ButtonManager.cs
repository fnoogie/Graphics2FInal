using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonManager : MonoBehaviour
{
    public Button OutlineButton;
    public Button IridescentButton;
    public Button DepthofFeildButton;
    public Button WireFrameButton;
    public Button AnimationButton;
    public Button CubeWaveButton;

    bool animating, toggleDoF, toggleCubeWave;
    GameObject[] demoObjects;

    // Start is called before the first frame update
    void Start()
    {
        demoObjects = GameObject.FindGameObjectsWithTag("DemoObject");
        OutlineButton.onClick.AddListener(Outline);
        IridescentButton.onClick.AddListener(Iridescent);
        DepthofFeildButton.onClick.AddListener(DepthofFeild);
        WireFrameButton.onClick.AddListener(Wireframe);
        AnimationButton.onClick.AddListener(Animation);
        CubeWaveButton.onClick.AddListener(CubeWave);
    }

    void Outline()
    {
        MaterialSwap(1);
        DoF(false);
    }

    void Iridescent()
    {
        MaterialSwap(2);
        DoF(false);
    }

    void Wireframe()
    {
        MaterialSwap(3);
        DoF(false);
    }

    void MaterialSwap(int index)
    {
        
        for (int i = 0; i < demoObjects.Length; i++)
        {
            GameObject currentObject = demoObjects[i];
            if (currentObject.GetComponent<MeshRenderer>().material.shader == currentObject.GetComponent<MaterialHolder>().materials[index].shader)
            {
                index = 0;
            }
                currentObject.GetComponent<MeshRenderer>().material = currentObject.GetComponent<MaterialHolder>().materials[index];
            
        }
        GameObject.Find("Main Camera").GetComponent<SineWaveCubes>().material = demoObjects[2].GetComponent<MaterialHolder>().materials[index];
        GameObject.Find("Main Camera").GetComponent<SineWaveCubes>().index = index;
    }

    void Animation()
    {
        animating = !animating;
        Animate(animating);
    }

    void DepthofFeild()
    {
        MaterialSwap(0);
        toggleDoF = !toggleDoF;
        DoF(toggleDoF);
    }

    void DoF(bool onOff)
    {
        Camera.main.GetComponent<DoFEffect>().enabled = onOff;
    }

    void Animate(bool animateObjects)
    {
        int onOff = animateObjects ? 1 : 0;
        for (int i = 0; i < demoObjects.Length; i++)
        {
            GameObject currentObject = demoObjects[i];
            for (int j = 0; j < currentObject.GetComponent<MaterialHolder>().materials.Length; j++)
            {
                currentObject.GetComponent<MaterialHolder>().materials[j].SetFloat("_Animate", onOff);
            }
        }
    }

    void CubeWave()
    {
        toggleCubeWave = !toggleCubeWave;
        GameObject.Find("Main Camera").GetComponent<SineWaveCubes>().CalculateOnShader = toggleCubeWave;
    }
}
