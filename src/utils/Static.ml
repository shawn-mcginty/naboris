let getFilePath basePath pathParts =
  let slash =
    match Sys.os_type with
    | _ -> "/"
  in
  basePath ^ List.fold_left (fun a b -> a ^ slash ^ b) slash pathParts 