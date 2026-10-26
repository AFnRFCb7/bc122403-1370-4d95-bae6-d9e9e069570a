{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        config-identity ? x : x ,
                        implementation-identity ? x : x ,
                        lib-identity ? x : x ,
                        pkgs-identity ? x : x
                    } :
                        let
                            implementation =
                                { config , lib , pkgs , ... } :
                                    let
                                        _config = config-identity config ;
                                        _lib = lib-identity lib ;
                                        _pkgs = pkgs-identity pkgs ;
                                        in
                                            {
                                                options.wrap =
                                                    _lib.mkOption
                                                        {
                                                            default =
                                                                _pkgs.writeShellApplication
                                                                    {
                                                                        name = "wrap" ;
                                                                        runtimeInputs = [ ( _config.failure { } ) _pkgs.coreutils ] ;
                                                                        text =
                                                                            ''
                                                                                INPUT_FILE="$1"
                                                                                if [[ ! -f "$INPUT_FILE" ]]
                                                                                then
                                                                                    failure 8595268982657679
                                                                                fi
                                                                                OUTPUT_FILE="$2"
                                                                                PERMISSIONS="$3"
                                                                                if [[ ! "$PERMISSIONS" =~ ^0?[0-7]{3,4}$ ]]
                                                                                then
                                                                                    failure 1166717505596797
                                                                                fi
                                                                                shift 3
                                                                                SED_EXPRESSIONS=()
                                                                                while [[ "$#" -gt 0 ]]
                                                                                do
                                                                                    case "$1" in
                                                                                        --replace)
                                                                                            if [[ "$#" -lt 2 ]]
                                                                                            then
                                                                                                failure 9002657793311682
                                                                                            fi
                                                                                            SED_EXPRESSIONS+=( -e "s#\\\$$2#$3#g" )
                                                                                            shift 3
                                                                                            ;;
                                                                                        *)
                                                                                            failure 0980715480386338 "$@"
                                                                                            ;;
                                                                                    esac
                                                                                done
                                                                                OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )" || failure 8360484024222791
                                                                                mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                sed "${ "$" }{SED_EXPRESSIONS[@]}" -e "w$OUTPUT_FILE" "$INPUT_FILE" > /dev/null 2>&1
                                                                                chmod "$PERMISSIONS" "$OUTPUT_FILE"
                                                                            '' ;
                                                                    } ;
                                                            type = _lib.types.package ;
                                                        } ;
                                            } ;
                            in
                                {
                                    check =
                                        {
                                            nixosTest ,
                                            obviated-by
                                        } :
                                        {
                                            initialization ,
                                            invocation ,
                                            expected-content ,
                                            expected-permissions
                                        } :
                                            {
                                                obviated-by = obviated-by ;
                                                test =
                                                    nixosTest
                                                        {
                                                            name = "nixos-test" ;
                                                            nodes.client =
                                                                { config , pkgs , ... } :
                                                                    let
                                                                        _config = config-identity config ;
                                                                        _pkgs = pkgs-identity pkgs ;
                                                                        in
                                                                            {
                                                                                config.environment.systemPackages =
                                                                                    [
                                                                                        (
                                                                                            _pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "test-script" ;
                                                                                                    runtimeInputs = [ ( _config.failure { } ) _config.wrap pkgs.coreutils pkgs.diffutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            OUTPUT_FILE="$( mktemp --dry-run )" || failure 9806337050783776
                                                                                                            ${ invocation ( builtins.toFile "input" initialization ) "$OUTPUT_FILE" }
                                                                                                            diff --unified ${ builtins.toFile "expected" expected-content } "$OUTPUT_FILE"
                                                                                                            OBSERVED_PERMISSIONS="$( stat --printf %a ${ output-file } )" || failure 1669229998858597
                                                                                                            if [[ ${ builtins.toString expected-permissions } != "$OBSERVED_PERMISSIONS" ]]
                                                                                                            then
                                                                                                                failure 4837225148265565
                                                                                                            fi
                                                                                                        '' ;
                                                                                                }
                                                                                        )
                                                                                    ] ;
                                                                                imports = [ implementation ] ;
                                                                            } ;
                                                            testScript =
                                                                ''
                                                                '' ;
                                                        } ;
                                                type = "wrap" ;
                                            } ;
                                    implementation = implementation-identity implementation ;
                                } ;
            } ;
}