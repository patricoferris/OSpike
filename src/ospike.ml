(*********** COMMAND LINE TOOL ***********)
let command = 
  Core.Command.basic 
    ~summary:"🐫  OSpike - a tool for parsing Spike logs with OCaml  🐫"
    Core.Command.Let_syntax.(
      let%map_open 
            mode   = anon (maybe ("mode" %: string))
        and _output = flag "-o" (optional string)  ~doc:"filename where the results should be stored"
        and lower  = flag "-lower" (optional int) ~doc:"lower-bound on the address range to include in the stats"
        and upper  = flag "-upper" (optional int) ~doc:"upper-bound on the address range to include in the stats"
        and group  = flag "-group" (optional_with_default 1 int) ~doc:"size of the groups of adjacent instruction to look at (default 1)"
      in
        fun () -> 
          match mode with 
            | Some "stdin" -> 
              let options : Parser.t = {lower; upper; group} in 
                Parser.(print_sorted (from_stdin options) options)
            | Some "file"  -> print_endline "File"
            | None | Some _ -> print_endline "Please provide either build, spike-build, run, spike, log or clean as mode"
    )

let () = Core.Command.run command 