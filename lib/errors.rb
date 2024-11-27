# frozen_string_literal: true

# CustomErrors module defines custom error classes for Chess.
module CustomErrors
  # PlayerLimitViolation class represents an error when the number of players exceeds the limit.
  class PlayerLimitViolation < StandardError
    # Public: Initializes a new PlayerLimitViolation instance.
    #
    # msg - The message to be displayed for the error (default: 'Chess only allows up to 2 players.').
    # exception_type - The type of exception (default: 'custom').
    #
    # Returns a new PlayerLimitViolation object.
    def initialize(msg = 'Chess only allows up to 2 players.', exception_type = 'custom')
      @exception_type = exception_type
      super(msg)
    end
  end

  # BoardLimitViolation class represents an error when attempting to create more than one game board.
  class BoardLimitViolation < StandardError
    # Public: Initializes a new BoardLimitViolation instance.
    #
    # msg - The message to be displayed for the error (default: 'Chess only allows 1 board.').
    # exception_type - The type of exception (default: 'custom').
    #
    # Returns a new BoardLimitViolation object.
    def initialize(msg = 'Chess only allows 1 board.', exception_type = 'custom')
      @exception_type = exception_type
      super(msg)
    end
  end

  # Public: Checks for game rule violations and handles them appropriately.
  #
  # error          - The custom error class to be raised if a violation occurs.
  # class_variable - The current value to be checked against the limit.
  # limit          - The limit value to be checked against.
  #
  # Raises the specified error if class_variable exceeds the limit.
  # Displays the error message and exits the program if an error is raised.
  def handle_game_violations(error, current_value, limit)
    # Raise error if more than one board instance is created
    raise error if current_value > limit
  rescue error => e
    puts e.message # Display the error message
    raise e
  end
end
