﻿using UnityEngine;
using System.Collections;

public class Controller : MonoBehaviour
{
	public float moveSpeed = 6;
	Rigidbody rigidBody;
	Camera viewCamera;
	Vector3 velocity;
	void Start()
	{
		rigidBody = GetComponent<Rigidbody>();
		viewCamera = Camera.main;
	}
	void Update()
	{
		Vector3 mousePos = viewCamera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, viewCamera.transform.position.y));
		transform.LookAt(mousePos + Vector3.up * transform.position.y);
		velocity = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical")).normalized * moveSpeed;
	}
	void FixedUpdate()
	{
		rigidBody.MovePosition(rigidBody.position + velocity * Time.fixedDeltaTime);
	}
}