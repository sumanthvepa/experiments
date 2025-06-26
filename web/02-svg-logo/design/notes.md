# Creating the Netfinet Logo

To create the netfinet logo in Adobe Illustrator, we followed these
steps:
1. Create the slate blue netfinet logo text with Mohave as the font.
   Use 48px as the font size. Note that we have globally changed the
   units to pixels in in Illustrator. To do this go to Illustrator 
   -> Settings (open the sub menu by following the right arrow ->) ->
   Units. Then change General, Stroke and Type to pixels.
2. Select the text, then go to Type -> Create Outlines. If create
   outlines is greyed out, then you are probably in the wrong mode
   (e.g. in the text tool). Make sure you are in the selection tool
   and at the top-level. If you are not at the top-evel, you'll see
   that in the top left corner of the Illustrator window (e.g. it
   will show Layer 2 -> Group)
3. Ungroup the text by going to Object -> Ungroup. If ungroup is
   greyed out, then you are probably in the wrong mode (e.g. in the
   text tool). Make sure you are in the selection tool and at the
   top-level.
4. Now use the rectangle tool (shortcut M) to create a rectangle that
   exactly covers the dot in the i. Make sure that snap to point and
   snap to glyph are enabled (View -> Snap to Point and View -> Snap
   to Glyph). Also enable smart guides (View -> Smart Guides).
5. Then create new layer above the current layer. To do this click
   on the new layer icon in the layers panel. If you don't see the
   layers panel, go to Window -> Layers.
6. Then cut the rectangle you just created (Ctrl + X or Cmd + X on
   Mac,) select the new layer you just created, and paste it in place
   (Ctrl + Shift + V or Cmd + Shift + V on Mac). This will paste the 
   rectangle in the new layer, and it will be exactly on top of the
   dot in the i.
7. Now use the ellipse tool (shortcut L) to create a circle that has
   the same height and width as the rectangle you just created. It should 
   be in the same new layer.Set  the fill color to #cc5858. Stroke to
   none. Make sure that the circle is exactly on top of the rectangle.
8. Delete the rectangle you created in step 4.
9. Then select the i. You may not be able to select i without the
   f included. That is okay.
10. Use the direct selection tool (white arrow, shortcut A) to
    select each individual point of the dot in the i and delete them.
11. Finally cut the circle you created in step 7 (Ctrl + X or Cmd + X on
    Mac), and past in it in place into the layer with netfinet text.
12. Now group the netfinet text and the circle by selecting both
    and going to Object -> Group.

## Exporting the Logo
Select the group you just created, then go to File -> Export Selection...
and export it as a SVG file.

The raw SVG file will need some cleaning up. See the diff between 
the inline SVG in index.html and the raw SVG file (netfinet-logo.svg)
in this directory.

 