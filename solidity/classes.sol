// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

// 3.0 Создаем контракт для рациональных чисел.
contract RationalMath {
    Rational internal PI  = rational( 22, 7 );
    Rational internal TWO = rational(  2, 1 );

    struct Rational {
        int256 numerator;
        int256 denominator;
    }

    function rational( int n, int d ) internal pure returns ( Rational memory ) {
        require( d != 0, "Denominator can't be equal to 0." );

        if ( d < 0 ) {
            n = -n;
            d = -d;
        }

        return Rational( n, d );
    }

    function rsum( Rational memory a, Rational memory b ) internal pure returns ( Rational memory ) {
        return rational( a.numerator * b.denominator + b.numerator * a.denominator, a.denominator * b.denominator );
    }

    function rsub( Rational memory a, Rational memory b ) internal pure returns ( Rational memory ) {
        return rational( a.numerator * b.denominator - b.numerator * a.denominator, a.denominator * b.denominator );
    }

    function rmul( Rational memory a, Rational memory b ) internal pure returns ( Rational memory ) {
        return rational( a.numerator * b.numerator, a.denominator * b.denominator );
    }

    function rdiv( Rational memory a, Rational memory b ) internal pure returns ( Rational memory ) {
        require( b.numerator != 0, "You can't divide by 0." );

        return rational( a.numerator * b.denominator, a.denominator * b.numerator );
    }

    function rnormalize( Rational memory r ) internal pure returns ( Rational memory ) {
        int d = gcd( r.numerator, r.denominator );

        return rational( r.numerator / d, r.denominator / d );
    }

    function gcd( int a, int b ) internal pure returns ( int ) {
        while ( b != 0 ) {
            ( a, b ) = ( b, a % b );
        }

        return a;
    }
}

// 3.1 Создаем абстрактный контракт для фигуры с наследованием от контракта рациональных чисел.
abstract contract Figure is RationalMath {
    function Perimeter( ) public virtual view returns ( Rational memory );
    function Area( )      public virtual view returns ( Rational memory );
}

// 3.2 Создаем контракт для прямоугольника с наследованием от контракта фигуры.
contract Rectangle is Figure {
    Rational private width;
    Rational private height;

    constructor( Rational memory w, Rational memory h ) {
        width  = w;
        height = h;
    }

    function Perimeter( ) public override view returns ( Rational memory ) {
        return rnormalize( rmul( TWO, rsum( width, height ) ) );
    }

    function Area( ) public override view returns ( Rational memory ) {
        return rnormalize( rmul( width, height ) );
    }
}

// 3.3 Создаем контракт для окружности с наследованием от контракта фигуры.
contract Circle is Figure {
    Rational private radius;

    constructor( Rational memory r ) { // Пример ввода: ["1", "2"]
        radius = r;
    }

    function Perimeter( ) public override view returns ( Rational memory ) {
        return rnormalize( rmul( radius, rmul( TWO, PI ) ) );
    }

    function Area( ) public override view returns ( Rational memory ) {
        return rnormalize( rmul( PI, rmul( radius, radius ) ) );
    }
}
