Just some notes to remind me of the various steps needed to update a release
on GitHub.

1.  In KiCad, run the ERC on the schematic and the the DRC on the PCB and
    resolve any errors or warnings before proceeding.
2.  Plot the schematic as a PDF file.
3.  Delete the existing `am9511-6502-schematic.pdf` and rename `am9511-6502.pdf`
    as `am9511-6502-schematic.pdf`.
4.  Use `Export > Drawing to Clipboard` to get the schematic onto the clipboard,
    then in Preview, use Command-N to get a new image document containing the 
    drawing. Crop the schematic image to remove the drawing sheet elements. Save
    the result as `images/schematic.png`
5.  Rebuild `am9511-6502-description.pdf` from `am9511-6502-description.tex`.
6.  Generate gerbers and drill files in the `gerbers` directory. Compress
    the `gerbers` directory, delete the existing `am9511-6502-gerbers.zip` and
    rename `gerbers.zip` as `am9511-6502-gerbers.zip`.
7.  Open the PCB in the 3D viewer, turn off THT component rendering so just the
    board itself is visible, then export the front and back images as 
    `images/pcb-front.png` and `images/pcb-back.png` respectively.
8.  Remove the viewer background from the PCB images and scrub silkscreen text.
9.  Rebuild the output files in `logic` using Galette.
10. Commit and push everything to the repo on GitHub.