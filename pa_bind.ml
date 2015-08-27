(*
   Enable exception tracing by replacing calls to the Lwt bind operator >>=
   by a call that records the source code location.
*)

open Camlp4
open Camlp4.PreCast
open Syntax

let map_anonymous_bind = object
  inherit Ast.map as super
  method expr e = match super#expr e with
    | <:expr@_loc< $lid:f$ $a$ $b$ >> when f = ">>=" ->
        <:expr< Lwt.backtrace_bind
                   (fun e -> try Pa_bind_runtime.reraise e with e -> e)
                   $a$ $b$ >>
    | e -> e
end

let () =
  AstFilters.register_str_item_filter map_anonymous_bind#str_item;
  AstFilters.register_topphrase_filter map_anonymous_bind#str_item
