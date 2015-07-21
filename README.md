# Active Record Intro:  Belongs To

## Summary

![Database Schema](schema_design_new.png)

*Figure 1*.  Schema design for this challenge, showing connections between primary keys and foreign keys.

In this challenge we're going to begin to explore the relationships between our models.  In Active Record, we call these relationships *associations*. We'll be focusing exclusively on the *belongs to* association:  one object belongs to another object.  For example, a dog belongs to an owner.  We'll discuss how to identify when a belongs to association is appropriate and the naming conventions around defining a belongs to association. 

We know from our work with SQL that rows of data in one table can be paired with rows of data in another table (e.g., when joining tables).  We often make these connections by matching the primary key in one table with a foreign key in another table (see Figure 1).

If we had a dog with a known id, say 1, how could we find the name of its owner?  We have to get data from the people table, but we only have information about data in the dogs table.

```sql
SELECT people.first_name, people.last_name
FROM dogs
JOIN people
ON dogs.owner_id = people.id
WHERE dogs.id = 1;
```
*Figure 2*.  SQL query to retrieve the name of the owner of the dog with id 1.

We could check our database for the dog with id 1 and get the owner id value—the owner id is a foreign key field.  Say the owner id is 5.  We can take that value and go find the record in the people table with id 5.  This record would contain data for the dog's owner.  Then we could get the first and last names.  In principle this is what we're doing in the query in Figure 2.

When we define Active Record associations for our models, Active Record will be doing all of this SQL work for us.  But, as we'll see when we discuss Active Record conventions, it's important to know what's going on in the background.


### Identifying a Belongs To Association
A belongs to association is possible when we can connect the foreign key in one table to the primary key in another table.  The model with the foreign key and the model with the primary key can be associated with each other, but the type of association we need to declare depends on which key is with which model.

In this challenge, we're exploring the belongs to association.  Based on our schema, we could say that ...

- a dog belongs to an owner/person
- a rating belongs to the judge/person who did the rating
- a rating belongs to the dog that was rated

With these three belongs to relationships in mind, let's look again at the schema in Figure 1.  Given the two models between which these associations are made (e.g., rating and dog), can we deduce on which table the foreign key resides?  Is the foreign key with the model that belongs to another model, or the other way around?

We've said that a rating belongs to the dog that was rated.  In connecting the ratings table to the dogs table, we match a foreign key on the ratings table, dog id, with the dogs table primary key, id.  The ratings table contains the foreign key.  And this is how we identify that we would define a belongs to association for the `Rating` class.

If a model's database table has a foreign key that points to another model, it belongs to the other model.


### Declaring a Belongs To Association
```ruby
class Rating < ActiveRecord::Base
  belongs_to :dog
end
```

*Figure 3.*  Code for the class `Rating` with a belongs to association defined.

We've discussed how to identify where a belongs to association can be declared.  Now we'll talk about how to actually make the declaration (i.e., what is the syntax for declaring a belongs to association).

Figure 3 shows a `Rating` class that defines a belongs to association between `Rating` and `Dog`.  Note the line `belongs_to :dog`.  What is `.belongs_to`?  What is `:dog`?

`.belongs_to` is a method.  It is very similar to the methods `attr_reader`, `attr_writer`, and `attr_accessor` that we've been using.  Like these methods, `.belongs_to` is a method that will be called on the class we're defining—in this case `Rating`.  

Do we remember what the attribute methods do (e.g., `attr_reader`)?  They are a shorthand way of declaring *getter* and *setter* methods for instance variables.

```ruby
rating = Rating.first
# => #<Rating id: 1, ... dog_id: 1, ... >
rating.dog
# => #<Dog id: 1, name: "Tenley", ... >
```
*Figure 4*.  Getting the dog to which a rating belongs.

In the same way, `.belongs_to` is going to provide us with methods that facilitate interacting with an object's associated object.  In this specific case, a `Rating` object will have methods for interacting with its `Dog` object (see Figure 4).

In this challenge we're going to explore the methods that `.belongs_to` generates.  It's important to note that the method names are derived from the first argument passed to the `.belongs_to` method.  In this case, we passed `:dog`.  For a belongs_to association, this must be singular.

What methods will we get?  We will have both getter and setter methods for the `Dog` object; use of the getter method is demonstrated in Figure 4.  The getter method is `#dog` and the setter method is `#dog=`.

In addition to the getter and setter methods, there a few more methods that are provided when we declare that a rating belongs to a dog:  `#build_dog`, `#create_dog`, and `#create_dog!`.  We can use these methods to make a `Dog` object to which a rating object belongs—again we'll take a look at these in this challenge.


### Active Record Conventions
Convention over configuration.  Active Record provides a lot of functionality with very little code.  In order to achieve this, we need to follow conventions.  For example, our table names should match our class names; otherwise, Active Record doesn't work out of the box, and we have to configure it.

The same is true for defining associations between two classes.  Declaring  that a rating belongs to a dog as seen in Figure 3 rests upon us following convention.  When we declare a belongs to association for a class, there are conventions regarding the name of the class to which the class belongs and the name of the foreign key field:

