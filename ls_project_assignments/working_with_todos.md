# Working with Todos
## In this assignment, we'll continue the process of implementing methods in the `DatabasePersistence` class to restore the original functionality of the application. We'll focus on the methods that are required to `create, complete, and delete todos.`

1. Write a new implementation of `DatabasePersistence#create_new_todo` that inserts new rows into the database.
  * Problem:
    * add one new todo to a list.
    * create a method called `create_new_todo`
    * taking (list_id, todo_name) as arguments.
    * execute SQL to add a new row to the `todos` table.
    * adding a value in the `list_id` column to link it to an existing list
```ruby
def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos(list_id, name) VALUES($1, $2)"
    query(sql, list_id, todo_name)
end
```

2. Write a new implementation of `DatabasePersistence#delete_todo_from_list` that removes the correct row from the todos table.
  * Problem:
    * write a method `delete_todo_from_list` to remove a todo from a specific list.
    * method parameters (list_number, todo_number)
    * execute SQl to delete a specific row from the `todos` table.
    * we need to include both the list_id and the todo id to make sure we delete the correct id (good idea to be very specific when do destructive operations)
     
      
```ruby
def delete_todo_from_list(list_number, todo_number)
    sql = "DELETE FROM todos where list_id = $1 AND id = $2"
    query(sql, list_number, todo_number)
```

* LS note:
  * since our system has one user having both list_id and todo id is not necessary for us to delete the correct todo row here. 
    * but good practice to use most specific conditions for destructive actions
    * if our system had multiple users, having the `list_id` would definitely be needed.
 * since our todo id's are universally unique (primary keys), and not unique to just that list (like multiple todos having an id of 1, but different list_id values)
   * then we can delete them by specifying just the todo `id`
   * since we are working with a database and not a stored object like a hash or an array that we mutate to delete
     * then we cannot just iterate through the data structure and delete that matching todo. (we have to know certain info to delete it from the database- like the unique `id`) (versus with storing the session data)

3. Write a new implementation of `DatabasePersistence#update_todo_status` that updates a row in the database.`
* Problem: 
  * add code to the `update_todo_status` method
  * with parameters (list_id, todo_id, new_status)
  * update that specific row in the `todos` table 
  * and update its value for the `completed` completed
  * to be set to the value of `new_status`
  
```ruby 
def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE list_id = $2 AND id = $3"
    query(sql, new_status, list_id, todo_id)
end
```


4. Write a new implementation of `DatabasePersistence#mark_all_todos_as_completed` that updates all rows in the database.
  * Problem:
    * update the `mark_all_todos_as_completed` method 
    * that takes parameters (list_id)
    * we're marking all the todos for a specified list as completed
    * we have to update all the row values for `completed` in the `todos` table that match that input `list_id`
    * the `completed` column for those todo rows should be set to the boolean true

```ruby 
def mark_all_todos_as_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
end