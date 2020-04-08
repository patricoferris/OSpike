open Ospike_lib

(*********** COMMAND LINE TOOL ***********)
let command = 
  Core.Command.basic 
    ~summary:"🐫  OSpike - a tool for parsing Spike logs with OCaml  🐫"
    Core.Command.Let_syntax.(
      let%map_open 
            mode   = anon (maybe ("mode - <stdin|file>" %: string))
        and output = flag "-o" (optional string)  ~doc:"filename location for the results to be stored"
        and lower  = flag "-lower" (optional int) ~doc:"lower-bound on the address range to include in the stats (yet to be implemented)"
        and upper  = flag "-upper" (optional int) ~doc:"upper-bound on the address range to include in the stats (yet to be implemented)"
        and group  = flag "-group" (optional_with_default 1 int) ~doc:"size the size of the groups of adjacent instructions to look at (default 1)"
        and compare_mode = flag "-compare" (optional_with_default "instr" string) ~doc:"mode how to compare instructions - default is without registers, any other string will use registers"
      in
        fun () -> 
          match mode with 
            | Some "stdin" -> 
              let options : Parser_options.t = 
                if compare_mode = "instr" then {lower; upper; group; compare_mode=Parser_options.Instr} 
                else if compare_mode = "full" then {lower; upper; group; compare_mode=Parser_options.Full}
                else {lower; upper; group; compare_mode=Parser_options.Instr_Reg} in 
                begin match output with 
                  | None -> Parser.(print_sorted stdout (from_stdin options) options)
                  | Some file -> 
                    let oc = open_out file in 
                      Printf.fprintf oc "%s\n" (Parser_options.to_string options);
                      Parser.(print_sorted oc (from_stdin options) options)
                  end
            | Some "file"  -> print_endline "File"
            | None | Some _ -> print_endline "Please provide which mode <stdin|file> you wish to use"
    )

let () = Core.Command.run command 