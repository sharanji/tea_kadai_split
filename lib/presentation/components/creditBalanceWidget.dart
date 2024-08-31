import 'package:flutter/material.dart';

class CreditBalanceWidget extends StatelessWidget {
  final double totalCreditBalance;

  const CreditBalanceWidget({Key? key, required this.totalCreditBalance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the prefix message and determine the color of the amount
    String prefixMessage;
    Color amountColor;

    if (totalCreditBalance < 0) {
      prefixMessage = 'You get back: ';
      amountColor = Colors.green;
    } else if (totalCreditBalance == 0) {
      prefixMessage = 'No pending credits, all settled';
      amountColor = Colors.black;
    } else {
      prefixMessage = 'You should give: ';
      amountColor = Colors.red;
    }

    return Center(
      child: Container(
       
        child: totalCreditBalance == 0
            ? Text(
                prefixMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              )
            : RichText(
                text: TextSpan(
                  text: prefixMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'KumbhSans'
                  ),
                  children: [
                    TextSpan(
                      text: '₹${totalCreditBalance.abs().toStringAsFixed(2)}', // Display the amount with two decimal places
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                        fontFamily: 'KumbhSans'
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
