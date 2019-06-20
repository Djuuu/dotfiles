
# Send prompt sign to new line when available columns are below $PROMPT_COLUMN_LIMIT
function newline_narrow_prompt_command {

    PROMPT_COLUMN_LIMIT=${PROMPT_COLUMN_LIMIT:-100}

    if [ $COLUMNS -lt $PROMPT_COLUMN_LIMIT ]; then
        BASE_PROMPT=${PS1/%??/}
        PS1="${BASE_PROMPT}\n${promptSign} "
    fi
}
