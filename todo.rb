require 'sinatra'
require 'tilt/erubis'
require 'sinatra/content_for'

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do 
  require 'sinatra/reloader'
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new(logger)
end

# def disconnect
#   @storage.close
# end

# after do
#   @storage.disconnect
# end

def load_list(id)
   list = @storage.find_list(id)
  return list if list

  @storage.set_error_message("The specified list was not found.")
  redirect "/lists"
end

# return an error message if name is invalid. return nil if name is valid
def error_for_list_name(name)
  # if list_name.size >= 1 && list_name.size <= 100
  if !(1..100).cover? name.size
    'List name must be between 1 and 100 characters.'
  elsif @storage.all_lists.any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

def error_for_todo(name)
   if !(1..100).cover? name.size
    'Todo must be between 1 and 100 characters.'
   end
end 


# helper methods here are intended to be used in the view templates, leave other methods separate
helpers do 
  def list_complete?(list)
    todos_count(list) > 0 && todos_remaining_count(list) == 0
  end 
  
  def list_class(list)
    "complete" if list_complete?(list)
  end
  def todos_count(list)
    list[:todos].size
  end
  
  def todos_remaining_count(list)
    list[:todos].count { |todo| todo[:completed] == false }
  end
  
  def sort_lists(lists, &block) 
    incomplete_lists = {}
    complete_lists = {}
    
    complete_lists, incomplete_lists = lists.partition { |list| list_complete?(list) }
    
    incomplete_lists.each(&block)
    complete_lists.each(&block)
  
  end 
  
  def sort_todos(todos, &block)
    incomplete_todos= {}
    complete_todos = {}
  
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }
    incomplete_todos.each(&block)
    complete_todos.each(&block)
  end
end 

get '/' do
  redirect '/lists'
end

# view all of the lists
get '/lists' do
  @lists = @storage.all_lists
  erb :lists, layout: :layout
end

# render the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# create a new list, and validate list length

# goal is for these blocks to do one thing as well as methods
post '/lists' do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)
  if error
    @storage.set_error_message(error)
    erb :new_list, layout: :layout
  else
    
    # list_number = session[:lists].size
    @storage.create_new_list(list_name)
    @storage.set_success_message('The list has been created.')
    redirect '/lists'
  end
end

# goal page to display a single list
get '/lists/:number' do
  @list_number = params[:number].to_i
  @list = load_list(@list_number)
  erb :list, layout: :layout
end


# edit  an existing todo list
get '/lists/:number/edit' do
    list_id = params[:number].to_i
  @current_list = load_list(list_id)
  erb :edit_list, layout: :layout
end

# update an existing todolist
post '/lists/:number' do
  @list_number = params[:number].to_i
  @current_list = load_list(@list_number) #list id is the list index in the array
  list_name = params[:new_list_name].strip
  error = error_for_list_name(list_name)
  if error
    @storage.set_error_message(error)
    erb :edit_list, layout: :layout
  else
   # @current_list[:name] = list_name
   @storage.update_list_name(@list_number, list_name)
    @storage.set_success_message('The list name has been changed.')
    redirect '/lists'
  end
end

# delete a list
# delete the list, go back to main lists page.
post '/lists/:number/delete' do   #use post, modifying data, flash success when deleted?
    list_number = params[:number].to_i
    @list = load_list(list_number)
    list_name = @list[:name]
# if deleted?
  # session[:lists].delete_if { |list| list[:id] == list_number }
  @storage.delete_list(list_number)
  #session[:lists].reject! { |list| list[:id] == list_number }
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    return "/lists"
  elsif !@storage.all_lists.include?(@list)
    @storage.set_success_message("The list named '#{list_name}' was successfully deleted")
  else  @storage.set_error_message("Error. List was not deleted.")
  end 
  
  redirect '/lists'  # goes to the get request version
end

  
# add a new todo to a list
post '/lists/:list_number/todos' do
  @list_number = params[:list_number].to_i
  todo_name = params[:todo].strip
  @list = load_list(@list_number)
  
  
  error = error_for_todo(todo_name)
  
  if error
    @storage.set_error_message(error)
    erb :list, layout: :layout
  else 
    @storage.create_new_todo(@list_number, todo_name)
    @storage.set_success_message("The todo item was added")
    redirect "/lists/#{@list_number}"
  end 

end

# delete a todo item from list
post '/lists/:list_number/todos/:todo_number/delete' do
  list_number = params[:list_number].to_i
   @list = load_list(list_number)
  

  todo_number = params[:todo_number].to_i
  @storage.delete_todo_from_list(list_number, todo_number)
 
  @storage.set_success_message("The todo was successfully deleted")
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    return status 204
  else
    redirect "/lists/#{list_number}"
  # else session[:error] = "Error. '#{@todo[:name]}' todo was not deleted."
  end

end

# update the status of a todo
post '/lists/:list_number/todos/:todo_number/toggle' do
  list_number = params[:list_number].to_i
  @list = load_list(list_number)
  
  todo_number = params[:todo_number].to_i
  new_status = (params[:completed] == "true" ? true : false)
  @storage.update_todo_status(list_number, todo_number, new_status)
  @storage.set_success_message("The todo has been updated")
  
  redirect "/lists/#{list_number}"
  
end

# mark all todos in a list as completed
post '/lists/:number/complete_all' do
  list_number = params[:number].to_i
  @storage.mark_all_todos_as_completed(list_number)
  @storage.set_error_message("All todos have been completed")

  redirect "/lists/#{list_number}"
end



