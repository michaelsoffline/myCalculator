import 'dart:developer';
import 'dart:ffi';
import 'dart:math';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String displayVal = '0';
  String actualVal = '';
  String storedVal = '';
  bool isAllClear = true;
  bool stringEmpty = true;
  bool opInProgress = false;
  bool opButtonPressed = false;
  int equalButtonPressed = 0;
  int opCode = 0; // 1 = divide, 2 = multiply, 3 = subtract, 4 = add
  int places = 0;
  int overflow = 0; // number of decimal places
  int clearCount = 0;
  int roundedUp = 0;
  double val1 = 0;
  double val2 = 0;

  double resultVal = 0.0;
  var output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('myCalculator'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              // The display screen
              child: Container(
                color: Colors.cyanAccent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 125, 10, 0),
                  child: Text(
                    // The current value being displayed
                    '$displayVal',
                    textAlign: TextAlign.right,
                    // If the value is longer than 9 digits AND the value is a
                    // negative number, adjust the font size to 65px
                    style: (actualVal.length > 9 && double.parse(actualVal) < 0)
                        ? TextStyle(fontWeight: FontWeight.bold, fontSize: 65)
                    // If the value is longer than 9 digits OR the displayed
                    // value is 9 digits AND an arithmetic operation is going
                    // on, adjust the font size to 70px
                        : actualVal.length > 9 ||
                                (displayVal.length > 9 && opButtonPressed)
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 70,
                              )
                    // If the value is longer than 8 digits OR the displayed
                    // value is 8 digits AND an operation is going on, adjust
                    // the font size to 80px
                            : (actualVal.length > 8 ||
                                    (displayVal.length > 8 && opButtonPressed)
                                ? TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 80)
                    // If the value is longer than 7 digits OR the displayed
                    // value is 7 digits AND an operation is going on, adjust
                    // the font size to 90px
                                : (actualVal.length > 7 ||
                                        (displayVal.length > 7 &&
                                            opButtonPressed))
                                    ? TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 90,
                                      )
                    // If there is no current value in the register and an
                    // operation is currently going on (the displayed value is
                    // 0), keep the font size of 0 to 100px
                                    : (actualVal.length == '' &&
                                            opButtonPressed)
                                        ? TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 100)
                    // In all other cases (numbers with less than 7 digits),
                    // display the value with a font size of 100px
                                        : TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 100,
                                          )),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              // The body of the calculator
              child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.deepPurple,
                  // Dictates the spacing between the button columns
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Dictates the spacing between the button rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 80,
                            height: 80,
                            // Clears the display
                            child: FloatingActionButton.extended(
                              // If a value is being displayed, the button
                              // changes to CE. If the clear button has been
                              // pressed, the button changes to AC
                              label: !isAllClear
                                  ? Text(
                                      'CE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'AC',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black,
                                      ),
                                    ),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  // How many times the clear button has been
                                  // pressed
                                  clearCount++;
                                  // If hit twice, clears everything out and
                                  // resets display value to 0
                                  if (clearCount == 2) {
                                    opButtonPressed = false;
                                    opInProgress = false;
                                    val1 = 0;
                                    val2 = 0;
                                    clearCount = 0;
                                  }
                                  displayVal = '0';
                                  actualVal = '';
                                  val1 = 0;
                                  isAllClear = true;
                                  stringEmpty = true;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              // Makes positive values negative and negative
                              // values positive
                              label: Text('+/−',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  // When there's a value and operation
                                  // is in progress
                                  if (!stringEmpty && opInProgress) {
                                    // If value is negative
                                    if (val2 < 0) {
                                      actualVal = actualVal.substring(1);
                                      displayVal = actualVal;
                                      // If value is 0
                                    } else if (val2 == -0) {
                                      displayVal = '0';
                                      stringEmpty = true;
                                    } else {
                                      actualVal = '-' + '$actualVal';
                                      displayVal = actualVal;
                                    }
                                    val2 = val2 * -1;
                                    // There's a value being displayed but
                                    // no operation in progress
                                  } else if (!stringEmpty) {
                                    if (val1 < 0) {
                                      actualVal = actualVal.substring(1);
                                      displayVal = actualVal;
                                    } else if (val1 == 0) {
                                      displayVal = '0';
                                      stringEmpty = true;
                                    } else {
                                      actualVal = '-' + '$actualVal';
                                      displayVal = actualVal;
                                    }

                                    val1 = val1 * -1;
                                  } else {
                                    actualVal = '-' + '0';
                                    displayVal = actualVal;
                                    actualVal = '-';

                                    if (val1 != 0) {
                                      val2 = 0;
                                    } else if (val2 != 0) {
                                      val1 = 0;
                                    }

                                    stringEmpty = false;
                                  }

                                });
                              },
                            ),
                          ),
                          // Percent button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('%',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  opInProgress = false;
                                  !stringEmpty
                                      ? val1 = double.parse(actualVal)
                                      : 0;
                                  val1 = val1 / 100.0;
                                  actualVal = val1.toString();
                                  if (actualVal.length <= 10) {
                                    (val1 * 10) % 10 == 0
                                        ? actualVal = val1.toInt().toString()
                                        : val1.toString();
                                    displayVal = actualVal;
                                  } else {
                                    actualVal = val1.toString();
                                    displayVal = actualVal;
                                  }

                                });
                              },
                            ),
                          ),
                          // Division button (divides 2nd value by the first)
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('÷',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: opButtonPressed && opCode == 1
                                  ? Colors.cyanAccent
                                  : Colors.cyan,
                              onPressed: () {
                                setState(() {
                                  // If there is an operation in progress
                                  if (!stringEmpty && opInProgress) {
                                    if (val2 != 0) {
                                      actualVal =
                                          handleOperations(val1, val2, opCode);
                                      val2 = double.parse(actualVal);
                                      displayVal = actualVal;
                                    }
                                    opInProgress = true;
                                    opCode = 1;
                                    displayVal = actualVal;
                                    // If there's only a displayed value
                                  } else if (!stringEmpty) {
                                    val2 = val1;
                                    opInProgress = true;
                                    opCode = 1;
                                    actualVal = '';
                                  } else {
                                    opCode = 1;
                                  }
                                  if (opCode != 1) {
                                    opButtonPressed = false;
                                  } else {
                                    opButtonPressed = true;
                                  }
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // 7 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('7',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {

                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 7 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '7';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '7';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // 8 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('8',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 8 to the value as long as it fits
                                  // in the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '8';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '8';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // 9 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('9',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  // replaces displayed value with 9 during
                                  // an arithmetic operation
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 9 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '9';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '9';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // Multiplication button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('×',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: opButtonPressed && opCode == 2
                                  ? Colors.cyanAccent
                                  : Colors.cyan,
                              onPressed: () {
                                setState(() {
                                  if (!stringEmpty && opInProgress) {
                                    if (val2 != 0) {
                                      // Handles multiplication
                                      actualVal =
                                          handleOperations(val1, val2, opCode);
                                      val2 = double.parse(actualVal);
                                      displayVal = actualVal;
                                    }
                                    opInProgress = true;
                                    opCode = 2;
                                    displayVal = actualVal;
                                  } else if (!stringEmpty) {
                                    val2 = val1;
                                    opInProgress = true;
                                    opCode = 2;
                                    actualVal = '';
                                  } else {
                                    opCode = 2;
                                  }
                                  if (opCode != 2) {
                                    opButtonPressed = false;
                                  } else {
                                    opButtonPressed = true;
                                  }
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // 4 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('4',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 4 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '4';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '4';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // 5 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('5',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 5 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '5';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '5';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // 6 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('6',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 6 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '6';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '6';
                                  }
                                  val1 = double.parse(actualVal);

                                  opButtonPressed = false;

                                });
                              },
                            ),
                          ),
                          // Minus button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('−',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: opButtonPressed && opCode == 3
                                  ? Colors.cyanAccent
                                  : Colors.cyan,
                              onPressed: () {
                                setState(() {
                                  if (!stringEmpty && opInProgress) {
                                    if (val2 != 0) {
                                      // Handles subtraction
                                      actualVal =
                                          handleOperations(val1, val2, opCode);
                                      val2 = double.parse(actualVal);
                                      displayVal = actualVal;
                                    }
                                    opInProgress = true;
                                    opCode = 3;
                                    displayVal = actualVal;
                                  } else if (!stringEmpty) {
                                    val2 = val1;
                                    opInProgress = true;
                                    opCode = 3;
                                    actualVal = '';
                                  } else {
                                    opCode = 3;
                                    val1 = 0;
                                  }
                                  if (opCode != 3) {
                                    opButtonPressed = false;
                                  } else {
                                    opButtonPressed = true;
                                  }
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // 1 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('1',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 1 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '1';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '1';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;
                                });
                              },
                            ),
                          ),
                          // 2 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('2',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 2 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '2';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '2';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;
                                });
                              },
                            ),
                          ),
                          // 3 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('3',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 3 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '3';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '3';
                                  }
                                  val1 = double.parse(actualVal);
                                  opButtonPressed = false;
                                });
                              },
                            ),
                          ),
                          // Addition button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('+',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: opButtonPressed && opCode == 4
                                  ? Colors.cyanAccent
                                  : Colors.cyan,
                              onPressed: () {
                                setState(() {
                                  if (!stringEmpty && opInProgress) {
                                    if (val2 != 0) {
                                      // Handles addition
                                      actualVal =
                                          handleOperations(val1, val2, opCode);
                                      val2 = double.parse(actualVal);
                                    }
                                    opInProgress = true;
                                    opCode = 4;
                                    displayVal = actualVal;
                                  } else if (!stringEmpty) {
                                    val2 = val1;
                                    opInProgress = true;
                                    opCode = 4;
                                    displayVal = actualVal;
                                    actualVal = '';
                                  } else {
                                    opCode = 4;
                                  }
                                  if (opCode != 4) {
                                    opButtonPressed = false;
                                  } else {
                                    opButtonPressed = true;
                                  }
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // 0 button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyan,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  isAllClear = false;
                                  opButtonPressed = false;
                                  if (opButtonPressed ||
                                      equalButtonPressed > 0) {
                                    actualVal = '';
                                    equalButtonPressed = 0;
                                  }
                                  // Adds 0 to the value as long as it fits
                                  // within the screen
                                  if (actualVal.length < 10) {
                                    actualVal = '$actualVal' + '0';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '0';
                                  }
                                  val1 = double.parse(actualVal);

                                });
                              },
                            ),
                          ),
                          // Decimal point button

                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton.extended(
                              label: Text('.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black)),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  opButtonPressed = false;
                                  // Adds decimal point to the value as long as
                                  // it fits within the screen
                                  if (actualVal.length < 9) {
                                    actualVal = '$actualVal' + '.';
                                    displayVal = '$actualVal';
                                  } else {
                                    actualVal = '$actualVal' + '.';
                                  }
                                  val1 = double.parse(actualVal);

                                });
                              },
                            ),
                          ),
                          // Delete button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton(
                              child: Icon(
                                Icons.backspace,
                                color: Colors.black,
                              ),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  stringEmpty = false;
                                  opInProgress = false;
                                  if (actualVal.length <= 1) {
                                    actualVal = '';
                                    val1 = 0;
                                  } else {
                                    actualVal = actualVal.substring(
                                        0, actualVal.length - 1);
                                    val1 = double.parse(actualVal);
                                  }

                                  if (actualVal.length < 9) {
                                    displayVal = actualVal;
                                  }

                                });
                              },
                            ),
                          ),
                          // Equals button
                          Container(
                            width: 80,
                            height: 80,
                            child: FloatingActionButton(
                              child: Text(
                                '=',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.black),
                              ),
                              backgroundColor: Colors.cyan,
                              splashColor: Colors.cyanAccent,
                              onPressed: () {
                                setState(() {
                                  if (!stringEmpty) {
                                    // Gets the result
                                    actualVal =
                                        handleOperations(val1, val2, opCode);
                                  }

                                  displayVal = actualVal;
                                  equalButtonPressed++;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
// Determines how many decimal places there are in the value
int determineDecimalCount(double val) {
  String decimalString = val.toString().split('.')[1];
  int retVal = decimalString.length;
  return retVal;
}
// Rounds the value after the decimal point
double roundRightPlaces(double val, int places) {
  num mod = pow(10, places);
  double result = (val * mod).round().toDouble() / mod;

  return ((val * mod).round().toDouble() / mod);
}
// Handles the different arithmetic operations
String handleOperations(double val1, double val2, int opCode) {
  double resultVal;
  String newVal = '';
  int places;
  int roundedToWhole;
  // Performs a different operation based on the associated opCode
  switch (opCode) {
    // Performs division if opCode is 1
    case 1:
      resultVal = val2 / val1;

      if ((resultVal * 10.0) % 10 == 0) {
        newVal = resultVal.toInt().toString();
      } else {
        newVal = resultVal
            .toString()
            .substring(0, min(resultVal.toString().length, 10));
        places = determineDecimalCount(double.parse(newVal));

        // If value is longer than 10 digits, chop off the last digit to make
        // it fit the screen, then round last digit up
        if (resultVal.toString().length > 10) {
          //newVal = resultVal.round().toString();
          newVal = resultVal
              .toString()
              .substring(0, resultVal.toString().length - 1);
          resultVal = double.parse(newVal);
        } else {
          resultVal = roundRightPlaces(resultVal, places);
          newVal = resultVal.toString();
        }
        resultVal = roundRightPlaces(resultVal, places);
        newVal = resultVal.toString();
      }
      val1 = resultVal;

      break;
      // Performs multiplication if opCode is 2
    case 2:
      resultVal = val2 * val1;

      if ((resultVal * 10.0) % 10 == 0) {
        newVal = resultVal
            .toInt()
            .toString()
            .substring(0, min(resultVal.toInt().toString().length, 10));
      } else {
        places = determineDecimalCount(resultVal);
        // If value is longer than 10 digits, chop off the last digit to make
        // it fit the screen, then round last digit up
        if (resultVal.toString().length > 10) {
          //newVal = resultVal.round().toString();
          newVal = resultVal
              .toString()
              .substring(0, resultVal.toString().length - 1);
          resultVal = double.parse(newVal);
        } else {
          resultVal = roundRightPlaces(resultVal, places);
          newVal = resultVal.toString();
        }
      }
      val1 = resultVal;

      break;
      // Performs subtraction if opCode is 3
    case 3:
      resultVal = val2 - val1;

      if ((resultVal * 10.0) % 10 == 0) {
        newVal = resultVal.toInt().toString();
      } else {
        newVal = resultVal
            .toString()
            .substring(0, min(resultVal.toString().length, 10));
        places = determineDecimalCount(double.parse(newVal));
        // If value is longer than 10 digits, chop off the last digit to make
        // it fit the screen, then round last digit up
        if (resultVal.toString().length > 10) {
          newVal = resultVal
              .toString()
              .substring(0, resultVal.toString().length - 1);
          resultVal = double.parse(newVal);
        } else {
          resultVal = roundRightPlaces(resultVal, places);
          newVal = resultVal.toString();
        }
        resultVal = roundRightPlaces(resultVal, places);
        newVal = resultVal.toString();
      }
      val1 = resultVal;
      break;
      // Performs addition if opCode is 4
    case 4:
      resultVal = val2 + val1;
      if ((resultVal * 10.0) % 10 == 0) {
        newVal = resultVal.toInt().toString();
      } else {
        newVal = resultVal
            .toString()
            .substring(0, min(resultVal.toString().length, 10));
        places = determineDecimalCount(double.parse(newVal));
        // If value is longer than 10 digits, chop off the last digit to make
        // it fit the screen, then round last digit up
        if (resultVal.toString().length > 10) {
          //newVal = resultVal.round().toString();
          newVal = resultVal
              .toString()
              .substring(0, resultVal.toString().length - 1);
          resultVal = double.parse(newVal);
        } else {
          resultVal = roundRightPlaces(resultVal, places);
          newVal = resultVal.toString();
        }
        resultVal = roundRightPlaces(resultVal, places);
        newVal = resultVal.toString();
      }
      val1 = resultVal;
      break;
  }

// Return result of operation
  return newVal;
}
