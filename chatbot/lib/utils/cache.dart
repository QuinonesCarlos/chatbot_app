import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sistema.dart';

String img(String? img) {
  if (img == null) return 'S/N';
  return (img.contains('https://', 0)
      ? img
      : img.length > 10
          ? ('${Sistema.storage}$img?alt=media')
          : '');
}

Widget fadeImage(String img, {double? width, double? height, int days: 90}) {
  if (img.contains('assets/', 0))
    return FadeInImage(
        width: width,
        height: height,
        image: AssetImage(img),
        placeholder: AssetImage(img),
        fit: BoxFit.cover);
  if (img.toString().length <= 10)
    return FadeInImage(
        width: width,
        height: height,
        image: AssetImage(img),
        placeholder: AssetImage(img),
        fit: BoxFit.cover);
  return FadeInImage(
      width: width,
      height: height,
      image: Image.network(img, width: width, height: height).image,
      imageErrorBuilder: (context, ob, stack) =>
          Container(child: Image.asset('assets/no-image.png')),
      placeholder: AssetImage('assets/no-image.png'),
      fit: BoxFit.cover);
}
