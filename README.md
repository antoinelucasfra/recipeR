# recipeR

A feature-rich R Shiny recipe manager built as a golem package.

## Features

✓ **Recipe Management**: Create, view, edit, delete recipes with title, source, and instructions
✓ **Ingredient Parsing**: Automatic parsing of ingredient lines with fractions (1 1/2), decimals, and units
✓ **Recipe Scaling**: Scale recipes by serving size multiplier with intelligent unit conversions
✓ **Ingredient Inventory**: Track available ingredients with quantity and unit
✓ **Recipe Matching**: Browse recipes with match percentage based on available ingredients
✓ **Shopping List**: Add missing ingredients from recipes to consolidated shopping list
✓ **Density-Based Conversions**: 40+ built-in ingredient densities for volume-to-mass conversions
✓ **Custom Density Management**: Add, view, and manage custom ingredient densities via admin UI
✓ **Unit System Preferences**: Toggle between American (cups/oz/lb) and European (ml/g/kg) units
✓ **Persistence**: All data persisted to RDS files at `~/.recipeR/` directory
✓ **Import/Export**: Import and export recipes in JSON or CSV format
✓ **Backup/Restore**: Create timestamped backups and restore previous states

## Getting Started

### Install Dependencies

```bash
R -e 'install.packages(c("shiny", "golem", "DT", "jsonlite"))'
```

### Run the App

```bash
cd /path/to/recipeR
R -e 'devtools::load_all(); run_app()'
```

The app will start at `http://localhost:3815`

## Usage

### Home Tab
- View app overview and feature summary

### Browse Recipes Tab
- Browse all recipes with match percentage based on available ingredients
- Filter by match threshold and search by keyword
- View recipe details, edit, or delete

### Add Recipe Tab
- Create new recipes with:
  - Title (required)
  - Source/URL (optional)
  - Ingredients (one per line, e.g., "1 1/2 cups flour")
  - Instructions (one per line or multi-line)
- Real-time preview of parsed ingredients

### My Ingredients Tab
- Track available ingredients with quantity and unit
- Add new ingredients or update quantities
- View as filterable DT table

### Shopping List Tab
- View consolidated shopping list
- Add missing ingredients from recipes
- Clear when shopping is complete

### Settings Tab
- **Units**: Toggle between American and European unit systems
- **Ingredient Densities**: 
  - View all 40+ built-in ingredient densities
  - Add custom densities for ingredients not in built-in table
  - Custom densities automatically used in conversions
  - Custom densities persist across app sessions
- **Import/Export**:
  - Export recipes to JSON or CSV
  - Import recipes from JSON or CSV files
  - Backup and restore functionality

## Technical Details

### Data Storage

All data stored in `~/.recipeR/` directory as RDS files:
- `recipes.rds` - All recipes with metadata
- `ingredients.rds` - Ingredient inventory
- `shopping.rds` - Shopping list
- `prefs.rds` - User preferences (unit system)
- `densities.rds` - Custom ingredient densities

### Ingredient Parsing

Supports various quantity formats:
- Mixed fractions: `1 1/2`
- Simple fractions: `1/2`
- Decimals: `1.5`
- Integers: `2`

Unit parsing handles common abbreviations:
- Volume: cup/tbsp/tsp, ml/l
- Mass: oz/lb, g/kg

### Density Conversions

**Built-in densities** include 40+ common ingredients:
- Flours: flour, whole wheat, almond, cornmeal, rice, oats
- Sugars: sugar, brown sugar, powdered sugar, honey
- Fats: butter, coconut oil, vegetable oil, olive oil
- Liquids: water, milk, cream, yogurt, buttermilk
- Seasonings: salt, baking powder, cinnamon, cocoa powder
- Others: peanut butter, chocolate chips, berries

**Custom densities** can be added via Settings → Ingredient Densities:
1. Enter ingredient name (e.g., "matcha", "tapioca starch")
2. Enter density value in g/ml (e.g., 0.72)
3. Click "Add Density"

Custom densities are prioritized in conversions and persist across app restarts.

## Running Tests

```bash
R -e 'devtools::load_all(); testthat::test_dir("tests/testthat")'
```

Current test coverage:
- ✓ Ingredient line parsing (qty, unit, name extraction)
- ✓ Fraction parsing (mixed, simple, decimals)
- ✓ Unit conversions (round-trip american ↔ metric)
- ✓ Density lookups and volume-to-mass conversions
- All 11 tests passing

## Development

Test scripts available in `dev/`:
- `run_dev.R` - Development environment setup
- `test_density_admin.R` - Density management unit tests
- `test_density_feature_complete.R` - End-to-end density feature scenarios

## Notes

- Density conversions are approximate (typically ±5% accuracy)
- Ingredient name matching uses keyword-based lookup (case-insensitive)
- Custom densities override built-in densities for matching ingredients
- Scaling recipes preserves both original and scaled quantities
- All times stored as UTC (Sys.time())
