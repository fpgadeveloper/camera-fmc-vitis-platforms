SUMMARY = "startup script"
SECTION = "PETALINUX/setting "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=fa7ffd0ad615cced5e214402246bb709"

SRC_URI = " \
	file://dpu_sw_optimize.tar.gz \
	file://COPYRIGHT \
	file://dpu-auto-config \
"

S = "${WORKDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit update-rc.d

RDEPENDS:${PN} += " bash parted e2fsprogs-resize2fs"

INITSCRIPT_NAME = "dpu-auto-config"
INITSCRIPT_PARAMS = "start 99 5 ."

do_install() {

	mkdir -p ${D}/home/root/
	cp -rf ${WORKDIR}/dpu_sw_optimize	${D}/home/root/
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${S}/dpu-auto-config ${D}${sysconfdir}/init.d/dpu-auto-config

	chmod ug-s -R ${D}/home/root/*
	if [ -d ${D}/${LICENSE_FILES_DIRECTORY} ]; then
		# Now make sure the directory is set to 0755
		chmod 0755 ${D}/${LICENSE_FILES_DIRECTORY}
	fi
}


FILES:${PN} += " \
	/home/root/* \
	${sysconfdir}/* \
"

INSANE_SKIP:${PN} += "already-stripped"
