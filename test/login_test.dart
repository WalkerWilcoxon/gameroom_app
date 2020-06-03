import 'package:flutter_test/flutter_test.dart';
import 'package:gameroom_app/utils/imports.dart';

main() {
  test('Login Page Username field is empty', () {
    var result = validateUsername('');
    expect(result, isNotNull);
  });

  test('Login Page Username field returns true', () {
    var result = validateUsername('jackripper');
    expect(result, isNull);
  });

//  test('Login Page Password field is empty', () {
//    var result = validatePassword('');
//    expect(result, isNotNull);
//  });
//
//  test('Login Page Password field returns true', () {
//    var result = validatePassword('123');
//    expect(result, isNull);
//  });

  test('Create Account Page Username field is empty', () {
    var result = validateUsername('');
    expect(result, isNotNull);
  });

//  test('Create Account Page Username field returns true', () {
//    var result = validateEmail('jackripper');
//    expect(result, isNull);
//  });
//
//  test('Create Account Page Password field is empty', () {
//    var result = validatePassword('');
//    expect(result, isNotNull);
//  });
//
//  test('Create Account Page Password field returns true', () {
//    var result = validatePassword('123');
//    expect(result, isNull);
//  });
//
//  test('Create Account Page Email field is empty', () {
//    var result = validateEmail('');
//    expect(result, isNotNull);
//  });

//  test('Create Account Page Email field returns true', () {
//    var result = validateEmail('test@test.com');
//    expect(result, isNull);
//  });
}
