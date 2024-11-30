const readline = require('readline');

class BankAccount {
  constructor(accountNumber, accountHolder) {
    this.accountNumber = accountNumber;
    this.accountHolder = accountHolder;
    this.balance = 0;
    this.transactionHistory = [];
  }

  deposit(amount) {
    if (amount <= 0) {
      console.log("Amount must be greater than zero.");
      return;
    }
    this.balance += amount;
    this.transactionHistory.push(`Deposited: $${amount}`);
    console.log(`Deposited: $${amount}`);
  }

  withdraw(amount) {
    if (amount <= 0) {
      console.log("Amount must be greater than zero.");
      return;
    }
    if (amount > this.balance) {
      console.log("Insufficient funds.");
      return;
    }
    this.balance -= amount;
    this.transactionHistory.push(`Withdrew: $${amount}`);
    console.log(`Withdrew: $${amount}`);
  }

  getBalance() {
    console.log(`Balance: $${this.balance}`);
  }

  printTransactionHistory() {
    console.log("Transaction History:");
    this.transactionHistory.forEach(transaction => console.log(transaction));
  }
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

let account = null;

function menu() {
  console.log("\n--- Simple Banking System ---");
  console.log("1. Create New Account");
  console.log("2. Deposit Money");
  console.log("3. Withdraw Money");
  console.log("4. Check Balance");
  console.log("5. View Transaction History");
  console.log("6. Exit");
  
  rl.question("Choose an option: ", (choice) => {
    switch(choice) {
      case '1':
        rl.question("Enter account number: ", (accountNumber) => {
          rl.question("Enter account holder name: ", (accountHolder) => {
            account = new BankAccount(accountNumber, accountHolder);
            console.log(`Account created for ${accountHolder}`);
            menu();
          });
        });
        break;
      case '2':
        if (!account) {
          console.log("Please create an account first.");
          menu();
          return;
        }
        rl.question("Enter deposit amount: $", (amount) => {
          account.deposit(parseFloat(amount));
          menu();
        });
        break;
      case '3':
        if (!account) {
          console.log("Please create an account first.");
          menu();
          return;
        }
        rl.question("Enter withdrawal amount: $", (amount) => {
          account.withdraw(parseFloat(amount));
          menu();
        });
        break;
      case '4':
        if (!account) {
          console.log("Please create an account first.");
          menu();
          return;
        }
        account.getBalance();
        menu();
        break;
      case '5':
        if (!account) {
          console.log("Please create an account first.");
          menu();
          return;
        }
        account.printTransactionHistory();
        menu();
        break;
      case '6':
        rl.close();
        break;
      default:
        console.log("Invalid option. Please try again.");
        menu();
        break;
    }
  });
}

menu();
