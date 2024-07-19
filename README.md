![Signed](https://img.shields.io/badge/Signed-No-FF3333)
![Game Trackmania](https://img.shields.io/badge/Game-Trackmania-blue)

# Warrior Medals

Are author medals too easy for you, but Champion medals still seem out of reach? Are you looking for something in-between?

This is of course inspired by the [Champion Medals](https://openplanet.dev/plugin/championmedals) plugin. Warrior medals are available for every official campaign (including training and the TMO discoveries) and every Track of the Day. Warrior medals may also be added for custom campaigns by request from the campaign's author/maintainer. [Message me on Discord](https://discord.gg/uu9kUZGte6) to request Warrior medals for your campaign.

Medals may be manually adjusted due to physics changes or for being more difficult than they should be. They will only ever be adjusted to be easier, not more difficult. [Message me on Discord](https://discord.gg/uu9kUZGte6) or [create a GitHub issue](https://github.com/ezio416/tm-warrior-medals/issues) if you feel like a Warrior medal does not make sense in some way. Do not ask for Warrior medals to be harder - grind for the Champion medal instead.

There are currently no plans to add any other medals, though I'm not necessarily opposed to the idea. With enough user requests I may add another medal, but you must also suggest a good name for it, and the change will not happen quickly.

This plugin does not collect any of your personal information. This is solely for your own personal use.

Seasonal campaign:
-
- 2 weeks after the season starts
- 1/4 of the way between author and world record
- example (Summer 2024 - 01 and 25):

    |Author  |World Record|Warrior |
    |:-:     |:-:         |:-:     |
    |23.923  |22.325      |23.524  |
    |1:10.347|1:07.943    |1:09.746|

Track of the Day:
-
- 2 hours after the track releases (21:00 CET)
- if someone has author by at least 8ms:
    - 1/8 of the way between author and world record
    - otherwise 1 ms faster than author
- much more lenient than the seasonal campaign as these authors like to hunt their times
- example (arbitrary numbers):

    |Author|World Record|Warrior|
    |:-:   |:-:         |:-:    |
    |45.678|44.926      |45.584 |
    |40.000|40.069      |39.999 |

Function used for calculation:
-
```Python
def get_warrior_time(author_time: int, world_record: int, totd: bool = False) -> int:
    diff: int = 1

    if (world_record < author_time - (7 if totd else 3)):
        diff = int((author_time - world_record) / (8 if totd else 4))

    return author_time - diff
```

<!-- ![Signed](https://img.shields.io/badge/Signed-Yes-00AA00) -->
<!-- ![Signed](https://img.shields.io/badge/Signed-School_Mode-CC1199) -->
<!-- ![Number of downloads](https://img.shields.io/badge/dynamic/json?query=downloads&url=https%3A%2F%2Fopenplanet.dev%2Fapi%2Fplugin%2F___&label=Downloads&color=purple) -->
<!-- ![Version](https://img.shields.io/badge/dynamic/json?query=version&url=https%3A%2F%2Fopenplanet.dev%2Fapi%2Fplugin%2F___&label=Version&color=red) -->
<!-- ![Game Maniaplanet](https://img.shields.io/badge/Game-Maniaplanet_4-blue) -->
<!-- ![Game Turbo](https://img.shields.io/badge/Game-Turbo-blue) -->
