using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct Sphere
{
    Vector3 pos;
    float radius;
    Vector3 albedo;
    Vector3 spec;
};

public class SceneCullingDriver : MonoBehaviour
{
    public Texture SkyboxTexture;
    public ComputeShader SceneCullShader;
    private RenderTexture _target;
    private Camera _camera;
    /*
    private static bool _meshObjectsNeedRebuilding = false;
    private static List<SceneCullObj> _rayTracingObjects = new List<SceneCullObj>();
    public static void RegisterObject(SceneCullObj obj)
    {
        _rayTracingObjects.Add(obj);
        _meshObjectsNeedRebuilding = true;
    }
    public static void UnregisterObject(SceneCullObj obj)
    {
        _rayTracingObjects.Remove(obj);
        _meshObjectsNeedRebuilding = true;
    }
    */
    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }
    private void SetShaderParameters()
    {
        SceneCullShader.SetMatrix("_CamToWorld", _camera.cameraToWorldMatrix);
        SceneCullShader.SetMatrix("_CamInvProj", _camera.projectionMatrix.inverse);
        SceneCullShader.SetTexture(0, "_SkyboxTexture", SkyboxTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetShaderParameters();
        Render(destination);
    }

    private void Render(RenderTexture dest)
    {
        InitRenderTexture();

        // Set the target and dispatch the compute shader
        SceneCullShader.SetTexture(0, "Result", _target);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        SceneCullShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);
        // Blit the result texture to the screen
        Graphics.Blit(_target, dest);
    }

    private void InitRenderTexture()
    {
        if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            if (_target != null)
                _target.Release();
            
            _target = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _target.enableRandomWrite = true;
            _target.Create();
        }
    }
}
