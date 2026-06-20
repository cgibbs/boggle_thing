//Load your file.
ChatterboxLoadFromFile("test_crochet.yarn"); //or whatever you called yours
// Create Chatterbox
chatterbox = ChatterboxCreate("test_crochet.yarn"); // Initialise Chatterbox by jumping to a node ("Start")
ChatterboxJump(chatterbox,"Start");// Get Content from Chatterbox
text        = ChatterboxGetContent(chatterbox,0);
nodeTitle   = ChatterboxGetCurrent(chatterbox);