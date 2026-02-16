# @summary
#   Generic on/off/enable/disable/true/false
#
type Managedmac::Universalonoff = Variant[
    Managedmac::Enabledisable,
    Managedmac::Onoff,
    Managedmac::Universalboolean,
  ]
