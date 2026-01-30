using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class GamepadCursor : MonoBehaviour
{
    public RectTransform cursor;
    public float speed = 1200f;

    Vector2 position;

    void Start()
    {
        position = cursor.position;
        Cursor.visible = false; // optional
    }

    void Update()
    {
        if (Gamepad.current == null) return;

        Vector2 stick = Gamepad.current.leftStick.ReadValue();
        position += stick * speed * Time.deltaTime;

        // Clamp to screen
        position.x = Mathf.Clamp(position.x, 0, Screen.width);
        position.y = Mathf.Clamp(position.y, 0, Screen.height);

        cursor.position = position;
    }
}
