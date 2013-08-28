iterate = (entries, entryCallback) =>
    if entries.length > 0
        entryCallback entries[0], =>
            iterate entries[1..], entryCallback


window.TabController = ($scope) ->
    $scope.tabs = []
    $scope.updateSettings = (tab) -> tab.settings.flush()
    $scope.gotoTab = (tab) -> selectTab tab


    # Kick everything of
    withCurrentTab (currentTab) ->
        anyTabsInWindowMatching currentTab.windowId, cycleableTabPredicate, (matchedTabs) ->
            iterate matchedTabs, (tab, next) ->
                withScreenshotOf tab, (imageUrl) ->
                    withSettings tab, (settings) ->
                        $scope.$apply ->
                            tab.settings = settings
                            tab.imageUrl = imageUrl
                            $scope.tabs.push tab

                        next()


    # Listens for closed tabs
    chrome.tabs.onRemoved.addListener (tabId, removeInfo) =>
        $scope.$apply =>
            $scope.tabs = _.filter $scope.tabs, (e) -> e.id != tabId


###
    Chrome helper functions
###

withCurrentTab = (callback) ->
    chrome.tabs.getCurrent (current) => callback current

forNewTabsInWindow = (windowId, callback) ->
    chrome.tabs.onCreated.addListener (newTab) =>
        if windowId == newTab.windowId
            callback newTab

anyTabsInWindowMatching = (windowId, predicate, callback) ->
    withAllTabsInWindow windowId, (tabs) ->
        callback _.filter tabs, predicate

withAllTabsInWindow = (windowId, callback) ->
    chrome.tabs.query { windowId: windowId }, callback

withSettings = (tab, callback) ->
    settings = new TabSettings tab.url
    settings.load ->
        callback settings

withScreenshotOf = (subjectTab, screenshotListener) ->
    withCurrentTab (originalTab) ->
        selectTab subjectTab, ->
            chrome.tabs.captureVisibleTab subjectTab.windowId, { }, (imageUrl) ->
                selectTab originalTab, ->
                    screenshotListener imageUrl



