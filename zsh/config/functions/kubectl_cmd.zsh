# Kubectl command shortcuts

# Utility to fetch the info based on the resource type.
#
# Sets internal variables '_fkubectlinfo_*' for usage in other functions.
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

# Utility to extract column headers from given custom columns 
_fkubectlcolumnsheader() {
  local headers=$(sed -E "s/:[^,]+//g" <<< "$1")
  echo "$headers"
}

# Utility to spawn a fzf with a preview window with sane keybindings.
#
# The initial fzf will execute $start_cmd, with preview_window
# executing $preview_cmd on the current selection.
_fkubectlpreview() {
	local rand_string=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
	local temp_file="_fkubectlpreview_$rand_string.txt"

    # Defaults
    local positional=()
    local resource_type=""
    local action_cmd="echo {}"
    local action_desc="Select"
    local action_mode="become"
    local select_cmd="cat $temp_file"
    local select_desc="Output preview to terminal"
    local select_mode="become"
    local grep_opts=""

    # Parsing behaviour:
    # - does NOT support short option chaining (ie: -vh)
    # - everything after -- is positional even if it looks like an option (ie: -f)
    while (( $# )); do
      case "${1-}" in
        --)                 shift; positional+=("${@[@]}"); break  ;;
        --type)             shift; resource_type=$1                ;;
        --action)           shift; action_cmd=$1                   ;;
        --action_desc)      shift; action_desc=$1                  ;;
        --action_mode)      shift; action_mode=$1                  ;;
        --select)           shift; select_cmd=$1                   ;;
        --select_desc)      shift; select_desc=$1                  ;;
        --select_mode)      shift; select_mode=$1                  ;;
        -g|--grep)          shift; grep_opts=$1                    ;;
        -*)                 echo "Unknown option: $1" && return    ;;
        *)                  positional+=("$1");                    ;;
      esac
      shift
    done

    [[ -z "$resource_type" ]] && {
      echo "Resource type cannot be empty"
      return
    }

    _fkubectlresourceinfo "$resource_type"

	local start_cmd="kubectl get $resource_type --no-headers \
    -o \"custom-columns=$_fkubectlinfo_columns\" $positional"
	local preview_cmd="kubectl describe $resource_type {1} --namespace={2}"
	local exit_cmd="[[ -e $temp_file ]] && rm $temp_file"
    local column_headers=$(_fkubectlcolumnsheader $_fkubectlinfo_columns)

	local on_action="$action_cmd; $exit_cmd"
	local on_select="$select_cmd; $exit_cmd"

	# Spawn fzf with preview window and keybindings
	# Action is purposefully tied to uncommon key binding to prevent accidental commit
	fzf \
		--min-height=10 --height=60% --info=inline --layout=reverse \
        --border-label="Fuzzy Kubernetes / Ctrl-Space ($action_desc) / Enter ($select_desc) / Ctrl-u (Up preview) / Ctrl-d (Down preview) / Ctrl-r (Reload)" \
        --header "Columns: $column_headers" \
        --bind "start:reload($start_cmd)" --bind "ctrl-r:reload($start_cmd)" \
		--bind "ctrl-c:become($exit_cmd)" --bind "esc:become($exit_cmd)" --bind "ctrl-q:become($exit_cmd)" \
		--bind "ctrl-u:preview-up+preview-up+preview-up,ctrl-d:preview-down+preview-down+preview-down" \
		--bind "enter:$select_mode($on_select)" --bind "double-click:$select_mode($on_select)" \
		--bind "ctrl-space:$action_mode($on_action)" \
		--preview="$preview_cmd | tee $temp_file" --preview-window=bottom,wrap
}

# Search selected k8s resource
#
# Usage:
#   fkubectlsearch k8s_resource [-g|--grep grep_pattern] -- [k8s_options...]
#
# Example:
#   fkubectlsearch pods -g "-ive 'running'" -- --context target_context --namespace target_namespace
fkubectlsearch() {
  local resource_type="$1"; shift
  _fkubectlpreview --type "$resource_type" \
    "${@[@]}"
}

# Edit selected k8s resource
#
# Usage:
#   fkubectledit k8s_resource [-g|--grep grep_pattern] -- [k8s_options...]
#
# Example:
#   fkubectledit pods -g "-ive 'running'" -- --context target_context --namespace target_namespace
fkubectledit() {
  local resource_type="$1"; shift
  _fkubectlpreview --type "$resource_type" \
    --action "kubectl edit $resource_type {1} --namespace={2}" \
    --action_desc "Edit $resource_type" --action_mode "become" \
    "${@[@]}"
}

# Delete selected k8s resource
#
# Usage:
#   fkubectldelete k8s_resource [-g|--grep grep_pattern] -- [k8s_options...]
#
# Example:
#   fkubectldelete pods -g "-ive 'running'" -- --context target_context --namespace target_namespace
fkubectldelete() {
  local resource_type="$1"; shift
  _fkubectlpreview --type "$resource_type" \
    --action "kubectl delete $resource_type {1} --namespace={2}" \
    --action_desc "Delete $resource_type" --action_mod "execute" \
    "${@[@]}"
}

# Fuzzy search on logs of selected k8s resource
#
# Usage:
#   fkubectllogs k8s_resource [-g|--grep grep_pattern] -- [k8s_options...]
#
# Example:
#   fkubectllogs pods -g "-ive 'running'" -- --context target_context --namespace target_namespace
fkubectllogs() {
  local resource_type="$1"; shift
  _fkubectlpreview --type "$resource_type" \
    --action "kubectl logs $resource_type/{1} --namespace={2} --tail=10000 | sort --reverse | fzf --height=80% --info=inline --layout=reverse" \
    --action_desc "Fuzzy search on logs" --action_mode "become" \
    "${@[@]:1}"
}
