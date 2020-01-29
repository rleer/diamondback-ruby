# 1 "dypgen_lexer.mll"
 
open Dypgen_parser
open Lexing

let ($) = Buffer.add_string
let ocaml_code_buffer = Buffer.create 100000
(*let paren_count = ref 0*)
let in_string = ref false
let comment_count = ref 0
(*let dypgen_comment = ref 0*)
let look_for_type = ref false

let start_ocaml_type = ref dummy_pos
let start_ocaml_code = ref dummy_pos
let start_curlyb = ref []
let start_bracket = ref []
let start_pattern = ref dummy_pos
let start_dypgen_comment = ref []
let start_ocaml_comment = ref []
let start_string = ref dummy_pos

let update_loc lexbuf file line absolute chars =
  let pos = lexbuf.lex_curr_p in
  let new_file = match file with
                 | None -> pos.pos_fname
                 | Some s -> s
  in
  lexbuf.lex_curr_p <- { pos with
    pos_fname = new_file;
    pos_lnum = if absolute then line else pos.pos_lnum + line;
    pos_bol = pos.pos_cnum - chars;
  }

# 36 "dypgen_lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\229\255\230\255\231\255\000\000\233\255\234\255\236\255\
    \237\255\238\255\239\255\240\255\241\255\242\255\218\000\170\001\
    \026\000\002\000\005\000\255\255\235\255\015\000\016\000\018\000\
    \029\000\030\000\016\000\022\000\022\000\031\000\038\000\034\000\
    \253\255\044\000\246\255\049\000\033\000\032\000\252\255\041\000\
    \053\000\035\000\047\000\042\000\044\000\251\255\041\000\051\000\
    \250\255\054\000\057\000\007\000\245\255\049\000\045\000\045\000\
    \048\000\046\000\065\000\049\000\055\000\053\000\249\255\054\000\
    \248\255\059\000\001\000\054\000\070\000\058\000\064\000\069\000\
    \065\000\079\000\069\000\247\255\232\255\007\000\252\255\008\000\
    \253\255\001\000\001\000\255\255\254\255\160\002\245\255\011\000\
    \246\255\004\000\004\000\249\255\250\255\001\000\252\255\253\255\
    \254\255\255\255\251\255\248\255\247\255\043\001\252\255\012\000\
    \253\255\254\255\002\000\255\255";
  Lexing.lex_backtrk = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\012\000\011\000\
    \255\255\001\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\002\000\
    \255\255\003\000\003\000\255\255\255\255\255\255\255\255\009\000\
    \255\255\010\000\010\000\255\255\255\255\010\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\002\000\
    \255\255\255\255\003\000\255\255";
  Lexing.lex_default = 
   "\255\255\000\000\000\000\000\000\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255\255\255\
    \255\255\255\255\255\255\000\000\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\000\000\255\255\255\255\255\255\000\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\000\000\255\255\255\255\
    \000\000\255\255\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\000\000\000\000\078\000\000\000\255\255\
    \000\000\255\255\255\255\000\000\000\000\086\000\000\000\255\255\
    \000\000\255\255\255\255\000\000\000\000\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\102\000\000\000\255\255\
    \000\000\000\000\255\255\000\000";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\017\000\019\000\017\000\017\000\018\000\017\000\019\000\
    \052\000\080\000\080\000\052\000\079\000\088\000\104\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \017\000\000\000\017\000\098\000\000\000\016\000\000\000\052\000\
    \013\000\012\000\076\000\083\000\010\000\100\000\099\000\004\000\
    \084\000\081\000\000\000\000\000\000\000\000\000\082\000\000\000\
    \000\000\000\000\008\000\009\000\006\000\002\000\007\000\020\000\
    \107\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\011\000\000\000\000\000\000\000\015\000\
    \067\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\005\000\003\000\023\000\065\000\063\000\
    \022\000\053\000\046\000\039\000\035\000\029\000\033\000\024\000\
    \021\000\047\000\030\000\031\000\025\000\026\000\027\000\028\000\
    \032\000\034\000\036\000\037\000\038\000\040\000\041\000\042\000\
    \043\000\044\000\045\000\049\000\048\000\050\000\051\000\054\000\
    \055\000\056\000\057\000\058\000\059\000\060\000\061\000\062\000\
    \064\000\066\000\068\000\069\000\070\000\071\000\072\000\073\000\
    \074\000\075\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\000\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\000\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \001\000\014\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \000\000\000\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\104\000\000\000\000\000\
    \103\000\014\000\000\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\000\000\000\000\000\000\
    \106\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\105\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\000\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\015\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\000\000\000\000\000\000\
    \000\000\015\000\000\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\000\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\000\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\088\000\000\000\000\000\087\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\092\000\000\000\094\000\000\000\000\000\000\000\
    \090\000\000\000\089\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\095\000\093\000\096\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\091\000\000\000\097\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \255\255";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\017\000\000\000\000\000\017\000\018\000\
    \051\000\077\000\079\000\051\000\077\000\087\000\103\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\017\000\093\000\255\255\000\000\255\255\051\000\
    \000\000\000\000\004\000\082\000\000\000\089\000\090\000\000\000\
    \081\000\077\000\255\255\255\255\255\255\255\255\077\000\255\255\
    \255\255\255\255\000\000\000\000\000\000\000\000\000\000\016\000\
    \106\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\255\255\255\255\255\255\000\000\
    \066\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\016\000\021\000\022\000\
    \016\000\023\000\024\000\025\000\026\000\027\000\028\000\016\000\
    \016\000\024\000\029\000\030\000\016\000\016\000\016\000\027\000\
    \031\000\033\000\035\000\036\000\037\000\039\000\040\000\041\000\
    \042\000\043\000\044\000\046\000\047\000\049\000\050\000\053\000\
    \054\000\055\000\056\000\057\000\058\000\059\000\060\000\061\000\
    \063\000\065\000\067\000\068\000\069\000\070\000\071\000\072\000\
    \073\000\074\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\014\000\255\255\255\255\255\255\255\255\255\255\077\000\
    \255\255\255\255\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\101\000\255\255\255\255\
    \101\000\014\000\255\255\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\255\255\255\255\255\255\
    \101\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\101\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\255\255\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\015\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\014\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\255\255\255\255\255\255\
    \255\255\015\000\255\255\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\101\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\255\255\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\255\255\015\000\015\000\015\000\015\000\015\000\015\000\
    \015\000\015\000\085\000\255\255\255\255\085\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\085\000\255\255\085\000\255\255\255\255\255\255\
    \085\000\255\255\085\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\085\000\085\000\085\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\085\000\255\255\085\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \085\000";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 44 "dypgen_lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        token lexbuf
      )
