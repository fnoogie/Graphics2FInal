using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    float moveSpeed = 5;
    float zoomSpeed = 5;

    float minZoom;
    float maxZoom;

    float rotateSpeed = 5;
    float rotateSensitivity = 10;

    Camera camera;
    float upDown;
    // Start is called before the first frame update
    void Start()
    {
        camera = this.GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.E))
        {
            upDown = 1;
        }
        else if (Input.GetKey(KeyCode.Q))
        {
            upDown = -1;
        }
        else
        {
            upDown = 0;
        }
        transform.position += (transform.forward * Input.GetAxis("Vertical") + transform.right * Input.GetAxis("Horizontal") + transform.up * upDown) * moveSpeed * Time.deltaTime;

        if (Input.GetMouseButton(0))
        {
            float rotationX = -Input.GetAxis("Mouse Y") * rotateSensitivity;
            float rotationY = Input.GetAxis("Mouse X") * rotateSensitivity;
            camera.transform.localEulerAngles += new Vector3(rotationX, rotationY, 0);
        }
    }
}
