let get_file_path base_path path_parts =
  let slash = match Sys.os_type with "Win32" -> "\\" | _ -> "/" in

  base_path ^ List.fold_left (fun a b -> a ^ slash ^ b) slash path_parts
