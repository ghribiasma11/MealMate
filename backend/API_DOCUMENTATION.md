# FlavorCraft Laravel API — Documentation

## Base URL
```
http:///api/v1
```
For production deployment, replace with your server URL.

---

## Authentication

All protected routes require a Bearer token in the `Authorization` header:
```
Authorization: Bearer {your_token}
```

---

## Endpoints

### Auth

#### POST `/register`
Create a new account.

**Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": { "id": 1, "name": "John Doe", "email": "john@example.com" },
    "token": "1|abc123..."
  }
}
```

---

#### POST `/login`
Sign in to an existing account.

**Body:**
```json
{
  "email": "test@example.com",
  "password": "password"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { "id": 1, "name": "Test User", "email": "test@example.com" },
    "token": "1|abc123..."
  }
}
```

---

#### POST `/logout` 🔒
Invalidate the current token.

---

#### GET `/me` 🔒
Get the authenticated user's profile.

---

### Ingredients (Global Catalogue)

#### GET `/ingredients` 🔒
List all available ingredients.

**Query params:**
- `search` — filter by name (e.g. `?search=chicken`)
- `category` — filter by category (e.g. `?category=dairy`)

**Response:**
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Eggs", "emoji": "🥚", "category": "dairy" },
    ...
  ]
}
```

---

### User Fridge (My Ingredients)

#### GET `/user/ingredients` 🔒
Get all ingredients the user has in their fridge.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Eggs",
      "emoji": "🥚",
      "category": "dairy",
      "expiry_date": "2026-05-15",
      "expires_soon": false,
      "is_expired": false
    }
  ]
}
```

---

#### POST `/user/ingredients` 🔒
Add an ingredient by ID.

**Body:**
```json
{
  "ingredient_id": 1,
  "expiry_date": "2026-05-15"
}
```

---

#### POST `/user/ingredients/by-name` 🔒
Add an ingredient by name (creates it if it doesn't exist).

**Body:**
```json
{
  "name": "Mozzarella",
  "expiry_date": "2026-05-12"
}
```

---

#### DELETE `/user/ingredients/{ingredient_id}` 🔒
Remove an ingredient from the user's fridge.

---

#### GET `/user/ingredients/expiring` 🔒
Get ingredients expiring soon (within 3 days by default).

**Query params:**
- `days` — number of days to look ahead (default: 3)

**Response:**
```json
{
  "success": true,
  "data": [
    { "name": "Milk", "expiry_date": "2026-05-09", "days_until_expiry": 1 }
  ],
  "message": "You have 1 ingredient(s) expiring soon!"
}
```

---

#### PATCH `/user/ingredients/{ingredient_id}/expiry` 🔒
Update the expiry date of an ingredient.

**Body:**
```json
{ "expiry_date": "2026-05-20" }
```

---

### Allergies

#### GET `/user/allergies` 🔒
Get the user's allergen list.

#### POST `/user/allergies` 🔒
Add an allergen.

**Body:**
```json
{ "ingredient_id": 3 }
```

#### DELETE `/user/allergies/{ingredient_id}` 🔒
Remove an allergen.

---

### Recipes ⭐

#### GET `/recipes` 🔒
List all recipes with optional filters.

**Query params:**
- `category` — e.g. `Breakfast`, `Lunch`, `Dinner`, `Snack`
- `difficulty` — `Easy`, `Medium`, `Hard`
- `max_time` — maximum cooking time in minutes
- `vegetarian=true`
- `gluten_free=true`
- `lactose_free=true`

---

#### GET `/recipes/match` 🔒 ⭐ CORE FEATURE
Match recipes to available ingredients using the scoring algorithm.

**Body (JSON):**
```json
{
  "ingredients": ["Eggs", "Tomato", "Butter", "Salt"],
  "max_time": 30,
  "vegetarian": false,
  "gluten_free": false,
  "lactose_free": false
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Scrambled Eggs with Tomato",
      "image": "https://...",
      "time": 10,
      "difficulty": "Easy",
      "category": "Breakfast",
      "match_score": 95,
      "matched_count": 4,
      "total_ingredients": 5,
      "ingredients_have": ["Eggs", "Tomato", "Butter", "Salt"],
      "ingredients_missing": ["Basil"],
      "instructions": ["Step 1...", "Step 2..."],
      "ingredients": [...]
    }
  ]
}
```

**Scoring Algorithm:**
```
score = matched / total

if has_main_ingredient:  score += 10%
if missing_critical:     score -= 20%
if time <= 15 min:       score += 5%

Recipes with user allergens are excluded entirely.
Results sorted by score desc, top 10 returned.
```

---

#### GET `/recipes/{id}` 🔒
Get full details for a single recipe.

---

### Shopping List

#### POST `/shopping/generate` 🔒
Generate an optimised shopping list from recipes or missing ingredients.

**Body:**
```json
{
  "recipe_ids": [1, 2],
  "missing_ingredients": ["Basil", "Black Pepper"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Shopping List — May 08, 2026",
    "grouped": [
      {
        "category": "vegetables",
        "items": [
          { "id": 1, "ingredient_name": "Basil", "quantity": null, "is_checked": false }
        ]
      }
    ],
    "total": 5
  }
}
```

---

#### GET `/shopping/list` 🔒
Get the current shopping list (grouped by category).

---

#### POST `/shopping/items` 🔒
Manually add an item to the shopping list.

**Body:**
```json
{ "ingredient_name": "Olive Oil", "quantity": "1 bottle" }
```

---

#### PATCH `/shopping/item/{id}` 🔒
Check or uncheck a shopping item.

**Body:**
```json
{ "is_checked": true }
```

---

#### DELETE `/shopping/item/{id}` 🔒
Delete a specific shopping item.

---

#### DELETE `/shopping/clear` 🔒
Delete the entire shopping list.

---

## Demo Credentials

```
Email:    test@example.com
Password: password
```

---



## Categories

**Ingredient categories:** `dairy`, `meat`, `seafood`, `vegetables`, `fruits`, `grains`, `pantry`, `spices`, `other`

**Recipe categories:** `Breakfast`, `Lunch`, `Dinner`, `Snack`

**Recipe difficulties:** `Easy`, `Medium`, `Hard`
