class_name MatchReport
extends RefCounted
## Evidencia de pruebas local, sin cuentas, identificadores personales ni red.
static func save(data: Dictionary) -> String:
	var directory := "user://playtests"
	var result := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	if result != OK:
		push_warning("No se pudo crear el directorio de pruebas locales")
		return ""
	var path := directory.path_join("match-%d-%d.json" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()])
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar el informe de partida")
		return ""
	file.store_string(JSON.stringify(data, "\t"))
	return path
