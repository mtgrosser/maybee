# maybee

Simple Model-Based Authorization for Rails.

## Install
```
gem install maybee
```

## Usage

In maybee, subjects may do the things that objects allow them to do.

To have an authorization subject, which will in most cases be your user model:

```ruby
class User < ActiveRecord::Base
  acts_as_authorization_subject
end
```
To have models that act as authorization objects, i.e. something that users may or may not use:

```ruby
class Car < ActiveRecord::Base
  acts_as_authorization_object
end
```

### Defining access rules

Access rules are defined inside models using a simple DSL syntax and may be named as you like. A named rule like

```ruby
class Car < ActiveRecord::Base
  acts_as_authorization_object
  
  allows :to => :drive
end
```
will have model instances respond `true` if asked

```ruby
car.allow?(:drive, user) => true
```

Usually, you will want to restrict access based on some internal state of the model (the authorization object) or the user (the subject). This can be accomplished using the options `:if`, `:unless`, `:if_subject` and `:unless_subject`:

```ruby
allows :to => :drive, :if => :license_plate_valid?, :if_subject => :has_drivers_license?
```

With this declaration, the car would allow any (ruby) object to drive, if the car has a valid license plate and the ruby object responds to `#has_drivers_license?` with a true value. 

In order to limit the access to instances of a certain class, you can give the subject class in the rule declaration:

```ruby
class User < ActiveRecord::Base
  acts_as_authorization_subject
end

class Driver < User
  # only some users are actual drivers
end

class Car < ActiveRecord::Base
  acts_as_authorization_object
  
  allows :drivers, :to => :drive, :unless_subject => :drunk?
end
```

If you do not care for the subject class, you may also write

```ruby
allows_to :drive, :start, :if => ....
```

which is the same as `allows :to => ....`.


### Passing blocks

It is also possible to pass a proc to any of the conditional options:

```ruby
allows :drivers, :to => :start, :if => lambda { |driver| gasoline_level > 0 }
```

Blocks passed to `:if` and `:unless` are evaluated inside the authorization object, while `:if_subject` and `:unless_subject` get evaluated inside the authorization subject (the user).


### Dealing with nil

In most cases, you will want to restrict authorizations to authorized subjects only. So maybee will refuse any access by default if the subject is `nil`. For the special case, where an access should also be granted if the subject is nil, use the `:allow_nil` option:

```ruby
class Image
  allows :users, :to => :view, :if => :publicly_accessible?, :allow_nil => true
  allows :users, :to => :view, :if_subject => lambda { |image| self.company_id == image.company_id }

  def publicly_accessible?
    # implementation, or a simple attribute
  end
end
```

This would allow anyone (including `nil`) to view an image if it is publicly accessible, and allow users to view the images belonging to the same company as the user.


### Authorizing create, update and destroy (in an MVC way)

There are three special accesses which limit creation, updating and destruction of records. By default, if a model is an authorization object, it will prevent new records from being created, and existing ones from being updated or destroyed. As models by default do not know about the application's `current_user`, maybee defines an `attr_accessor` on auth objects where the `authorization_subject` can be set by the controller.

. You may name the
access rule as you like. , however there are three special accesses, `:create`,


```ruby

# Just grant the authorization without any requirement for the subject
allows_to :create, :update, :allow_nil => true
```