- Active Record expects to find a class with a name matching the first argument passed to `.belongs_to`.  In Figure 3, we passed `:dog`, so Active Record expects to find a `Dog` class.

- Active Record expect to find a foreign key field with a name matching the first argument passed to `.belongs_to`.  In Figure 3, we passed `:dog`, so Active Record expects to find a foreign key field `dog_id` on the ratings table.

In this particular case, both of these conventions are followed, so our association works.  If one or both of these conventions were broken, we would have to configure the association.  In other words, we'd have to tell Active Record which class and/or foreign key field to use.

```
class Rating
  belongs_to :dog, { :class_name => "Dog", :foreign_key => :dog_id }
end
```
*Figure 5*.  Passing an options hash when declaring a belongs to association.

We can configure an association by passing an optional hash argument to the `.belongs_to` method.  Within the options hash, we can specify key-value pairs for the class name and the foreign key field to use.  In Figure 5, we're declaring a belongs to association and passing in an options hash to configure the association—though in this case, the options hash is unnecessary because convention was not broken.

If we look back at Figure 1, we can see that the ratings table holds another foreign key:  `judge_id`.  But, we don't have a judge model; we have a person model.  If we wanted to declare that a rating belongs to a judge (i.e., `belongs_to :judge`), we'd break convention.  Active Record would expect that a `Judge` class exists, but it does not.  So, we would need to specify to which class we're referring.  Active Record will also expect to find a `judge_id` foreign key field on the ratings table, which it does find, so we've not broken that convention and would not need to configure the foreign key field to use.


## Releases
### Pre-release: Setup
```
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```
*Figure 6*.  Setting up and seeding the database.

Before we begin, we need to create, migrate, and seed our database.  We'll seed our database with record for all three models:  `Dog`, `Rating`, and `Person`.  All the files necessary for this are provided:  the migrations and the seeds file.  We simply need to run the Rake tasks (see Figure 6).

We're going to work with our `Rating` class from within the Rake console.  Let's begin by opening the console.  Once it's open, we can begin interacting with our models.  As we work through each release, we should execute the provided example code ourselves and look at the return values.


### Release 0: Getting the Dog to Which a Rating Belongs
```ruby
rating = Rating.first
# => #<Rating id: 1, coolness: 6, ... >
rating.dog
# => #<Dog id: 1, name: "Tenley", ... >
```
*Figure 7*. Getting the dog to which a rating belongs.

We're going to explore the methods generated when we declare a belongs to association, and we'll start with the getter method.  When we declare that a rating belongs to a dog, we're provided with a method to get the dog.  Given an instance of the `Rating` class, we can ask the rating for the dog to which it belongs.

In Figure 7, we call `Rating.first` to get an instance of the `Rating` class.  We assign this instance of `Rating` to the variable `rating`.  We then call the `#dog` getter method provided to us by the `.belongs_to` method.  Through this method, we're able to retrieve the `Dog` object to which an instance of `Rating` belongs.  In this case, `#dog` returns the dog named Tenley.

- `other_dog = Dog.find(3)`

  We're assigning the variable `other_dog` to another instance of `Dog`, the one with the `id` of `3`.

- `our_rating.dog = other_dog`

  We're calling the *setter* method provided by `.belongs_to` to change the instance of `Dog` to which `our_rating` belongs.

- `our_rating.dog_id`

  We can see that Active Record has updated the value of `our_rating`'s `dog_id` attribute.  However, this change only exists in our Ruby object, not the database.

- `our_rating.save`

  Calling `#save` on `our_rating` will persist the change in the `Dog` object to which `our_rating` belongs.

- `new_rating = Rating.new(coolness: 8, cuteness: 9, judge_id: 5)`

  This creates a new instance of `Rating` that has not been save to the database; we can see that it has `nil` for its `id` attribute.  Also note that the value of its `dog_id` attribute is also `nil`.

- `new_rating.create_dog(name: "Toot", owner_id: 4, license: "OH-1234567")`

  Here were using one of the other methods provided by the `.belongs_to` method:  `#create_dog`.  It will create the dog to which `new_rating` belongs.

- `new_rating.dog`

  We can get the dog that we just created for `new_rating` through the `#dog` getter method.  Because we called `#create_dog`, a Ruby instance of `Dog` was created, and the data was saved to the database.  We can see that this new dog has an `id`.

- `new_rating`

  If we look at `new_rating`, we can see that its `dog_id`, which was previously `nil`, has been assigned the value of the `id` of the dog that was just created.  Active Record did this for us when we ran the `#create_dog` method.

-  `new_rating.save`

- `exit`

### Release 2:  Write `.belongs_to` Associations

At the end of the *Summary* section, two other belongs to associations were described:  A rating belongs to a judge.  A dog belongs to an owner.

Define these associations in the appropriate classes.  Test have been provided to guide development.  When all of the tests are complete, submit the challenge.
