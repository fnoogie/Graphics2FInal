using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WireFrame : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnPreRender()
    {
        GL.wireframe = true;
    }
    private void OnPostRender()
    {
        GL.wireframe = false;
    }
}
