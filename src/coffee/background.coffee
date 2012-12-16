active = false



chrome.browserAction.onClicked.addListener (tab) =>
    if active
        disable()
    else
        activate()


disable = =>
    active = false
    chrome.browserAction.setBadgeText { text: "" }
    chrome.browserAction.setIcon { path: "src/images/icon_19x19_grey.png" }

    withCurrentWindow (window) ->
        withAllTabsInWindow window.id, (tabs) ->
            sendCloseMessage = (tab) -> chrome.tabs.sendMessage tab.id, { event: 'slideshow.ended' }
            sendCloseMessage(tab) for tab in tabs

activate = =>
    active = true
    chrome.browserAction.setBadgeText { text: "Active" }
    chrome.browserAction.setIcon { path: "src/images/icon_19x19.png" }


    withCurrentWindow (window) ->
        withAllTabsInWindow window.id, (tabs) ->
            sendCloseMessage = (tab) -> chrome.tabs.sendMessage tab.id, { event: 'slideshow.started' }
            sendCloseMessage(tab) for tab in tabs

    withCurrentWindow (window) ->
        withFirstTab window.id, (firstTab) ->
            transitionTo firstTab


withFirstTab = (windowId, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        if tabs.length > 0
            callback tabs[0]


withSettingsFor = (tab, callback) ->
    settings = new TabSettings tab.url
    settings.load callback


transitionTo = (tab) ->
    if active
        withSettingsFor tab, (tabSettings) ->
            secondsOnPage = tabSettings.seconds

            selectTab tab, ->
                chrome.tabs.sendMessage tab.id, { event: 'tab.focus.gained' }


                withNextTab tab, (next) ->
                    withSettingsFor next, (nextSettings) ->
                        if nextSettings.reload
                            chrome.tabs.reload next.id

                        timeoutCallback = ->
                            transitionTo next

                        beforeTimeoutCallback = ->
                            chrome.tabs.sendMessage tab.id, { event: 'tab.focusloss.imminent' }

                        chrome.tabs.sendMessage next.id, { event: 'tab.focus.scheduled' }
                        setTimeout timeoutCallback, secondsOnPage * 1000
                        setTimeout beforeTimeoutCallback, (secondsOnPage-1) * 1000


withNextTab = (current, callback) ->
    anyTabsInWindowMatching current.windowId, httpTabPredicate, (httpTabs) ->
        if httpTabs.length > 0
            chosenTab = httpTabs[0]
            pickNext = false

            for tab in httpTabs
                do (tab) ->
                    if current.id == tab.id
                        pickNext = true

                    else if pickNext
                        chosenTab = tab
                        pickNext = false

            callback chosenTab

        else
            alert "No tabs!?"
            disable()
