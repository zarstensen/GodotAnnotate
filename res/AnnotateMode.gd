@tool
extends OptionButton
###
### We do not want to display the mode text in the OptionButton icon,
### only in the dropdown menu showed when it is clicked on.
### Therefore we clear the text contents everytime the text is set on the button,
### by the OptionButton base class.
###

func _ready():
	text = ""

func _on_item_selected(index):
	text = ""
