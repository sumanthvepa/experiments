
## Presentations as Reference Documents
Presentations in this deck are in reality complete standalone documents
that can be read without the presence of a speaker. They are effectively
documents in the form of a presentation and should act as reference
materials for students reading their content.

When asked to create a PowerPoint presentation execute the following steps:

Step 1: Ask for the outline
If an outline in the form of a markdown has not been given to you, ask for it.
Do NOT attempt to create slide deck without an outline.


## Step 2: Creating Slides
Create the textual content for individual slides in separate markdown
files

Use the outline to expand the content of each slide into a separate markdown file. The location of the markdown file should be in the same location as the
slide outline. The file name should be slide1-slide-title-with-hyphens.md

Respect the user's instructions when creating the slides. They may ask you
to create all the slides in one go or ask you to pause and take their feedback
for each slide. Do as they instruct.

Any equations in the markdown files should be in LaTeX.


Ask the user to review the slides before proceeding to the next step. Unless explicitly instructed not to do so.

If you have diagram suggestions follow the style of diagrams in assets/netfinet.potx.  Describe the diagram in text and create an SVG version of the diagram in the same directory with the name slideN-diagramM.svg. Where N is the number of the slide you are working on and M is the Mth diagram on the slide.


## Step 3: Create slide in a separate presentation.
This prevents corrupting other already created slides in a presentation. Give
the created presentation the same name as the markdown file from which it was
created except with a .pptx suffix.

When creating PowerPoint slides use assets/netfinet.potx (relative to
the repository root) as the template.

Use Microsoft's equation editor, if you are able to, to insert equations. You can paste LaTeX from markdown file directly into the equation. If you are unable to do so, let the user know, and simply paste the LaTeX as text box into the slide. 


Similarly insert any diagram SVGs into the slide.

Try to follow the layout of the slides in the template. But you can change the layout if you deem it necessary.

### Titles in the body of the slide
Do not use ALL CAPS for titles in a slide. This does not fit the visual design
language of the deck.

### Notes
Notes should contain significant explanations of the main material on the slide that indicate where the content of the main material was sourced from
and why it is relevant. It should, if necessary provide either more detailed explanations. The user may sometimes update the notes in the markdown file before the slides are created during the review phase.

### References in Notes
Reference citations should be in Harvard style. In 10pt font as a numbered list.
Follow the style shown in the template.
