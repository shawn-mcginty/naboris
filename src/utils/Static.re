let getFilePath = (basePath, pathParts) => {
  let slash =
    switch (Sys.os_type) {
    | "Win32" => "\\"
    | _ => "/"
    };
  basePath ++ List.fold_left((a, b) => a ++ slash ++ b, slash, pathParts);
};