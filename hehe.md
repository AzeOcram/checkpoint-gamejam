### changes in Player
- added:
    - variables:
        - social_battery_per_second
        - var max_social_battery
        - social_batterry
    - functions:
        - add_social_battery
        - get_max_social_battery
        - get_social_battery_per_second

### changes in Social Battery System
- changed:
    - in func add changed player.social_battery += amount -> player.add_social_battery(amount)
    - in func can_afford, now player.get_social_battery()
- added:
    - connected signal Timer.timeout()
    - implemented generate() while taking max social battery into account
    - get_max()
