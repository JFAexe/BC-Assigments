// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

// 1.0 Создаем контракт для кошелька.
contract Account {
    address payable private owner;
    uint            private balance;

    struct Transaction {
        uint amount;
        uint timestamp;
    }

    // 2.1 Маппинг содержащий информацию о транзакциях с определенных адресов.
    mapping( address => Transaction[ ] ) private transactions;

    constructor( ) payable {
        owner   = payable( msg.sender );
        balance = msg.value; // 1.1 Изначальное вложение в контракт.
    }

    // 1.2 Зачисление на счет контракта.
    function Deposit( ) public payable {
        require( msg.value > 0, "Amount must be greater than 0" );

        balance += msg.value;

        // 2.2 Сохранение информации о транзакции для определенного адреса.
        transactions[ msg.sender ].push( Transaction( {
            amount:    msg.value,
            timestamp: block.timestamp
        } ) );
    }

    // 1.3 Владелец может снять все накопления с контракта.
    function WithdrawAll( ) public isOwner {
        trasferTo( owner, balance );
    }

    // 1.4 Владелец может снять часть накоплений с контракта.
    function Withdraw( uint amount ) public isOwner {
        trasferTo( owner, ( balance > amount ) ? amount : balance );
    }

    // 1.5 Перевод средств со счета контракта.
    function Transfer( address payable receiver, uint amount ) public payable isOwner {
        require( amount > 0, "Amount must be greater than 0" );

        trasferTo( receiver, ( balance > amount ) ? amount : balance );
    }

    // 1.6 Информация о балансе контракта.
    function Balance( ) public view isOwner returns ( uint ) {
        return balance;
    }

    // 2.3 Информация о транзакциях с определенного адреса.
    function AddressTransactions( address sender ) public view isOwner returns ( Transaction[ ] memory ) {
        return transactions[ sender ];
    }

    // Только владелец может переводить со счета контракта.
    function trasferTo( address payable receiver, uint amount ) private isOwner {
        require( balance > 0, "Balance is 0, maybe you should try getting a job." );

        receiver.transfer( amount );

        balance -= amount;
    }

    modifier isOwner( ) {
        require( msg.sender == owner, "Go away, I don't know you." );

        _;
    }
}
