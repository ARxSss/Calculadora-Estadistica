import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../widgets/input_field.dart';
import '../logic/prob_calculator.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  DistType _selectedDist = DistType.binomial;
  CalcType _selectedCalc = CalcType.lessEq;

  final _xiCtrl = TextEditingController();
  final _xjCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _lambdaCtrl = TextEditingController();
  final _ntotalCtrl = TextEditingController();
  final _kSuccessCtrl = TextEditingController();
  final _meanCtrl = TextEditingController();
  final _stdDevCtrl = TextEditingController();

  String _resultText = "Ingrese datos para calcular";

  @override
  void dispose() {
    _xiCtrl.dispose();
    _xjCtrl.dispose();
    _nCtrl.dispose();
    _pCtrl.dispose();
    _lambdaCtrl.dispose();
    _ntotalCtrl.dispose();
    _kSuccessCtrl.dispose();
    _meanCtrl.dispose();
    _stdDevCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculadora Estadística")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDistSelector(),
            const SizedBox(height: 10),
            _buildDynamicInputs(),
            const SizedBox(height: 10),
            _buildOperationSelector(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onCalculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("CALCULAR"),
            ),
            const SizedBox(height: 20),
            Text(
              _resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<DistType>(
          value: _selectedDist,
          isExpanded: true,
          underline: Container(),
          onChanged: (val) => setState(() {
            _selectedDist = val!;
            _resultText = "";
          }),
          items: DistType.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toString().split('.').last.toUpperCase()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildOperationSelector() {
    bool isInterval = _selectedCalc.toString().contains('interval');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton<CalcType>(
              value: _selectedCalc,
              isExpanded: true,
              underline: Container(),
              onChanged: (val) => setState(() => _selectedCalc = val!),
              items: _getCalcItems(),
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(controller: _xiCtrl, label: "xi (Valor)"),
                ),
                if (isInterval) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputField(
                      controller: _xjCtrl,
                      label: "xj (Límite Sup)",
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicInputs() {
    List<Widget> children = [];
    switch (_selectedDist) {
      case DistType.binomial:
        children = [
          InputField(
            controller: _nCtrl,
            label: "n (Ensayos)",
            integerOnly: true,
          ),
          InputField(controller: _pCtrl, label: "p (Probabilidad)"),
        ];
        break;
      case DistType.poisson:
        children = [InputField(controller: _lambdaCtrl, label: "λ (Lambda)")];
        break;
      case DistType.hypergeo:
        children = [
          InputField(
            controller: _ntotalCtrl,
            label: "N (Población)",
            integerOnly: true,
          ),
          InputField(
            controller: _kSuccessCtrl,
            label: "K (Éxitos Pob.)",
            integerOnly: true,
          ),
          InputField(
            controller: _nCtrl,
            label: "n (Muestra)",
            integerOnly: true,
          ),
        ];
        break;
      case DistType.normal:
        children = [
          InputField(controller: _meanCtrl, label: "μ (Media)"),
          InputField(controller: _stdDevCtrl, label: "σ (Desviación)"),
        ];
        break;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: children),
      ),
    );
  }

  List<DropdownMenuItem<CalcType>> _getCalcItems() {
    const map = {
      CalcType.greater: "P(x > xi)",
      CalcType.less: "P(x < xi)",
      CalcType.greaterEq: "P(x ≥ xi)",
      CalcType.lessEq: "P(x ≤ xi)",
      CalcType.intervalStrict: "P(xi < x < xj)",
      CalcType.intervalInclusive: "P(xi ≤ x ≤ xj)",
      CalcType.intervalLeftInc: "P(xi ≤ x < xj)",
      CalcType.intervalRightInc: "P(xi < x ≤ xj)",
    };
    return map.entries
        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
        .toList();
  }

  void _onCalculate() {
    setState(() {
      _resultText = ProbCalculator.calculate(
        distType: _selectedDist,
        calcType: _selectedCalc,
        sXi: _xiCtrl.text,
        sXj: _xjCtrl.text,
        sN: _nCtrl.text,
        sP: _pCtrl.text,
        sLambda: _lambdaCtrl.text,
        sNTotal: _ntotalCtrl.text,
        sKSuccess: _kSuccessCtrl.text,
        sMean: _meanCtrl.text,
        sStdDev: _stdDevCtrl.text,
      );
    });
  }
}
