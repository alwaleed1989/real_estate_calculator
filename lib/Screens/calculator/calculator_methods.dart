class calculator_methods {
  late final double amount;
  calculator_methods(this.amount);

  double VAT( double VAT) {
    VAT = VAT / 100;
    print("VAT : ${VAT}");
    print("Total Amount ${amount * VAT}");
    return amount * VAT;
  }

  double Fees( double Fee) {
    Fee = Fee / 100;
    print("VAT : ${Fee}");
    print("Total Amount ${amount * Fee}");
    return amount * Fee;
  }

  double calculate_btn()
  {
    print("--------start--------");

    calculator_methods cal = new calculator_methods(amount);
    double vat = cal.VAT( 15);
    double fee =cal.Fees(2.5);
    print("----------------");
    print(amount+vat+fee);
    return amount+vat+fee;
  }



}



