#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let uutf = Conf.with_pkg "uutf"
let cmdliner = Conf.with_pkg "cmdliner"

let build_support () =
  let ocaml = Conf.tool "ocaml" `Build_os in
  OS.Cmd.run Cmd.(ocaml % "pkg/build_support.ml")

let distrib =
  (* FIXME OPAMv2, move this to an x-unicode-version field in the opam file. *)
  let watermarks = ("UNICODE_VERSION", `String "10.0.0") :: Pkg.watermarks in
  let exclude_paths () = Pkg.exclude_paths () >>| fun ps -> "support" :: ps in
  Pkg.distrib ~watermarks ~massage:build_support ~exclude_paths ()

let () =
  Pkg.describe "uucp" ~distrib @@ fun c ->
  let uutf = Conf.value c uutf in
  let cmdliner = Conf.value c cmdliner in
  Ok [ Pkg.mllib ~api:["Uucp"] "src/uucp.mllib";
       Pkg.bin ~cond:(uutf && cmdliner) "test/ucharinfo";
       Pkg.test ~run:false "test/test";
       Pkg.test "test/perf";
       Pkg.test "test/examples";
       Pkg.test "test/link_test";
       Pkg.doc "DEVEL.md";
       Pkg.doc "test/examples.ml"; ]
