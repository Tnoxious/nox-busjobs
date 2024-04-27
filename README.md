Here you go, a new bus job well two jobs in one! 
You can be a Coach Driver or City Bus Driver living the bus driver dream. The script started with qb-busjob and ended up being a full remake and layout for my server. This version is a striped down copy of my server one (mine has XP rewards and ranking systems in the core, requiring custom dependencies), which would have been hard for others to set up like I have mine on my server, so this version is just a plain qb-core drag-and-drop nice and easy setup see guide below.

How to Install
1. Go to server.cfg config and add " ensure nox-busjobs " below line " ensure [defaultmaps] "and save
2. Delete qb-busjobs from [qb] folder it's no longer needed and may conflict
3. Open config.lua in " nox-busjobs/config/config.lua " edit what you like (see notes in config)
4. Start server and set player job to "bus" it's already in qb-core you don't have to edit jobs file in core to run this.


Script Dependances
* QB-CORE - @qb-core    - https://github.com/qbcore-framework
* PolyZone - @PolyZone  - https://github.com/mkafrin/PolyZone


Vehicle Whitelisting maybe needed if so go to " resources\[qb]\qb-smallresources\config.lua "

Find line - " Config.BlacklistedVehs "
Add This:
    [`bus`] = false,
    [`coach`] = false,

If using custom Peds also add them to " resources\[qb]\qb-smallresources\config.lua "

Find line - " Config.BlacklistedPeds "
Add This:
    [`a_m_m_tourist_01`] = true,
    [`a_m_y_business_02`] = true,


Note: Because this is a stripped-down version of one I run on my own server, it may have a few lines of code that look sloppy, but it works for what's needed.
2nd Note: A locales folder has been set for easy translation.
