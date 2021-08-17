![](https://cdn.discordapp.com/attachments/853155888667164692/876975862698881064/OneType.png) 
#### OneType is a mostly from the ground up re-write of `Window_Message.rb` from **OneShot** aimed at allowing developer configuration, and text animations! *(also includes `ED_Message.rb`)*


## Usage

The *main* goal of the new features is to reinforce expression in character speech using new customizable text effects and extra tidbits of formatting


### New Control Characters
Format | Function 
----|--------
 \f[#] | Applies the **Effect** with the given **ID** `(Defined in Config)`
 \s[#] | Changes the **Font Size**
 \b[#] | Changes the **Blip Sound** `(Defined in Config)`
 \\*   | Auto-terminates the Message

### Misc Features

Feature | Notes `(Extra Info in the Wiki)`
------- | ------
Animated Facesprites | add `_#` for each frame _`(have a base frame without a number to call)`_
Text Blinker | toggled in the config, adds a solid block that blinks at the end of the message
Dedicated Blip Folder | modified in the config, allows you to set a folder in Audio to use for blip sounds
Custom Text Colours | modified in the config, allows you to set new, or modify the base colour ID's
Custom Blip Prefixes | modified in the config, allows you to set prefixes for blips like `[` for `text_robot`
Blip Pitch Ranges | modified in the config, allows you to set the pitch randomization range `100..100` is default

## Known Issues | Pull requests to fix these issues welcome!

* Message Choices write out like a normal message rather than instantly appearing

* Message Box doesn't show the little arrow at the bottom of the window

* Spamming an event that has dialogue will cause the text to render without the window and softlock all movement until the event is re-interacted with (this doesn't apply to mashing through long cutscenes, just spamming for example a jar that has Niko comment on it having stuff in it and will never cause the player to get trapped beyond repair and shouldn't ever come up but it is an issue in the first place)

* Solo choices that don't have a textbox to accomidate will interrupt the text box fading in for the following dialogue if there is no small wait on the next show message (though it's still mostly visible this is also another small issue that needs to be fixed)