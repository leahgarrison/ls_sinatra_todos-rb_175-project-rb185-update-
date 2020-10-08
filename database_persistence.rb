require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    #@db.type_map_for_results = PG::BasicTypeMapForResults.new(@db)
    @logger = logger
    # @success = nil
    # @error = nil
  end
  
  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end
  
  
  def mark_all_todos_as_completed(list_id)
    #find_list(list_id)[:todos].each { |todo| todo[:completed] = true}
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end
  
  def update_todo_status(list_id, todo_id, new_status)
    #find_todo(list_id, todo_id)[:completed] = new_status
    sql = "UPDATE todos SET completed = $1 WHERE list_id = $2 AND id = $3"
    query(sql, new_status, list_id, todo_id)
  end
  
  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    #result = @db.exec_params(sql, [id])
    todos = find_todos_for_list(id)
    tuple = result.first
    {id: tuple["id"], name: tuple["name"], todos: todos}
    # [] << r.first
    #@session[:lists].find{ |list| list[:id] == id }
  end
  
  def all_lists
    # problem: need to join lists with every one of its todo items.
    # need the todos items each as a hash inside a list.
    # use the id from the column to do a query and grab all the todo rows for it. put them into the array
    list_sql = "SELECT * FROM lists"
    

    list_result =  query(list_sql)
    list_result.map do |list_tuple|
      list_id = list_tuple["id"].to_i
      todos = find_todos_for_list(list_id)

      {id: list_id, name: list_tuple["name"], todos: todos}
    end 
  end
  
  def create_new_list(list_name)
     #id = self.next_list_id
    #@session[:lists] << { id: id, name: list_name, todos: [] }
     sql = "INSERT INTO lists(name) VALUES ($1)"
     query(sql, list_name)
  end
  
  def delete_list(list_id)
    #list = find_list(id)
   #@session[:lists].delete(list)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, list_id)
  end
  
  def create_new_todo(list_id, todo_name)
    #list = self.find_list(list_id)
    #id = self.next_todo_id(list_id)
    #list[:todos] <<  {id: id, name: todo_name, completed: false}
    sql = "INSERT INTO todos(list_id, name) VALUES($1, $2)"
    query(sql, list_id, todo_name)
  end
  
  def find_todo(list_id, todo_id)
      #list = self.find_list(list_id)
      #list[:todos].find{ |todo| todo[:id] == todo_id }
  end
  
  def delete_todo_from_list(list_id, todo_id)
    #item = find_todo(list_id, todo_id)
    #find_list(list_id)[:todos].delete(item)
    sql = "DELETE FROM todos where list_id = $1 AND id = $2"
    query(sql, list_id, todo_id)
  end
  
  def update_list_name(list_id, new_name)
    #self.find_list(list_id)[:name] = name
    sql = "UPDATE lists set name = $2 where id = $1"
    query(sql, list_id, new_name)
  end
  
  def set_success_message(message)
    #@success = message
  end
  
  def set_error_message(message)
    #@error = message
  end
  
  def get_success_message
    #@success
  end 
  
  def get_error_message
    #@error
  end
  
  def reset_messages
    #@success = nil
    #@error = nil
  end
  
  private
  
  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
     todo_result = query(todo_sql, list_id.to_i)
      todo_result.map do |todo_tuple| 
        # todo_tuple["completed"] = false if todo_tuple["completed"] == "f"
        # todo_tuple["completed"] = true if todo_tuple["completed"] == "t"
        {id: todo_tuple["id"].to_i, name: todo_tuple["name"], completed: todo_tuple["completed"] == "t"} 
      end 
  end

end