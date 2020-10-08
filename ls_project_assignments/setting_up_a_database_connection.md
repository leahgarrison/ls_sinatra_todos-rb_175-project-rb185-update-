# Setting up a Database Connection
## we're switching from storing our session data inside our `SessionPersistence` instance, to storing it in a database.
## now we're going to connect to our newly created `todos` database/tables.
## we'll also be doing some code cleanup; moving our `SessionPersistence` class into its own file and copy it into a new class to be used by the database.

## we'll be using the ruby `pg` gem ; which will let us easily interface between our database mgt system (POSTgreSQL) and our ruby code.

# Practice Problem
1. Why can we call the `map` method directly on an instance of `PG::Result`?
  *  whenever we access a value from a `PG::Result` object it's automatically cast to a Ruby object 
  *  Whenever we access a data row (like a row from the `lists` table); for example using the ruby `each` method
    * we get a hash object for each row, with each column name as a `key` and its row value as the `value`
    * Since our `todo.rb` ruby program is set up to work with a specific data type for `lists` (an array of list hash objects)
      * where each list is a hasho object inside an array.
      * then we need to return that type of data structure.
      * Using the `map` ruby method returns an array. we can use each `tuple` list as elements inside the array.
  * Using `map` let's us create the specific data type that our program expects for the `all_lists` method.
  * we have to use some kind of value accessor method on the `Result` object for it to be automatically mapped into ruby code.
  * 
  * LS note - Since PG::Result includes `Enumerable`, any of the methods provided by that module can be called on it. You can see what modules are included in `PG::Result` in its documentation.
    * `Included Modules -Enumerable`