extends Area3D

func _on_body_entered(body):
    var upgrade_manager = get_node("/root/UpgradeManager")
    upgrade_manager.reset_all()