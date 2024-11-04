// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Implementation is ERC20, Ownable {
    uint8   private _decimals;
    uint256 private _fee;

    event FeeUpdated( uint256 fee );

    constructor( string memory name, string memory symbol, uint256 initial, uint8 decimal, uint256 fee_ ) Ownable( _msgSender( ) ) ERC20( name, symbol ) {
        _decimals = decimal;
        _fee      = fee_;

        _mint( _msgSender( ), initial * cost( ) );
    }

    function mint( address to, uint256 amount ) external onlyOwner {
        _mint( to, amount );
    }

    function burn( address from, uint256 amount ) external onlyOwner {
        _burn( from, amount );
    }

    function decimals( ) public view override returns ( uint8 ) {
        return _decimals;
    }

    function cost( ) internal view returns ( uint256 ) {
        return 10 ** decimals( );
    }

    function fee( ) public view returns ( uint256 ) {
        return _fee;
    }

    function set_fee( uint256 new_fee ) external onlyOwner {
        _fee = new_fee;

        emit FeeUpdated( new_fee );
    }

    function transfer( address to, uint256 value ) public override returns ( bool ) {
        address sender = _msgSender( );

        uint256 fee_ = fee( );

        _transfer( sender, to, value - fee_ );

        if ( fee_ > 0 ) {
            _transfer( sender, owner( ), fee_ );
        }

        return true;
    }
}
