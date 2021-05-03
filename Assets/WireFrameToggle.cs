using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WireFrameToggle : MonoBehaviour
{
    bool active = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        active = !active;
        this.GetComponent<WireFrame>().enabled = active;
    }
}
