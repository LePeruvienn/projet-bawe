
const __STRING_ADAPTIVE_THEME_PREFERENCES__ = "adaptive_theme_preferences";
const __STRING_FLUTTER_FEUR_SAVED_LOCALE__  = "flutter.feur_saved_locale";

const __STRING_THEME_MODE__ = "theme_mode";

const __STRING_APP_TITLE__       = "app-title";
const __STRING_APP_MESSAGE__     = "app-message";
const __STRING_LOADING_MESSAGE__ = "loading-message";


const __EN__ = "en";
const __FR__ = "fr";

const __TRAD_DATA__ = {

	"en": {
		__MESSAGE__: "Connecting you to the world...",
		__LOADING__: "Loading ...",
		__RUNNING_APP__: "Running app ...",
		__INIT_APP__: "Initializing engine ..."
	},
	"fr": {
		__MESSAGE__: "En train de te connecter au monde...",
		__LOADING__: "Chargement ...",
		__RUNNING_APP__: "Lancement de l'app ...",
		__INIT_APP__: "Intilisation du moteur ..."
	}
};

const __THEMES_DATA__ = {

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


const __LOADING_ELEMENT__ = document.getElementById(__STRING_LOADING_MESSAGE__);
const __MESSAGE_ELEMENT__ = document.getElementById(__STRING_APP_MESSAGE__);

const __ADAPTIVE_THEME_DATA__ = localStorage.getItem(__STRING_ADAPTIVE_THEME_PREFERENCES__);
const __FEUR_LOCALE_DATA__ = localStorage.getItem(__STRING_FLUTTER_FEUR_SAVED_LOCALE__);


const __CURRENT_LOCALE__ = (__FEUR_LOCALE_DATA__) ? JSON.parse(__FEUR_LOCALE_DATA__) : __EN__;

if (__MESSAGE_ELEMENT__)
	__MESSAGE_ELEMENT__.textContent = __TRAD_DATA__[__CURRENT_LOCALE__].__MESSAGE__;
else
	console.error("Could not find html: __MESSAGE_ELEMENT__");

if (__LOADING_ELEMENT__)
	__LOADING_ELEMENT__.textContent = __TRAD_DATA__[__CURRENT_LOCALE__].__LOADING__;
else
	console.error("Could not find html: __LOADING_ELEMENT__");

async function handleLoading(engineInitializer) {

	if (__LOADING_ELEMENT__)
		__LOADING_ELEMENT__.textContent = __TRAD_DATA__[__CURRENT_LOCALE__].__INIT_APP__;

	const appRunner = await engineInitializer.initializeEngine();

	if (__LOADING_ELEMENT__)
		__LOADING_ELEMENT__.textContent = __TRAD_DATA__[__CURRENT_LOCALE__].__RUNNING_APP__;

	await appRunner.runApp();
}

function applyTheme() {

	// Light theme by default
	let currentTheme = __THEMES_DATA__.__LIGHT__;

	try {

		let parsedData = undefined;

		if (__ADAPTIVE_THEME_DATA__) {

			parsedData = JSON.parse(__ADAPTIVE_THEME_DATA__);

			if (parsedData.length !== undefined)
				parsedData = JSON.parse(parsedData);
		}

		const savedTheme = (parsedData) ? parsedData[__STRING_THEME_MODE__] : undefined;

		// Determine if dark theme is preferred (0 is light 1 is dark)
		const isDarkPreferred = savedTheme || (savedTheme === undefined && window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches);

		// Set current theme
		currentTheme = (isDarkPreferred) ? __THEMES_DATA__.__DARK__ : __THEMES_DATA__.__LIGHT__;

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
