###
    Will be injected into all http tabs!
###

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
    if request.event == 'tab.focus.scheduled'
        if $('#chrometabblinder').length == 0
            console.log("Adding blinder...")
            blind = document.createElement 'div'
            blind.id = 'chrometabblinder'
            blind.className = 'chrome-tab-blinder'
            blind.style.top = window.crollY

            document.body.appendChild(blind)

    else if request.event == 'tab.focus.gained'
        $('#chrometabblinder').css('top', window.scrollY).addClass('roulette-fade-content-in').removeClass('roulette-fade-content-out')

    else if request.event == 'tab.focusloss.imminent'
        $('#chrometabblinder').css('top', window.scrollY).addClass('roulette-fade-content-out').removeClass('roulette-fade-content-in')

    else if request.event == 'slideshow.ended'
        $('#chrometabblinder').remove()