# 342 "dypgen_lexer.ml"

  | 1 ->
# 48 "dypgen_lexer.mll"
      ( token lexbuf )
# 347 "dypgen_lexer.ml"

  | 2 ->
# 49 "dypgen_lexer.mll"
             ( look_for_type:=true; KWD_TOKEN )
# 352 "dypgen_lexer.ml"

  | 3 ->
# 50 "dypgen_lexer.mll"
             ( look_for_type:=true; KWD_START )
# 357 "dypgen_lexer.ml"

  | 4 ->
# 51 "dypgen_lexer.mll"
                ( look_for_type:=false; KWD_RELATION )
# 362 "dypgen_lexer.ml"

  | 5 ->
# 52 "dypgen_lexer.mll"
           ( KWD_MLI )
# 367 "dypgen_lexer.ml"

  | 6 ->
# 53 "dypgen_lexer.mll"
                   ( KWD_CONSTRUCTOR )
# 372 "dypgen_lexer.ml"

  | 7 ->
# 54 "dypgen_lexer.mll"
           ( KWD_FOR )
# 377 "dypgen_lexer.ml"

  | 8 ->
# 55 "dypgen_lexer.mll"
                    ( KWD_NON_TERMINAL )
# 382 "dypgen_lexer.ml"

  | 9 ->
# 56 "dypgen_lexer.mll"
            ( KWD_TYPE )
# 387 "dypgen_lexer.ml"

  | 10 ->
# 57 "dypgen_lexer.mll"
                   ( KWD_MERGE )
# 392 "dypgen_lexer.ml"

  | 11 ->
# 59 "dypgen_lexer.mll"
      ( let pos = lexeme_start_p lexbuf in
        let line = pos.pos_lnum in
        let col1 = pos.pos_cnum - pos.pos_bol in
        let col2 = lexbuf.lex_curr_p.pos_cnum - lexbuf.lex_curr_p.pos_bol in
        LIDENT((Lexing.lexeme lexbuf),(line,col1,col2)) )
# 401 "dypgen_lexer.ml"

  | 12 ->
# 65 "dypgen_lexer.mll"
      ( let pos = lexeme_start_p lexbuf in
        let line = pos.pos_lnum in
        let col1 = pos.pos_cnum - pos.pos_bol in
        let col2 = lexbuf.lex_curr_p.pos_cnum - lexbuf.lex_curr_p.pos_bol in
        UIDENT((Lexing.lexeme lexbuf),(line,col1,col2)) )
# 410 "dypgen_lexer.ml"

  | 13 ->
# 70 "dypgen_lexer.mll"
         ( LPAREN )
