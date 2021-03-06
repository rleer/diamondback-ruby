{
open Forest_parser
exception Eof
}
rule token = parse
    [' ' '\t']        { token lexbuf }     (* skip blanks *)
  | ['\n' ]           { EOL }
  | ['0'-'9']+ as lxm { INT(int_of_string lxm) }
  | '+'               { PLUS }
  | eof | 'q' | 'e'   { raise Eof }
