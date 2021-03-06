# A collection of Action and Organizer dummies used in specs

module TestDoubles
  class AddsTwoAction
    include LightService::Action

    executed do |context|
      number = context.fetch(:number, 0)
      context[:number] = number + 2
    end
  end

  class AnAction; end
  class AnotherAction; end

  class AnOrganizer
    include LightService::Organizer

    def self.do_something(action_arguments)
      with(action_arguments).reduce([AnAction, AnotherAction])
    end

    def self.do_something_with_no_actions(action_arguments)
      with(action_arguments).reduce
    end

    def self.do_something_with_no_starting_context
      reduce([AnAction, AnotherAction])
    end
  end

  class MakesTeaWithMilkAction
    include LightService::Action
    expects :tea, :milk
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk}"
    end
  end

  class MultipleExpectsAction
    include LightService::Action
    expects :tea
    expects :milk, :chocolate
    promises :milk_tea

    executed do |context|
      context.milk_tea = "#{context.tea} - #{context.milk} - with #{context.chocolate}"
    end
  end

  class MakesCappuccinoAction
    include LightService::Action
    expects :coffee, :milk
    promises :cappuccino
  end

  class MakesLatteAction
    include LightService::Action
    expects :coffee, :milk
    promises :latte

    executed do |context|
      if context.milk == :very_hot
        context.fail!("Can't make a latte from a milk that's too hot!")
        next context
      end

      context[:latte] = "#{context.coffee} - with lots of #{context.milk}"

      if context.milk == "5%"
        context.skip_all!("Can't make a latte with a fatty milk like that!")
        next context
      end
    end
  end

  class MultiplePromisesAction
    include LightService::Action
    expects :coffee, :milk
    promises :cappuccino
    promises :latte

    executed do |context|
      context.cappuccino = "Cappucino needs #{context.coffee} and a little milk"
      context.latte = "Latte needs #{context.coffee} and a lot of milk"
    end
  end

  class MakesTeaAndCappuccino
    include LightService::Organizer

    def self.call(tea, milk, coffee)
      with(:tea => tea, :milk => milk, :coffee => coffee)
          .reduce(TestDoubles::MakesTeaWithMilkAction,
                  TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwo
    include LightService::Organizer

    def self.call(milk, coffee)
      with(:milk => milk, :coffee => coffee)
          .reduce(TestDoubles::AddsTwoAction,
                  TestDoubles::MakesLatteAction)
    end
  end

  class MakesCappuccinoAddsTwoAndFails
    include LightService::Organizer

    def self.call(coffee)
      with(:milk => :very_hot, :coffee => coffee)
          .reduce(TestDoubles::MakesLatteAction,
                  TestDoubles::AddsTwoAction)

    end
  end

  class MakesCappuccinoSkipsAddsTwo
    include LightService::Organizer

    def self.call(coffee)
      with(:milk => "5%", :coffee => coffee)
          .reduce(TestDoubles::MakesLatteAction,
                  TestDoubles::AddsTwoAction)

    end
  end
end
