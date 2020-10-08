# Working with Lists
In this assignment, we'll continue the process of implementing methods in the `DatabasePersistence` class to restore the original functionality of the application. We'll focus on the methods that are required to `create, edit, and delete lists.`

## Practice Problem

1. Write a new implementation of `DatabasePersistence#create_new_list` that inserts new rows into the database.\
  * Problem: recreate the `create_new_list` method for the `DatabasePersistence` class.
    * Previously we add a new list hash to `session[:lists]` . (adding a new hash element to the array paired with the `:lists` key).
    * now we need to execute sql statements and add a new list to the `lists` table. (todos get added with a different method).
   
   * rules: takes a string argument called name.
   * we check for name uniqueness before we try to insert the new list
   * but our `lists` column `name` does have a `UNIQUE` constraint. (it won't be added if the name is not unique).
   * return value is not important; we'll be modifying the database.
   * the only thing our `lists` table requires (having a `NOT NULL` constraint) is the `name` column.
```
    def create_new_list(name)
      sql = "INSERT INTO lists(name) VALUES($1)"
      query(sql, name)
    end
```

2. Write a new implementation of `DatabasePersistence#delete_list` that removes the correct row from the lists table.
  * Problem: recreate the `delete_list` method for the `DatabasePersistence` class.
    * this a modifying method; modifying (deleting) data from the database.
    * need to delete the correct list from the database, given the list id. 
  * rules: 
    * argument - list_id.
    * we need to execute a SQl statement where we delete the row from `lists` where the id equals `list_id`
    * each list in `lists` has a primary key called `id`
    * this is a modifying(destructive method) - do not have a meaningful return value
    * deleting data from the database via SQL and not testing (to make sure we're querying the right data) can be dangerous.
    * I added an `ON DELETE CASCADE` clause so any foreign key todo rows would be deleted along with the list (so no errors)
      * any todos that go along with the list (foreign key column `list_id` in `todos` references `list` table primary key column `id`)
      * the fk has the `ON DELETE CASCADE` clause set; so all todos referencing that list should be gone(won't get errors)
```sql

ALTER TABLE todos 
    DROP CONSTRAINT "todos_list_id_fkey"
    
ALTER TABLE todos 
    ADD FOREIGN KEY (list_id) 
        REFERENCES lists(id) ON DELETE CASCADE;
```

```
def delete_list(list_id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, list_id)
end
```


3. Write a new implementation of `DatabasePersistence#update_list_name` that updates a row in the database.
  * Problem:  recreate the `update_list_name` method for the `DatabasePersistence` class.
    * parameters: list_id, list_name (string)
    * need sql query to select the correct list from `lists` using `list_id` argument. and update its value for `name` column to `list_name`
    * error checking is handled before this method call in `todo.rb`
    * `name` for `lists` table also has a `UNIQUE` constraint

```
def update_list_name(list_id, new_name)
    sql = "UPDATE lists set name = $2 where id = $1"
    query(sql, list_id, new_name)
end
```