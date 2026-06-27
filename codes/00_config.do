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
*** The window governs the balanced-panel completeness screen in
*** 01_mortality_data.do — i.e. how many municipalities survive. A shorter window
*** requires completeness over fewer years, so MORE municipalities are retained
*** (this is what moves the BR municipality count toward 1,961). The BR replication
*** regressions in 02_mortality.do (AT3/AT5) are ALWAYS run over 1992-2002; the
*** window only changes the municipality sample they operate on. "full" reproduces
*** the original pre-switch behavior exactly.
*** ============================================================================

*if "$window" == "prog" 
global window "prog"      // default when caller sets nothing

* Independent if-blocks (no else) so this runs correctly whether the file is
* `do`-ne or pasted line-by-line into the console.
global yr_start
global yr_end
if "$window" == "full" {
    global yr_start 1990
    global yr_end   2017
}
if "$window" == "prog" {
    global yr_start 1990
    global yr_end   2006
}
if "$window" == "br" {
    global yr_start 1992
    global yr_end   2002
}
if "$yr_start" == "" {
    di as error "Unknown window '$window' — use full | prog | br"
    error 198
}

global nyears = $yr_end - $yr_start + 1
global master_suffix "_$window"

di as txt "==> Analysis window: $window  ($yr_start-$yr_end, $nyears years)"
