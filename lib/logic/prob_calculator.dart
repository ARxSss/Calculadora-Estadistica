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
      double res = 0.0;
      double xi = double.parse(sXi);
      double xj = (sXj.isNotEmpty) ? double.parse(sXj) : 0.0;

      int n = int.tryParse(sN ?? '0') ?? 0;
      double p = double.tryParse(sP ?? '0') ?? 0.0;
      double lambda = double.tryParse(sLambda ?? '0') ?? 0.0;
      int nTotal = int.tryParse(sNTotal ?? '0') ?? 0;
      int kSuccess = int.tryParse(sKSuccess ?? '0') ?? 0;
      double mean = double.tryParse(sMean ?? '0') ?? 0.0;
      double stdDev = double.tryParse(sStdDev ?? '1') ?? 1.0;

      double getCDF(double k) {
        if (distType == DistType.normal) {
          return MathLogic.normalCDF(k, mean, stdDev);
        }
        int limit = k.floor();
        double sum = 0.0;
        int maxLoop = (distType == DistType.poisson) ? (k * 2).toInt() + 20 : n;

        for (int i = 0; i <= limit; i++) {
          if (i > maxLoop && distType == DistType.poisson) break;
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
          res = getCDF(xj) - getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.intervalStrict:
          res = getCDF(isContinuous ? xj : xj - 1) - getCDF(xi);
          break;
        case CalcType.intervalLeftInc:
          res =
              getCDF(isContinuous ? xj : xj - 1) -
              getCDF(isContinuous ? xi : xi - 1);
          break;
        case CalcType.intervalRightInc:
          res = getCDF(xj) - getCDF(xi);
          break;
      }

      if (res < 0) res = 0.0;
      if (res > 1) res = 1.0;

      return "Probabilidad:\n${res.toStringAsFixed(6)}\n(${(res * 100).toStringAsFixed(4)}%)";
    } catch (e) {
      return "Error: Verifica los datos numéricos.";
    }
  }
}