# 415 "dypgen_lexer.ml"

  | 14 ->
# 71 "dypgen_lexer.mll"
         ( RPAREN )
# 420 "dypgen_lexer.ml"

  | 15 ->
# 73 "dypgen_lexer.mll"
      ( Buffer.clear ocaml_code_buffer;
        let pos = lexeme_start_p lexbuf in
        start_pattern := pos;
        (*paren_count:=1;*)
        ocaml_code lexbuf;
        PATTERN (Buffer.contents ocaml_code_buffer,
          (pos.pos_lnum,pos.pos_cnum-pos.pos_bol))
      )
# 432 "dypgen_lexer.ml"

  | 16 ->
# 81 "dypgen_lexer.mll"
         ( COMMA )
# 437 "dypgen_lexer.ml"

  | 17 ->
# 82 "dypgen_lexer.mll"
         ( SEMI )
# 442 "dypgen_lexer.ml"

  | 18 ->
# 83 "dypgen_lexer.mll"
         ( COLON )
# 447 "dypgen_lexer.ml"

  | 19 ->
# 84 "dypgen_lexer.mll"
         ( GREATER )
# 452 "dypgen_lexer.ml"

  | 20 ->
# 85 "dypgen_lexer.mll"
         ( look_for_type:=false; PERCENTPERCENT )
# 457 "dypgen_lexer.ml"

  | 21 ->
# 87 "dypgen_lexer.mll"
      ( if !look_for_type=false then LESS
        else
          (Buffer.clear ocaml_code_buffer;
          start_ocaml_type := lexeme_start_p lexbuf;
          ocaml_type lexbuf;
          OCAML_TYPE (Buffer.contents ocaml_code_buffer))
      )
# 468 "dypgen_lexer.ml"

  | 22 ->
# 95 "dypgen_lexer.mll"
      ( Buffer.clear ocaml_code_buffer;
        let pos = lexeme_start_p lexbuf in
        start_ocaml_code := pos;
        ocaml_code lexbuf;
        OCAML_CODE (Buffer.contents ocaml_code_buffer,
          (pos.pos_lnum,pos.pos_cnum-pos.pos_bol))
      )
# 479 "dypgen_lexer.ml"

  | 23 ->
# 103 "dypgen_lexer.mll"
       ( (*dypgen_comment := !dypgen_comment+1;*)
         start_dypgen_comment := (lexeme_start_p lexbuf)::(!start_dypgen_comment);
         comment lexbuf; token lexbuf )
# 486 "dypgen_lexer.ml"

  | 24 ->
# 106 "dypgen_lexer.mll"
         ( BAR )
# 491 "dypgen_lexer.ml"

  | 25 ->
# 107 "dypgen_lexer.mll"
         ( EQUAL )
# 496 "dypgen_lexer.ml"

  | 26 ->
# 108 "dypgen_lexer.mll"
        ( EOF )
# 501 "dypgen_lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 77
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 111 "dypgen_lexer.mll"
         ( (*dypgen_comment := !dypgen_comment+1;*)
           start_dypgen_comment := (lexeme_start_p lexbuf)::(!start_dypgen_comment);
           comment lexbuf )
# 515 "dypgen_lexer.ml"

  | 1 ->
# 115 "dypgen_lexer.mll"
      ( (*dypgen_comment := !dypgen_comment-1;*)
         start_dypgen_comment := List.tl (!start_dypgen_comment);
         if !start_dypgen_comment=[] then () else comment lexbuf )
# 522 "dypgen_lexer.ml"

  | 2 ->
# 119 "dypgen_lexer.mll"
      ( update_loc lexbuf None 1 false 0; comment lexbuf )
# 527 "dypgen_lexer.ml"

  | 3 ->
# 120 "dypgen_lexer.mll"
      ( comment lexbuf )
# 532 "dypgen_lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and ocaml_code lexbuf =
    __ocaml_lex_ocaml_code_rec lexbuf 85
and __ocaml_lex_ocaml_code_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 124 "dypgen_lexer.mll"
      ( 
        if !in_string = false && !comment_count = 0 then
          begin
            match !start_curlyb with
              | [] ->
                if !start_ocaml_code=dummy_pos then (
                  ocaml_code_buffer $ "}";
                  ocaml_code lexbuf)
                else start_ocaml_code:=dummy_pos
              | _::tl ->
                  start_curlyb:=tl;
                  ocaml_code_buffer $ "}";
                  ocaml_code lexbuf

            (*if (!paren_count) = 0 then start_ocaml_code := dummy_pos
            else
              let _ = ocaml_code_buffer $
                (String.make 1 (Lexing.lexeme_char lexbuf 0)) in
              let _ = paren_count := ((!paren_count)-1) in
              ocaml_code lexbuf*)
          end
        else
          begin
            ocaml_code_buffer $ "}";
            ocaml_code lexbuf
          end
      )
