# bootstrap --
#
#       This file provides scriptable bootstrap functionality on a cisco
#       router or switch.
#
namespace eval ::bootstrap {
  namespace export *
  namespace ensemble create

}

namespace eval ::bootstrap::api {
  namespace export *
  namespace ensembel create


  # getModelNumber --
  #
  #       Asks netPixi to poll me with snmp and get the snmpObjectID.
  #
  proc getModelNumber {
     
  }
}
