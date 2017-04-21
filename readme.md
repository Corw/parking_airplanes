# Parking airplanes

## Task

Since we wrote our first task, Picky Airlines has gotten really popular. We expanded our fleet
and now we have 80 autonomous planes! They are pretty awesome, but we haven't
programmed them to find their parking spot yet and the airports are really mad at us since they
just stay on the runway after landing, and the passengers have to walk to the terminal as well.
We own one hundred parking spots, and we are planning to use Redis to assign each plane
(with IDs 1 to 80) to its own parking spot (IDs 1 to 99) which will stay assigned to it forever.

Your task is to write a Redis script in Lua that takes an airplane ID as an argument and assigns
a random available parking spot to the plane if it doesn't have one yet. It should always return
the parking spot ID (even if it was assigned earlier). And don't worry about multiple airports, we will have a separate Redis instance running with this script at each airport.

## Solution

### Description
 I'm using 2 keys to store required information, "parking" and "free".
 * "parking" is list of parking spaces, each member of the list represents one parking space.
 If the parking space is free, its value will be "free". If space is reserved its value will be the plane id of the plane that is assigned to the place.
 * "free" is a helper set, it is collection of indexes of members of "parking" list that are free. It is used to quickly access free parking spots without itterating trough "parking" list.
 
 I have defined 2 functions: get_assigned_parking and assign_parking:
 * **get_assigned_parking()** helper function, it is taking the plane id and it itterates trough members of "parking" to find if the plane is assigned to a parking space. If it finds plane id as a value of the list member, it returns index of the list member. If plane id is not found, it returns nil.
 
 * **assign_parking()** is main function for the task. It is taking the plane id and it is using the get_assigned_parking function to check if the plane already has assigned parking place. If the get_assigned_parking() returns nill, assign_parking() will get random member of "free" set, remove that member of "free" set, use it as an index to write plane id to "parking" list and return index as result. If the get_assigned_parking() returns non-nill value, that value will be passed as result.
 
 ### Implementation
 Implementation is using 3 files:
 * **init.lua** is requred to reset the redis database to initial value. It is adding parking spaces ("parking" list) and free space indexes ("free" set)
 * **assign_parking.lua** is main script of the task. When called it should have a plane id passed as parameter to the call. In the bottom of the script is commented out test from task description to assign parking spaces to 80 planes. 
 
 Number of parking places can be changed in scripts, "nb_spaces" variable. Default is 100, as required in task.
 
  ### Execution
  
  It is assumed execution is done on the machine that is runing redis server localy and that scripts are in current directory.
  First run init.lua script:
  * redis-cli --eval init.lua
  
  You can check result by executing redis-cli and running following commands:
  * lrange parking 0 -1
  * smembers free
  
  They will give you values for "parking" list (all members with value "free") and values of "free" set (all values from 0 to n-1 where n is configured number of parking spaces in scripts).
  
  To get parking spot for a plane execute assign_parking.lua script ("P1" is example of plane id):
  * redis-cli --eval assign_parking.lua P1
  
  Result should be id of the parking spot. If you execte script again with same plane id you will get same parking spod id.
  If you run it for another plane id, you will get new parking spot id, but the parking spot id for same plane id will always be the same.
  
   Again, after each call you can check result by executing redis-cli and running following commands:
  * lrange parking 0 -1
  * smembers free
  
  ### Disclaimer
  
  There is likely better way to solve the task. I have never before worked with either Lua or Redis and it took me some reading and testing to get things right.