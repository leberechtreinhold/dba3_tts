De Bellis Antiquitatis 3.0 for Tabletop Simulator
=================================================

Features: Setup
---------------

- Create tables with different environments, like grass fields, steppe or deserts.
- Automatically fix terrain to the table so it doesn't move.
- Automatic army creation based on the DBA lists. The models have been adapted and lists are easy to create using a scripting system.
- Spawned bases have a base ground theme depending on the table created. Furtheremore, lighter troops spawn in a loose formation, and there are variations between models and textures.
- The game will tell the options of the army so you don't have to doublecheck everything.
- There's a checkbox to enable deployment rulers which significantly help with the deployment.
- The armies, including bases, are color coded, to avoid confusions.
- The models have a specific minimal collider to avoid problem with pikes, calvary, etc.

Features: Gameplay
------------------

- Snapping system: When you drop a base close to another, they will snap, as long as they are close enough and the angle is correct. Snapping includes charging and even "close the door" manouver. It can be turned off for particular manouvers.
- Single movement: If you pick a base and move it, a small text will appear in the screen telling exactly in realtime how many BWs you are moving. This includes all corners, so it's useful for rotations etc. Once dropped, the total will be shown in the log.
- Reset movement: When moving a single base, if snapping is active, and you move less than 10pieces, resets the abse to its original position, which can be useful to evaluate future movements.
- Group movement: Select multiple bases and with one click move all as a group forward! You can select how much to move with a slider.
- Preview movement: Using the slider, you also have a small gizmo in front of the troops that shows where the base will end after pressing move.
- Preview Bow/Artillery range: Like the movement, the range is also projected from the future movement position (which you can set position to check the current range).
- Show ZOC: Like the arty range, this is an option that can be toggled that shows how far the ZOC extends.
- Push back Column: Moves a column back, by the depth of the front element (if the element has more depth than width, only pushes back by its width).

Development
-----------

This was previously developed on a single file with a gist but since it grew, it's now using Atom's include. [More info here](http://blog.onelivesleft.com/2017/08/atom-tabletop-simulator-package.html).

The project is structured in the following way:

- main: The root, and the only lua script needed to import so atom can attach and upload correctly to the game. Doesn't contain functionality by itself.
- scripts/log: A simple script to centralize how the logs (printed to the console and to atom) are written.
- scripts/uievents: The script that controls the uievents
- scripts/utilities: A bunch of utilities since lua doesn't offer much, like vector operations, some algebra, rounding, string utilities, unit conversion etc etc.
- scripts/data_*: All the data to spawn troops, bases, and armies, and general settings.
- scripts/logic_*: All the game logic.
- dice/dice_base: All the code for the different dices
- dice/pip_blue-red: The code assigned to two dice objets, both should be D6 and they calculate the PIPs.
- ui/main.xml: The XML for the UI, which, AFAIK, cannot be #included into TTS through ATOM and needs to be copy/pasted. Can be used directly using include src tag.
- ui/ui_elements.txt: Since the UI is referenced by the Scripting window and must be imported in each game, this is a list to the elements with the corresponding url.
- unittests: Unit tests.  Test cases start with the file name "test_".  
  Run each file in isolation outside of TTS using lua.

It's not required, but it's encouraged to put this repo with the name "dba3_tts" with main.ttslua inside and everything following the structure of the repo. That's only if you want to match the one uploaded in the repo. Otherwise, the only thing required is:

* In Global.-1.ttslua, put:

    #include dba3_tts/main

* In Global.-1.ttslua, put:

    <Include src="dba3_tts\ui\main.xml"/>

* Create two dice object, red and blue, and put this in each:

    #include dba3_tts/scripts/dice/pip_blue
    #include dba3_tts/scripts/dice/pip_red

How to add a building to terrain
--------------------------------

Buildings are placed in Built Up Areas (BUA) when the terrain is locked,
to make the table look pretty. 

Create a building that has its floor centered at 0,0,0, and have the
.obj and .jpeg files on the local file system.

Test the files by starting DBA3 in TTS.  Select Objects/Components/Custom/Model.The cursor will change to a chess pawn.  Click on the table, which should
leave a white dot.  The click on the select menu item.  You should get
a dialog for Custom Model. Under Model select your .obj and .jpeg file
for Model/Mesh and Defuse/Image, choose local file.  Under Material 
select Carboard. 

Ensure that the model looks good.

Now we need to scale the model.  We first create a sample lot to place the
building on.  Objects/Blocks/Red Square, to create a 1x1x1 box.

Click Gizmo/Scale and click on the box.  In the transform dialog change 
the position of the box to 0,1.16,0 and the scale to
3,0.25,2.25, and close the dialog.  The building will have to fit 
on this box, with a bit of space for the front yard and back yard.

Click Gizmo/Scale and click on the building.  Change the position
to 0,1,0; the building should move on top of the box.  Without 
exiting the dialog adjust the scale values to the same value (e.g. 0.3),
so that the building fits comfortably on the box. 

You may now add a BUA area, and lock the table. Spawn an army
with models.  Compare your new building to the existing buildings.
Adjust the scaling as desired. Write down the final scale.

Spawn a new model like before but this this time select to have the files
on the cloud. Write down the URLs on the steam server.

In a text editor open data_terrain.ttsla.  Copy the entry for
terrain_building_desert_shack, and change the contents to 
the values for your building.

Find the entry for "bua = { object = {" for the terrain where your
building fits, and add the variable name as a string.

Test by commenting out the other buildings and have a game with all BUA
areas on the table, with the BUAs rotated in different directions,
ond lock the table.  Your building should be enclosed in the BUAs, and
should not overlap other buildings. 
Uncomment the other builds, and run the test again.


TODO
----

The project is managed by a trello board:

https://trello.com/b/4XQ8tFlB/dba-tts

License
-------

See the LICENSE.md at the top directory.
