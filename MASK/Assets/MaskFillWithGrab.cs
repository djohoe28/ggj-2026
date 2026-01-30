using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

public class MaskFillWithGrab : MonoBehaviour
{
    public Image blueFill;
    public Image redFill;

    public RectTransform cursor;
    public float fillSpeed = 0.4f;

    void Update()
    {
        if (Gamepad.current == null) return;

        bool grabbing = Gamepad.current.buttonSouth.isPressed;
        if (!grabbing) return;

        Vector2 cursorPos = cursor.position;

        if (IsOverImage(cursorPos, blueFill))
            blueFill.fillAmount += fillSpeed * Time.deltaTime;

        if (IsOverImage(cursorPos, redFill))
            redFill.fillAmount += fillSpeed * Time.deltaTime;

        blueFill.fillAmount = Mathf.Clamp01(blueFill.fillAmount);
        redFill.fillAmount = Mathf.Clamp01(redFill.fillAmount);
    }

    bool IsOverImage(Vector2 screenPos, Image img)
    {
        return RectTransformUtility.RectangleContainsScreenPoint(
            img.rectTransform,
            screenPos,
            null
        );
    }
}
