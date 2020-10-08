class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
    @success = nil
    @error = nil
  end
  
  def mark_all_todos_as_completed(list_id)
    find_list(list_id)[:todos].each { |todo| todo[:completed] = true}
  end
  
  def update_todo_status(list_id, todo_id, new_status)
    find_todo(list_id, todo_id)[:completed] = new_status
  end
  
  def find_list(id)
    @session[:lists].find{ |list| list[:id] == id }
  end
  
  def all_lists
    @session[:lists]
  end
  
  def create_new_list(list_name)
     id = self.next_list_id
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end
  
  def delete_list(id)
    list = find_list(id)
   @session[:lists].delete(list)
  end
  
  def create_new_todo(list_id, todo_name)
    list = self.find_list(list_id)
    id = self.next_todo_id(list_id)
    list[:todos] <<  {id: id, name: todo_name, completed: false}
  end
  
  def find_todo(list_id, todo_id)
      list = self.find_list(list_id)
      list[:todos].find{ |todo| todo[:id] == todo_id }
  end
  
  def delete_todo_from_list(list_id, todo_id)
    item = find_todo(list_id, todo_id)
    find_list(list_id)[:todos].delete(item)
  end
  
  def update_list_name(list_id, name)
    self.find_list(list_id)[:name] = name
  end
  
  def set_success_message(message)
    @success = message
  end
  
  def set_error_message(message)
    @error = message
  end
  
  # def get_message
  #   @
  # end 
  def get_success_message
    @success
  end 
  
  def get_error_message
    @error
  end
  
  def reset_messages
    @success = nil
    @error = nil
  end
  
  private
  
   def next_todo_id(list_id)
    max = self.find_list(list_id)[:todos].map { |todo| todo[:id] }.max || 0
    max + 1
   end
  
  def next_list_id
    max = self.all_lists.map { |list| list[:id] }.max || 0
    max + 1
  end
  
end