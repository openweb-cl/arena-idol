class_name GraphicsSettings
extends RefCounted
static var low := false

static func apply(viewport: Viewport, light: DirectionalLight3D) -> void:
	light.shadow_enabled = not low
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		viewport.scaling_3d_scale = 0.75 if low else 1.0
