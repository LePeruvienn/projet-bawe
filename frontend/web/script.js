
const __STRING_ADAPTIVE_THEME_PREFERENCES__ = "adaptive_theme_preferences";
const __STRING_THEME_MODE__ = "theme_mode";

const __THEMES__ = {

	__LIGHT__: {
		__PRIMARY__: "#6751A2",
		__SECONDARY__: "#78737D",
		__BACKGROUND__: "#FEF7FF"
	},
	__DARK__: {
		__PRIMARY__: "#CFBBFF",
		__SECONDARY__: "#C9C3CF",
		__BACKGROUND__: "#1B191E"
	}
};

const __LOADING_ELEMENT__ = document.getElementById("loading-message");
const __ADAPTIVE_THEME_DATA__ = localStorage.getItem(__STRING_ADAPTIVE_THEME_PREFERENCES__);

async function handleLoading(engineInitializer) {

	if (__LOADING_ELEMENT__)
		__LOADING_ELEMENT__.textContent = "Initializing engine...";

	const appRunner = await engineInitializer.initializeEngine();

	if (__LOADING_ELEMENT__)
		__LOADING_ELEMENT__.textContent = "Running app...";

	await appRunner.runApp();
}

function applyTheme() {

	// Light theme by default
	let currentTheme = __THEMES__.__LIGHT__;

	try {

		let parsedData = undefined;

		if (__ADAPTIVE_THEME_DATA__) {

			parsedData = JSON.parse(__ADAPTIVE_THEME_DATA__);

			if (parsedData.length !== undefined)
				parsedData = JSON.parse(parsedData);
		}

		const savedTheme = (parsedData) ? parsedData[__STRING_THEME_MODE__] : undefined;

		// Determine if dark theme is preferred
		const isDarkPreferred = savedTheme || (savedTheme === undefined && window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches);

		// Set current theme
		currentTheme = (isDarkPreferred) ? __THEMES__.__DARK__ : __THEMES__.__LIGHT__;

	} catch (e) {

		console.error("Could not access localStorage for theme preference:", e);
		console.log("Failed to apply theme CSS will fallback to default theme.");
	}

	// Apply default theme
	const rootStyle = document.documentElement.style;
	rootStyle.setProperty("--bg-color", currentTheme.__BACKGROUND__);
	rootStyle.setProperty("--primary-color", currentTheme.__PRIMARY__);
	rootStyle.setProperty("--secondary-color", currentTheme.__SECONDARY__);

	document.body.style.backgroundColor = currentTheme.__BACKGROUND__;
}
