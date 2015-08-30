(*
   Enable exception tracing by replacing calls to the Lwt bind operator >>=
   by a call that records the source code location.
*)

open Camlp4
open Camlp4.PreCast
open Syntax

let string_of_loc loc =
  let start = Loc.start_pos loc in
  let stop = Loc.stop_pos loc in
  let open Lexing in
  let char1 = start.pos_cnum - start.pos_bol in
  let char2 = char1 + stop.pos_cnum - start.pos_cnum - 1 in
  Printf.sprintf "File %S, line %i, characters %i-%i"
    start.pos_fname
    start.pos_lnum
    char1 char2

let map_anonymous_bind = object
  inherit Ast.map as super
  method expr e = match super#expr e with
    | <:expr@_loc< $lid:f$ $a$ $b$ >> when f = ">>=" ->
        let b_loc =
          String.escaped (string_of_loc (Ast.loc_of_expr b))
        in
        <:expr< Lwt.bind $a$ (Pa_bind_runtime.wrap_thread $b$ $str:b_loc$) >>

    | e -> e
end

let () =
  AstFilters.register_str_item_filter map_anonymous_bind#str_item;
  AstFilters.register_topphrase_filter map_anonymous_bind#str_item
