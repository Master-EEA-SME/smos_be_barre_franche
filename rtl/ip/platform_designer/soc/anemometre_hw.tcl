# TCL File Generated by Component Editor 18.1
# Mon Nov 28 08:21:13 CET 2022
# DO NOT MODIFY


# 
# anemometre "anemometre" v1.0
#  2022.11.28.08:21:13
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module anemometre
# 
set_module_property DESCRIPTION ""
set_module_property NAME anemometre
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME anemometre
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avalon_anemometre
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file avalon_anemometre.vhd VHDL PATH ../../../src/f1/avalon_anemometre.vhd TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter G_FREQ_IN INTEGER 50000000
set_parameter_property G_FREQ_IN DEFAULT_VALUE 50000000
set_parameter_property G_FREQ_IN DISPLAY_NAME G_FREQ_IN
set_parameter_property G_FREQ_IN TYPE INTEGER
set_parameter_property G_FREQ_IN UNITS None
set_parameter_property G_FREQ_IN ALLOWED_RANGES -2147483648:2147483647
set_parameter_property G_FREQ_IN HDL_PARAMETER true


# 
# display items
# 


# 
# connection point external_connection
# 
add_interface external_connection conduit end
set_interface_property external_connection associatedClock ""
set_interface_property external_connection associatedReset ""
set_interface_property external_connection ENABLED true
set_interface_property external_connection EXPORT_OF ""
set_interface_property external_connection PORT_NAME_MAP ""
set_interface_property external_connection CMSIS_SVD_VARIABLES ""
set_interface_property external_connection SVD_ADDRESS_GROUP ""

add_interface_port external_connection anemo_i export Input 1


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clk_i clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset arst_i reset Input 1


# 
# connection point s0
# 
add_interface s0 avalon end
set_interface_property s0 addressUnits WORDS
set_interface_property s0 associatedClock clk
set_interface_property s0 associatedReset reset
set_interface_property s0 bitsPerSymbol 8
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 burstcountUnits WORDS
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 maximumPendingWriteTransactions 0
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0
set_interface_property s0 ENABLED true
set_interface_property s0 EXPORT_OF ""
set_interface_property s0 PORT_NAME_MAP ""
set_interface_property s0 CMSIS_SVD_VARIABLES ""
set_interface_property s0 SVD_ADDRESS_GROUP ""

add_interface_port s0 write_data_i writedata Input 32
add_interface_port s0 read_data_o readdata Output 32
add_interface_port s0 address_i address Input 1
add_interface_port s0 write_i write Input 1
set_interface_assignment s0 embeddedsw.configuration.isFlash 0
set_interface_assignment s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s0 embeddedsw.configuration.isPrintableDevice 0

