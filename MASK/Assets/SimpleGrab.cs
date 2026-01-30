using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class SimpleGrab : MonoBehaviour
{
    [Header("Cursor Settings")]
    public RectTransform cursor;
    public float cursorSpeed = 500f;
    
    [Header("Grab Settings")]
    public LayerMask pieceLayer;
    public float grabRadius = 0.5f; // Try a radius instead of point

    private GameObject grabbed;
    private Rigidbody2D rb;
    private Vector3 offset;

   void Update()
{
    if (Gamepad.current == null) return;

    Vector3 worldPos = Camera.main.ScreenToWorldPoint(
        new Vector3(
            cursor.position.x,
            cursor.position.y,
            Mathf.Abs(Camera.main.transform.position.z)
        )
    );
    worldPos.z = 0;

    Debug.Log("World Position: " + worldPos);

    if (Gamepad.current.buttonSouth.wasPressedThisFrame)
    {
        Collider2D hit = Physics2D.OverlapPoint(worldPos);
        if (hit)
        {
            grabbed = hit.gameObject;
            rb = grabbed.GetComponent<Rigidbody2D>();
            offset = rb.position - (Vector2)worldPos;
            Debug.Log("GRABBED: " + grabbed.name);
        }
        else
        {
            Debug.Log("No object grabbed");
        }
    }

    if (grabbed && Gamepad.current.buttonSouth.isPressed)
    {
        rb.MovePosition(worldPos + offset);
    }

    if (grabbed && Gamepad.current.buttonSouth.wasReleasedThisFrame)
    {
        Debug.Log("DROPPED: " + grabbed.name);
        grabbed = null;
        rb = null;
    }

    Debug.DrawRay(worldPos, Vector3.up * 0.5f, Color.green);

}


}
