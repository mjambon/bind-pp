let wrap_thread f loc_txt =
  fun x ->
    Lwt.catch
      (fun () ->
         try f x
         with e -> Trax.reraise_with_stack_trace e
      )
      (fun e -> Trax.raise loc_txt e)
