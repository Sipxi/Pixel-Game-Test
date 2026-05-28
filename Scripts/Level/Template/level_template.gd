extends Node2D


@onready var camera: Camera2D = $LevelCamera





func _ready() -> void:
    var player = find_child("Player")

    if player and camera:
        var remote_transform = player.get_node_or_null("RemoteTransform2D")

        if remote_transform:
            camera.make_current()
            remote_transform.remote_path = camera.get_path()