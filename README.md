# Animation of Earthquakes in Japan in 2011

Personal project to create my first-ever animation in R. Here, I made a time lapse of earthquakes in Japan between February and July 2011 (excluding seismic intensity <1). For this animation, I had to dig a bit deeper into earthquake intensity units, with many countries having their own scaling metrics. For this exercise, I decided on using seismic energy. Often used "Magnitude" follows a logarithmic scale, so each full step reflects ~10x increase in wave amplitude and ~32x in energy. For this animation, point size reflects seismic energy using the formula: E = 10^(5.24 + 1.44 Mw) (More info here: https://www.usgs.gov/programs/earthquake-hazards/earthquake-magnitude-energy-release-and-shaking-intensity), with square-root transformation for visualization.

Data were downloaded from: Japanese Meteorological Agency (JMA) Earthquake Database.

Infromational text for the LinkedIn Post:

🗾 Japan, located on the Ring of Fire, experiences hundreds to thousands of earthquakes each year. With record-high tourism, it’s vital that visitors understand the risks and know how to respond in an emergency.

📊 To reflect on this, I created an animated map showing earthquake activity across Japan between February and July 2011. A year marked by one of the most powerful earthquakes in recorded history. The animation helps visualize the frequency and scale of seismic activity.

🧭 If you're visiting Japan or any earthquake-prone region, please take a moment to review local emergency procedures. Japan’s government offers an app and website for hazard information and alerts for travelers: https://www.jnto.go.jp/safety-tips/eng/

---

## *Share, adapt, attribute*

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.
