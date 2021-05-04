using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SineWaveCubes : MonoBehaviour
{
    public bool CalculateOnShader = false;
    public ComputeShader WaveShader;
    public ComputeBuffer posBuffer;
    [Range(5, 1000)]
    public int numCubes;
    public int resolution;
    public GameObject cubePrefab;
    public List<GameObject> cubes;
    float time = 0;
    public int index = 0;
    public Mesh mesh;
    public Material material;
    /*
    static readonly int 
        positionsId = Shader.PropertyToID("_Positions"),
        resolutionId = Shader.PropertyToID("_Resolution"),
        stepId = Shader.PropertyToID("_Step"),
        timeId = Shader.PropertyToID("_Time");
    */
    // Start is called before the first frame update
    /*
    private void OnEnable()
    {
        posBuffer = new ComputeBuffer(resolution * resolution, 3*4);
    }
    private void OnDisable()
    {
        posBuffer.Release();
        posBuffer = null;
    }
    */
    void Start()
    { 
        
        for(int i = 0; i < numCubes; i++)
        {
            cubes.Add(Instantiate(cubePrefab, new Vector3(i, 0, 0), Quaternion.identity));
        }
        WaveShader.SetInt("_Resolution", resolution);
    }

    // Update is called once per frame
    void Update()
    {
        
        
        //material = GetComponent<MaterialHolder>().materials[index];
        time += Time.deltaTime;

        for (int i = 0; i < numCubes; i++)
        {
            cubes[i].GetComponent<MeshRenderer>().enabled = !CalculateOnShader;
            cubes[i].GetComponent<MeshRenderer>().material = cubes[i].GetComponent<MaterialHolder>().materials[index];
            if (CalculateOnShader)
            {
                WaveShader.SetFloat("_Offset", i);
                //WaveShader.Dispatch(0, 1, 1, 1);
                var bounds = new Bounds(new Vector3(cubes[i].transform.position.x, Mathf.Sin(Time.time + i),cubes[i].transform.position.z), Vector3.one);
                Graphics.DrawMeshInstancedProcedural(mesh, 0, material, bounds, 1);
                
            }
        }
    }
}
