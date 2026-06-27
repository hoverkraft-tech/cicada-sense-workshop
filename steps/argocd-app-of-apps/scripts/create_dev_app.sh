#!/bin/sh

set -eu

usage() {
	cat <<'EOF'
Usage: create_dev_app.sh --new-app <new-app> [--dry-run]
EOF
}

validate_app_name() {
	label="$1"
	value="$2"

	if ! printf '%s' "$value" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
		echo "$label must be kebab-case, got: $value" >&2
		exit 1
	fi
}

replace_app_name_in_tree() {
	target_dir="$1"
	new_app="$2"

	find "$target_dir" -type f | while IFS= read -r file_path; do
		temp_file=$(mktemp)
		sed "s|__APP_NAME__|$new_app|g" "$file_path" >"$temp_file"
		mv "$temp_file" "$file_path"
	done
}

replace_app_name_in_paths() {
	target_dir="$1"
	new_app="$2"

	find "$target_dir" -depth -name '*__APP_NAME__*' | while IFS= read -r file_path; do
		renamed_path=$(printf '%s' "$file_path" | sed "s|__APP_NAME__|$new_app|g")
		mv "$file_path" "$renamed_path"
	done
}

resolve_scaffold_paths() {
	scaffold_name="$1"

	case "$scaffold_name" in
	dev-app)
		template_dir="$repo_root/templates/dev/review-app/app"
		target_dir="$repo_root/dev/apps/review-apps/$new_app"
		;;
	dev-manifest)
		template_dir="$repo_root/templates/dev/review-app/manifest"
		target_dir="$repo_root/dev/manifests/review-apps/$new_app"
		;;
	uat-app)
		template_dir="$repo_root/templates/prod/uat/app"
		target_dir="$repo_root/prod/apps/uat/$new_app"
		;;
	uat-manifest)
		template_dir="$repo_root/templates/prod/uat/manifest"
		target_dir="$repo_root/prod/manifests/uat/$new_app"
		;;
	production-app)
		template_dir="$repo_root/templates/prod/production/app"
		target_dir="$repo_root/prod/apps/production/$new_app"
		;;
	production-manifest)
		template_dir="$repo_root/templates/prod/production/manifest"
		target_dir="$repo_root/prod/manifests/production/$new_app"
		;;
	*)
		echo "Unknown scaffold: $scaffold_name" >&2
		exit 1
		;;
	esac
}

new_app=""
dry_run="0"

while [ "$#" -gt 0 ]; do
	case "$1" in
	--new-app)
		shift
		new_app="${1-}"
		;;
	--dry-run)
		dry_run="1"
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown argument: $1" >&2
		usage >&2
		exit 1
		;;
	esac
	shift
done

if [ -z "$new_app" ]; then
	usage >&2
	exit 1
fi

validate_app_name "new-app" "$new_app"

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

for scaffold_name in \
	dev-app \
	dev-manifest \
	uat-app \
	uat-manifest \
	production-app \
	production-manifest; do
	resolve_scaffold_paths "$scaffold_name"

	if [ ! -d "$template_dir" ]; then
		echo "Missing template directory: $template_dir" >&2
		exit 1
	fi

	if [ -e "$target_dir" ]; then
		echo "Target directory already exists: $target_dir" >&2
		exit 1
	fi
done

for scaffold_name in \
	dev-app \
	dev-manifest \
	uat-app \
	uat-manifest \
	production-app \
	production-manifest; do
	resolve_scaffold_paths "$scaffold_name"

	if [ "$dry_run" = "1" ]; then
		echo "Would create $target_dir from $template_dir"
		continue
	fi

	mkdir -p "$target_dir"
	cp -R "$template_dir/." "$target_dir"
	replace_app_name_in_tree "$target_dir" "$new_app"
	replace_app_name_in_paths "$target_dir" "$new_app"
	echo "Created $target_dir"
done
