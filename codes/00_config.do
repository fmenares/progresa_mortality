*** ============================================================================
*** 00_config.do — Analysis window switch
*** ----------------------------------------------------------------------------
*** Set the global $window BEFORE calling this file to choose the analytic window:
***   "full" : 1990–2017  (current baseline; full vital-statistics span)
***   "prog" : 1990–2006  (program decade; preferred analytic window)
***   "br"   : 1992–2002  (Barham & Rowberry 2013 replication window)
***
*** Defines: $yr_start $yr_end $nyears $master_suffix
***
*** The window governs BOTH (i) the balanced-panel completeness screen in
*** 01_mortality_data.do — which determines how many municipalities survive —
*** and (ii) the BR replication regression windows in 02_mortality.do. A shorter
*** window requires completeness over fewer years, so MORE municipalities are
*** retained (this is what moves the BR municipality count toward 1,961).
*** ============================================================================

if "$window" == "" global window "full"      // default when caller sets nothing

if      "$window" == "full" { global yr_start 1990 ; global yr_end 2017 }
else if "$window" == "prog" { global yr_start 1990 ; global yr_end 2006 }
else if "$window" == "br"   { global yr_start 1992 ; global yr_end 2002 }
else {
    di as error "Unknown window '$window' — use full | prog | br"
    error 198
}

global nyears = $yr_end - $yr_start + 1
global master_suffix "_$window"

di as txt "==> Analysis window: $window  ($yr_start-$yr_end, $nyears years)"
