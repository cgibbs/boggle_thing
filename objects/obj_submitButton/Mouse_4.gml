var testWord = getPlayedWordAsString();
var potentialScore = getPlayedWordValue();

show_debug_message(testWord);

if (global.dictionary.check(testWord)) {
	show_debug_message("word is valid!");
	show_debug_message("submitted \"" + testWord + "\" for " + string(potentialScore) + " points!");
} else {
	show_debug_message("word is invalid!");	
}