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

  local exit_cmd="[[ -e $temp_file ]] && rm $temp_file"

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
    --min-height=15 --height=80% --info=inline --layout=reverse \
    --border-label="$header / Enter (Select) / Ctrl-u (Up preview) / Ctrl-d (Down preview) / Ctrl-y ($yank_desc)" \
    --bind "start:reload:($start_cmd)" \
    --bind "enter:become($on_select)" --bind "double-click:become("$on_select")" \
    --bind "ctrl-c:become($exit_cmd)" --bind "esc:become($exit_cmd)" --bind "ctrl-q:become($exit_cmd)" \
    --bind "ctrl-u:preview-up+preview-up+preview-up,ctrl-d:preview-down+preview-down+preview-down" \
    --bind "ctrl-y:become($on_yank)" \
    --preview="$preview_cmd | tee $temp_file" --preview-window=bottom,wrap
}

# Utility to fetch the info based on the resource type.
#
# Sets internal variable for usage in other functions.
#
# Is this a good way? No. But kubectl does not support `--extra-columns`.
# Using custom columns straight up removes all other columns, so we need to
# rewrite the existing columns based on resource type.
_fkubectlresourceinfo() {
  local resource_type="$1"

  local columns_var="_fkubectlinfo_columns"

  # Common kubectl columns
  local name_header="NAME:.metadata.name"
  local namespace_header="NAMESPACE:.metadata.namespace"
  local creation_header="CREATED:.metadata.creationTimestamp"

  # csr	certificatesigningrequests
  if [[ "$resource_type" =~ ^(csr|certificatesigningrequest(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,SIGNER:.spec.signerName,CONDITION:.status.conditions[*].type,$creation_header"
  # cm	configmaps
  elif [[ "$resource_type" =~ ^(cm|configmap(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # ds	daemonsets
  elif [[ "$resource_type" =~ ^(ds|daemonset(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,READY:.status.numberReady,TARGET:.status.desiredNumberScheduled,$creation_header"
  # deploy	deployments
  elif [[ "$resource_type" =~ ^(deploy|deployment(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,READY:.status.readyReplicas,TARGET:.spec.replicas,$creation_header"
  # ep	endpoints
  elif [[ "$resource_type" =~ ^(ep|endpoint(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,ENDPOINTS:.subsets[*].addresses[*].ip,PORTS:.subsets[*].ports[*].port,$creation_header"
  # ev	events
  elif [[ "$resource_type" =~ ^(ev|event(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,REASON:.reason,SOURCE:.source.component,TYPE:.type,$creation_header"
  # hpa	horizontalpodautoscalers
  elif [[ "$resource_type" =~ ^(hpa|horizontalpodautoscaler(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,TARGET KIND:.spec.scaleTargetRef.kind,TARGET NAME:.spec.scaleTargetRef.name,MIN:.spec.minReplicas,MAX:.spec.maxReplicas,REPLICAS:.status.currentReplicas,$creation_header"
  # ing	ingresses
  elif [[ "$resource_type" =~ ^(ing|ingress(es)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[*].hostname,$creation_header"
  # limits	limitranges
  elif [[ "$resource_type" =~ ^(limits|limitrange(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # ns	namespaces
  elif [[ "$resource_type" =~ ^(ns|namespace(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,STATUS:.status.phase,$creation_header"
  # no	nodes
  elif [[ "$resource_type" =~ ^(no|node(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,STATUS:.status.conditions[?(@.reason=='KubeletReady')].type,VERSION:.status.nodeInfo.kubeletVersion,$creation_header"
  # pvc	persistentvolumeclaims
  elif [[ "$resource_type" =~ ^(pvc|persistentvolumeclaim(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,STATUS:.status.phase,VOLUME:.spec.volumeName,CAPACITY:.status.capacity.storage,ACCESS MODES:.spec.accessModes[*],STORAGE CLASS:.spec.storageClassName,$creation_header"
  # pv	persistentvolumes
  elif [[ "$resource_type" =~ ^(pv|persistentvolume(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,CAPACITY:.spec.capacity.storage,ACCESS MODES:.spec.accessModes[*],RECLAIM POLICY:.spec.persistentVolumeReclaimPolicy,STATUS:.status.phase,CLAIM:.spec.claimRef.name,$creation_header"
  # po	pods
  elif [[ "$resource_type" =~ ^(po|pod(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,READY:.status.conditions[?(@.type=='Ready')].type,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,$creation_header"
  # pdb	poddisruptionbudgets
  elif [[ "$resource_type" =~ ^(pdb|poddisruptionbudget(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,MIN:.spec.minAvailable,MAX:.spec.maxAvailable,EXPECTED:.status.expectedPods,ALLOWED DISRUPTIONS:.status.disruptionsAllowed,$creation_header"
  # rs	replicasets
  elif [[ "$resource_type" =~ ^(rs|replicaset(s)?)$ ]]; then
    set -A "$name_header,$namespace_header,REPLICAS:.spec.replicas,$creation_header"
  # rc	replicationcontrollers
  elif [[ "$resource_type" =~ ^(rc|replicationcontroller(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # quota	resourcequotas
  elif [[ "$resource_type" =~ ^(quota|resourcequota(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # sa	serviceaccounts
  elif [[ "$resource_type" =~ ^(sa|serviceaccount(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # sc	storageclass
  elif [[ "$resource_type" =~ ^(sc|storageclass(es)?)$ ]]; then
    set -A "$columns_var" "$name_header,PROVISIONER:.provisioner,RECLAIM POLICY:.reclaimPolicy,VOL BINDING MODE:.volumeBindingMode,$creation_header"
  # svc	services
  elif [[ "$resource_type" =~ ^(svc|service(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIPs[*],EXTERNAL-IP:.status.loadBalancer.ingress[*].hostname,PORT(S):.spec.ports[*].port,$creation_header"
  # crd customresourcedefinitions
  elif [[ "$resource_type" =~ ^(crd(s)?|customresourcedefinition(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$creation_header,$creation_header"
  # cj cronjobs
  elif [[ "$resource_type" =~ ^(cj|cronjob(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,SCHEDULE:.spec.schedule,SUSPEND:.spec.suspend,LAST SCHEDULE:.status.lastScheduleTime,$creation_header"
  # job jobs
  elif [[ "$resource_type" =~ ^(job(s)?)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,STATUS:.status.conditions[?(@.type=='Complete')].type,$creation_header"
  # netpol networkpolicies
  elif [[ "$resource_type" =~ ^(netpol|networkpolicies)$ ]]; then
    set -A "$columns_var" "$name_header,$namespace_header,$creation_header"
  # pc priorityclasses
  elif [[ "$resource_type" =~ ^(pc|priorityclass(es)?)$ ]]; then
    set -A "$columns_var" "$name_header,VALUE:.metadata.value,$creation_header"
  else
    set -A "$columns_var" "$name_header,$creation_header"
  fi
}

# # Utility to extract header from kubectl custom columns
# # Strip all non capital & non comma
# _fkubectl_column_header() {
#   local input="$1"
#   echo "${input//[A-Z]:/}"
# }

# Fuzzy search on Kubernetes context
# 
# Usage:
#   fkubectlcontext
#
# Example:
#   fkubectlcontext
fkubectlcontext() {
  local cmd="kubectl config get-contexts --no-headers -o name"
  local accept_cmd="kubectl config use-context {}"

  fzf \
    --height=25% --info=inline --layout=reverse \
    --border-label="Kubernetes Config - Enter (Select)" \
    --bind "start:reload:($cmd)" \
    --bind "enter:become($accept_cmd)" --bind "double-click:become($accept_cmd)" \
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
    --min-height=15 --height=90% --info=inline --layout=reverse \
    --border-label="Kubernetes Events - Opts: $opts / Enter (Select)" \
    --bind="start:reload:($cmd)" \
    --preview="$preview_cmd" --preview-window=bottom,wrap
}

# Fuzzy search on Kubernetes resource and do edit
#
# Usage:
#   fkubectledit k8s_resource [k8s_resource]
#
# Example:
#   fkubectledit deployment --context target_context --namespace target_namespace
#   fkubectledit pods --context target_context --namespace target_namespace
fkubectledit() {
  local all_args=("$@")
  local resource_type="$1"
  local kubectl_opts=("${all_args[@]:1}")

  _fkubectlresourceinfo "$resource_type"

  local start_cmd="kubectl get $resource_type --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns\" $kubectl_opts"
  local edit_cmd="kubectl edit $resource_type {1} --namespace={2}"
  local header="Kubernetes Edit - Opts: $all_args / Enter (edit resource)"

  fzf \
    --min-height=15 --height=90% --info=inline --layout=reverse \
    --border-label="$header" \
    --bind "start:reload:($start_cmd)" \
    --bind "Enter:become($edit_cmd)" \
}

# Fuzzy search on Kubernetes resource and do deletion
#
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

  _fkubectlresourceinfo "$resource_type"

  local start_cmd="kubectl get $resource_type --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns\" $kubectl_opts"
  local delete_cmd="kubectl delete $resource_type {1} --namespace={2}"
  local delete_cmd_force="$delete_cmd --force"
  local header="Kubernetes Delete - Opts: $all_args / Ctrl-Space (delete resource) / Ctrl-/ (force delete)"

  fzf \
    --min-height=15 --height=90% --info=inline --layout=reverse \
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

  _fkubectlresourceinfo "$resource_type"

  local start_cmd="kubectl get $resource_type --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns\" $kubectl_opts"
  local preview_cmd="kubectl logs $resource_type/{1} --namespace={2} --tail=10000"
  local header="Kubernetes Logs - Opts: $all_args"

  # Pipe to another instance of fzf to do fuzzy search
  local yank_cmd="sort --reverse | fzf --height=80% --info=inline --layout=reverse"
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

  _fkubectlresourceinfo "$resource_type"

  local start_cmd="kubectl get $resource_type -L app --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns,APP:.metadata.labels.app\" $kubectl_opts"
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

  _fkubectlresourceinfo "$resource_type"

  local start_cmd="kubectl get $resource_type --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns\" $kubectl_opts"
  local preview_cmd="kubectl describe $resource_type {1} --namespace={2}"
  local header="Kubernetes Describe - Opts: $all_args"

  _fkubectlpreview "$start_cmd" "$preview_cmd" "$header"
}

