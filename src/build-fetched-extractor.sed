# If the line 'will be fetched' is matched ...
/will be fetched/ {
    # Create a label to iterate over dervivations
    :b

    # Get next line from input into pattern buffer
    # (Overwrite the pattern buffer)
    n

    # If the line matches a nix store path ...
    /\/nix/ {

        # ... strip leading whitespaces and print it
        s/\s*(.*)/\1/p

        # and go on with the next line (step back to b)     
        bb
    }
}

