open Ospike_lib

module Po = Parser_options

(*********** COMMAND LINE TOOL ***********)
let command = 
  Core.Command.basic 
    ~summary:"🐫  OSpike - a tool for parsing Spike logs with OCaml  🐫"
    Core.Command.Let_syntax.(
      let%map_open 
            mode   = anon (maybe ("mode - <stdin|file>" %: string))
        and output = flag "-o" (optional string)  ~doc:"filename location for the results to be stored"
        and lower  = flag "-lower" (optional int) ~doc:"lower-bound on the address range to include in the stats"
        and upper  = flag "-upper" (optional int) ~doc:"upper-bound on the address range to include in the stats"
        and impl   = flag "-impl" (optional_with_default "regex" string) ~doc:"parsing-implementation decides whether to use <regex> or <string> implementation"
        and group  = flag "-group" (optional_with_default 1 int) ~doc:"size the size of the groups of adjacent instructions to look at (default 1)"
        and compare_mode = flag "-compare" (optional_with_default "instr" string) ~doc:"mode how to compare instructions - default is without registers, any other string will use registers except full which includes everything about the instruction"
      in
        fun () -> 
          match mode with 
            | Some "stdin" -> 
              let implementation : Po.impl = Po.impl_from_string impl in 
              let options : Po.t = 
                if compare_mode = "instr" then {lower; upper; group; implementation; compare_mode=Parser_options.Instr} 
                else if compare_mode = "full" then {lower; upper; group; implementation; compare_mode=Parser_options.Full}
                else {lower; upper; group; implementation; compare_mode=Parser_options.Instr_Reg} in
                let imp_name = Po.impl_to_string implementation in 
                let module P =
                  (val (try Core.Hashtbl.find_exn Parser.parsers imp_name
                        with Not_found -> Printf.eprintf "Unknown parser %s\n" imp_name; exit 2) : Parser.S) in 
                begin match output with 
                  | None -> P.(print_sorted stdout (from_stdin options) options)
                  | Some file -> 
                    let oc = open_out file in 
                      Printf.fprintf oc "%s\n" (Po.to_string options);
                      P.(print_sorted oc (from_stdin options) options)
                  end
            | Some "file"  -> print_endline "File"
            | None | Some _ -> print_endline "Please provide which mode <stdin|file> you wish to use"
    )

let () = Core.Command.run command 