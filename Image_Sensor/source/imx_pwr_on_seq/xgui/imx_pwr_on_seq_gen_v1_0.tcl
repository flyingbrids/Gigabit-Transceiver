# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST PARAM_VALUE.pDEVICE_FAMILY PROJECT_PARAM.FAMILY } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "pDEVICE_FAMILY" -parent ${Page_0}

  set_property value ${PROJECT_PARAM.FAMILY} ${PARAM_VALUE.pDEVICE_FAMILY}

}

proc update_PARAM_VALUE.pDEVICE_FAMILY { IPINST PARAM_VALUE.pDEVICE_FAMILY PROJECT_PARAM.FAMILY} {
	# Procedure called to update pDEVICE_FAMILY when any of the dependent parameters in the arguments change
    set_property value ${PROJECT_PARAM.FAMILY} ${PARAM_VALUE.pDEVICE_FAMILY}
}

proc validate_PARAM_VALUE.pDEVICE_FAMILY { IPINST PARAM_VALUE.pDEVICE_FAMILY } {
	# Procedure called to validate pDEVICE_FAMILY
	return true
}


proc update_MODELPARAM_VALUE.pDEVICE_FAMILY { IPINST MODELPARAM_VALUE.pDEVICE_FAMILY PARAM_VALUE.pDEVICE_FAMILY PROJECT_PARAM.FAMILY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.pDEVICE_FAMILY}] ${MODELPARAM_VALUE.pDEVICE_FAMILY}
}

