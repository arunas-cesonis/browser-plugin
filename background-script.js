const backend = 'http://localhost:8000'

const report = tabUrl => 
  fetch(backend, {
    body: JSON.stringify({tabUrl}),
    // headers: {
    //   'content-type': 'application/json',
    // },
    method: 'POST',
  })

browser.tabs.onActivated.addListener(async (obj) => {
  report((await browser.tabs.get(obj.tabId)).url)
})

browser.tabs.onUpdated.addListener((tabId, changeInfo) => {
  if (changeInfo.url) report(changeInfo.url)
})
