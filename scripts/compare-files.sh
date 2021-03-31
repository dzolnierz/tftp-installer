#!/bin/bash
set -e

CWD="${BASH_SOURCE%/*}"

DIRS=(
	"${1}"
	"${2}"
)
AUTOUPDATE="${3}"

TARGETS=(
	"debian-installer/amd64/boot-screens/"
	"debian-installer/amd64/grub/"
	"debian-installer/amd64/bootnetx64.efi"
	"debian-installer/amd64/grubx64.efi"
	"debian-installer/amd64/initrd.gz"
	"debian-installer/amd64/linux"
	"debian-installer/amd64/pxelinux.0"
)
IGNORE=(
	"debian-installer/amd64/boot-screens/adtxt.cfg"
	"debian-installer/amd64/boot-screens/menu.cfg"
)

filelist=()
for target in "${TARGETS[@]}"; do
	if test -d "${target}"; then
		filelist+=( $(find "${target}" -type f) )
	fi
	if test -f "${target}"; then
		filelist+=( "${target}" )
	fi
done
for file in "${filelist[@]}"; do
	# compare files
	if [[ ! "$(sha256sum "${1}/${file}" | cut -d' ' -f1)" == "$(sha256sum "${2}/${file}" | cut -d' ' -f1)" ]]; then
		for ignored in "${IGNORE[@]}" ; do
			if [[ "${file}" == "${ignored}" ]]; then
				continue 2
			fi
		done
		echo "File ${file} needs to be updated"
		[[ "${AUTOUPDATE}" == "yes" ]] && cp -av "${2}/${file}" "${1}/${file}"
	fi
done
[[ "${AUTOUPDATE}" == "yes" ]] && {
	patch="../../../patches/syslinux.cfg.patch"
	cd "${CWD}/../debian-installer/amd64/boot-screens"
	patch -p0 < "${patch}"
}
