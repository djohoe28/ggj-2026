using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzlePiece : MonoBehaviour
{
    public Vector3 targetPosition;
    public float snapDistance = 0.5f;

    public bool placedCorrectly = false;

    public void TrySnap()
    {
        if (placedCorrectly) return;

        float dist = Vector3.Distance(transform.position, targetPosition);

        if (dist <= snapDistance)
        {
            transform.position = targetPosition;
            placedCorrectly = true;

            // Disable grabbing & physics
            GetComponent<Collider2D>().enabled = false;
        }
    }
}

