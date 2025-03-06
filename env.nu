# env.nu
#
# Installed by:
# version = "0.102.0"

# =====================================================================================================
# Configuration file by Katacc
# github: https://github.com/Katacc/
#
#
# This is written and tested on windows machine, so make sure to change environment variables to match
# your system variables. eg $user_name
#
#
# Prequisites
# - Git
# - Neofetch
# If you don't have neofetch installed or dont want to use it, please comment it out from the last line.
# ======================================================================================================




# !Configuration file starts from here!
#
# ----------------------------------------------------------------------------------------
# Environment variables


# Preferred code editor when openin files for editing.
$env.config.buffer_editor = "code"
let user_name = $env.USERNAME

# To disable Nu Shell welcome message
$env.config.show_banner = false



# -----------------------------------------------------------------------------------------
# Left side prompt


$env.PROMPT_INDICATOR = $"( ansi "#ccffcc" )❃ "
$env.PROMPT_COMMAND = {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let unstaged_files = ""


    use std
    let git_current_ref = do -i {$" (git rev-parse --abbrev-ref HEAD e> (std null-device))"}
    let new_files = if ($git_current_ref != "") {do -i {$"(git ls-files --others --exclude-standard e> (std null-device) | lines | length)"}}
    let unstaged_changes = if ($git_current_ref != "") { do -i {$"(git ls-files --modified --exclude-standard e> (std null-device) | lines | length)"}}


    let git_segment = if ($git_current_ref | is-empty) {
        $"(ansi "#ffbebc")($user_name)(ansi reset)"
    } else { $"(ansi "#ffbebc")($user_name)(ansi reset) | Git ᚴ(ansi "#ee79d1")($git_current_ref) ≡ ($unstaged_changes) ⌥  ($new_files)(ansi reset)" }



    let path_color = (if (is-admin) { ansi red_bold } else { ansi "#f3a7c9" })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi "#ccffcc" })

    let path_segment = $"\n(ansi white)┌──{ ($git_segment) }(ansi reset)\n└─($path_color){ ($dir) ($path_color)}(ansi reset) "


    $path_segment | str replace --all (char path_sep) $"($separator_color) / ($path_color)"
}

# --------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------
# Date time on the right side


$env.PROMPT_COMMAND_RIGHT = {||
    # create a right prompt in magenta with green separators and am/pm underlined

    let time_segment = ([
        (ansi reset)
        (ansi "#94ffa2")
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi white)${1}(ansi "#94ffa2")" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")


    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }
    ([$last_exit_code, (char space), $time_segment] | str join)
}

# ---------------------------------------------------------------------------------------------



# Neofetch COMMENT OUT IF YOU DONT HAVE NEOFETCH
neofetch

