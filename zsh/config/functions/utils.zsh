# Safely source argument if it exists
#
# Usage: 
#   safe_source <filename>
#
# Params:
#   - filename  STRING  path to file
safe_source() {
  [[ ! -e "$1" ]] || source "$1"
}

# Append paths to the given variable if it does not exist.
#
# Usage:
# path_append <name_of_var> [path1 [path2 [path3]]]
#
# Example:
#   # Note the lack of '$' prefix to allow PATH to be 
#   # passed as indirect variable
#   path_append PATH "/usr/bin/"
#
# Params:
#   - <name_of_var> name of variable containing paths.
#   - path STRING path to append
path_append() {
  for ARG in "${@:2}"
  do
    if [ -e "$ARG" ] && [[ ":${(P)1}:" != *":$ARG:"* ]]; then
      if [[ -z "${(P)1}" ]]; then
        export "$1=$ARG"
      else
        export "$1=${(P)1}:$ARG"
      fi
    fi
  done
}

# Prepend paths to the given variable if it does not exist.
#
# Usage:
# path_append <name_of_var> [path1 [path2 [path3]]]
#
# Example:
#   # Note the lack of '$' prefix to allow PATH to be 
#   # passed as indirect variable
#   path_append PATH "/usr/bin/"
#
# Params:
#   - <name_of_var> name of variable containing paths.
#   - path STRING path to append
path_prepend() {
  for ARG in "${@:2}"
  do
    if [ -e "$ARG" ] && [[ ":${(P)1}:" != *":$ARG:"* ]]; then
      if [[ -z "${(P)1}" ]]; then
        export "$1=$ARG"
      else
        export "$1=$ARG:${(P)1}"
      fi
    fi
  done
}

# Load local plugin from the plugin_name and plugin_source.
#
# Usage: 
#   zsh_load_local_plugin <plugin_name> <plugin_source>
# 
# Example:
#   zsh_load_local_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"
#
# Params:
#   - plugin_name     STRING            refers to the name of plugin, e.g. zsh-syntax-highlighting
#   - plugin_source   STRING            refers to the path to entry point of the plugin, e.g. zsh-syntax-highlighting.zsh
#   - plugin_dir      ENV:$ZSH_PLUGIN   directory to find the plugin_dir from. Fetched via environment variable: $ZSH_PLUGIN. Defaults to ${HOME}/.config/zsh/plugin
zsh_load_local_plugin() {
  local plugin_name="$1"
  local plugin_source="$2"
  local plugin_dir="${(P)ZSH_PLUGIN:-$HOME/.config/zsh/plugin}"

  safe_source "$plugin_dir/$plugin_name/$plugin_source"
}

