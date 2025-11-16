# Script to populate recipeR with vegetarian Asian recipes

devtools::load_all()

cat("\n", strrep("=", 70), "\n", sep="")
cat("POPULATING RECIPE DATABASE WITH VEGETARIAN ASIAN RECIPES\n")
cat(strrep("=", 70), "\n\n", sep="")

# Clear existing data for fresh start
recipes_file <- data_file()
if (file.exists(recipes_file)) {
  file.remove(recipes_file)
  cat("Cleared existing recipe database\n\n")
}

# Recipe 1: Vegetable Fried Rice
cat("Adding: Vegetable Fried Rice...\n")
add_recipe(list(
  title = "Vegetable Fried Rice",
  source = "Asian Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "rice", quantity = 3, unit = "cup", raw_text = "3 cups cooked white rice"),
    list(ingredient_name = "eggs", quantity = 2, unit = "", raw_text = "2 eggs"),
    list(ingredient_name = "carrot", quantity = 1, unit = "medium", raw_text = "1 medium carrot, diced"),
    list(ingredient_name = "peas", quantity = 1, unit = "cup", raw_text = "1 cup frozen peas"),
    list(ingredient_name = "green onion", quantity = 3, unit = "", raw_text = "3 green onions, chopped"),
    list(ingredient_name = "soy sauce", quantity = 3, unit = "tbsp", raw_text = "3 tbsp soy sauce"),
    list(ingredient_name = "vegetable oil", quantity = 2, unit = "tbsp", raw_text = "2 tbsp vegetable oil"),
    list(ingredient_name = "garlic", quantity = 2, unit = "clove", raw_text = "2 cloves garlic, minced"),
    list(ingredient_name = "sesame oil", quantity = 1, unit = "tsp", raw_text = "1 tsp sesame oil")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Heat oil in wok over high heat"),
    list(step_number = 2, instruction_text = "Scramble eggs and set aside"),
    list(step_number = 3, instruction_text = "Stir-fry garlic, carrot, and peas for 2 minutes"),
    list(step_number = 4, instruction_text = "Add rice and break up clumps, stir-fry for 3-4 minutes"),
    list(step_number = 5, instruction_text = "Add soy sauce and sesame oil, mix well"),
    list(step_number = 6, instruction_text = "Add eggs and green onions, toss to combine"),
    list(step_number = 7, instruction_text = "Serve hot")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 2: Vegetable Pad Thai
cat("Adding: Vegetable Pad Thai...\n")
add_recipe(list(
  title = "Vegetable Pad Thai",
  source = "Thai Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "rice noodles", quantity = 8, unit = "oz", raw_text = "8 oz dried rice noodles"),
    list(ingredient_name = "peanut butter", quantity = 3, unit = "tbsp", raw_text = "3 tbsp peanut butter"),
    list(ingredient_name = "tamarind paste", quantity = 2, unit = "tbsp", raw_text = "2 tbsp tamarind paste"),
    list(ingredient_name = "fish sauce", quantity = 2, unit = "tbsp", raw_text = "2 tbsp fish sauce"),
    list(ingredient_name = "lime", quantity = 2, unit = "", raw_text = "2 limes, juiced"),
    list(ingredient_name = "brown sugar", quantity = 2, unit = "tbsp", raw_text = "2 tbsp brown sugar"),
    list(ingredient_name = "tofu", quantity = 14, unit = "oz", raw_text = "14 oz firm tofu, cubed"),
    list(ingredient_name = "bell pepper", quantity = 1, unit = "large", raw_text = "1 large red bell pepper, sliced"),
    list(ingredient_name = "zucchini", quantity = 1, unit = "medium", raw_text = "1 medium zucchini, julienned"),
    list(ingredient_name = "carrot", quantity = 1, unit = "medium", raw_text = "1 medium carrot, julienned"),
    list(ingredient_name = "garlic", quantity = 3, unit = "clove", raw_text = "3 cloves garlic, minced"),
    list(ingredient_name = "vegetable oil", quantity = 2, unit = "tbsp", raw_text = "2 tbsp vegetable oil"),
    list(ingredient_name = "peanuts", quantity = 1/4, unit = "cup", raw_text = "1/4 cup crushed peanuts")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Soak rice noodles in warm water for 20 minutes, drain"),
    list(step_number = 2, instruction_text = "Mix peanut butter, tamarind, fish sauce, lime juice, and brown sugar"),
    list(step_number = 3, instruction_text = "Heat oil in wok, stir-fry garlic for 30 seconds"),
    list(step_number = 4, instruction_text = "Add tofu and vegetables, stir-fry for 3 minutes"),
    list(step_number = 5, instruction_text = "Add noodles and sauce, toss everything together for 2-3 minutes"),
    list(step_number = 6, instruction_text = "Top with crushed peanuts and serve")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 3: Miso Ramen
cat("Adding: Miso Ramen...\n")
add_recipe(list(
  title = "Miso Ramen",
  source = "Japanese Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "ramen noodles", quantity = 2, unit = "", raw_text = "2 portions fresh or dried ramen noodles"),
    list(ingredient_name = "vegetable broth", quantity = 4, unit = "cup", raw_text = "4 cups vegetable broth"),
    list(ingredient_name = "miso paste", quantity = 3, unit = "tbsp", raw_text = "3 tbsp miso paste"),
    list(ingredient_name = "soy sauce", quantity = 1, unit = "tbsp", raw_text = "1 tbsp soy sauce"),
    list(ingredient_name = "mirin", quantity = 1, unit = "tbsp", raw_text = "1 tbsp mirin"),
    list(ingredient_name = "ginger", quantity = 1, unit = "tbsp", raw_text = "1 tbsp ginger, minced"),
    list(ingredient_name = "garlic", quantity = 2, unit = "clove", raw_text = "2 cloves garlic, minced"),
    list(ingredient_name = "green onion", quantity = 2, unit = "", raw_text = "2 green onions, chopped"),
    list(ingredient_name = "mushroom", quantity = 4, unit = "oz", raw_text = "4 oz shiitake mushrooms, sliced"),
    list(ingredient_name = "spinach", quantity = 2, unit = "cup", raw_text = "2 cups fresh spinach"),
    list(ingredient_name = "eggs", quantity = 2, unit = "", raw_text = "2 eggs, soft-boiled"),
    list(ingredient_name = "sesame seeds", quantity = 1, unit = "tsp", raw_text = "1 tsp sesame seeds"),
    list(ingredient_name = "sesame oil", quantity = 1, unit = "tsp", raw_text = "1 tsp sesame oil")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Bring vegetable broth to boil in large pot"),
    list(step_number = 2, instruction_text = "Add minced ginger and garlic, simmer 2 minutes"),
    list(step_number = 3, instruction_text = "Stir in miso paste, soy sauce, and mirin"),
    list(step_number = 4, instruction_text = "Add mushrooms and simmer for 3 minutes"),
    list(step_number = 5, instruction_text = "Add spinach and cook until wilted"),
    list(step_number = 6, instruction_text = "Cook ramen noodles separately according to package directions"),
    list(step_number = 7, instruction_text = "Divide noodles between bowls and pour broth over"),
    list(step_number = 8, instruction_text = "Top with soft-boiled egg, green onion, and sesame seeds"),
    list(step_number = 9, instruction_text = "Drizzle with sesame oil and serve")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 4: Green Curry Vegetables
cat("Adding: Green Curry Vegetables...\n")
add_recipe(list(
  title = "Green Curry Vegetables",
  source = "Thai Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "green curry paste", quantity = 3, unit = "tbsp", raw_text = "3 tbsp green curry paste"),
    list(ingredient_name = "coconut milk", quantity = 1, unit = "can", raw_text = "1 can (13.5 oz) coconut milk"),
    list(ingredient_name = "vegetable broth", quantity = 1, unit = "cup", raw_text = "1 cup vegetable broth"),
    list(ingredient_name = "tofu", quantity = 14, unit = "oz", raw_text = "14 oz firm tofu, cubed"),
    list(ingredient_name = "bell pepper", quantity = 1, unit = "large", raw_text = "1 large green bell pepper, sliced"),
    list(ingredient_name = "zucchini", quantity = 2, unit = "medium", raw_text = "2 medium zucchini, sliced"),
    list(ingredient_name = "bamboo shoots", quantity = 1, unit = "cup", raw_text = "1 cup canned bamboo shoots"),
    list(ingredient_name = "basil leaves", quantity = 1/2, unit = "cup", raw_text = "1/2 cup fresh Thai basil leaves"),
    list(ingredient_name = "lime", quantity = 1, unit = "", raw_text = "1 lime"),
    list(ingredient_name = "fish sauce", quantity = 1, unit = "tbsp", raw_text = "1 tbsp fish sauce"),
    list(ingredient_name = "palm sugar", quantity = 1, unit = "tbsp", raw_text = "1 tbsp palm sugar")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Heat curry paste in large pot for 1 minute"),
    list(step_number = 2, instruction_text = "Slowly add coconut milk, stirring to combine"),
    list(step_number = 3, instruction_text = "Add vegetable broth and bring to simmer"),
    list(step_number = 4, instruction_text = "Add tofu and let simmer for 5 minutes"),
    list(step_number = 5, instruction_text = "Add bell pepper and zucchini, cook 5 minutes"),
    list(step_number = 6, instruction_text = "Stir in bamboo shoots, fish sauce, and palm sugar"),
    list(step_number = 7, instruction_text = "Add basil leaves and cook 1 minute"),
    list(step_number = 8, instruction_text = "Squeeze lime juice over and adjust seasoning"),
    list(step_number = 9, instruction_text = "Serve over jasmine rice")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 5: Vegetable Lo Mein
cat("Adding: Vegetable Lo Mein...\n")
add_recipe(list(
  title = "Vegetable Lo Mein",
  source = "Chinese Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "lo mein noodles", quantity = 12, unit = "oz", raw_text = "12 oz fresh lo mein noodles"),
    list(ingredient_name = "broccoli", quantity = 2, unit = "cup", raw_text = "2 cups broccoli florets"),
    list(ingredient_name = "snap peas", quantity = 2, unit = "cup", raw_text = "2 cups snap peas"),
    list(ingredient_name = "carrot", quantity = 2, unit = "medium", raw_text = "2 medium carrots, julienned"),
    list(ingredient_name = "mushroom", quantity = 8, unit = "oz", raw_text = "8 oz mushrooms, sliced"),
    list(ingredient_name = "soy sauce", quantity = 3, unit = "tbsp", raw_text = "3 tbsp soy sauce"),
    list(ingredient_name = "oyster sauce", quantity = 2, unit = "tbsp", raw_text = "2 tbsp oyster sauce"),
    list(ingredient_name = "ginger", quantity = 1, unit = "tbsp", raw_text = "1 tbsp ginger, minced"),
    list(ingredient_name = "garlic", quantity = 3, unit = "clove", raw_text = "3 cloves garlic, minced"),
    list(ingredient_name = "vegetable oil", quantity = 2, unit = "tbsp", raw_text = "2 tbsp vegetable oil"),
    list(ingredient_name = "sesame oil", quantity = 1, unit = "tbsp", raw_text = "1 tbsp sesame oil"),
    list(ingredient_name = "green onion", quantity = 2, unit = "", raw_text = "2 green onions, chopped")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Cook lo mein noodles according to package directions, drain"),
    list(step_number = 2, instruction_text = "Heat vegetable oil in wok over high heat"),
    list(step_number = 3, instruction_text = "Stir-fry garlic and ginger for 30 seconds"),
    list(step_number = 4, instruction_text = "Add mushrooms and cook for 2 minutes"),
    list(step_number = 5, instruction_text = "Add broccoli, snap peas, and carrots, stir-fry 3 minutes"),
    list(step_number = 6, instruction_text = "Add noodles, soy sauce, and oyster sauce"),
    list(step_number = 7, instruction_text = "Toss everything together for 2 minutes"),
    list(step_number = 8, instruction_text = "Drizzle with sesame oil and top with green onions"),
    list(step_number = 9, instruction_text = "Serve immediately")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 6: Vegetable Samosas
cat("Adding: Vegetable Samosas...\n")
add_recipe(list(
  title = "Vegetable Samosas",
  source = "Indian Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "flour", quantity = 2, unit = "cup", raw_text = "2 cups all-purpose flour"),
    list(ingredient_name = "salt", quantity = 1/2, unit = "tsp", raw_text = "1/2 tsp salt"),
    list(ingredient_name = "vegetable oil", quantity = 1/3, unit = "cup", raw_text = "1/3 cup vegetable oil"),
    list(ingredient_name = "water", quantity = 1/2, unit = "cup", raw_text = "1/2 cup water"),
    list(ingredient_name = "potato", quantity = 3, unit = "medium", raw_text = "3 medium potatoes, boiled and diced"),
    list(ingredient_name = "peas", quantity = 1, unit = "cup", raw_text = "1 cup frozen peas"),
    list(ingredient_name = "onion", quantity = 1, unit = "medium", raw_text = "1 medium onion, finely diced"),
    list(ingredient_name = "ginger", quantity = 1, unit = "tbsp", raw_text = "1 tbsp ginger, minced"),
    list(ingredient_name = "garlic", quantity = 2, unit = "clove", raw_text = "2 cloves garlic, minced"),
    list(ingredient_name = "cumin seeds", quantity = 1, unit = "tsp", raw_text = "1 tsp cumin seeds"),
    list(ingredient_name = "coriander", quantity = 1, unit = "tsp", raw_text = "1 tsp coriander"),
    list(ingredient_name = "turmeric", quantity = 1/2, unit = "tsp", raw_text = "1/2 tsp turmeric"),
    list(ingredient_name = "chili powder", quantity = 1/2, unit = "tsp", raw_text = "1/2 tsp chili powder"),
    list(ingredient_name = "cilantro", quantity = 2, unit = "tbsp", raw_text = "2 tbsp fresh cilantro, chopped")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Mix flour and salt, add oil and rub in with fingers"),
    list(step_number = 2, instruction_text = "Gradually add water and knead into smooth dough"),
    list(step_number = 3, instruction_text = "Cover and let rest 30 minutes"),
    list(step_number = 4, instruction_text = "Heat oil, toast cumin seeds for 30 seconds"),
    list(step_number = 5, instruction_text = "Add onion, ginger, garlic and cook until soft"),
    list(step_number = 6, instruction_text = "Add potatoes, peas, and spices, cook 3 minutes"),
    list(step_number = 7, instruction_text = "Remove from heat and stir in cilantro"),
    list(step_number = 8, instruction_text = "Divide dough into 12 balls, flatten into thin circles"),
    list(step_number = 9, instruction_text = "Cut circles in half, form cones, fill with potato mixture"),
    list(step_number = 10, instruction_text = "Deep fry until golden brown, about 2-3 minutes"),
    list(step_number = 11, instruction_text = "Drain on paper towels and serve hot")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 7: Vegetable Biryani
cat("Adding: Vegetable Biryani...\n")
add_recipe(list(
  title = "Vegetable Biryani",
  source = "Indian Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "basmati rice", quantity = 2, unit = "cup", raw_text = "2 cups basmati rice"),
    list(ingredient_name = "potato", quantity = 3, unit = "medium", raw_text = "3 medium potatoes, cut into chunks"),
    list(ingredient_name = "cauliflower", quantity = 2, unit = "cup", raw_text = "2 cups cauliflower florets"),
    list(ingredient_name = "carrot", quantity = 2, unit = "medium", raw_text = "2 medium carrots, cubed"),
    list(ingredient_name = "peas", quantity = 1, unit = "cup", raw_text = "1 cup frozen peas"),
    list(ingredient_name = "onion", quantity = 3, unit = "large", raw_text = "3 large onions, sliced"),
    list(ingredient_name = "ginger", quantity = 2, unit = "tbsp", raw_text = "2 tbsp ginger, minced"),
    list(ingredient_name = "garlic", quantity = 4, unit = "clove", raw_text = "4 cloves garlic, minced"),
    list(ingredient_name = "yogurt", quantity = 1, unit = "cup", raw_text = "1 cup plain yogurt"),
    list(ingredient_name = "cumin seeds", quantity = 1, unit = "tsp", raw_text = "1 tsp cumin seeds"),
    list(ingredient_name = "bay leaf", quantity = 3, unit = "", raw_text = "3 bay leaves"),
    list(ingredient_name = "cinnamon stick", quantity = 1, unit = "", raw_text = "1 cinnamon stick"),
    list(ingredient_name = "clove", quantity = 4, unit = "", raw_text = "4 whole cloves"),
    list(ingredient_name = "cardamom", quantity = 4, unit = "", raw_text = "4 green cardamom pods"),
    list(ingredient_name = "chili powder", quantity = 1, unit = "tsp", raw_text = "1 tsp chili powder"),
    list(ingredient_name = "turmeric", quantity = 1, unit = "tsp", raw_text = "1 tsp turmeric"),
    list(ingredient_name = "vegetable oil", quantity = 1/2, unit = "cup", raw_text = "1/2 cup vegetable oil"),
    list(ingredient_name = "cilantro", quantity = 2, unit = "tbsp", raw_text = "2 tbsp fresh cilantro")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Preheat oven to 350F"),
    list(step_number = 2, instruction_text = "Soak basmati rice in water for 20 minutes"),
    list(step_number = 3, instruction_text = "Heat oil and fry onions until golden, set aside half"),
    list(step_number = 4, instruction_text = "Add ginger and garlic to remaining oil, cook 1 minute"),
    list(step_number = 5, instruction_text = "Add vegetables and yogurt, cook 5 minutes"),
    list(step_number = 6, instruction_text = "Add spices and mix well"),
    list(step_number = 7, instruction_text = "Boil rice in salted water until 70% cooked, drain"),
    list(step_number = 8, instruction_text = "In baking dish: layer vegetable mixture, then rice"),
    list(step_number = 9, instruction_text = "Top with reserved fried onions and cilantro"),
    list(step_number = 10, instruction_text = "Cover with foil and bake for 40 minutes"),
    list(step_number = 11, instruction_text = "Remove foil, fluff rice with fork, serve")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 8: Spring Rolls
cat("Adding: Spring Rolls...\n")
add_recipe(list(
  title = "Spring Rolls",
  source = "Vietnamese Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "rice paper", quantity = 12, unit = "", raw_text = "12 rice paper wrappers"),
    list(ingredient_name = "vermicelli noodles", quantity = 4, unit = "oz", raw_text = "4 oz vermicelli noodles, cooked"),
    list(ingredient_name = "lettuce", quantity = 1, unit = "head", raw_text = "1 head lettuce, shredded"),
    list(ingredient_name = "carrot", quantity = 2, unit = "medium", raw_text = "2 medium carrots, julienned"),
    list(ingredient_name = "cucumber", quantity = 1, unit = "medium", raw_text = "1 medium cucumber, julienned"),
    list(ingredient_name = "mint", quantity = 1/2, unit = "cup", raw_text = "1/2 cup fresh mint leaves"),
    list(ingredient_name = "cilantro", quantity = 1/2, unit = "cup", raw_text = "1/2 cup fresh cilantro"),
    list(ingredient_name = "basil", quantity = 1/4, unit = "cup", raw_text = "1/4 cup fresh basil")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Soak rice paper in warm water for 30 seconds"),
    list(step_number = 2, instruction_text = "Lay wet rice paper on damp cloth"),
    list(step_number = 3, instruction_text = "Place lettuce, noodles, and vegetables in center"),
    list(step_number = 4, instruction_text = "Add mint, cilantro, and basil leaves"),
    list(step_number = 5, instruction_text = "Fold sides and roll tightly"),
    list(step_number = 6, instruction_text = "Serve with peanut sauce or fish sauce-based dipping sauce")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 9: Vegetable Tempura
cat("Adding: Vegetable Tempura...\n")
add_recipe(list(
  title = "Vegetable Tempura",
  source = "Japanese Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "eggplant", quantity = 1, unit = "medium", raw_text = "1 medium eggplant, sliced"),
    list(ingredient_name = "zucchini", quantity = 1, unit = "medium", raw_text = "1 medium zucchini, sliced"),
    list(ingredient_name = "mushroom", quantity = 8, unit = "oz", raw_text = "8 oz mushrooms"),
    list(ingredient_name = "sweet potato", quantity = 1, unit = "medium", raw_text = "1 medium sweet potato, sliced"),
    list(ingredient_name = "broccoli", quantity = 2, unit = "cup", raw_text = "2 cups broccoli florets"),
    list(ingredient_name = "flour", quantity = 1, unit = "cup", raw_text = "1 cup all-purpose flour"),
    list(ingredient_name = "cornstarch", quantity = 1/4, unit = "cup", raw_text = "1/4 cup cornstarch"),
    list(ingredient_name = "eggs", quantity = 1, unit = "", raw_text = "1 egg"),
    list(ingredient_name = "water", quantity = 1, unit = "cup", raw_text = "1 cup ice cold water"),
    list(ingredient_name = "salt", quantity = 1/2, unit = "tsp", raw_text = "1/2 tsp salt"),
    list(ingredient_name = "vegetable oil", quantity = 2, unit = "cup", raw_text = "2 cups vegetable oil for frying")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Mix flour, cornstarch, and salt in bowl"),
    list(step_number = 2, instruction_text = "Whisk egg and ice water together"),
    list(step_number = 3, instruction_text = "Gently fold wet ingredients into dry ingredients (leave lumpy)"),
    list(step_number = 4, instruction_text = "Heat oil to 350F in deep pan"),
    list(step_number = 5, instruction_text = "Pat vegetables dry and dip into batter"),
    list(step_number = 6, instruction_text = "Fry in batches until golden, about 2-3 minutes"),
    list(step_number = 7, instruction_text = "Drain on paper towels"),
    list(step_number = 8, instruction_text = "Serve hot with tempura dipping sauce")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Recipe 10: Tofu Stir-Fry
cat("Adding: Tofu Stir-Fry...\n")
add_recipe(list(
  title = "Tofu Stir-Fry",
  source = "Chinese Cuisine",
  source_url = "www.example.com",
  ingredients = list(
    list(ingredient_name = "tofu", quantity = 14, unit = "oz", raw_text = "14 oz firm tofu, cubed"),
    list(ingredient_name = "broccoli", quantity = 2, unit = "cup", raw_text = "2 cups broccoli florets"),
    list(ingredient_name = "bell pepper", quantity = 1, unit = "large", raw_text = "1 large red bell pepper, sliced"),
    list(ingredient_name = "baby corn", quantity = 1, unit = "cup", raw_text = "1 cup baby corn"),
    list(ingredient_name = "water chestnuts", quantity = 1, unit = "cup", raw_text = "1 cup canned water chestnuts"),
    list(ingredient_name = "soy sauce", quantity = 3, unit = "tbsp", raw_text = "3 tbsp soy sauce"),
    list(ingredient_name = "oyster sauce", quantity = 2, unit = "tbsp", raw_text = "2 tbsp oyster sauce"),
    list(ingredient_name = "ginger", quantity = 1, unit = "tbsp", raw_text = "1 tbsp ginger, minced"),
    list(ingredient_name = "garlic", quantity = 3, unit = "clove", raw_text = "3 cloves garlic, minced"),
    list(ingredient_name = "vegetable oil", quantity = 3, unit = "tbsp", raw_text = "3 tbsp vegetable oil"),
    list(ingredient_name = "sesame oil", quantity = 1, unit = "tsp", raw_text = "1 tsp sesame oil"),
    list(ingredient_name = "cornstarch", quantity = 1, unit = "tbsp", raw_text = "1 tbsp cornstarch"),
    list(ingredient_name = "water", quantity = 1/4, unit = "cup", raw_text = "1/4 cup water"),
    list(ingredient_name = "green onion", quantity = 2, unit = "", raw_text = "2 green onions, chopped")
  ),
  instructions = list(
    list(step_number = 1, instruction_text = "Mix cornstarch and water to make slurry"),
    list(step_number = 2, instruction_text = "Heat 2 tbsp oil in wok and lightly fry tofu until golden"),
    list(step_number = 3, instruction_text = "Remove tofu and set aside"),
    list(step_number = 4, instruction_text = "Add remaining oil, stir-fry garlic and ginger for 30 seconds"),
    list(step_number = 5, instruction_text = "Add broccoli, bell pepper, baby corn, and water chestnuts"),
    list(step_number = 6, instruction_text = "Stir-fry for 3-4 minutes until tender-crisp"),
    list(step_number = 7, instruction_text = "Return tofu to wok"),
    list(step_number = 8, instruction_text = "Mix in soy sauce, oyster sauce, and cornstarch slurry"),
    list(step_number = 9, instruction_text = "Toss everything for 2 minutes until sauce thickens"),
    list(step_number = 10, instruction_text = "Drizzle with sesame oil and top with green onions"),
    list(step_number = 11, instruction_text = "Serve over rice")
  ),
  date_added = Sys.time(),
  last_modified = Sys.time()
))

# Display summary
cat("\n", strrep("=", 70), "\n", sep="")
recipes <- get_recipes()
cat(sprintf("Successfully added %d vegetarian Asian recipes!\n\n", length(recipes)))
cat("Recipes added:\n")
for (recipe in recipes) {
  cat(sprintf("  - %s\n", recipe$title))
}
cat("\n", strrep("=", 70), "\n\n", sep="")
