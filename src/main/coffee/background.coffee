disableFunction = null


###
    Tabs
    ----
    http://developer.chrome.com/extensions/tabs.html
###

matchingTabsInWindow = (windowId, predicate, callback) -> chrome.tabs.query { windowId: windowId }, (tabs) ->
    matchedTabs = tabs.filter (tab) -> predicate(tab)
    callback(matchedTabs)


nextTab = (currentTab, tabSelector, callback) ->
    tabSelector (matchedTabs) ->
        lastTabIndex = matchedTabs.length - 1
        selectedTab = matchedTabs[0]

        for tab, i in matchedTabs
            if tab.id == currentTab.id && i < lastTabIndex
                selectedTab = matchedTabs[i+1]
                break

        callback(selectedTab)



###
    Content Script - Messages
    http://developer.chrome.com/extensions/messaging.html
###

sendMessageToTab = (recipientTab, payload) ->
    chrome.tabs.sendMessage recipientTab.id, payload

sendDelayedMessageToTab = (recipentTab, delayInMillis, payload) ->
    delayedFunc = -> sendMessageToTab recipentTab, payload
    setTimeout delayedFunc, delayInMillis


###
    Badge
    -----
    http://developer.chrome.com/extensions/browserAction.html
###

updateBadge = (text, iconPath) ->
    chrome.browserAction.setBadgeText { text: text }
    chrome.browserAction.setIcon { path: iconPath }

deactivateBadge = -> updateBadge("", "assets/images/icon_19x19_grey.png")
activateBadge = -> updateBadge("ON!", "assets/images/icon_19x19.png")


chrome.browserAction.onClicked.addListener (startingTab) =>
    if disableFunction == null
        activateBadge()

        disableFunction = (reason) ->
            if reason?.length
                alert reason

            disableFunction = null
            deactivateBadge()

            fileAndHttpTabsInWindow (tabs) ->
                sendCloseMessage = (tab) -> sendMessageToTab tab, { event: 'slideshow.ended' }
                sendCloseMessage(tab) for tab in tabs


        fileAndHttpTabsInWindow = (callback) ->
            matchingTabsInWindow startingTab.windowId, cycleableTabPredicate, callback

        cancelRouletteOnEmpty = (tabSelector) ->
            (callback) ->
                tabSelector (matchedTabs) ->
                    if matchedTabs.length > 0
                        callback(matchedTabs)
                    else
                        disable("No tabs - Cancelling!")

        nextTabSelector = (currentTab, callback) ->
            nextTab currentTab, cancelRouletteOnEmpty(fileAndHttpTabsInWindow), (nextTab) ->
                callback(currentTab, nextTab)


        considerReloading = (tab) ->
            withSettingsFor tab, (tabSettings) ->
                if tabSettings.reload
                    func = -> chrome.tabs.reload tab.id
                    setTimeout func, 1000




        cycle = (previousTab, targetTab) ->
            if disableFunction != null
                sendMessageToTab targetTab, { event: 'tab.focus.scheduled' }

                selectTab targetTab, (activeTab) -> # Todo: Check that activeTab exists
                    sendMessageToTab activeTab, { event: 'tab.focus.gained' }
                    considerReloading previousTab

                    withSettingsFor activeTab, (settings) ->
                        func = -> nextTabSelector targetTab, cycle
                        setTimeout func, settings.seconds * 1000

                        sendDelayedMessageToTab activeTab, (settings.seconds - 1) * 1000, { event: 'tab.focusloss.imminent' }



        # Kickoff from the tab that was active when the badge was clicked
        nextTabSelector startingTab, cycle


    else
        if disableFunction != null
            disableFunction()