# 570 "dypgen_lexer.ml"

  | 1 ->
# 151 "dypgen_lexer.mll"
        ( if !in_string=false && !comment_count=0 then (
          match !start_bracket with
            | _::tl -> start_bracket := tl;
                ocaml_code_buffer $ "]";
                ocaml_code lexbuf
            | [] ->
                if !start_pattern=dummy_pos then (
                  ocaml_code_buffer $ "]";
                  ocaml_code lexbuf)
                else
                  start_pattern:=dummy_pos)
          else (
            ocaml_code_buffer $ "]";
            ocaml_code lexbuf) )
# 588 "dypgen_lexer.ml"

  | 2 ->
# 165 "dypgen_lexer.mll"
        ( if !in_string=false && !comment_count=0 then
            start_bracket := (lexeme_start_p lexbuf)::(!start_bracket);
          ocaml_code_buffer $ "[";
          ocaml_code lexbuf )
# 596 "dypgen_lexer.ml"

  | 3 ->
# 170 "dypgen_lexer.mll"
      ( (if !in_string then ocaml_code_buffer $ "$"
      else ocaml_code_buffer $ "_");
        ocaml_code lexbuf
      )
# 604 "dypgen_lexer.ml"

  | 4 ->
# 175 "dypgen_lexer.mll"
      ( ocaml_code_buffer $ "\\\"";
        ocaml_code lexbuf
      )
# 611 "dypgen_lexer.ml"

  | 5 ->
# 179 "dypgen_lexer.mll"
      ( 
        if !in_string then (in_string := false; start_string := dummy_pos)
        else (in_string := true; start_string := lexeme_start_p lexbuf);
        ocaml_code_buffer $ "\"";
        ocaml_code lexbuf
      )
# 621 "dypgen_lexer.ml"

  | 6 ->
# 186 "dypgen_lexer.mll"
      ( ocaml_code_buffer $ "{";
        if !in_string = false && !comment_count = 0 then
          start_curlyb := (lexeme_start_p lexbuf)::!start_curlyb;
          (*paren_count := (!paren_count)+1;*)
        ocaml_code lexbuf
      )
# 631 "dypgen_lexer.ml"

  | 7 ->
# 193 "dypgen_lexer.mll"
      ( 
        if !in_string then () else (comment_count := !comment_count + 1;
          start_ocaml_comment :=
            (lexeme_start_p lexbuf)::(!start_ocaml_comment));
        ocaml_code_buffer $ "(*";
        ocaml_code lexbuf
      )
# 642 "dypgen_lexer.ml"

  | 8 ->
# 201 "dypgen_lexer.mll"
      ( 
        if !in_string then () else (comment_count := !comment_count - 1;
          start_ocaml_comment := List.tl (!start_ocaml_comment));
        ocaml_code_buffer $ "*)";
        ocaml_code lexbuf
      )
# 652 "dypgen_lexer.ml"

  | 9 ->
# 208 "dypgen_lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        ocaml_code_buffer $
          (String.make 1 (Lexing.lexeme_char lexbuf 0));
        ocaml_code lexbuf
      )
# 661 "dypgen_lexer.ml"

  | 10 ->
# 214 "dypgen_lexer.mll"
      ( ocaml_code_buffer $
          (String.make 1 (Lexing.lexeme_char lexbuf 0));
        ocaml_code lexbuf
      )
# 669 "dypgen_lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_ocaml_code_rec lexbuf __ocaml_lex_state

and ocaml_type lexbuf =
    __ocaml_lex_ocaml_type_rec lexbuf 101
and __ocaml_lex_ocaml_type_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 221 "dypgen_lexer.mll"
      ( ocaml_code_buffer $ "->";
        ocaml_type lexbuf
      )
# 683 "dypgen_lexer.ml"

  | 1 ->
# 224 "dypgen_lexer.mll"
        ( start_ocaml_type := dummy_pos; () )
# 688 "dypgen_lexer.ml"

  | 2 ->
# 226 "dypgen_lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        ocaml_code_buffer $
          (String.make 1 (Lexing.lexeme_char lexbuf 0));
        ocaml_type lexbuf
      )
# 697 "dypgen_lexer.ml"

  | 3 ->
# 232 "dypgen_lexer.mll"
      ( ocaml_code_buffer $
          (String.make 1 (Lexing.lexeme_char lexbuf 0));
        ocaml_type lexbuf
      )
# 705 "dypgen_lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_ocaml_type_rec lexbuf __ocaml_lex_state

;;

