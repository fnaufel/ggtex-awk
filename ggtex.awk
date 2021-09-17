#! /usr/bin/gawk -f

# A gawk script to convert modified LaTeX math-mode code to Geogebra code.
#
# For syntax and more info, see http://github.com/fnaufel/ggtex-gawk.
#
# To install gawk for Windows, see http://gnuwin32.sourceforge.net/packages/gawk.htm
#
# Usage:
#
#     gawk -f ggtex.awk TEXFILE.tex
#
#   Or, if you're on GNU-Linux and ggtex.awk has been made executable
#
#     ggtex.awk TEXFILE.tex
#
#   The result will be in file TEXFILE.gg.tex


BEGIN {
    # Each chunk ends with a math mode delimiter
    RS = "(\\\\\\[)" "|" "(\\\\\\])"

    # Output filename
    output = ARGV[1]
    sub(/\.tex$/, "", output)
    sub(/$/, ".gg.tex", output)
}

{
    # For each chunk
    if (RT != "\\]")
        # it's not math mode: just print
        printf("%s", $0) > output
    else
        # it's math mode: translate and print
        printf("%s", process($0)) > output
}

END {

    close(output)

}

function process(c) {

    original = "\\[" c "\\]"
    before_trans = "\n\n\\noindent\\hrulefill\n\\begin{verbatim}\n"
    after_trans = "\n\\end{verbatim}\n\\hrulefill\\\\"

    translation = translate(c)
    
    return original before_trans translation after_trans
    
}

function translate(chunk) {

    # Strip leading and trailing newlines
    sub(/^\n/, "", chunk)
    sub(/\n$/, "", chunk)

    # Add calls and trailing parens
    chunk = "FormulaText(Simplify(\n\"" chunk "\"\n))"
    
    # Add " + before and add + " after Geogebra expressions escaped with @
    chunk = gensub(/@([^@]+)@/, "\" + \\1 + \"", "g", chunk)

    # Delete possible " " + at the beginning
    sub(/"\s*" \+\s*/, "", chunk)

    # Delete possible + "" at the end
    sub(/\s*\+ "\s*"/, "", chunk)

    return chunk

}
