@tool
extends Node

const ENTITY_BASE_PATH := "res://scenes/entities/entity.tscn"
const ENTITY_BASE_UID := "uid://r0hndivp7jre"
const ENTITY_ROOT_UNIQUE_ID := 1284932722
const ENTITY_OUTPUT_DIR := "res://scenes/entities/tiles/"

const ENTITY_KINDS := [
	["Wall", Entity.EntityKind.WALL],
	["Box", Entity.EntityKind.BOX],
	["P1_Box", Entity.EntityKind.P1_BOX],
	["P2_Box", Entity.EntityKind.P2_BOX],
	["P1_Body", Entity.EntityKind.P1_BODY],
	["P2_Body", Entity.EntityKind.P2_BODY],
	["Goal", Entity.EntityKind.GOAL]
]

@export_tool_button("Generate Entities") var generate_action = generate

func generate():
	for entry in ENTITY_KINDS:
		var entity_name: String = entry[0]
		var kind: Entity.EntityKind = entry[1]
		var output_path := ENTITY_OUTPUT_DIR + entity_name + ".tscn"

		var uid_int := ResourceUID.create_id()
		var uid_text := ResourceUID.id_to_text(uid_int)
		ResourceUID.add_id(uid_int, output_path)

		var content := _build_inherited_scene_content(uid_text, entity_name, int(kind))

		var file := FileAccess.open(output_path, FileAccess.WRITE)
		if file == null:
			push_error("Generator: Failed to open " + output_path + " for writing")
			continue

		file.store_string(content)
		file.close()

func _build_inherited_scene_content(uid: String, entity_name: String, entity_kind: int) -> String:
	return (
		"[gd_scene load_steps=2 format=3 uid=\"%s\"]\n\n"
		+ "[ext_resource type=\"PackedScene\" uid=\"%s\" path=\"%s\" id=\"1_entity\"]\n\n"
		+ "[node name=\"%s\" type=\"StaticBody2D\" unique_id=%d instance=ExtResource(\"1_entity\")]\n"
		+ "entity_kind = %d\n"
	) % [uid, ENTITY_BASE_UID, ENTITY_BASE_PATH, entity_name, ENTITY_ROOT_UNIQUE_ID, entity_kind]
