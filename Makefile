BL_VERS_NUM=5.5.0.0

CONFIG_BL_FULLMAC ?= m

# Enable A-MSDU support (need FW support)
## Select this if FW is compiled with AMSDU support
CONFIG_BL_SPLIT_TX_BUF ?= n
## Select this TO send AMSDU
CONFIG_BL_AMSDUS_TX ?= n

# Enable HW queue for Broadcast/Multicast traffic (need FW support)
CONFIG_BL_BCMC ?= y

# extra DEBUG config
CONFIG_BL_SW_PROFILING ?= n
CONFIG_BL_DBG ?= n
CONFIG_AUTO_DNLD ?= n

obj-$(CONFIG_BL_FULLMAC) := bl_fdrv.o
bl_fdrv-y := bl_cfgfile.o           \
               bl_main.o            \
               bl_mod_params.o      \
	           bl_platform.o	    \
	           bl_sdio.o            \
               bl_msg_tx.o          \
               bl_msg_rx.o          \
               bl_utils.o           \
               bl_cmds.o            \
               bl_irqs.o            \
               ipc_host.o           \
               bl_txq.o             \
               bl_strs.o            \
               bl_tx.o              \
               bl_rx.o              \
               bl_v7.o              \
			   bl_bootrom.o
bl_fdrv-$(CONFIG_DEBUG_FS)         += bl_debugfs.o

ccflags-y := -DCONFIG_BL_FULLMAC
ccflags-y += -I$(src)/..
ccflags-$(CONFIG_BL_SPLIT_TX_BUF) += -DCONFIG_BL_SPLIT_TX_BUF
ifeq ($(CONFIG_BL_SPLIT_TX_BUF), y)
ccflags-$(CONFIG_BL_AMSDUS_TX) += -DCONFIG_BL_AMSDUS_TX
endif
ccflags-$(CONFIG_BL_DBG) += -DCONFIG_BL_DBG

ccflags-y += -DCONFIG_USER_MAX=1

ifeq ($(CONFIG_BL_BCMC), y)
ccflags-y += -DNX_TXQ_CNT=5
else
ccflags-y += -DNX_TXQ_CNT=4
endif
ccflags-$(CONFIG_AUTO_DNLD) += -DCONFIG_AUTO_DNLD

ccflags-$(CONFIG_DEBUG_FS) += -DCONFIG_BL_DEBUGFS
ccflags-y += -I$(src)

# FW VARS
ccflags-y += -DNX_VIRT_DEV_MAX=4
ccflags-y += -DNX_REMOTE_STA_MAX=10
ccflags-y += -DNX_CHAN_CTXT_CNT=3

ccflags-y += -DBL_VERS_MOD="\"$(BL_VERS_NUM)\""

all: modules

modules clean:
	+make -C /lib/modules/`uname -r`/build M=$(PWD) $@
