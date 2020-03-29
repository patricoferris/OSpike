open Ospike_lib

(*********** COMMAND LINE TOOL ***********)
let command = 
  Core.Command.basic 
    ~summary:"🐫  OSpike - a tool for parsing Spike logs with OCaml  🐫"
    Core.Command.Let_syntax.(
      let%map_open 
            mode   = anon (maybe ("mode" %: string))
        and output = flag "-o" (optional string)  ~doc:"filename where the results should be stored"
        and lower  = flag "-lower" (optional int) ~doc:"lower-bound on the address range to include in the stats"
        and upper  = flag "-upper" (optional int) ~doc:"upper-bound on the address range to include in the stats"
        and group  = flag "-group" (optional_with_default 1 int) ~doc:"size of the groups of adjacent instruction to look at (default 1)"
      in
        fun () -> 
          match mode with 
            | Some "stdin" -> 
              let options : Parser.t = {lower; upper; group} in 
                begin match output with 
                  | None -> Parser.(print_sorted stdout (from_stdin options) options)
                  | Some file -> Parser.(print_sorted (open_out file) (from_stdin options) options)
                end
            | Some "file"  -> print_endline "File"
            | None | Some _ -> print_endline "Please provide which mode <stdin|file> you wish to use"
    )

let () = Core.Command.run command 