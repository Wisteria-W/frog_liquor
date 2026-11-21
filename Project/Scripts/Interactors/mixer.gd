class_name Mixer
extends IngredientConsumer

## The brewing mixer: every consumed ingredient goes into the
## PotionService brewing slots.


func _ready() -> void:
	interaction_prompt = "Add ingredient"


func _consume(ingredient: Ingredient) -> void:
	PotionService.add_ingredient(ingredient.id)
