import 'package:flutter/material.dart';

/// Radii verified from Stitch — uses very large organic radii.
class AppRadii {
  // Pill / full
  static const double pill = 999.0;
  static final BorderRadius pillRadius = BorderRadius.circular(pill);

  // xl2 — hero card, booking card, nav dock: rounded-[32px]
  static const double xl2 = 32.0;
  static final BorderRadius xl2Radius = BorderRadius.circular(xl2);

  // xl — secondary cards: rounded-[28px]
  static const double xl = 28.0;
  static final BorderRadius xlRadius = BorderRadius.circular(xl);

  // lg — map area: rounded-[24px], confirmation bg
  static const double lg = 24.0;
  static final BorderRadius lgRadius = BorderRadius.circular(lg);

  // img corner — thumbnail: rounded-[22px], slot icon
  static const double imgCorner = 22.0;
  static final BorderRadius imgRadius = BorderRadius.circular(imgCorner);

  // md — inner containers: rounded-[20px]
  static const double md = 20.0;
  static final BorderRadius mdRadius = BorderRadius.circular(md);

  // sm — small elements: rounded-[16px]
  static const double sm = 16.0;
  static final BorderRadius smRadius = BorderRadius.circular(sm);

  // xs — chips: rounded-lg (8px)
  static const double xs = 8.0;
  static final BorderRadius xsRadius = BorderRadius.circular(xs);
}
