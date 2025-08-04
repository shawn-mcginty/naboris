(** Exposed only for unit testing *)
val getExtension : string -> string

(** Given a filename returns content type.
    Defaults to ["text/plain"] if type cannot be inferred. *)
val getMimeType : string -> string 