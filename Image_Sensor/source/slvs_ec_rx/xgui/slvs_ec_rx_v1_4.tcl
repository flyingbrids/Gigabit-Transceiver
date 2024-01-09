# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set CORE_VAR [ipgui::add_param $IPINST -name "CORE_VAR" -parent ${Page_0} -widget comboBox]
  set_property tooltip {CRC or ECC core variant} ${CORE_VAR}
  set LANE_NUM [ipgui::add_param $IPINST -name "LANE_NUM" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Number of input data lanes} ${LANE_NUM}


}

proc update_PARAM_VALUE.CORE_VAR { PARAM_VALUE.CORE_VAR } {
	# Procedure called to update CORE_VAR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CORE_VAR { PARAM_VALUE.CORE_VAR } {
	# Procedure called to validate CORE_VAR
	return true
}

proc update_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to update LANE_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LANE_NUM { PARAM_VALUE.LANE_NUM } {
	# Procedure called to validate LANE_NUM
	return true
}


proc update_MODELPARAM_VALUE.CORE_VAR { MODELPARAM_VALUE.CORE_VAR PARAM_VALUE.CORE_VAR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CORE_VAR}] ${MODELPARAM_VALUE.CORE_VAR}
}

proc update_MODELPARAM_VALUE.LANE_NUM { MODELPARAM_VALUE.LANE_NUM PARAM_VALUE.LANE_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LANE_NUM}] ${MODELPARAM_VALUE.LANE_NUM}
}

