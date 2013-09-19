tabUrlMatching = (regex) ->
    (tab) ->
        regex.test(tab?.url)

window.cycleableTab = tabUrlMatching(/^(http|file)/)
