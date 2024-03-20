# Kubectl command shortcuts

# Utility to spawn a fzf with a preview window with sane keybindings.
#
# The initial fzf will execute $start_cmd, with preview_window
# executing $preview_cmd on the current selection.
#
# Accepts yank callbacks.
_fkubectlpreview() {
  local start_cmd="$1"
  local preview_cmd="$2"
  local header="$3"

  local rand_string=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
  local temp_file="_fkubectlpreview_$rand_string.txt"

  local exit_cmd="rm $temp_file"

  # Handle on yank
  # Default is to output the temp file content to terminal and cleanup
  local default_yank_cmd="cat"
  local default_yank_desc="Output preview to terminal"
  local yank_cmd="${4:-$default_yank_cmd}"
  local yank_desc="${5:-$default_yank_desc}"
  local on_yank="{cat $temp_file | $yank_cmd} && $exit_cmd"

  # Handle on select
  # Default is to output the selection content to terminal and cleanup
  local select_cmd="cat"
  local on_select="{echo {} | $select_cmd} && $exit_cmd"

  # Spawn fzf with preview window and keybindings
  fzf \
    --min-height=15 --height=90% --info=inline --layout=reverse \
    --border-label="$header / Enter (Select) / Ctrl-u (Up preview) / Ctrl-d (Down preview) / Ctrl-y ($yank_desc)" \
    --bind "start:reload:($start_cmd)" \
    --bind "enter:become($on_select)" --bind "double-click:become("$on_select")" \
    --bind "ctrl-c:become($exit_cmd)" --bind "esc:become($exit_cmd)" --bind "ctrl-q:become($exit_cmd)" \
    --bind "ctrl-u:preview-up+preview-up+preview-up,ctrl-d:preview-down+preview-down+preview-down" \
    --bind "ctrl-y:become($on_yank)" \
    --preview="$preview_cmd | tee $temp_file" --preview-window=right
}

# Fuzzy search on Kubernetes events
# 
# Usage:
#   fkubectlevents [k8s_options...]
#
# Example:
#   fkubectlevents --context target_context --namespace target_namespace
#   fkubectlevents --context target_context --namespace target_namespace
fkubectlevents() {
  local opts="$@"
  local cmd="kubectl events $opts --watch=true --no-headers"

  fzf \
    --height=60% --info=inline --layout=reverse \
    --border-label="Fuzzy Search Kubernetes Events - Opts: $opts / Enter (Select)" \
    --bind="start:reload:($cmd)" \
    --preview="$preview_cmd" --preview-window=bottom,wrap
}

# Fuzzy search on Kubernetes resource and do deletion
# Usage:
#   fkubectldelete k8s_resource [k8s_resource]
#
# Example:
#   fkubectldelete deployment --context target_context --namespace target_namespace
#   fkubectldelete pods --context target_context --namespace target_namespace
fkubectldelete() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")

  local start_cmd="kubectl get $resource_type --no-headers $kubectl_opts \
    -o=custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace"
  local delete_cmd="kubectl delete $resource_type {1} --namespace={2}"
  local delete_cmd_force="$select_cmd --force"
  local header="Kubernetes Delete - Opts: $all_args / Ctrl-Space (delete resource) / Ctrl-/ (force delete)"

  fzf \
    --height=80% --info=inline --layout=reverse \
    --border-label="$header" \
    --bind "start:reload:($start_cmd)" \
    --bind "ctrl-space:execute($delete_cmd)" \
    --bind "ctrl-/:execute($delete_cmd_force)"
}

# Fuzzy search on k8s resource and show pods logs
#
# Usage:
#   fkubectllogs k8s_resource [k8s_options...]
#
# Example:
#   fkubectllogs deployment --context target_context --namespace target_namespace
#   fkubectllogs statefulsets --context target_context --namespace target_namespace
fkubectllogs() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")

  local start_cmd="kubectl get $resource_type --no-headers $kubectl_opts \
    -o=custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace"
  local preview_cmd="kubectl logs $resource_type/{1} --namespace={2} --tail=10000"
  local header="Kubernetes Logs - Opts: $all_args"

  # Pipe to another instance of fzf to do fuzzy search
  local yank_cmd="fzf --height=80% --info=inline --layout=reverse"
  local yank_desc="Fuzzy search on logs"

  _fkubectlpreview "$start_cmd" "$preview_cmd" "$header" "$yank_cmd" "$yank_desc"
}

# Fuzzy search on k8s resource and show pods status.
# Assumes that the resource selector uses matchLabels.app = pod.app
#
# Usage:
#   fkubectlpods k8s_resource [k8s_options...]
#
# Example:
#   fkubectlpods deployment --context target_context --namespace target_namespace
#   fkubectlpods statefulsets --context target_context --namespace target_namespace
fkubectlpods() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")

  local start_cmd="kubectl get $resource_type -L app --no-headers $kubectl_opts \
    -o=custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,APP:.metadata.labels.app"
  local preview_cmd="kubectl get pods --namespace={2} --selector=app={3}"
  local header="Kubernetes Pods - Opts: $all_args"

  _fkubectlpreview "$start_cmd" "$preview_cmd" "$header"
}

# Fuzzy search on k8s resource and execute describe on selected resource
#
# Usage:
#   fkubectldescribe k8s_resource [k8s_options...]
#
# Example:
#   fkubectldescribe deployment --context target_context --namespace target_namespace
#   fkubectldescribe pods --context target_context --namespace target_namespace
fkubectldescribe() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")

  local start_cmd="kubectl get $resource_type --no-headers $kubectl_opts \
    -o=custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace"
  local preview_cmd="kubectl describe $resource_type {1} --namespace={2}"
  local header="Kubernetes Describe - Opts: $all_args"

  _fkubectlpreview "$start_cmd" "$preview_cmd" "$header"
}

