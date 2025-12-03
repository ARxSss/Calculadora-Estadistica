import 'dart:math';

class MathLogic {
  static int factorial(int n) {
    if (n < 0) return 0;
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  static double combination(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    if (k > n / 2) k = n - k;
    double res = 1;
    for (int i = 1; i <= k; i++) res = res * (n - i + 1) / i;
    return res;
  }

  static double binomialPDF(int k, int n, double p) {
    if (k < 0 || k > n) return 0.0;
    return combination(n, k) * pow(p, k) * pow(1 - p, n - k);
  }

  static double poissonPDF(int k, double lambda) {
    if (k < 0) return 0.0;
    return (pow(lambda, k) * exp(-lambda)) / factorial(k);
  }

  static double hypergeoPDF(int k, int N, int K, int n) {
    if (k < 0 || k > n) return 0.0;
    return (combination(K, k) * combination(N - K, n - k)) / combination(N, n);
  }

  static double normalCDF(double x, double mean, double stdDev) {
    return 0.5 * (1 + _erf((x - mean) / (stdDev * sqrt(2))));
  }

  static double _erf(double x) {
    double a1 = 0.254829592, a2 = -0.284496736, a3 = 1.421413741;
    double a4 = -1.453152027, a5 = 1.061405429, p = 0.3275911;
    int sign = 1;
    if (x < 0) sign = -1;
    x = x.abs();
    double t = 1.0 / (1.0 + p * x);
    double y =
        1.0 -
        (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);
    return sign * y;
  }
}
