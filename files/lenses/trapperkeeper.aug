(*
Module: Trapperkeeper
  Parses Trapperkeeper configuration files

Author: Raphael Pinson <raphael.pinson@camptocamp.com>

About: License
   This file is licenced under the LGPL v2+, like the rest of Augeas.

About: Lens Usage
   To be documented

About: Configuration files
   This lens applies to Trapperkeeper webservice configuration files. See <filter>.

About: Examples
   The <Test_Trapperkeeper> file contains various examples and tests.
*)
module Trapperkeeper =

autoload xfm

(************************************************************************
 * Group:                 USEFUL PRIMITIVES
 *************************************************************************)

(* View: empty *)
let empty = Util.empty

(* View: comment *)
let comment = Util.comment

(* View: sep *)
let sep = del /[ \t]*[:=]/ ":"

(* View: sep_with_spc *)
let sep_with_spc = sep . Sep.opt_space

(************************************************************************
 * Group:                 ENTRY TYPES
 *************************************************************************)

(* View: simple *)
let simple = [ Util.indent . key Rx.word
             . sep_with_spc . store /[^\[ \t\n]+/ . Util.eol ]

(* View: array *)
let array =
     let lbrack = Util.del_str "["
  in let rbrack = Util.del_str "]"
  in let comma = Util.delim ","
  in let elem = [ seq "elem" . store Rx.neg1 ]
  in let elems = counter "elem" . Build.opt_list elem comma
  in [ Util.indent . key Rx.word
     . sep_with_spc . lbrack . Sep.opt_space
     . (elems . Sep.opt_space)?
     . rbrack . Util.eol ]

(* View: hash *)
let hash (lns:lens) = [ Util.indent . key Rx.word . sep
               . Build.block_newlines lns Util.comment
               . Util.eol ]


(************************************************************************
 * Group:                   ENTRY
 *************************************************************************)

(* Just for typechecking *)
let entry_no_rec = hash (simple|array)

(* View: entry *)
let rec entry = hash (entry|simple|array)

(************************************************************************
 * Group:                LENS AND FILTER
 *************************************************************************)

(* View: lns *)
let lns = (empty|comment)* . (entry . (empty|comment)*)*

(* Variable: filter *)
let filter = incl "/etc/puppetserver/conf.d/*"
           . Util.stdexcl

let xfm = transform lns filter