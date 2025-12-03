import '../models/enums.dart';
import 'math_logic.dart';

class ProbCalculator {
  static String calculate({
    required DistType distType,
    required CalcType calcType,
    required String sXi,
    required String sXj,
    String? sN,
    String? sP,
    String? sLambda,
    String? sNTotal,
    String? sKSuccess,
    String? sMean,
    String? sStdDev,
  }) {
    try {
      double? xi = double.tryParse(sXi);
      double? xj = (sXj.isNotEmpty) ? double.tryParse(sXj) : 0.0;

      int n = int.tryParse(sN ?? '0') ?? 0;
      double p = double.tryParse(sP ?? '0') ?? 0.0;
      double lambda = double.tryParse(sLambda ?? '0') ?? 0.0;
      int nTotal = int.tryParse(sNTotal ?? '0') ?? 0;
      int kSuccess = int.tryParse(sKSuccess ?? '0') ?? 0;
      double mean = double.tryParse(sMean ?? '0') ?? 0.0;
      double stdDev = double.tryParse(sStdDev ?? '1') ?? 1.0;

      if (xi == null) return "Error: El valor 'xi' no es válido.";
      if (sXj.isNotEmpty && xj == null)
        return "Error: El límite 'xj' no es válido.";

      String? error = _validateRules(
        distType: distType,
        calcType: calcType,
        xi: xi,
        xj: xj ?? 0,
        n: n,
        p: p,
        lambda: lambda,
        nTotal: nTotal,
        kSuccess: kSuccess,
        stdDev: stdDev,
      );

      if (error != null) return "Error: $error";

      double getCDF(double k) {
        if (distType == DistType.normal) {
          return MathLogic.normalCDF(k, mean, stdDev);
        }
        int limit = k.floor();
        double sum = 0.0;
        int maxLoop = (distType == DistType.poisson) ? (k * 2).toInt() + 50 : n;

        for (int i = 0; i <= limit; i++) {
          if (i > maxLoop && distType == DistType.poisson)
            break; // Break seguridad Poisson

          if (distType == DistType.binomial)
            sum += MathLogic.binomialPDF(i, n, p);
          else if (distType == DistType.poisson)
            sum += MathLogic.poissonPDF(i, lambda);
          else if (distType == DistType.hypergeo)
            sum += MathLogic.hypergeoPDF(i, nTotal, kSuccess, n);
        }
        return sum;
      }

      bool isContinuous = (distType == DistType.normal);
      double res = 0.0;

      switch (calcType) {
        case CalcType.lessEq:
          res = getCDF(xi);
          break;
        case CalcType.less:
          res = getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.greater:
          res = 1.0 - getCDF(xi);
          break;
        case CalcType.greaterEq:
          res = 1.0 - getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.intervalInclusive:
          res = getCDF(xj!) - getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.intervalStrict:
          res = getCDF(isContinuous ? xj! : xj! - 1) - getCDF(xi);
          break;
        case CalcType.intervalLeftInc:
          res =
              getCDF(isContinuous ? xj! : xj! - 1) -
              getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.intervalRightInc:
          res = getCDF(xj!) - getCDF(xi);
          break;
      }

      if (res < 0) res = 0.0;
      if (res > 1) res = 1.0;

      return "Probabilidad:\n${res.toStringAsFixed(6)}\n(${(res * 100).toStringAsFixed(4)}%)";
    } catch (e) {
      return "Error inesperado en el cálculo.";
    }
  }

  static String? _validateRules({
    required DistType distType,
    required CalcType calcType,
    required double xi,
    required double xj,
    required int n,
    required double p,
    required double lambda,
    required int nTotal,
    required int kSuccess,
    required double stdDev,
  }) {
    bool isInterval = calcType.toString().contains('interval');
    if (isInterval && xi >= xj) {
      return "En intervalos, 'xi' debe ser menor que 'xj'.";
    }

    switch (distType) {
      case DistType.binomial:
        if (p < 0 || p > 1)
          return "La probabilidad 'p' debe estar entre 0 y 1.";
        if (n < 0) return "El número de ensayos 'n' no puede ser negativo.";
        break;

      case DistType.poisson:
        if (lambda < 0) return "Lambda (λ) no puede ser negativo.";
        break;

      case DistType.hypergeo:
        if (nTotal <= 0) return "La población total 'N' debe ser mayor a 0.";
        if (kSuccess < 0 || kSuccess > nTotal)
          return "'K' debe ser positivo y menor que 'N'.";
        if (n < 0 || n > nTotal)
          return "La muestra 'n' no puede ser mayor que la población.";
        break;

      case DistType.normal:
        if (stdDev <= 0) return "La desviación estándar debe ser mayor a 0.";
        break;
    }
    return null; // Todo correcto
  }
}
