# Active Record Intro:  `belongs_to` Association

## Summary

![Database Schema](schema_design_new.png)

*Figure 1*.  Database schema.

We've already written the database migrations that create the tables and fields that our application needs.  Each table has a primary key field:  `id`.  Some of them have foreign key fields that point to the `id` on another table.  When we can link tables to each other through primary and foreign keys, we can say that their corresponding models are associated with each other.  We just need to define what that association looks like.

In our schema for example, every record in the `ratings` table will have a `dog_id` value that points to a record in the `dogs` table—the record with the `id` that matches `dog_id`.  We're able to join records in the `ratings` table to records in the `dogs` table.  So, we can define an association that describes the relationship between the `Rating` class and the `Dog` class. 

The question is what kind of relationship do we have?  Let's consider this from the perspective of the `Rating` class.  The `ratings` table has the foreign key; therefore, an instance of `Rating` would belong to an instance of `Dog`.

```ruby
class Rating < ActiveRecord::Base

  belongs_to :dog

  validates :coolness, :cuteness, :judge_id, :dog_id, { :presence => true }
  validates :coolness, { :numericality => { :greater_than => 0, :less_than => 11 } }
  validates :cuteness, { :numericality => { :greater_than => 0, :less_than => 11 } }
  validates :judge_id, { :uniqueness => { :scope => :dog_id } }

end
```

*Figure 2.*  Code for `Rating` class.

Figure 2 shows an updated `Rating` class that defines the association between `Rating` and `Dog`.  Note the line `belongs_to :dog`.  

This is very similar to the `attr_reader`, `attr_writer`, and `attr_accessor` methods that we've seen.  Like these methods, `belongs_to` is a method that will be called on the class we're defining—in this case `Rating`.  Also, `belongs_to` is going to provide us with instance methods to call on `Rating` objects.

In particular, we will get *getter* and *setter* methods for the `Dog` object associated with any instance of `Rating`.  The method names are derived from the argument passed to the `belongs_to` method.  In this case, we passed `:dog`.  Therefore, the getter method is `#dog` and the setter method is `dog=`.

There are three more methods that are provided when we define that `Rating` belongs to `Dog`:  `#build_dog`, `#create_dog`, and `#create_dog!`.  We can use these methods to make the `Dog` object to which a `Rating` object belongs.

### Active Record Conventions

Convention over configuration.  Active Record provides a lot of functionality with very little code.  In order to achieve this, we need to follow conventions.  For example, our table names should match our class names; otherwise, Active Record doesn't work out of the box, and we have to configure it.

The same is true for defining associations between two classes.  Declaring in the `Rating` class `belongs_to :dog`, rests upon us following convention.

When we define a belongs to association, Active Record expects to find a class with a name matching the argument passed in.  In this case, we passed `:dogs`, so Active Record expects to find a `Dog` class.  We have one, so we're all right.  Also, Active Record needs to know how to identify the `Dog` object to which a `Rating` object belongs.  In other words, it needs to know the foreign key on the `ratings` that matches `id` on the `dogs` table.  Convention indicates that the foreign key should be named `dog_id`.  Again, we're following convention, so this association just works.

If one of these conventions were broken, we would have to configure the association.  In other words, we'd have to tell Active Record where to look.  We can do that with an optional hash argument that we can pass to the `belongs_to` method.  Active Record is going to assume that a specific class and a specific foreign key exits.  If they're not there we can pass that information along:

`belongs_to :dog, { :class_name => "Dog", :foreign_key => :dog_id }`

If we look back at Figure 1, we can see that the `ratings` table holds another foreign key:  `judge_id`.  We don't have a table for judges; we have a `people` table.  In our `Rating` class, if we want to say `belongs_to :judge`, we'll break convention.  Active Record will expect that a `Judge` class exists, but it does not.  So, we need to specify to which class we're referring.  Active Record will also expect to find a `judge_id` foreign key field on the `ratings` table, which it does find, so we've not broken that convention.

We would find ourselves in a similar situation if we wanted to define a belongs to association between `Dog` and `Person`.  If we wanted to say in the `Dog` class `belongs_to :owner`, we would violate convention.

## Releases

### Pre-release: Create, Migrate, and Seed the Database

1. Run Bundler to ensure that the proper gems have been installed.

2. Use the provided Rake task to create the database.

3. Use the provided Rake task to migrate the database.

4. Use the provided Rake task to seed the database.  This will seed all three tables with data.

### Release 0: Exploring `belongs_to` Association Methods

Use the provided Rake task to open the console:  `bundle exec rake console`.

From within the console run ...

- `our_rating = Rating.first`

  Calling `Rating::first` will return to us the first record in the `ratings` table, as ordered by the primary key.  This instance of `Rating` is assigned to the variable `our_rating`.  Looking at the object, we see that the object has a `dog_id` value of `1`.  In other words, `our_rating` belongs to the dog with an `id` of `1`.

- `our_rating.dog_id`

  We can retrieve the value of `our_rating`'s `dog_id` attribute and see that it is `1`.

- `our_rating.dog`

  We're calling the *getter* method provided to us by the `belongs_to` method.  We're able to retrieve the `Dog` object to which an instance of `Rating` belongs through this method.  In this case, this rating is for the dog Tenley.

- `other_dog = Dog.find(3)`

  We're assigning the variable `other_dog` to another instance of `Dog`, the one with the `id` of `3`.

- `our_rating.dog = other_dog`

  We're calling the *setter* method provided by `belongs_to` to change the instance of `Dog` to which `our_rating` belongs.

- `our_rating.dog_id`

  We can see that Active Record has updated the value of `our_rating`'s `dog_id` attribute.  However, this change only exists in our Ruby object, not the database.

- `our_rating.save`

  Calling `#save` on `our_rating` will persist the change in the `Dog` object to which `our_rating` belongs.

- `new_rating = Rating.new(coolness: 8, cuteness: 9, judge_id: 5)`

  This creates a new instance of `Rating` that has not been save to the database; we can see that it has `nil` for its `id` attribute.  Also note that the value of its `dog_id` attribute is also `nil`.

- `new_rating.create_dog(name: "Toot", owner_id: 4, license: "OH-1234567")`

  Here were using one of the other methods provided by the `belongs_to` method:  `#create_dog`.  It will create the dog to which `new_rating` belongs.

- `new_rating.dog`

  We can get the dog that we just created for `new_rating` through the `#dog` getter method.  Because we called `#create_dog`, a Ruby instance of `Dog` was created, and the data was saved to the database.  We can see that this new dog has an `id`.

- `new_rating`

  If we look at `new_rating`, we can see that its `dog_id`, which was previously `nil`, has been assigned the value of the `id` of the dog that was just created.  Active Record did this for us when we ran the `#create_dog` method.

-  `new_rating.save`

- `exit`

### Release 2:  Write `belongs_to` Associations

At the end of the *Summary* section, two other belongs to associations were described:  A rating belongs to a judge.  A dog belongs to an owner.

Define these associations in the appropriate classes.  Test have been provided to guide development.  When all of the tests are complete, submit the challenge.