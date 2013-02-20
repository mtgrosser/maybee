[![Gem Version](https://badge.fury.io/rb/maybee.png)](http://badge.fury.io/rb/maybee) [![Code Climate](https://codeclimate.com/github/mtgrosser/maybee.png)](https://codeclimate.com/github/mtgrosser/maybee)

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

Access rules are defined inside models using a simple DSL and may be named as you like. A named rule like

```ruby
class Car < ActiveRecord::Base
  acts_as_authorization_object
  
  allows :to => :drive
end
```
will have model instances respond `true` if asked

```ruby
car.allow?(:drive, user)
 => true
```

Usually, you will want to restrict access based on some internal state of the model (the authorization object) or the user (the subject). This can be accomplished using the options `:if`, `:unless`, `:if_subject` and `:unless_subject`:

```ruby
allows :to => :drive, :if => :license_plate_valid?, :if_subject => :has_drivers_license?
```

With this declaration, the car would allow any (ruby) object to drive, if the car has a valid license plate and the ruby object responds to `#has_drivers_license?` with a true value. 

In order to limit the access to instances of a certain class, you can include the desired subject class(es) in the rule definition:

```ruby
class User < ActiveRecord::Base
  acts_as_authorization_subject
end

# only some users are actual drivers
class Driver < User
  def drunk?
    0 == self.drinks
  end
end

class Car < ActiveRecord::Base
  acts_as_authorization_object
  
  allows :drivers, :to => :drive, :unless_subject => :drunk?
end
```
This will allow sober drivers to drive, but will reject normal users and drunk drivers.

If you do not care for the subject class, you may also write

```ruby
allows_to :drive, :if => ...
```
which is the same as `allows :to => ...`

Multiple access rights may be given in the same definition:

```ruby
allows :drivers, :to => [:start, :drive], :if => ...
```


### Passing blocks

It is also possible to pass a proc to any of the conditional options:

```ruby
allows :drivers, :to => :start, :if => lambda { |driver| gasoline_level > 0 }
```

Blocks passed to `:if` and `:unless` are evaluated inside the authorization object, while `:if_subject` and `:unless_subject` get evaluated inside the authorization subject (the user).


### Dealing with nil

In most cases, you will want to restrict authorizations to authorized subjects only. So maybee will refuse any access by default if the subject is `nil`. For the special case where an access should also be granted if the subject is nil, use the `:allow_nil` option:

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

### Authorizing create, update and destroy on the model level (in an MVC way)

There are three special accesses which limit creation, updating and destruction of records. By default, if a model is an authorization object, it will prevent new records from being created, and existing ones from being updated or destroyed. As models by default do not know about the application's `current_user`, maybee defines an `attr_accessor` on auth objects where the `authorization_subject` can be set by the controller.

In the simplest form, the access to create, update and destroy would be granted regardless of the `authorization_subject`. This would be the default behaviour of ActiveRecord, where besides validations there is no restriction on these operations:

```ruby
allows_to :create, :update, :destroy, :allow_nil => true
```

Say you have models for users and roles, and you want normal users not to be able to assign roles, but only admins:

```ruby
class User < ActiveRecord::Base
  acts_as_authorization_subject
  
  has_many :user_roles, :dependent => :destroy
  has_many :roles, :through => :user_roles
end


class Role < ActiveRecord::Base
end

class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  acts_as_authorization_object
  
  allows :users, :to => [:create, :update, :destroy], :if_subject => :admin?
end
```

Just adding a role to a user is no longer possible this way, as the association object `UserRole` requires an admin subject to be set in order to be created.

```ruby
user_role = user.user_roles.build
user_role.save
 => false
user_role.authorization_subject = current_user # current_user is an admin
user_role.save
 => true
```

### Enforcing rules

The idea behind maybee was to do things in an explicit way, so it doesn't do any magic in the background, but it provides your implementation with methods to determine whether an access is authorized or not.

In a classic Rails application, the controller is responsible for restricting access to objects. However, more complex rules of what is allowed and what is not should not go into the controller code, but be placed inside the model itself. This is where maybee can be used.

```ruby

class ImagesController < ApplicationController
  before_filter :find_image
  
  def show
    render
  end
  
  private
  
  def find_image
    @image = Image.find_by_id(params[:id]) or return(not_found)
    @image.allow?(:view, current_user) or return(forbidden)
  end
end
```

Instead of `allow?` you can always write `user.may?`

```ruby
current_user.may?(:view, @image)
```

### User feedback

Usually, you want to give some feedback to the user when she attempted an access which was denied. Maybee provides two authorization query methods which set an error on the record every time an access was denied.

```ruby
@image.authorize?(:destroy, user)
```
sets an error on the image instance when the user is not allowed to destroy it.

```ruby
current_user.authorized_to?(:destroy, @image)
```

is equivalent.

### Default authorization subject

For more generic implementations the subject argument to `authorize?` and `allow?` can be left out. It will then default to the value of the `authorization_subject` accessor, which should be set before, for example in a `before_filter`.

### Inheritance

By default, access rules are inherited by subclasses of auth objects. Additional rule definitions on the subclass extend the accesses possible on that class. If you want to redefine an access on a subclass without inheriting the access rules from its superclass, you can use the `exclusive` option:

```ruby
class Foo < ActiveRecord::Base
  allows_to :view, :if => :visible?
end

class SubFoo < Foo
  allows_to :view, :exclusive => true
end
```
