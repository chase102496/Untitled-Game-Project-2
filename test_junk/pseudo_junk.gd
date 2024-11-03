extends Node3D

#We want a main root house node or building for one enclosure
#it has an interaction point we interact with to go in and out.

#We also want a main "panel" to ghost via a message that main root will send the ghost wall

#upon going in, it plays an animation for the player to walk in, and when the animation finishes it pauses the outside world
#and unpauses the interior
#this pausing will include hiding environment, lighting, and any other globals that influence appearance so the house has its own
#independent lighting stage
