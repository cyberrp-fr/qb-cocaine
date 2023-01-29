# QB-Cocaine
FiveM Cocaine picking, processing and selling script for QBCore Framework.

### Dependencies
 - Cayo Perico Map
 - qb-core
 - qb-inventory

### Installation

1. clone repo into your `resources` folder

    git clone https://github.com/ibra-akv/qb-cocaine.git

2. Edit `items.lua` file to add these 2 new items

```lua
-- QB-Cocaine
['coca_leaves']					 = {['name'] = 'coca_leaves', 					['label'] = 'Feilles de Coca', 			['weight'] = 50,		['type'] = 'item',		['image'] = 'cocaineleaf.png',			['unique'] = false,		['useable'] = false,	['shouldClose'] = false,	['combinable'] = nil,	['description'] = 'Feuilles de coca pour produire de la Cocaïne.'},
['cocaine_bag']					 = {['name'] = 'cocaine_bag', 					['label'] = 'Pochon de Cocaïne', 		['weight'] = 1000,		['type'] = 'item',		['image'] = 'cocaine_baggy.png',		['unique'] = false,		['useable'] = false,	['shouldClose'] = false,	['combinable'] = nil,	['description'] = 'Pochon de Cocaïne que vous pouvez vendre.'},
```

3. copy the images in `assets` folder to `qb-inventory/html/images/`

4. start resource in `server.cfg` or `resources.cfg`

    ensure qb-cocaine

That's pretty much it, you can of course change some settings in `config.lua` file to your liking.

If this script was helpful, please consider leaving a star.

### Authors
 - [ibra-akv](https://github.com/ibra-akv/) 


### [LICENSE](https://github.com/ibra-akv/qb-cocaine/blob/master/LICENSE)