// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Implementation is ERC20, Ownable {
    uint8   private _decimals;
    uint256 private _fee;

    event FeeUpdated( uint256 fee );

    constructor( string memory name, string memory symbol, uint8 decimal, uint256 fee_ ) Ownable( _msgSender( ) ) ERC20( name, symbol ) payable {
        _decimals = decimal;
        _fee      = fee_;

        _mint( _msgSender( ), msg.value );
    }

    function mint( address to ) external payable onlyOwner {
        if ( isContract( to ) ) {
            revert ERC20InvalidReceiver( to );
        }

        _mint( to, msg.value );
    }

    function burn( address from, uint256 amount ) external onlyOwner {
        _burn( from, amount );
    }

    function transfer( address to, uint256 value ) public override returns ( bool ) {
        address sender  = _msgSender( );
        uint256 balance = balanceOf( sender );

        if ( balanceOf( sender ) < value ) {
            revert ERC20InsufficientBalance( sender, balance, value );
        }

        uint256 fee_ = transactionFee( );

        _transfer( sender, to, value - fee_ );

        if ( fee_ > 0 ) {
            _burn( sender, fee_ );
        }

        return true;
    }

    function set_fee( uint256 new_fee ) external onlyOwner {
        _fee = new_fee;

        emit FeeUpdated( new_fee );
    }

    function transactionFee( ) public view returns ( uint256 ) {
        return _fee;
    }

    function decimals( ) public view override returns ( uint8 ) {
        return _decimals;
    }

    function inWei( ) public view returns ( uint256 ) {
        return 10 ** decimals( );
    }

    function stake( ) public view returns ( uint256 ) {
        return address( this ).balance;
    }

    function isContract( address account ) internal view returns ( bool ) {
        return account.code.length == 0;
    }
}
