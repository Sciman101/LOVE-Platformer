**Current to-do list:**
- Let tileDataLayer draw autoLayerTiles if they exist
- Add layer class for AutoLayer
- Add layer class for TileLayer
- Add layer class for Entity layer
- Rewrite how scenes handle tile and entity checking (Ideally tile checking references the collision layer by default, specified by a name, and can optionally pass a layer ID. Entities can be all pooled together in a big table or something)