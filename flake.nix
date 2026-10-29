{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        input ? null ,
                        output ? null
                    } :
                        let
                            implementation =
                                { config , lib , pkgs , ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else builtins.throw "7300192311647690" ;
                                        in
                                            with identified ;
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
                                            failure ,
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
                                                                { config , pkgs , ... } @module :
                                                                    let
                                                                        identified =
                                                                            if builtins.typeOf input == "lambda" then input module
                                                                            else if builtins.typeOf input == "null" then module
                                                                            else builtins.throw "7138201742652634" ;
                                                                        in
                                                                            with identified ;
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
                                                                                                                OBSERVED_PERMISSIONS="$( stat --printf %a "$OUTPUT_FILE" )" || failure 1669229998858597
                                                                                                                if [[ ${ builtins.toString expected-permissions } != "$OBSERVED_PERMISSIONS" ]]
                                                                                                                then
                                                                                                                    failure 4837225148265565
                                                                                                                fi
                                                                                                            '' ;
                                                                                                    }
                                                                                            )
                                                                                        ] ;
                                                                                    imports = [ failure implementation ] ;
                                                                                } ;
                                                            testScript =
                                                                ''
                                                                    client.wait_for_unit("multi-user.target")
                                                                    client.succeed("test-script")
                                                                '' ;
                                                        } ;
                                                type = "wrap" ;
                                            } ;
                                    implementation =
                                        if builtins.typeOf output == "lambda" then output implementation
                                        else if builtins.typeOf output == "null" then implementation
                                        else builtins.throw "6676315963943978" ;
                                } ;
            } ;
}