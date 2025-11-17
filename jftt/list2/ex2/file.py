# our function
def calculator():
    print("Simple Calculator")
    print("Choose operation:")
    print("1. Addition")
    print("2. Subtraction")

    choice = input("Enter choice (1/2): ")        # choice you can make

    a = float(input("Enter \"first\" number: "))
    b = float(input("Enter second number: "))

    '''
    multi 
    line
    comment
    '''

    if choice == "1":

        '''
        another one ':)'
        '''
        result = a + b
        print(f"#Result of addition: {result}")
    elif choice == "2":
        """
        and
        another one
        """
        result = a - b
        print(f"#Result of subtraction: {result}")
    else:
        print("Invalid choice!")

# Run the calculator
calculator()