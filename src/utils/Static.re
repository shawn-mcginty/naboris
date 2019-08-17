let getFilePath = (basePath, pathParts) => {
  let slash =
    switch (Sys.os_type) {
    | _ => "/"
    };
  basePath ++ List.fold_left((a, b) => a ++ slash ++ b, slash, pathParts);
};