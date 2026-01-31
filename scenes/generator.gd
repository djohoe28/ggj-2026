@tool
extends Node

const ENTITY_BASE_PATH := "res://scenes/entities/entity.tscn"
const ENTITY_BASE_UID := "uid://r0hndivp7jre"
const ENTITY_ROOT_UNIQUE_ID := 1284932722
const ENTITY_OUTPUT_DIR := "res://scenes/entities/tiles/"

@export_tool_button("Generate Entities") var generate_action = generate

func generate():
	for visible_to_player1 in [true, false]:
		for visible_to_player2 in [true, false]:
			for relationship_with_player1 in [Entity.Relationship.GHOST, Entity.Relationship.MOVABLE, Entity.Relationship.IMMOVABLE, Entity.Relationship.CONTROLLED]:
				for relationship_with_player2 in [Entity.Relationship.GHOST, Entity.Relationship.MOVABLE, Entity.Relationship.IMMOVABLE, Entity.Relationship.CONTROLLED]:
					# Determine the name of the Entity.
					var _color: String
					if visible_to_player1 and visible_to_player2:
						_color = "Both"
					elif visible_to_player1:
						_color = "Blue"
					elif visible_to_player2:
						_color = "Red"
					else:
						_color = "None"

					var _type1: String
					match relationship_with_player1:
						Entity.Relationship.GHOST:
							_type1 = "Ghost"
						Entity.Relationship.MOVABLE:
							_type1 = "Movable"
						Entity.Relationship.IMMOVABLE:
							_type1 = "Immovable"
						Entity.Relationship.CONTROLLED:
							_type1 = "Controlled"

					var _type2: String
					match relationship_with_player2:
						Entity.Relationship.GHOST:
							_type2 = "Ghost"
						Entity.Relationship.MOVABLE:
							_type2 = "Movable"
						Entity.Relationship.IMMOVABLE:
							_type2 = "Immovable"
						Entity.Relationship.CONTROLLED:
							_type2 = "Controlled"

					var entity_name := _color + "_" + _type1 + "_" + _type2
					var output_path := ENTITY_OUTPUT_DIR + entity_name + ".tscn"

					# Create inherited scene content: root node instances entity.tscn with overrides.
					var uid_int := ResourceUID.create_id()
					var uid_text := ResourceUID.id_to_text(uid_int)
					ResourceUID.add_id(uid_int, output_path)

					var content := _build_inherited_scene_content(
						uid_text,
						entity_name,
						visible_to_player1,
						visible_to_player2,
						int(relationship_with_player1),
						int(relationship_with_player2)
					)

					var file := FileAccess.open(output_path, FileAccess.WRITE)
					if file == null:
						push_error("Generator: Failed to open " + output_path + " for writing")
						continue

					file.store_string(content)
					file.close()

func _build_inherited_scene_content(uid: String, entity_name: String, visible_p1: bool, visible_p2: bool, rel_p1: int, rel_p2: int) -> String:
	return (
		"[gd_scene load_steps=2 format=3 uid=\"%s\"]\n\n"
		+ "[ext_resource type=\"PackedScene\" uid=\"%s\" path=\"%s\" id=\"1_entity\"]\n\n"
		+ "[node name=\"%s\" type=\"StaticBody2D\" unique_id=%d instance=ExtResource(\"1_entity\")]\n"
		+ "visible_to_player1 = %s\n"
		+ "visible_to_player2 = %s\n"
		+ "relationship_with_player1 = %d\n"
		+ "relationship_with_player2 = %d\n"
	) % [uid, ENTITY_BASE_UID, ENTITY_BASE_PATH, entity_name, ENTITY_ROOT_UNIQUE_ID, visible_p1, visible_p2, rel_p1, rel_p2]
