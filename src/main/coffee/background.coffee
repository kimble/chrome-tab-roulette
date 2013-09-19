# Badge functions

updateBadge = (state) ->
    chrome.browserAction.setBadgeText { text: state.text }
    chrome.browserAction.setIcon { path: state.icon }

activateBadge = (asyncCallback) ->
    updateBadge({ text: "ON!", icon: "assets/images/icon_19x19.png" })
    asyncCallback(null, "badge-activated")

deactivateBadge = (asyncCallback) ->
    updateBadge({ text: "", icon: "assets/images/icon_19x19_grey.png" })
    asyncCallback(null, "badge-disabled")


# Content script messaging functions

sendMessageToTab = (recipientTab, payload, asyncCallback) ->
    chrome.tabs.sendMessage recipientTab.id, payload, (response) ->
        asyncCallback null, response

sendSimpleEventMessage = (recipientTab, eventName, asyncCallback) ->
    sendMessageToTab(recipientTab, { event: eventName }, asyncCallback)


sendSimpleEventMessageToNeighbouringTabs = (windowId, eventName, asyncCallback) ->
    simpleEventMessageMapper = (recipientTab, asyncCallback) ->
        sendSimpleEventMessage recipientTab, eventName, asyncCallback

    async.waterfall(
            [
                findNeighbouringCyclableTabs(windowId),
                (neighbouringTabs, asyncCallback) ->
                    async.map(neighbouringTabs, simpleEventMessageMapper, asyncCallback)
            ],
            asyncCallback
    )

neighbouringTabSimpleEventMessanger = (windowId, eventName) ->
    (asyncCallback) ->
        sendSimpleEventMessageToNeighbouringTabs(windowId, eventName, asyncCallback)

asyncCallbackErrorSinkBridge = (name) ->
    (err, results) ->
        if err then errorSink name + ": " + err
        else console.error(" :: " + name + ": " + results)


# State

active = false
windowId = undefined

activateState = (currentTab) ->
    (asyncCallback) ->
        active = true
        windowId = currentTab.windowId
        asyncCallback(null, "state-activated")

deactivateState = (asyncCallback) ->
    active = false
    windowId = undefined
    asyncCallback(null, "state-deactivated")


# Error

errorSink = (excuse) ->
    if excuse == "no-tab" then alert("Can't determine next tab")
    else alert("Tab roulette crash: " + excuse)

    deactivate()






executeTransition = (currentTab, nextTab) ->
    forwardScreenshot = (asyncCallback) ->
        async.waterfall([
            takeScreenshotOf(windowId),
            (imageUri, asyncCallback) ->
                payload = { event: 'tab.previous.screenshot', imageUri: imageUri }
                sendMessageToTab(nextTab, payload, asyncCallback)
        ],
        asyncCallback)


    informAboutFocus = (asyncCallback) ->
        sendSimpleEventMessage nextTab, 'tab.focus.gained', asyncCallback

    asyncDelay = (millis) ->
        (asyncCallback) ->
            f = -> asyncCallback(null, "delayed by " + millis + " ms")
            setTimeout f, millis

    changeTab = (asyncCallback) ->
        chrome.tabs.update nextTab.id, { active: true }, ->
            asyncCallback(null, null)

    considerReload = (asyncCallback) ->
        async.waterfall([
            settingsLookup(currentTab),
            (currentTabSettings, asyncCallback) ->
                reload(currentTab) if currentTabSettings.reload
                asyncCallback(null, null)
        ], asyncCallback)

    async.waterfall([
        settingsLookup(nextTab),
        (nextTabSettings, asyncCallback) ->
            async.series([
                forwardScreenshot,
                changeTab,
                informAboutFocus,
                considerReload,
                asyncDelay(nextTabSettings.seconds * 1000),

                (asyncCallback) ->
                    initiateTransitionFrom(nextTab) if active
                    asyncCallback(null, null)
            ],
            asyncCallback)
    ],
    asyncCallbackErrorSinkBridge("Execute transition"))


initiateTransitionFrom = (tab) ->
    async.waterfall([
        determineNextTab(tab),
        (nextTab, asyncCallback) ->
            executeTransition(tab, nextTab)
            asyncCallback(null)
    ],
    asyncCallbackErrorSinkBridge("Transitioning from: " + tab.title))


# Lifecycle

activate = (currentTab) ->
    async.series([
        activateBadge,
        activateState(currentTab),
        initiateTransitionFrom(currentTab)
    ],
    asyncCallbackErrorSinkBridge("Activate tab roulette"))

deactivate = ->
    async.parallel([
        deactivateBadge,
        deactivateState,
        neighbouringTabSimpleEventMessanger(windowId, 'slideshow.ended')
    ],
    asyncCallbackErrorSinkBridge("Disabled slideshow"))


activateOrDeactivate = validTabListener errorSink, (currentTab) ->
    if active then deactivate() else activate(currentTab)

chrome.browserAction.onClicked.addListener(activateOrDeactivate)





# On install

chrome.runtime.onInstalled.addListener (type) ->
    if type.reason == "install"
        chrome.tabs.create url: "assets/html/after-install.html", active: true

