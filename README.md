# ALFGOFarming
Demo for my talk @ CocoaHead Taipei, August 2017

This demo app shows how to convert a general optimization problem into views and constraints.  The goal of this demo is to highlight the fact that Auto Layout is, at its core, a linear programming solver.

The optimization problem at hand is:  Given a list of in-game locations and their play cost & item drop probabilities, how do you most efficiently farm for a set of items you need?

Once the problem is represented using views and constraints, Auto Layout would find the optimal solution for us.
