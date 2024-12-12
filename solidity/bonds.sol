// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Bonds {
    using SafeMath for uint256;

    address private issuer;
    uint256 private bond_price;
    uint256 private interest_rate;
    uint256 private maturity_time;
    uint256 private total_count;
    uint256 private issued_count;
    uint256 private owned_count;
    uint256 private total_funds;

    struct Bond {
        uint256 id;
        address owner;
        uint256 issue_time;
        bool    redeemed;
    }

    mapping( uint256 => Bond ) private bonds;
    mapping( address => uint256[ ] ) private owned_bonds;

    event BondIssued( address indexed owner, uint256 indexed bond_id );
    event BondRedeemed( address indexed owner, uint256 indexed bond_id, uint256 payout );

    constructor( uint256 price, uint256 total, uint256 rate, uint256 time ) {
        issuer        = msg.sender;
        total_count   = total;
        bond_price    = price;
        interest_rate = rate;
        maturity_time = time;
    }

    function IssueBonds( uint256 amount ) public onlyIssuer {
        require( issued_count.add( amount ) <= total_count, "Exceeds total bond limit");

        for ( uint256 i = 0; i < amount; i++ ) {
            uint256 id = issued_count;

            bonds[ id ] = Bond( {
                id:         id,
                owner:      address( 0 ),
                issue_time: block.timestamp,
                redeemed:   false
            } );

            issued_count = issued_count.add( 1 );
        }
    }

    function PurchaseBond( uint256 id ) public payable saleActive {
        require( msg.value == bond_price, "Incorrect amount of ETH sent" );
        require( bonds[ id ].owner == address( 0 ), "Bond is already owned" );
        require( !IsBondMature( id ), "Bond has already matured" );

        bonds[ id ].owner = msg.sender;

        owned_bonds[ msg.sender ].push( id );

        owned_count = owned_count.add( 1 );
        total_funds = total_funds.add( msg.value );

        emit BondIssued( msg.sender, id );
    }

    function CalculatePayout( uint256 id ) public view bondExists( id ) onlyBondOwner( id ) bondActive( id ) returns ( uint256 ) {
        require( IsBondMature( id ), "Bond has not matured yet" );

        return bond_price.add( bond_price.mul( interest_rate ).mul( block.timestamp.sub( bonds[ id ].issue_time ) ).div( 365 days ).div( 100 ) );
    }

    function RedeemBond( uint256 id ) public bondExists( id ) onlyBondOwner( id ) bondActive( id ) {
        uint256 payout = CalculatePayout( id );

        require( total_funds >= payout, "Insufficient funds to redeem bond" );

        ( bool success, ) = payable( msg.sender ).call{ value: payout }( "" );

        require( success, "Payout error" );

        bonds[ id ].redeemed = true;

        total_funds = total_funds.sub( payout );

        emit BondRedeemed( msg.sender, id, payout );
    }

    function DepositFunds( ) public payable onlyIssuer {
        require( msg.value > 0, "Amount must be greater than 0" );

        total_funds = total_funds.add( msg.value );
    }

    function WithdrawFunds( ) public onlyIssuer {
        require( total_funds > 0, "There are no funds to withdraw" );

        ( bool success, ) = payable( msg.sender ).call{ value: total_funds }( "" );

        require( success, "Withdraw error" );

        total_funds = 0;
    }

    function GetOwnedBonds( address user ) public view returns ( uint256[] memory ) {
        return owned_bonds[ user ];
    }

    function IsSaleActive( ) public view returns ( bool ) {
        return owned_count < total_count;
    }

    function GetBondPrice( ) public view returns ( uint256 ) {
        return bond_price;
    }

    function GetInterestRate( ) public view returns ( uint256 ) {
        return interest_rate;
    }

    function GetMaturityTime( ) public view returns ( uint256 ) {
        return maturity_time;
    }

    function GetTotalCount( ) public view returns ( uint256 ) {
        return total_count;
    }

    function GetIssuedCount( ) public view returns ( uint256 ) {
        return issued_count;
    }

    function GetOwnedCount( ) public view returns ( uint256 ) {
        return owned_count;
    }

    function IsBondMature( uint256 id ) internal view returns ( bool ) {
        return block.timestamp >= bonds[ id ].issue_time.add( maturity_time );
    }

    modifier onlyIssuer( ) {
        require( msg.sender == issuer, "Only issuer can perform this operation" );

        _;
    }

    modifier onlyBondOwner( uint256 id ) {
        require( bonds[ id ].owner == msg.sender, "Only bond owner can perform this operation" );

        _;
    }

    modifier bondExists( uint256 id ) {
        require( bonds[ id ].owner != address( 0 ), "Bond does not exist" );

        _;
    }

    modifier bondActive( uint256 id ) {
        require( !bonds[ id ].redeemed, "Bond has already been redeemed") ;

        _;
    }

    modifier saleActive( ) {
        require( IsSaleActive( ), "The bond sale is completed" );

        _;
    }
}
