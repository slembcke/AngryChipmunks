Angry Chipmunks
=

![Screenshot](http://files.slembcke.net/upshot/upshot_vkg18tla.png)

Angry Chipmunks is a simple game that will show you how easy it is to use Chipmunk to painlessly add physics to your Cocos2D game. Feel free to reuse any of this code in your own projects.

In this example you will see how to:

* Create a GameObject class to help bind Cocos2D sprites and physics objects together and easily manange them.
* Use the integrated CCDebugNode and CCPhysicsSprite classes.
* Use the ChipmunkObject protocol to easily manage composite physics objects.
* Use collision handlers to recieve collision events from the physics system.
* Create breakable physics objects.
* Use layers to put physics objects inside of each other.
* Estimate the path of an object and where and when it will first collide with something.

The game rules are simple enough. You have a pile of boxes and a golden box on top. You lose if you break the golden box, and win if you can get it onto the ground without breaking it. To get it to the ground, you shoot cages with angry chipmunks inside of them at the boxes in order to break them.

Why are the Chipmunks in cages and why are they angry? Well, because I spent more time coming up with a list of features the example code would show than I did on it's premise. :p

Chipmunk (the C-API) is free and open source software. Chipmunk Pro (including the Objective-C binding and optimized solver) is what we've built on top of Chipmunk. Chipmunk Pro can help you save a lot of time as it plugs into the usual Objective C memory model and familiar APIs. It even works seemlessly with ARC. You can learn more here: http://chipmunk-physics.net/chipmunkPro.php