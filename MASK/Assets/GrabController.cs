using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;


public class GrabController : MonoBehaviour
{
    public RectTransform cursor;
    public LayerMask pieceLayer;

    GameObject grabbed;
    Vector3 offset;

    void Update()
    {
        if (Gamepad.current == null) return;

        Vector3 cursorWorld = ScreenToWorld(cursor.position);

        if (Gamepad.current.buttonSouth.wasPressedThisFrame)
            TryGrab(cursorWorld);

        if (grabbed && Gamepad.current.buttonSouth.isPressed)
            grabbed.transform.position = cursorWorld + offset;

        if (grabbed && Gamepad.current.buttonSouth.wasReleasedThisFrame)
            Release();
    }

    void TryGrab(Vector3 pos)
    {
        if (grabbed) return;

        Collider2D hit = Physics2D.OverlapPoint(pos, pieceLayer);
        if (!hit) return;

        grabbed = hit.gameObject;
        offset = grabbed.transform.position - pos;
    }

    void Release()
    {
        PuzzlePiece piece = grabbed.GetComponent<PuzzlePiece>();
        piece.TrySnap();
        grabbed = null;
    }

    Vector3 ScreenToWorld(Vector2 screenPos)
    {
        Vector3 p = Camera.main.ScreenToWorldPoint(screenPos);
        p.z = 0;
        return p;
    }
}
