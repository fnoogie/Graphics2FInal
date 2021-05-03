using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonManager : MonoBehaviour
{
    public Button BevelButton;
    public Button IridescentButton;
    public Button DepthofFeildButton;
    public Button TesselationButton;
    public Button AnimationButton;
    public Button SceneCullingButton;

    // Start is called before the first frame update
    void Start()
    {
        BevelButton.onClick.AddListener(Bevel);
        IridescentButton.onClick.AddListener(Iridescent);
        DepthofFeildButton.onClick.AddListener(DepthofFeild);
        TesselationButton.onClick.AddListener(Tesselation);
        AnimationButton.onClick.AddListener(Animation);
        SceneCullingButton.onClick.AddListener(SceneCulling);
    }

    void Bevel()
    {
        Debug.Log("Bevel things");
    }

    void Iridescent()
    {
        Debug.Log("Iridescent things");
    }

    void DepthofFeild()
    {
        Debug.Log("DepthofFeild things");
    }

    void Tesselation()
    {
        Debug.Log("Tesselation things");
    }

    void Animation()
    {
        Debug.Log("Animation things");
    }

    void SceneCulling()
    {
        Debug.Log("SceneCulling things");
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
