require_relative '../spec_helper'

describe "Rating" do
  describe "inheritance" do
    it "inherits from ActiveRecord::Base" do
      expect(Rating < ActiveRecord::Base).to be true
    end
  end


  describe "associations" do

    before(:all) do
      Person.delete_all
      teagan = Person.create(first_name: "Teagan",  last_name: "Hickman")

      Dog.delete_all
      dog = Dog.create( { :name     => "Tenley",
                          :license  => "OH-9384764",
                          :age      => 1,
                          :breed    => "Golden Doodle",
                          :owner_id => 1 } )

      Rating.delete_all
      Rating.create({ coolness: 5, cuteness: 6, judge_id: teagan.id, dog_id: dog.id })
    end

    describe "belongs to dog" do
      describe "#dog" do
        it "returns the rating's dog" do
          rating = Rating.first
          expected_dog = Dog.find(rating.dog_id)

          expect(rating.dog).to eq expected_dog
        end

        it "returns a Dog object" do
          rating = Rating.first
          expect(rating.dog).to be_instance_of Dog
        end
      end

      describe "#dog=" do
        it "sets dog_id" do
          rating = Rating.new
          dog = Dog.first

          expect{ rating.dog = dog }.to change{ rating.dog_id }.from(nil).to(dog.id)
        end
      end
    end

    describe "belongs to judge" do
      describe "#judge" do
        it "returns the rating's judge" do
          rating = Rating.first
          expected_judge = Person.find(rating.judge_id)

          expect(rating.judge).to eq expected_judge
        end

        it "returns a Person object" do
          rating = Rating.first
          expect(rating.judge).to be_instance_of Person
        end
      end

      describe "#judge=" do
        it "sets judge_id" do
          rating = Rating.new
          judge = Person.first

          expect{ rating.judge = judge }.to change{ rating.judge_id }.from(nil).to(judge.id)
        end
      end
    end
  end
end
